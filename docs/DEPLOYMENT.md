

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

