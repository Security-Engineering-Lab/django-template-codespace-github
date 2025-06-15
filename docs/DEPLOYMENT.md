

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
