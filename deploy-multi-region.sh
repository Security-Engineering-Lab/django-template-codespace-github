#!/bin/bash

echo "🚀 Django deployment with multiple region attempts..."

# Список регіонів для спроби
REGIONS=("West US 2" "Central US" "West Europe" "East US 2" "South Central US")
RESOURCE_GROUP="rg-django-template"
APP_SERVICE_PLAN="asp-django-template"
WEB_APP_NAME="django-template-$(date +%s)"
SKU="F1"  # Спробуємо знову Free tier

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Web App Name: $WEB_APP_NAME"
echo "   SKU: $SKU (Free tier)"

# Перевіряємо автентифікацію
if ! az account show &> /dev/null; then
    echo "Please login to Azure:"
    az login --use-device-code
fi

# Переключаємося на студентську підписку
echo "🔄 Switching to student subscription..."
az account set --subscription "826d896f-b844-48c3-998e-c8e36c27e681"

SUBSCRIPTION=$(az account show --query name -o tsv)
echo "📊 Using subscription: $SUBSCRIPTION"

# Видаляємо попередні ресурси
echo "🧹 Cleaning up previous resources..."
az group delete --name $RESOURCE_GROUP --yes --no-wait 2>/dev/null || echo "No previous resources"
sleep 20

# Спробуємо кожен регіон
for LOCATION in "${REGIONS[@]}"; do
    echo ""
    echo "🌍 Trying region: $LOCATION"
    
    # Перевіряємо квоти в цьому регіоні
    echo "   Checking quotas..."
    QUOTA_CHECK=$(az vm list-usage --location "$LOCATION" --query "[?name.value=='standardDSv3Family'].{current:currentValue,limit:limit}" --output tsv 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "   Quota check passed for $LOCATION"
        
        # Створюємо resource group
        echo "   Creating resource group..."
        if az group create --name $RESOURCE_GROUP --location "$LOCATION" --output table; then
            
            # Спробуємо створити App Service Plan
            echo "   Creating App Service Plan..."
            if az appservice plan create \
                --name $APP_SERVICE_PLAN \
                --resource-group $RESOURCE_GROUP \
                --sku $SKU \
                --is-linux \
                --output table; then
                
                echo "✅ Success in $LOCATION! Continuing with deployment..."
                
                # Створюємо Web App
                echo "   Creating Web App..."
                az webapp create \
                    --name $WEB_APP_NAME \
                    --resource-group $RESOURCE_GROUP \
                    --plan $APP_SERVICE_PLAN \
                    --runtime "PYTHON|3.12" \
                    --output table
                
                # Налаштування
                echo "   Configuring Web App..."
                az webapp config appsettings set \
                    --name $WEB_APP_NAME \
                    --resource-group $RESOURCE_GROUP \
                    --settings \
                        DJANGO_SETTINGS_MODULE="hello_world.settings" \
                        DJANGO_DEBUG="False" \
                        SCM_DO_BUILD_DURING_DEPLOYMENT="true" \
                    --output table
                
                # Підготовка коду
                echo "📦 Preparing deployment..."
                python manage.py collectstatic --noinput
                
                zip -r deployment.zip . \
                    -x "*.git*" "*__pycache__*" "*.pyc" "venv/*" "env/*" \
                       "*.md" ".devcontainer/*" "docs/*" "*.log" \
                       "deployment.zip" "*deploy*.sh"
                
                # Розгортання
                echo "🚀 Deploying..."
                az webapp deploy \
                    --name $WEB_APP_NAME \
                    --resource-group $RESOURCE_GROUP \
                    --src-path deployment.zip \
                    --type zip
                
                # Startup команда
                az webapp config set \
                    --name $WEB_APP_NAME \
                    --resource-group $RESOURCE_GROUP \
                    --startup-file "gunicorn --bind=0.0.0.0 --timeout 600 hello_world.wsgi"
                
                # Перезапуск
                az webapp restart \
                    --name $WEB_APP_NAME \
                    --resource-group $RESOURCE_GROUP
                
                # Health check
                APP_URL="https://$WEB_APP_NAME.azurewebsites.net"
                echo "🏥 Health check..."
                sleep 90
                
                HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL --connect-timeout 30 || echo "000")
                
                if [ "$HTTP_STATUS" -eq 200 ]; then
                    echo "✅ Deployment successful!"
                    echo "🌐 Your Django app: $APP_URL"
                    echo "📍 Region: $LOCATION"
                    echo "💰 Cost: FREE (F1 tier)"
                    rm -f deployment.zip
                    exit 0
                else
                    echo "⚠️ Health check failed: HTTP $HTTP_STATUS"
                fi
                
                rm -f deployment.zip
                break
                
            else
                echo "❌ Failed to create App Service Plan in $LOCATION"
                # Видаляємо resource group і спробуємо наступний регіон
                az group delete --name $RESOURCE_GROUP --yes --no-wait 2>/dev/null
                continue
            fi
        else
            echo "❌ Failed to create resource group in $LOCATION"
            continue
        fi
    else
        echo "⚠️ Quota check failed for $LOCATION"
        continue
    fi
done

echo ""
echo "❌ All regions failed. Possible solutions:"
echo "1. Request quota increase: https://portal.azure.com → Support → New support request"
echo "2. Try different subscription with available quota"
echo "3. Use Azure Container Instances instead"
