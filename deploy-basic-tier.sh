
#!/bin/bash

# Django deployment with Basic tier (paid but cheap)
echo "🚀 Starting Django deployment with Basic tier..."

# Змінні конфігурації
RESOURCE_GROUP="rg-django-template"
LOCATION="East US"
APP_SERVICE_PLAN="asp-django-template"
WEB_APP_NAME="django-template-$(date +%s)"
SKU="B1"  # Basic tier - ~$13/місяць

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Web App Name: $WEB_APP_NAME"
echo "   Location: $LOCATION"
echo "   SKU: $SKU (Basic tier - ~$13/month)"
echo ""
read -p "Continue with paid tier? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled"
    exit 1
fi

# Авторизація в Azure
echo "🔐 Azure login..."
az account show &> /dev/null || {
    echo "Please login to Azure:"
    az login --use-device-code
}

# Видаляємо попередній resource group якщо існує
echo "🧹 Cleaning up previous resources..."
az group delete --name $RESOURCE_GROUP --yes --no-wait || echo "No previous resource group found"

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
zip -r deployment.zip . \
    -x "*.git*" "*__pycache__*" "*.pyc" "venv/*" "env/*" \
       "*.md" ".devcontainer/*" "docs/*" "*.log" \
       "deployment.zip" "*deploy*.sh"

# Розгортання
echo "🚀 Deploying to Azure..."
az webapp deploy \
    --name $WEB_APP_NAME \
    --resource-group $RESOURCE_GROUP \
    --src-path deployment.zip

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

for i in {1..5}; do
    echo "   Attempt $i/5..."
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL --connect-timeout 30 || echo "000")
    
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ Deployment successful!"
        echo "🌐 Your Django app: $APP_URL"
        echo "💰 Monthly cost: ~$13 (Basic tier)"
        echo "🏷️ App Name: $WEB_APP_NAME"
        break
    else
        echo "⚠️ HTTP Status: $HTTP_STATUS"
        if [ $i -lt 5 ]; then
            sleep 30
        fi
    fi
done

# Корисні команди
echo ""
echo "📝 Useful commands:"
echo "   View logs: az webapp log tail --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Stop app: az webapp stop --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Start app: az webapp start --name $WEB_APP_NAME --resource-group $RESOURCE_GROUP"
echo "   Delete all: az group delete --name $RESOURCE_GROUP --yes --no-wait"

# Очищення
rm -f deployment.zip

echo "🎉 Deployment completed!"
