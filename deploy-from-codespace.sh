#!/bin/bash

# Django deployment script for GitHub Codespace
echo "🚀 Starting Django deployment from GitHub Codespace..."

# Перевірка наявності Azure CLI
if ! command -v az &> /dev/null; then
    echo "📦 Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCli | sudo bash
    echo "✅ Azure CLI installed successfully!"
else
    echo "✅ Azure CLI already installed"
fi

# Змінні конфігурації
RESOURCE_GROUP="rg-django-template"
LOCATION="East US"
APP_SERVICE_PLAN="asp-django-template"
WEB_APP_NAME="django-template-$(date +%s)"
SKU="F1"

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Web App Name: $WEB_APP_NAME"
echo "   Location: $LOCATION"

# Авторизація в Azure
echo "🔐 Azure login..."
az account show &> /dev/null || {
    echo "Please login to Azure using device code:"
    az login --use-device-code
}

# Перевірка активної підписки
SUBSCRIPTION=$(az account show --query name -o tsv)
echo "📊 Using subscription: $SUBSCRIPTION"

# Створення ресурсів
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
    --runtime "PYTHON|3.11" \
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

# Подготовка коду
echo "📦 Preparing deployment package..."

# Встановлення залежностей
echo "   Installing Python dependencies..."
pip install -r requirements.txt

# Збір статичних файлів
echo "   Collecting static files..."
python manage.py collectstatic --noinput

# Створення ZIP архіву
echo "   Creating deployment package..."
zip -r deployment.zip . \
    -x "*.git*" "*__pycache__*" "*.pyc" "venv/*" "env/*" \
       "*.md" ".devcontainer/*" "docs/*"

# Розгортання
echo "🚀 Deploying to Azure..."
az webapp deployment source config-zip \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --src deployment.zip

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

echo "   Testing connection..."
for i in {1..5}; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL --connect-timeout 30 || echo "000")
    
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ Deployment successful!"
        echo "🌐 Your Django app: $APP_URL"
        echo "📊 Resource Group: $RESOURCE_GROUP"
        echo "🏷️ App Name: $WEB_APP_NAME"
        break
    else
        echo "⚠️ Attempt $i/5: HTTP $HTTP_STATUS"
        if [ $i -eq 5 ]; then
            echo "❌ Health check failed after 5 attempts"
            echo "🔍 Check logs:"
            echo "   az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
        else
            sleep 30
        fi
    fi
done

# Показати корисні команди
echo ""
echo "📝 Useful commands:"
echo "   View logs: az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Restart: az webapp restart --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   SSH: az webapp ssh --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Delete: az group delete --name $RESOURCE_GROUP --yes --no-wait"

# Очищення
rm -f deployment.zip

echo "🎉 Deployment completed!"
