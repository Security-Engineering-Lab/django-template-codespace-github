#!/bin/bash

echo "🚀 Simple Django deployment to Azure Container Instances..."

RESOURCE_GROUP="rg-django-container-simple"
CONTAINER_NAME="django-simple-$(date +%s)"
LOCATION="East US"

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Container Name: $CONTAINER_NAME"
echo "   Using public Docker Hub image"

# Перевіряємо Azure CLI
if ! command -v az &> /dev/null; then
    echo "Installing Azure CLI..."
    sudo apt-get update && sudo apt-get install azure-cli -y
fi

# Авторизація
if ! az account show &> /dev/null; then
    echo "Please login to Azure:"
    az login --use-device-code
fi

# Переключаємося на першу підписку
az account set --subscription "0023db84-3d8f-4017-b39e-ce7826ea388d"

# Реєструємо providers
echo "📝 Registering required providers..."
az provider register --namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.Web

# Створюємо resource group
echo "🏗️ Creating resource group..."
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Створюємо простий контейнер з публічним образом Django
echo "🚀 Creating container with public Django image..."
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --image "django:latest" \
    --cpu 1 \
    --memory 1 \
    --ip-address public \
    --ports 8000 \
    --environment-variables \
        DJANGO_SETTINGS_MODULE=mysite.settings \
        DJANGO_DEBUG=False \
    --command-line "python -m django startproject mysite /app && cd /app && python manage.py runserver 0.0.0.0:8000"

# Отримуємо IP адресу
echo "📍 Getting container IP..."
CONTAINER_IP=$(az container show \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --query ipAddress.ip \
    --output tsv)

if [ ! -z "$CONTAINER_IP" ]; then
    echo "✅ Container deployed successfully!"
    echo "🌐 Your Django app: http://$CONTAINER_IP:8000"
    echo "💰 Monthly cost: ~$5-10"
    echo "📊 Resource Group: $RESOURCE_GROUP"
    echo "🏷️ Container Name: $CONTAINER_NAME"
else
    echo "❌ Failed to get container IP"
    # Показуємо логи для діагностики
    az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME
fi

echo ""
echo "📝 Useful commands:"
echo "   View logs: az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME"
echo "   Stop container: az container stop --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME"
echo "   Delete all: az group delete --name $RESOURCE_GROUP --yes --no-wait"
