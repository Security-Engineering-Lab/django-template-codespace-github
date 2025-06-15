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






RESOURCE_GROUP="rg-django-student"
CONTAINER_NAME="django-student-$(date +%s)"
LOCATION="Central US"  # Спробуємо інший регіон

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Container Name: $CONTAINER_NAME"
echo "   Location: $LOCATION"
echo "   Subscription: Student"

# Переключаємося на студентську підписку
echo "🔄 Switching to student subscription..."
az account set --subscription "Azure для учащихся"

# Реєструємо providers
echo "📝 Registering providers..."
az provider register --namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.Web

# Чекаємо завершення реєстрації
echo "⏳ Waiting for provider registration..."
while [[ $(az provider show --namespace Microsoft.ContainerInstance --query registrationState -o tsv) != "Registered" ]]; do
    echo "   Still registering..."
    sleep 10
done
echo "✅ Providers registered!"

# Створюємо resource group
echo "🏗️ Creating resource group..."
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Створюємо контейнер з Microsoft зразком
echo "🚀 Creating container with Microsoft sample..."
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --image "mcr.microsoft.com/azuredocs/aci-helloworld:latest" \
    --cpu 1 \
    --memory 1 \
    --ip-address public \
    --ports 80 \
    --location "$LOCATION"

# Отримуємо IP
echo "📍 Getting container IP..."
sleep 30
CONTAINER_IP=$(az container show \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --query ipAddress.ip \
    --output tsv)

if [ ! -z "$CONTAINER_IP" ] && [ "$CONTAINER_IP" != "null" ]; then
    echo "✅ Container deployed successfully!"
    echo "🌐 Your app: http://$CONTAINER_IP"
    echo "💰 Cost: ~$3-5/month"
    echo "📊 Resource Group: $RESOURCE_GROUP"
    echo "🏷️ Container Name: $CONTAINER_NAME"
    
    # Тестуємо підключення
    echo "🔍 Testing connection..."
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$CONTAINER_IP" --connect-timeout 10 || echo "000")
    if [ "$HTTP_STATUS" -eq 200 ]; then
        echo "✅ Connection test passed!"
    else
        echo "⚠️ Connection test failed: HTTP $HTTP_STATUS"
    fi
else
    echo "❌ Failed to get container IP"
    echo "🔍 Checking container logs..."
    az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME
fi

echo ""
echo "📝 Useful commands:"
echo "   View logs: az container logs --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME"
echo "   Delete all: az group delete --name $RESOURCE_GROUP --yes --no-wait"
