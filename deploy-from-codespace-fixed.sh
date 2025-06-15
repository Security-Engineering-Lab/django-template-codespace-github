#!/bin/bash

# Fixed Django deployment script for GitHub Codespace
echo "🚀 Starting Django deployment from GitHub Codespace..."

# Встановлення Azure CLI через apt (надійний спосіб)
if ! command -v az &> /dev/null; then
    echo "📦 Installing Azure CLI via apt..."
    
    # Оновлюємо систему
    sudo apt-get update -y
    
    # Встановлюємо залежності
    sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg -y
    
    # Створюємо директорію для ключів
    sudo mkdir -p /etc/apt/keyrings
    
    # Додаємо Microsoft GPG ключ
    curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
        sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/microsoft.gpg
    
    # Додаємо Azure CLI репозиторій
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list
    
    # Оновлюємо індекс пакетів і встановлюємо Azure CLI
    sudo apt-get update -y
    sudo apt-get install azure-cli -y
    
    # Перевіряємо встановлення
    if command -v az &> /dev/null; then
        echo "✅ Azure CLI installed successfully!"
    else
        echo "❌ Azure CLI installation failed. Trying alternative method..."
        # Альтернативний метод через snap
        sudo snap install azure-cli --classic
    fi
else
    echo "✅ Azure CLI already installed"
fi

# Перевіряємо версію
az version --output table || echo "⚠️ Azure CLI installed but version check failed"

# Змінні конфігурації
RESOURCE_GROUP="rg-django-template"
LOCATION="East US"
APP_SERVICE_PLAN="asp-django-template"
WEB_APP_NAME="django-template-$(date +%s)"
SKU="F1"

echo ""
echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Web App Name: $WEB_APP_NAME"
echo "   Location: $LOCATION"

# Авторизація в Azure
echo ""
echo "🔐 Azure login..."
az account show &> /dev/null || {
    echo "Please login to Azure using device code:"
    az login --use-device-code
}

# Перевірка активної підписки
SUBSCRIPTION=$(az account show --query name -o tsv)
echo "📊 Using subscription: $SUBSCRIPTION"

# Створення ресурсів
echo ""
echo "🏗️ Creating Azure resources..."

# Resource Group
echo "   Creating resource group..."
az group create \
    --name $RESOURCE_GROUP \
    --location "$LOCATION" \
    --output table

# App Service Plan
echo "   Creating App Service Plan..."
az appservice plan create \
    --name $APP_SERVICE_PLAN \
    --resource-group $RESOURCE_GROUP \
    --sku $SKU \
    --is-linux \
    --output table

# Web App
echo "   Creating Web App..."
az webapp create \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN \
    --runtime "PYTHON|3.12" \
    --output table

# Налаштування додатку
echo ""
echo "⚙️ Configuring Web App..."
az webapp config appsettings set \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        DJANGO_SETTINGS_MODULE="hello_world.settings" \
        DJANGO_DEBUG="False" \
        SCM_DO_BUILD_DURING_DEPLOYMENT="true" \
        WEBSITE_HTTPLOGGING_RETENTION_DAYS="7" \
    --output table

# Подготовка коду
echo ""
echo "📦 Preparing deployment package..."

# Встановлення залежностей (якщо потрібно)
echo "   Installing Python dependencies..."
pip install -r requirements.txt

# Збір статичних файлів
echo "   Collecting static files..."
python manage.py collectstatic --noinput

# Створення ZIP архіву (виключаємо непотрібні файли)
echo "   Creating deployment package..."
zip -r deployment.zip . \
    -x "*.git*" "*__pycache__*" "*.pyc" "venv/*" "env/*" \
       "*.md" ".devcontainer/*" "docs/*" "*.log" \
       "deployment.zip" "*deploy*.sh"

# Розгортання
echo ""
echo "🚀 Deploying to Azure..."
az webapp deployment source config-zip \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --src deployment.zip

# Налаштування startup команди
echo ""
echo "🔧 Setting startup command..."
az webapp config set \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 hello_world.wsgi"

# Перезапуск додатку
echo ""
echo "🔄 Restarting application..."
az webapp restart \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP

# Health check з покращеною логікою
echo ""
echo "🏥 Health check..."
APP_URL="https://$WEB_APP_NAME.azurewebsites.net"

echo "   Waiting for application to start..."
sleep 120

echo "   Testing connection..."
SUCCESS=false
for i in {1..5}; do
    echo "   Attempt $i/5..."
    
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL --connect-timeout 30 || echo "000")
    
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ Deployment successful!"
        echo "🌐 Your Django app: $APP_URL"
        echo "📊 Resource Group: $RESOURCE_GROUP"
        echo "🏷️ App Name: $WEB_APP_NAME"
        SUCCESS=true
        break
    else
        echo "⚠️ HTTP Status: $HTTP_STATUS"
        if [ $i -lt 5 ]; then
            echo "   Waiting 30 seconds before retry..."
            sleep 30
        fi
    fi
done

if [ "$SUCCESS" = false ]; then
    echo ""
    echo "❌ Health check failed after 5 attempts"
    echo "🔍 Checking application logs..."
    az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP --timeout 30 || echo "Could not retrieve logs"
    echo ""
    echo "💡 Troubleshooting tips:"
    echo "   1. Check logs: az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
    echo "   2. Check configuration: az webapp config show --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
    echo "   3. Try restarting: az webapp restart --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
fi

# Показати корисні команди
echo ""
echo "📝 Useful commands:"
echo "   View logs: az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Restart: az webapp restart --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   SSH: az webapp ssh --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Delete: az group delete --name $RESOURCE_GROUP --yes --no-wait"

# Очищення
rm -f deployment.zip

echo ""
echo "🎉 Deployment script completed!"
echo "🌐 App URL: $APP_URL"
