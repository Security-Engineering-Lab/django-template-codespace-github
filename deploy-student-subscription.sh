#!/bin/bash

echo "🚀 Deploying to Azure Container Instances (Student Subscription)..."

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

RESOURCE_GROUP="rg-django-fixed"
CONTAINER_NAME="django-fixed-$(date +%s)"
LOCATION="Central US"

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Container Name: $CONTAINER_NAME"
echo "   Location: $LOCATION"

# Перевіряємо Azure CLI
if ! command -v az &> /dev/null; then
    echo "Installing Azure CLI..."
    sudo apt-get update && sudo apt-get install azure-cli -y
fi

# Авторизація
echo "🔐 Checking Azure login..."
if ! az account show &> /dev/null; then
    echo "Please login to Azure:"
    az login --use-device-code
fi

# Показуємо доступні підписки
echo "📊 Available subscriptions:"
az account list --output table

# Даємо користувачу вибрати підписку
echo ""
read -p "Enter subscription name or ID (or press Enter for current): " SUBSCRIPTION_INPUT

if [ ! -z "$SUBSCRIPTION_INPUT" ]; then
    echo "🔄 Switching to subscription: $SUBSCRIPTION_INPUT"
    az account set --subscription "$SUBSCRIPTION_INPUT"
fi

# Показуємо поточну підписку
CURRENT_SUBSCRIPTION=$(az account show --query name -o tsv)
echo "✅ Using subscription: $CURRENT_SUBSCRIPTION"

# Реєструємо providers
echo "📝 Registering providers..."
az provider register --namespace Microsoft.ContainerInstance --output none
az provider register --namespace Microsoft.Web --output none

# Створюємо resource group
echo "🏗️ Creating resource group..."
az group create --name $RESOURCE_GROUP --location "$LOCATION" --output table

# Створюємо простий контейнер
echo "🚀 Creating container..."
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --image "mcr.microsoft.com/azuredocs/aci-helloworld:latest" \
    --cpu 0.5 \
    --memory 0.5 \
    --ip-address public \
    --ports 80 \
    --location "$LOCATION" \
    --output table

# Чекаємо створення контейнера
echo "⏳ Waiting for container to start..."
sleep 60

# Отримуємо IP
echo "📍 Getting container details..."
CONTAINER_INFO=$(az container show \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --query "{ip:ipAddress.ip,state:instanceView.state}" \
    --output json)

CONTAINER_IP=$(echo $CONTAINER_INFO | python3 -c "import sys, json; print(json.load(sys.stdin).get('ip', 'N/A'))")
CONTAINER_STATE=$(echo $CONTAINER_INFO | python3 -c "import sys, json; print(json.load(sys.stdin).get('state', 'Unknown'))")

echo "📊 Container Status: $CONTAINER_STATE"

if [ "$CONTAINER_IP" != "N/A" ] && [ "$CONTAINER_IP" != "null" ]; then
    echo "✅ Container deployed successfully!"
    echo "🌐 Your app: http://$CONTAINER_IP"
    echo "💰 Cost: ~$3-5/month"
    echo "📊 Resource Group: $RESOURCE_GROUP"
    echo "🏷️ Container Name: $CONTAINER_NAME"
    
    # Тестуємо підключення
    echo "🔍 Testing connection..."
    sleep 30
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$CONTAINER_IP" --connect-timeout 10 || echo "000")
    
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ Connection test passed! Your app is running."
    else
        echo "⚠️ Connection test failed: HTTP $HTTP_STATUS"
        echo "Container might still be starting. Try again in a few minutes."
    fi
else
    echo "❌ Failed to get container IP"
    echo "🔍 Checking container status..."
    az container show --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --output table
    
    echo "🔍 Checking container logs..."
    az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME
fi

echo ""
echo "📝 Useful commands:"
echo "   View status: az container show --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --output table"
echo "   View logs: az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME"
echo "   Restart: az container restart --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME"
echo "   Delete all: az group delete --name $RESOURCE_GROUP --yes --no-wait"



