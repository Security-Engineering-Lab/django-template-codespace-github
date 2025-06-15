#!/bin/bash

echo "🚀 Django deployment with automatic Azure CLI installation..."

# Функція для встановлення Azure CLI
install_azure_cli() {
    echo "📦 Installing Azure CLI..."
    
    # Оновлюємо систему
    sudo apt-get update -q
    
    # Встановлюємо залежності
    sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg
    
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
    sudo apt-get update -q
    sudo apt-get install -y azure-cli
    
    # Перевіряємо встановлення
    if command -v az &> /dev/null; then
        echo "✅ Azure CLI installed successfully!"
        az --version
    else
        echo "❌ Azure CLI installation failed!"
        exit 1
    fi
}

# Перевіряємо наявність Azure CLI
if ! command -v az &> /dev/null; then
    echo "Azure CLI not found. Installing..."
    install_azure_cli
else
    echo "✅ Azure CLI already installed"
    az --version
fi

# Змінні конфігурації
RESOURCE_GROUP="rg-django-template"
LOCATION="East US"
APP_SERVICE_PLAN="asp-django-template"
WEB_APP_NAME="django-template-$(date +%s)"
SKU="B1"  # Basic tier

echo ""
echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Web App Name: $WEB_APP_NAME"
echo "   Location: $LOCATION"
echo "   SKU: $SKU (Basic tier - ~$13/month)"
echo ""

read -p "Continue with deployment? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 1
fi

# Авторизація в Azure
echo "🔐 Azure login..."
if ! az account show &> /dev/null; then
    echo "Please login to Azure using device code:"
    az login --use-device-code
fi

# Перевірка активної підписки
SUBSCRIPTION=$(az account show --query name -o tsv)
echo "📊 Using subscription: $SUBSCRIPTION"

# Видаляємо попередній resource group якщо існує
echo "🧹 Cleaning up previous resources..."
az group delete --name $RESOURCE_GROUP --yes --no-wait 2>/dev/null || echo "No previous resource group found"

# Чекаємо завершення видалення
echo "⏳ Waiting for cleanup to complete..."
sleep 30

# Створення ресурсів
echo "🏗️ Creating Azure resources..."

# Resource Group
echo "   Creating resource group..."
az group create \
    --name $RESOURCE_GROUP \
    --location "$LOCATION" \
    --output table

# App Service Plan з Basic tier
echo "   Creating App Service Plan (Basic tier)..."
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

# Підготовка коду
echo "📦 Preparing deployment package..."
python manage.py collectstatic --noinput

# Створення ZIP архіву
echo "   Creating ZIP package..."
zip -r deployment.zip . \
    -x "*.git*" "*__pycache__*" "*.pyc" "venv/*" "env/*" \
       "*.md" ".devcontainer/*" "docs/*" "*.log" \
       "deployment.zip" "*deploy*.sh"

# Розгортання
echo "🚀 Deploying to Azure..."
az webapp deploy \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --src-path deployment.zip \
    --type zip

# Налаштування startup команди
echo "🔧 Setting startup command..."
az webapp config set \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 hello_world.wsgi"

# Перезапуск додатку
echo "🔄 Restarting application..."
az webapp restart \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP

# Health check
echo "🏥 Health check..."
APP_URL="https://$WEB_APP_NAME.azurewebsites.net"

echo "   Waiting for application to start..."
sleep 120

SUCCESS=false
for i in {1..5}; do
    echo "   Attempt $i/5..."
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL --connect-timeout 30 || echo "000")
    
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ Deployment successful!"
        echo "🌐 Your Django app: $APP_URL"
        echo "💰 Monthly cost: ~$13 (Basic tier)"
        echo "🏷️ App Name: $WEB_APP_NAME"
        echo "📊 Resource Group: $RESOURCE_GROUP"
        SUCCESS=true
        break
    else
        echo "⚠️ HTTP Status: $HTTP_STATUS"
        if [ $i -lt 5 ]; then
            echo "   Waiting 30 seconds..."
            sleep 30
        fi
    fi
done

if [ "$SUCCESS" = false ]; then
    echo "❌ Health check failed. Checking logs..."
    az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP --timeout 30 || echo "Could not retrieve logs"
fi

# Корисні команди
echo ""
echo "📝 Useful commands:"
echo "   View logs: az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Stop app: az webapp stop --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Delete all: az group delete --name $RESOURCE_GROUP --yes --no-wait"

# Очищення
rm -f deployment.zip

echo ""
echo "🎉 Deployment completed!"
echo "🌐 Access your app: $APP_URL"
