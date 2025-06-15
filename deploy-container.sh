#!/bin/bash

# Deploy Django to Azure Container Instances (cheaper alternative)
echo "🚀 Deploying Django to Azure Container Instances..."

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



RESOURCE_GROUP="rg-django-container"
LOCATION="East US"
CONTAINER_NAME="django-container-$(date +%s)"
IMAGE_NAME="django-app"

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Container Name: $CONTAINER_NAME"
echo "   Cost: ~$3-5/month"

# Створення Dockerfile
cat > Dockerfile << 'EOF'
FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn

# Copy application code
COPY . .

# Collect static files
RUN python manage.py collectstatic --noinput

# Expose port
EXPOSE 8000

# Run the application
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--timeout", "600", "hello_world.wsgi"]
EOF

echo "🐳 Building Docker image..."
docker build -t $IMAGE_NAME .

# Login to Azure
az login --use-device-code

# Create resource group
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Create Azure Container Registry
ACR_NAME="acrdjango$(date +%s | tail -c 6)"
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic

# Login to ACR
az acr login --name $ACR_NAME

# Tag and push image
docker tag $IMAGE_NAME $ACR_NAME.azurecr.io/$IMAGE_NAME:latest
docker push $ACR_NAME.azurecr.io/$IMAGE_NAME:latest

# Create container instance
az container create \
    --resource-group $RESOURCE_GROUP \
    --name $CONTAINER_NAME \
    --image $ACR_NAME.azurecr.io/$IMAGE_NAME:latest \
    --cpu 1 \
    --memory 1 \
    --registry-login-server $ACR_NAME.azurecr.io \
    --registry-username $(az acr credential show --name $ACR_NAME --query username -o tsv) \
    --registry-password $(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv) \
    --ip-address public \
    --ports 8000 \
    --environment-variables DJANGO_DEBUG=False

# Get public IP
CONTAINER_IP=$(az container show --resource-group $RESOURCE_GROUP --name $CONTAINER_NAME --query ipAddress.ip --output tsv)

echo "✅ Container deployed!"
echo "🌐 Your Django app: http://$CONTAINER_IP:8000"
echo "💰 Monthly cost: ~$3-5"
