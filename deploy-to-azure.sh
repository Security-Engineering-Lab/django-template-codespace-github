#!/bin/bash

# Azure CLI Deployment Script for Django
# Виконайте цей скрипт локально після git clone

echo "🚀 Starting Django deployment to Azure..."

# Змінні конфігурації
RESOURCE_GROUP="rg-django-template"
LOCATION="East US"
APP_SERVICE_PLAN="asp-django-template"
WEB_APP_NAME="django-template-prod-$(date +%s)"  # Унікальна назва
SKU="F1"  # Безкоштовний рівень

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Web App Name: $WEB_APP_NAME"
echo "   Location: $LOCATION"

# Крок 1: Авторизація (якщо потрібно)
echo "🔐 Checking Azure login..."
az account show &> /dev/null || {
    echo "Please login to Azure:"
    az login
}

# Крок 2: Створення ресурсів
echo "🏗️ Creating Azure resources..."

# Створюємо Resource Group
echo "   Creating resource group..."
az group create \
    --name $RESOURCE_GROUP \
    --location "$LOCATION" \
    --output table

# Створюємо App Service Plan
echo "   Creating App Service Plan..."
az appservice plan create \
    --name $APP_SERVICE_PLAN \
    --resource-group $RESOURCE_GROUP \
    --sku $SKU \
    --is-linux \
    --output table

# Створюємо Web App
echo "   Creating Web App..."
az webapp create \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --plan $APP_SERVICE_PLAN \
    --runtime "PYTHON|3.11" \
    --output table

# Крок 3: Налаштування додатку
echo "⚙️ Configuring Web App..."
az webapp config appsettings set \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --settings \
        DJANGO_SETTINGS_MODULE="hello_world.settings" \
        DJANGO_DEBUG="False" \
        SCM_DO_BUILD_DURING_DEPLOYMENT="true" \
    --output table

# Крок 4: Розгортання коду
echo "📦 Deploying application..."

# Створюємо ZIP архів
echo "   Creating deployment package..."
zip -r app.zip . -x "*.git*" "*__pycache__*" "*.pyc" "venv/*" "*.md"

# Розгортаємо через ZIP deploy
echo "   Uploading to Azure..."
az webapp deployment source config-zip \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --src app.zip

# Крок 5: Налаштування startup команди
echo "🔧 Setting startup command..."
az webapp config set \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 hello_world.wsgi"

# Крок 6: Перевірка
echo "🏥 Health check..."
APP_URL="https://$WEB_APP_NAME.azurewebsites.net"

echo "   Waiting for app to start..."
sleep 90

echo "   Testing connection..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL || echo "000")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Deployment successful!"
    echo "🌐 Your Django app is running at: $APP_URL"
    echo "📊 Resource Group: $RESOURCE_GROUP"
    echo "🏷️ App Name: $WEB_APP_NAME"
else
    echo "⚠️ Health check returned HTTP $HTTP_STATUS"
    echo "🔍 Check logs with:"
    echo "   az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
    echo "🌐 App URL: $APP_URL"
fi

# Очищення
rm -f app.zip

echo "🎉 Deployment script completed!"
echo ""
echo "📝 Useful commands:"
echo "   View logs: az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Restart app: az webapp restart --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Delete resources: az group delete --name $RESOURCE_GROUP --yes --no-wait"
