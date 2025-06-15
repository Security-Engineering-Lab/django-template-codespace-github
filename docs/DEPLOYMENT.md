

Ця помилка виникає тому, що у вашій Azure DevOps організації немає доступних безкоштовних агентів для Microsoft-hosted pipelines. Ось кілька способів вирішення:

## 🆓 **Рішення 1: Запросити безкоштовний доступ (Рекомендовано)**

### **Заповніть форму Microsoft:**
1. Перейдіть за посиланням: https://aka.ms/azpipelines-parallelism-request
2. Заповніть форму з такою інформацією:
   - **Organization name:** назва вашої Azure DevOps організації
   - **Project name:** назва проекту
   - **Business justification:** "Learning and development purposes" або "Open source project"
   - **Contact information:** ваша електронна пошта

### **Що вказати в формі:**
```
Business Justification:
"I am using Azure DevOps for educational purposes to learn CI/CD practices 
and Django deployment. This is a personal learning project to understand 
Azure DevOps pipelines and Azure App Service deployment."
```

**⏱️ Час розгляду:** зазвичай 2-3 робочі дні

---

## 🔄 **Рішення 2: Тимчасове обхідне рішення - Self-hosted агент**

### **Створіть self-hosted агент на вашому комп'ютері:**

**Крок 1: Завантажте агент**
1. Azure DevOps → Project Settings → Agent pools
2. Default pool → New agent
3. Завантажте агент для вашої ОС

**Крок 2: Налаштуйте агент**
```bash
# Linux/macOS
mkdir myagent && cd myagent
tar zxvf ~/Downloads/vsts-agent-linux-x64-*.tar.gz
./config.sh

# Windows (PowerShell)
mkdir agent ; cd agent
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$HOME\Downloads\vsts-agent-win-x64-*.zip", "$PWD")
.\config.cmd
```

**Крок 3: Оновіть YAML файл**---


## 💰 **Рішення 3: Платна опція (якщо потрібно негайно)**

### **Придбайте Microsoft-hosted parallelism:**
1. Azure DevOps → Organization settings → Billing
2. Set up billing → Microsoft-hosted CI/CD
3. Купіть 1 parallel job (~$40/місяць)

---

## 🎯 **Рішення 4: Спрощений pipeline тільки для deployment**

### **Мінімальний YAML без складних перевірок:**---

```yaml

# Minimal Django Pipeline - No parallelism required
name: Django-Simple-Deploy-$(Date:yyyyMMdd)$(Rev:.r)

trigger:
- main

variables:
  pythonVersion: '3.11'
  azureServiceConnection: 'azure-production'  # Замініть на вашу назву
  webAppName: 'django-template-prod'          # Замініть на вашу назву
  resourceGroupName: 'rg-django-template'

# Використовуємо лише один stage для економії ресурсів
stages:
- stage: BuildAndDeploy
  displayName: 'Build and Deploy Django App'
  jobs:
  - job: BuildDeployJob
    timeoutInMinutes: 30
    steps:
    - task: UsePythonVersion@0
      inputs:
        versionSpec: '$(pythonVersion)'
      displayName: 'Use Python $(pythonVersion)'

    - script: |
        echo "🐍 Installing dependencies..."
        python -m pip install --upgrade pip
        pip install -r requirements.txt
      displayName: 'Install dependencies'

    - script: |
        echo "✅ Basic Django check..."
        python manage.py check
      displayName: 'Django check'

    - script: |
        echo "📦 Collecting static files..."
        python manage.py collectstatic --noinput
      displayName: 'Collect static files'

    - task: ArchiveFiles@2
      displayName: 'Create deployment package'
      inputs:
        rootFolderOrFile: '$(System.DefaultWorkingDirectory)'
        includeRootFolder: false
        archiveType: zip
        archiveFile: $(Build.ArtifactStagingDirectory)/app.zip
        replaceExistingArchive: true

    - task: AzureCLI@2
      displayName: 'Create Azure resources'
      inputs:
        azureSubscription: $(azureServiceConnection)
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          # Create resources if they don't exist
          az group create --name $(resourceGroupName) --location "East US" || true
          az appservice plan create --name asp-$(webAppName) --resource-group $(resourceGroupName) --sku F1 --is-linux || true
          az webapp create --name $(webAppName) --resource-group $(resourceGroupName) --plan asp-$(webAppName) --runtime "PYTHON|3.11" || true

    - task: AzureWebApp@1
      displayName: 'Deploy to Azure App Service'
      inputs:
        azureSubscription: $(azureServiceConnection)
        appType: 'webAppLinux'
        appName: $(webAppName)
        package: $(Build.ArtifactStagingDirectory)/app.zip
        runtimeStack: 'PYTHON|3.11'
        startUpCommand: 'gunicorn --bind=0.0.0.0 --timeout 600 hello_world.wsgi'

    - script: |
        echo "🎉 Deployment completed!"
        echo "🌐 Your app should be available at: https://$(webAppName).azurewebsites.net"
      displayName: 'Deployment summary'

```

## 🚀 **Рішення 5: Використовувайте GitHub Actions (альтернатива)**

### **Якщо Azure DevOps parallelism недоступний, використайте GitHub Actions:**

**Створіть `.github/workflows/deploy.yml`:**
```yaml
name: Deploy Django to Azure

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
    
    - name: Deploy to Azure Web App
      uses: azure/webapps-deploy@v2
      with:
        app-name: 'your-app-name'
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
```

---

## ✅ **Рекомендований план дій:**

1. **🆓 Негайно:** Заповніть форму для безкоштовного доступу
2. **⚡ Тимчасово:** Використайте мінімальний pipeline (якщо у вас є 1 безкоштовна хвилина)
3. **🔄 Альтернатива:** Налаштуйте self-hosted агент
4. **📞 Зв'язок:** Після отримання доступу поверніться до повного pipeline

**Яке рішення ви хочете спробувати спочатку?** Я можу допомогти з будь-яким із цих варіантів!
-----------------------------------------------------------------------------------------------------------------------------------------------------

Проблема в тому, що навіть мінімальний pipeline потребує hosted агента. У вас є **0 хвилин** безкоштовного часу для Microsoft-hosted агентів. Ось кілька рішень:

## 🔧 **Рішення 1: Self-hosted агент (Найшвидше)**

### **Налаштуйте агент на вашому комп'ютері:**

**Крок 1: Створіть агент pool**
1. Azure DevOps → Project Settings → Agent pools
2. Add pool → New → Self-hosted
3. Назвіть його `MyPool`

**Крок 2: Завантажте та налаштуйте агент**

**Для Windows:**
```powershell
# Створіть папку
mkdir C:\agent
cd C:\agent

# Завантажте агент з Azure DevOps UI або напряму
# Azure DevOps → Agent pools → MyPool → New agent → Download

# Розпакуйте та налаштуйте
.\config.cmd
# Введіть:
# Server URL: https://dev.azure.com/[your-organization]
# Authentication type: PAT
# Personal access token: [створіть PAT в User Settings]
# Agent pool: MyPool
# Agent name: MyAgent
# Work folder: _work

# Запустіть агент
.\run.cmd
```

**Для Linux/macOS:**
```bash
# Створіть папку
mkdir ~/agent && cd ~/agent

# Завантажте агент (замініть посилання з Azure DevOps UI)
wget https://vstsagentpackage.azureedge.net/agent/3.232.3/vsts-agent-linux-x64-3.232.3.tar.gz
tar zxvf vsts-agent-linux-x64-3.232.3.tar.gz

# Налаштуйте
./config.sh
# Введіть ті ж параметри що й для Windows

# Запустіть
./run.sh
```

**Крок 3: Оновіть YAML файл**---

```yaml

# Minimal Django Pipeline - No parallelism required
name: Django-Simple-Deploy-$(Date:yyyyMMdd)$(Rev:.r)

trigger:
- main

variables:
  pythonVersion: '3.11'
  azureServiceConnection: 'azure-production'  # Замініть на вашу назву
  webAppName: 'django-template-prod'          # Замініть на вашу назву
  resourceGroupName: 'rg-django-template'

# Використовуємо лише один stage для економії ресурсів
stages:
- stage: BuildAndDeploy
  displayName: 'Build and Deploy Django App'
  jobs:
  - job: BuildDeployJob
    pool:
      name: 'MyPool'  # Використовуємо self-hosted агент
    timeoutInMinutes: 30
    steps:
    - task: UsePythonVersion@0
      inputs:
        versionSpec: '$(pythonVersion)'
      displayName: 'Use Python $(pythonVersion)'

    - script: |
        echo "🐍 Installing dependencies..."
        python -m pip install --upgrade pip
        pip install -r requirements.txt
      displayName: 'Install dependencies'

    - script: |
        echo "✅ Basic Django check..."
        python manage.py check
      displayName: 'Django check'

    - script: |
        echo "📦 Collecting static files..."
        python manage.py collectstatic --noinput
      displayName: 'Collect static files'

    - task: ArchiveFiles@2
      displayName: 'Create deployment package'
      inputs:
        rootFolderOrFile: '$(System.DefaultWorkingDirectory)'
        includeRootFolder: false
        archiveType: zip
        archiveFile: $(Build.ArtifactStagingDirectory)/app.zip
        replaceExistingArchive: true

    - task: AzureCLI@2
      displayName: 'Create Azure resources'
      inputs:
        azureSubscription: $(azureServiceConnection)
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          # Create resources if they don't exist
          az group create --name $(resourceGroupName) --location "East US" || true
          az appservice plan create --name asp-$(webAppName) --resource-group $(resourceGroupName) --sku F1 --is-linux || true
          az webapp create --name $(webAppName) --resource-group $(resourceGroupName) --plan asp-$(webAppName) --runtime "PYTHON|3.11" || true

    - task: AzureWebApp@1
      displayName: 'Deploy to Azure App Service'
      inputs:
        azureSubscription: $(azureServiceConnection)
        appType: 'webAppLinux'
        appName: $(webAppName)
        package: $(Build.ArtifactStagingDirectory)/app.zip
        runtimeStack: 'PYTHON|3.11'
        startUpCommand: 'gunicorn --bind=0.0.0.0 --timeout 600 hello_world.wsgi'

    - script: |
        echo "🎉 Deployment completed!"
        echo "🌐 Your app should be available at: https://$(webAppName).azurewebsites.net"
      displayName: 'Deployment summary'

```


## 🎯 **Рішення 2: GitHub Actions (Альтернатива)**

Якщо Azure DevOps створює проблеми, використайте GitHub Actions (безкоштовно):**Для GitHub Actions потрібно:**
1. Створити Azure Web App
2. Отримати Publish Profile
3. Додати його як GitHub Secret

---

## 🆓 **Рішення 3: Azure CLI локально**


```bash
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
```


### **Розгорніть проект напряму з командного рядка:****Як використовувати:**
```bash
# Зробіть скрипт виконуваним
chmod +x deploy-to-azure.sh

# Запустіть розгортання
./deploy-to-azure.sh
```

---

## ✅ **Рекомендації:**

### **🎯 Найкращий варіант для вас:**

1. **Якщо хочете вивчити Azure DevOps:** Налаштуйте self-hosted агент (Рішення 1)
2. **Якщо потрібно швидко розгорнути:** Використайте Azure CLI скрипт (Рішення 3)
3. **Якщо віддаєте перевагу GitHub:** Перейдіть на GitHub Actions (Рішення 2)

### **🔄 Тимчасово:**
- Заповніть форму для безкоштовного parallelism
- Використайте один з альтернативних методів

**Який варіант хочете спробувати?** Я допоможу з налаштуванням будь-якого з них!


-------------------------------------------------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------------------


Проблема в тому, що у вашій Azure підписці **немає квоти для безкоштовних VM** (Free tier). Ось рішення:

## 🚨 **Основна проблема:**
```
Current Limit (Free VMs): 0
Amount required for this deployment (Free VMs): 1
```

## 🔧 **Рішення:**

### **Варіант 1: Запросити збільшення квоти (Рекомендовано)**

```bash
# Перевірте поточні квоти
az vm list-usage --location "East US" --output table

# Запросіть збільшення квоти через Azure Portal
```

**Кроки через Azure Portal:**
1. Відкрийте https://portal.azure.com
2. Перейдіть до **"Help + support"**
3. **"New support request"**
4. **Issue type:** Service and subscription limits (quotas)
5. **Quota type:** Compute-VM (cores-vCPUs) subscription limit increases
6. **Request:** Free tier VM quota increase to 1

---

### **Варіант 2: Використати платний tier (B1 Basic)**### **Варіант 3: Спробувати інший регіон**

```bash
# Перевірте доступні регіони
az account list-locations --output table

# Спробуйте інші регіони де може бути квота
LOCATION="West US 2"  # або "Central US", "West Europe"
```

---

### **Варіант 4: Використати Azure Container Instances (дешевше)**---

```bash
#!/bin/bash

# Deploy Django to Azure Container Instances (cheaper alternative)
echo "🚀 Deploying Django to Azure Container Instances..."

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
```











## ✅ **Рекомендовані дії:**

### **🎯 Найкращий варіант для навчання:**

1. **Запросіть збільшення квоти** через Azure Portal
2. **Тимчасово використайте Basic tier** (~$13/місяць)
3. **Видаліть ресурси** після тестування

### **💡 Швидке рішення:**

```bash
# Видаліть поточні ресурси
az group delete --name rg-django-template --yes --no-wait

# Використайте Basic tier
chmod +x deploy-basic-tier.sh
./deploy-basic-tier.sh
```

### **🔍 Перевірте квоти:**

```bash
# Перевірте поточні ліміти
az vm list-usage --location "East US" --output table
az vm list-usage --location "West US 2" --output table
```

**Який варіант оберете?** Basic tier дасть вам повний досвід Azure App Service за невелику плату (~$13/місяць), яку можна скасувати після навчання.







----------------------------------------------------------------------------------------------
Проблема все ще та сама - Azure CLI не встановлено. Давайте встановимо його спочатку:

## 🔧 **Встановлення Azure CLI**

### **Виконайте ці команди:**

```bash
# 1. Оновіть систему
sudo apt-get update

# 2. Встановіть необхідні залежності
sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg -y

# 3. Створіть директорію для ключів
sudo mkdir -p /etc/apt/keyrings

# 4. Додайте Microsoft GPG ключ
curl -sLS https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor | \
    sudo tee /etc/apt/keyrings/microsoft.gpg > /dev/null

sudo chmod go+r /etc/apt/keyrings/microsoft.gpg

# 5. Додайте Azure CLI репозиторій
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list

# 6. Оновіть індекс пакетів і встановіть Azure CLI
sudo apt-get update
sudo apt-get install azure-cli -y

# 7. Перевірте встановлення
az --version
```

### **Або швидкий спосіб одною командою:**

```bash
curl -sL https://aka.ms/InstallAzureCli | sudo bash
```

---

## ✅ **Після встановлення:**

### **1. Перевірте Azure CLI:**
```bash
az --version
which az
```

### **2. Увійдіть в Azure:**
```bash
az login --use-device-code
```

### **3. Запустіть скрипт заново:**
```bash
./deploy-basic-tier.sh
```

---

## 🚀 **Альтернативний спосіб через Azure Cloud Shell:**

Якщо встановлення локально не працює, використайте Azure Cloud Shell:

### **1. Відкрийте Azure Portal:**
- Перейдіть на https://portal.azure.com
- Натисніть іконку Cloud Shell (>_) у верхній панелі

### **2. Завантажте ваш код:**
```bash
# У Cloud Shell
git clone https://github.com/Security-Engineering-Lab/django-template-codespace-github.git
cd django-template-codespace-github
```

### **3. Запустіть розгортання:**
```bash
chmod +x deploy-basic-tier.sh
./deploy-basic-tier.sh
```

---

## 🔧 **Виправлений скрипт з перевіркою Azure CLI:**## ✅ **Виконайте:**

### **1. Спочатку встановіть Azure CLI:**
```bash
sudo apt-get update && sudo apt-get install azure-cli -y
```

### **2. Перевірте встановлення:**
```bash
az --version
```

### **3. Використайте новий скрипт:**
```bash
chmod +x deploy-with-cli-install.sh
./deploy-with-cli-install.sh
```

Цей скрипт автоматично встановить Azure CLI якщо його немає, а потім виконає розгортання. **Який варіант спробуєте?**



-----------------------------------------------------------------------------


Проблема в тому, що у вашій Azure підписці **також немає квоти для Basic tier VM**. Це означає, що обидві підписки мають ліміт 0 для віртуальних машин.

## 🚨 **Проблема:**
```
Current Limit (Basic VMs): 0
Amount required for this deployment (Basic VMs): 1
```

## 🔧 **Рішення:**

### **Варіант 1: Спробуйте іншу підписку**

У вас є доступ до двох підписок:
- **Azure subscription 1** (поточна) - без квоти
- **Azure для учащихся** - може мати квоту

```bash
# Переключіться на студентську підписку
az account set --subscription "826d896f-b844-48c3-998e-c8e36c27e681"

# Перевірте квоти в цій підписці
az vm list-usage --location "East US" --output table

# Спробуйте розгортання знову
./deploy-with-cli-install.sh
```

---

### **Варіант 2: Спробуйте інший регіон**### **Варіант 3: Azure Static Web Apps (БЕЗКОШТОВНО!)**## ✅ **Рекомендовані дії:**


```bash
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

```


### **🎯 Спробуйте в такому порядку:**

1. **Переключіться на студентську підписку і спробуйте різні регіони:**
```bash
chmod +x deploy-multi-region.sh
./deploy-multi-region.sh
```

2. **Якщо це не спрацює, запросіть збільшення квоти:**
   - Перейдіть на https://portal.azure.com
   - **Support** → **New support request**
   - **Issue type:** Service and subscription limits (quotas)
   - **Quota type:** Compute-VM (cores-vCPUs)
   - Запросіть 1 Free tier VM

3. **Альтернатива - Azure Static Web Apps (БЕЗКОШТОВНО):**
```bash
chmod +x deploy-static-web-app.sh
./deploy-static-web-app.sh
```


```bash
#!/bin/bash

echo "🚀 Deploying Django to Azure Static Web Apps (FREE!)"

RESOURCE_GROUP="rg-django-static"
STATIC_APP_NAME="django-static-$(date +%s)"
LOCATION="Central US"

echo "📋 Configuration:"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Static App Name: $STATIC_APP_NAME"
echo "   Cost: FREE"

# Переключаємося на студентську підписку
az account set --subscription "826d896f-b844-48c3-998e-c8e36c27e681"

# Створюємо resource group
echo "🏗️ Creating resource group..."
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Для Static Web Apps потрібен GitHub репозиторій
echo "📝 Note: This requires a GitHub repository with your code."
echo "Please ensure your code is pushed to GitHub first."

read -p "Enter your GitHub repository URL (https://github.com/username/repo): " GITHUB_REPO

if [ -z "$GITHUB_REPO" ]; then
    echo "❌ GitHub repository URL is required"
    exit 1
fi

# Створюємо статичну конфігурацію
cat > staticwebapp.config.json << 'EOF'
{
  "routes": [
    {
      "route": "/static/*",
      "headers": {
        "cache-control": "public, max-age=31536000, immutable"
      }
    },
    {
      "route": "/*",
      "serve": "/index.html",
      "statusCode": 200
    }
  ],
  "responseOverrides": {
    "404": {
      "redirect": "/index.html",
      "statusCode": 200
    }
  }
}
EOF

# Створюємо GitHub Actions workflow
mkdir -p .github/workflows
cat > .github/workflows/azure-static-web-apps.yml << 'EOF'
name: Azure Static Web Apps CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    types: [opened, synchronize, reopened, closed]
    branches: [ main ]

jobs:
  build_and_deploy_job:
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.action != 'closed')
    runs-on: ubuntu-latest
    name: Build and Deploy Job
    steps:
      - uses: actions/checkout@v3
        with:
          submodules: true
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      
      - name: Collect static files
        run: |
          python manage.py collectstatic --noinput
      
      - name: Build And Deploy
        id: builddeploy
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          repo_token: ${{ secrets.GITHUB_TOKEN }}
          action: "upload"
          app_location: "/"
          api_location: ""
          output_location: "hello_world/staticfiles"

  close_pull_request_job:
    if: github.event_name == 'pull_request' && github.event.action == 'closed'
    runs-on: ubuntu-latest
    name: Close Pull Request Job
    steps:
      - name: Close Pull Request
        id: closepullrequest
        uses: Azure/static-web-apps-deploy@v1
        with:
          azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
          action: "close"
EOF

echo "✅ Configuration files created!"
echo ""
echo "📋 Next steps:"
echo "1. Commit and push these files to your GitHub repository"
echo "2. Go to Azure Portal → Create Resource → Static Web Apps"
echo "3. Connect your GitHub repository"
echo "4. Azure will automatically deploy your app"
echo ""
echo "💰 Cost: FREE (with 100GB bandwidth/month)"

```


### **💡 Найпростіше рішення:**

Спробуйте **студентську підписку** в різних регіонах - у неї може бути доступна квота:

```bash
az account set --subscription "Azure для учащихся"
./deploy-multi-region.sh
```

**Який варіант спробуєте?** Студентські підписки зазвичай мають більше безкоштовних ресурсів!

--------------------------------------------------------------------------------


Помилка виникла через проблеми з Docker Hub (`An error response is received from the docker registry 'index.docker.io'`). Давайте спробуємо альтернативні підходи:

## 🎯 **Рішення 1: Heroku (Найпростіше і надійне)**

Heroku - найкращий варіант для демонстрації, оскільки не має проблем з квотами Azure:

```bash
chmod +x deploy-heroku.sh
./deploy-heroku.sh
```

---

## 🔄 **Рішення 2: Спробуйте студентську підписку з Container Instances**## 🌐 **Рішення 3: Azure Static Web Apps (Безкоштовно)**---

## ✅ **Рекомендації:**

### **🎯 Найкращі варіанти по порядку:**

1. **Heroku (найпростіше):**
```bash
chmod +x deploy-heroku.sh
./deploy-heroku.sh
```

2. **Студентська підписка з контейнерами:**
```bash
chmod +x deploy-student-subscription.sh
./deploy-student-subscription.sh
```

3. **Static Web Apps (безкоштовно):**
```bash
chmod +x deploy-static-simple.sh
./deploy-static-simple.sh
```

---

## 💡 **Чому не працює Container Instances:**

1. **Docker Hub недоступний** в цей момент
2. **Квоти Azure** для VM обмежені
3. **Проблеми з реєстрацією провайдерів**

### **Heroku - найнадійніший варіант:**
- ✅ Безкоштовно
- ✅ Без проблем з квотами
- ✅ Повна підтримка Django
- ✅ Автоматичне налаштування бази даних

**Який варіант спробуєте?** Рекомендую почати з Heroku!


---------------------------------------------------------------------------------------------










