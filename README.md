# GitHub Codespaces ♥️ Django

Welcome to your shiny new Codespace running Django! We've got everything fired up and running for you to explore Django.

You've got a blank canvas to work on from a git perspective as well. There's a single initial commit with what you're seeing right now - where you go from here is up to you!

Everything you do here is contained within this one codespace. There is no repository on GitHub yet. If and when you’re ready you can click "Publish Branch" and we’ll create your repository and push up your project. If you were just exploring then and have no further need for this code then you can simply delete your codespace and it's gone forever.

## installing dependancies

```python
pip install -r requirements.txt
```

## To collect static files:

```python
python manage.py collectstatic
```

## To run this application:

```python
python manage.py runserver
```

-------------------------------------------------

Це екран вибору шаблонів для GitHub Codespace - хмарного середовища розробки, яке дозволяє працювати з кодом прямо в браузері. Ось детальний опис доступних шаблонів:

## 🎯 **Виділений шаблон - Django**
Ви обрали Django - це потужний Python веб-фреймворк, який ідеально підходить для створення складних веб-додатків. Django надає готові рішення для роботи з базами даних, автентифікації користувачів та адміністративною панеллю.

## 📋 **Інші доступні шаблони:**

**🔸 Blank** - Порожній шаблон для тих, хто хоче почати з нуля або імпортувати власні пакети.

**🔸 React** - JavaScript бібліотека для створення інтерактивних користувацьких інтерфейсів. Відмінний вибір для сучасних веб-додатків.

**🔸 .NET** - Повнофункціональний шаблон від Microsoft для створення веб-додатків на C#.

**🔸 Ruby on Rails** - Повнофункціональний фреймворк для швидкої розробки динамічних веб-сайтів на Ruby.

**🔸 Jupyter Notebook** - Інтерактивне середовище для аналізу даних, машинного навчання та наукових обчислень.

**🔸 Express** - Мінімалістичний та гнучкий Node.js фреймворк для створення веб-серверів та API.

**🔸 Next.js** - React-фреймворк для створення повнофункціональних веб-додатків з серверним рендерингом.

**🔸 Flask** - Легкий Python веб-фреймворк для простих проектів.

**🔸 Preact** - Швидка 3kB альтернатива React з тим же сучасним API.

## 💡 **Рекомендації щодо вибору:**

- **Django** - для складних веб-додатків з базами даних
- **React/Next.js** - для сучасних фронтенд додатків
- **Flask** - для простих Python проектів
- **Express** - для Node.js API та серверів
- **Jupyter** - для аналізу даних та ML

Після вибору шаблону GitHub створить віртуальну машину в хмарі з усіма необхідними інструментами та залежностями!

-----------------------------------------------------------------------------------------------------------------------------


# 🚀 Django Template: Fork vs Template - Повний гід

## 🤔 Fork vs Template vs Import - Який спосіб обрати?

### Порівняння методів:

| Метод | Переваги | Недоліки | Коли використовувати |
|-------|----------|----------|---------------------|
| **Fork** | Зберігає зв'язок з upstream, легко синхронізувати | Історія оригіналу, складніше кастомізувати | Якщо плануєте контрибютити назад |
| **Template** | Чиста історія, повна свобода | Немає зв'язку з оригіналом | Для створення нового проекту (рекомендовано) |
| **Import** | Максимальний контроль | Ручна робота | Для складних кастомізацій |

## 🎯 Рекомендований підхід: Use Template

**Для вашого проекту рекомендую використовувати Template approach**, тому що:
- ✅ Чиста історія Git без зайвих комітів
- ✅ Повна свобода кастомізації
- ✅ Легше налаштувати під ваші потреби
- ✅ Краще для capstone/learning проектів

---

## Частина 1: Створення проекту з Template

### Метод 1: Використання GitHub Template (Рекомендовано)

#### Крок 1.1: Створення репозиторію з template

1. **Перейдіть на Django template**:
   ```
   https://github.com/github/codespaces-django
   ```

2. **Створіть репозиторій з template**:
   - Натисніть зелену кнопку **"Use this template"** (не Code!)
   - Оберіть **"Create a new repository"**
   - **Repository name**: `django-template-codespace-github`
   - **Description**: `Django project from GitHub template with Azure DevOps integration`
   - **Visibility**: Public (рекомендовано для навчальних проектів)
   - ✅ **Include all branches** (якщо потрібно)
   - Натисніть **"Create repository"**

#### Крок 1.2: Відкриття в Codespace

1. **У вашому новому репозиторії**:
   - Натисніть **"Code"** → вкладка **"Codespaces"**
   - **"Create codespace on main"**
   - Дочекайтеся створення (2-3 хвилини)

2. **Перевірте що все працює**:
   ```bash
   # У терміналі Codespace
   python --version
   python manage.py check
   python manage.py migrate
   python manage.py runserver 0.0.0.0:8000
   ```

### Метод 2: Fork + Customization (Альтернативний)

Якщо все ж хочете використовувати Fork:

#### Крок 2.1: Створення Fork

1. **На сторінці оригінального repo**:
   - Натисніть **"Fork"** у правому верхньому куті
   - **Repository name**: `django-template-codespace-github`
   - **Description**: `Forked Django template for learning`
   - Зніміть галочку **"Copy the main branch only"** якщо хочете всі гілки
   - **"Create fork"**

#### Крок 2.2: Очищення історії (опціонально)

Якщо хочете чисту історію:
```bash
# У Codespace після відкриття fork
git checkout --orphan new-main
git add .
git commit -m "Initial commit: Django template setup

- Based on github/codespaces-django template
- Customized for Azure DevOps integration
- Ready for development"

git branch -D main
git branch -m new-main main
git push -f origin main
```

---

## Частина 2: Кастомізація Django проекту

### Крок 2.1: Оновлення проекту

```bash
# У Codespace терміналі
# Створіть README для вашого проекту
cat > README.md << 'EOF'
# Django Template Project

🚀 Django проект створений з GitHub template для демонстрації:
- GitHub Codespace розробки
- Azure DevOps CI/CD pipeline
- Azure App Service deployment

## 📋 Project Status

- ✅ GitHub Codespace configured
- ✅ Django 4.x setup
- ✅ Azure deployment ready
- ⏳ Azure DevOps pipeline (in progress)
- ⏳ Azure Boards planning (in progress)

## 🚀 Quick Start

### GitHub Codespace (Recommended)
1. Click **"Code"** → **"Codespaces"** → **"Create codespace on main"**
2. Wait for automatic setup (2-3 minutes)
3. Run: `python manage.py runserver 0.0.0.0:8000`

### Local Development
```bash
git clone https://github.com/YOUR_USERNAME/django-template-codespace-github.git
cd django-template-codespace-github
python -m venv venv
source venv/bin/activate  # Linux/Mac
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

## 🏗️ Architecture

- **Framework**: Django 4.x
- **Database**: SQLite (dev) → PostgreSQL (prod)
- **Hosting**: Azure App Service
- **CI/CD**: Azure DevOps Pipelines
- **Project Management**: Azure Boards

## 📊 Features

- ✅ Modern Django setup
- ✅ GitHub Codespace optimized
- ✅ Azure cloud ready
- ✅ DevContainer configuration
- ✅ Automated testing
- ✅ Security best practices

## 🔧 Development

### Django Commands
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic
python manage.py test
```

### Azure Deployment
Project configured for automated deployment via Azure DevOps Pipeline.

## 📖 Documentation

- [Setup Guide](docs/SETUP.md)
- [Azure DevOps Integration](docs/AZURE_DEVOPS.md)
- [Deployment Guide](docs/DEPLOYMENT.md)

---

**Created from GitHub Django Template**
**Enhanced for Azure DevOps integration**
EOF

# Створіть директорію для документації
mkdir -p docs

# Створіть базову документацію
cat > docs/SETUP.md << 'EOF'
# Setup Guide

## Prerequisites
- GitHub account
- Azure subscription
- Basic Python knowledge

## Development Setup

### Option 1: GitHub Codespace (Recommended)
1. Open repository on GitHub
2. Click "Code" → "Codespaces" → "Create codespace"
3. Wait for automatic setup
4. Start developing!

### Option 2: Local Development
1. Clone repository
2. Create virtual environment
3. Install dependencies
4. Run Django server

## Configuration

### Environment Variables
- `DEBUG`: Development mode (True/False)
- `SECRET_KEY`: Django secret key
- `DATABASE_URL`: Database connection string
- `ALLOWED_HOSTS`: Allowed hostnames

### Database Setup
- Development: SQLite (automatic)
- Production: Azure Database for PostgreSQL

## Next Steps
1. Complete Azure DevOps setup
2. Configure CI/CD pipeline
3. Deploy to Azure App Service
EOF
```

### Крок 2.2: Підготовка для Azure

```bash
# Додайте файли для Azure deployment
mkdir -p deploy

# Створіть startup script для Azure
cat > deploy/startup.sh << 'EOF'
#!/bin/bash

echo "🚀 Starting Django application on Azure App Service..."

# Install dependencies
echo "📦 Installing Python dependencies..."
python -m pip install --upgrade pip
pip install -r requirements.txt

# Collect static files
echo "📁 Collecting static files..."
python manage.py collectstatic --noinput

# Run database migrations
echo "🗄️ Running database migrations..."
python manage.py migrate

# Create superuser if it doesn't exist (only for demo)
echo "👤 Setting up admin user..."
python manage.py shell << PYTHON
from django.contrib.auth.models import User
if not User.objects.filter(is_superuser=True).exists():
    User.objects.create_superuser('admin', 'admin@example.com', 'TempPassword123!')
    print('Demo admin user created: admin / TempPassword123!')
PYTHON

# Start Gunicorn
echo "🌐 Starting Gunicorn server..."
exec gunicorn --bind=0.0.0.0:$PORT --workers=4 --timeout=600 hello_world.wsgi:application
EOF

chmod +x deploy/startup.sh

# Оновіть requirements.txt для Azure
cat >> requirements.txt << 'EOF'

# Azure deployment dependencies
gunicorn>=20.1.0
whitenoise>=6.0.0
psycopg2-binary>=2.9.0
python-decouple>=3.6
EOF

# Створіть .env.example для налаштувань
cat > .env.example << 'EOF'
# Django Configuration
DEBUG=True
SECRET_KEY=your-secret-key-here
ALLOWED_HOSTS=localhost,127.0.0.1,*.azurewebsites.net

# Database (SQLite for dev, PostgreSQL for prod)
DATABASE_URL=sqlite:///db.sqlite3

# Azure Configuration (for production)
AZURE_STORAGE_ACCOUNT_NAME=your_storage_account
AZURE_STORAGE_ACCOUNT_KEY=your_storage_key

# Security
CSRF_TRUSTED_ORIGINS=https://*.azurewebsites.net
EOF

# Комміт змін
git add .
git commit -m "Enhanced Django template for Azure deployment

- Added comprehensive README with setup instructions
- Created Azure deployment configuration
- Added startup script for App Service
- Enhanced requirements.txt for Azure
- Added environment configuration examples
- Created documentation structure

Ready for Azure DevOps CI/CD setup"

git push origin main
```

---

## Частина 3: Створення Azure DevOps організації

### Крок 3.1: Створення організації та проекту

1. **Перейдіть на Azure DevOps**:
   ```
   https://dev.azure.com
   ```

2. **Створіть організацію**:
   - **"New organization"**
   - **Organization name**: `django-template-devops` (або `ваше-ім'я-devops`)
   - **Region**: `Central US` або найближчий
   - **Погодьтеся з умовами** та натисніть **"Continue"**

3. **Створіть проект**:
   - **Project name**: `Django-Template-Azure`
   - **Description**: `Django template project with GitHub integration and Azure deployment`
   - **Visibility**: `Private` (рекомендовано)
   - **Work item process**: `Agile` 
   - **Version control**: `Git`
   - **"Create project"**

### Крок 3.2: Налаштування Service Connections

#### GitHub Service Connection:

1. **Підключення GitHub**:
   - **Project Settings** (⚙️ внизу ліворуч)
   - **Service connections**
   - **"New service connection"** → **GitHub** → **Next**
   
2. **Авторизація**:
   - **Grant authorization**: Оберіть **"GitHub App"** (найбезпечніший)
   - Авторизуйтеся в GitHub
   - **Service connection name**: `github-django-template`
   - **Description**: `Connection to Django template repository`
   - ✅ **Grant access permission to all pipelines**
   - **"Save"**

#### Azure Service Connection:

3. **Підключення Azure**:
   - **"New service connection"** → **Azure Resource Manager** → **Next**
   - **Authentication method**: `Service principal (automatic)`
   - **Scope level**: `Subscription`
   - Оберіть **вашу Azure subscription**
   - **Resource group**: Залиште порожнім (створимо автоматично)
   - **Service connection name**: `azure-production`
   - **Description**: `Azure subscription for Django app deployment`
   - ✅ **Grant access permission to all pipelines**
   - **"Save"**

---

## Частина 4: Створення Azure DevOps Pipeline

### Крок 4.1: Створення Pipeline

1. **Створення нового Pipeline**:
   - **Pipelines** → **Pipelines** → **"New pipeline"**
   - **Where is your code?** → **GitHub**
   - Авторизуйтеся та оберіть ваш репозиторій `django-template-codespace-github`
   - **Configure your pipeline** → **"Starter pipeline"**

### Крок 4.2: Azure Pipeline YAML

Замініть вміст на наступний YAML:

```yaml
# Azure DevOps Pipeline for Django Template
# Automated build, test, and deployment to Azure App Service

name: Django-Template-CI-CD-$(Date:yyyyMMdd)$(Rev:.r)

trigger:
  branches:
    include:
    - main
    - develop
    - feature/*
  paths:
    exclude:
    - README.md
    - docs/**
    - "*.md"

pr:
  branches:
    include:
    - main
    - develop

variables:
  # Build Configuration
  pythonVersion: '3.11'
  vmImageName: 'ubuntu-latest'
  
  # Azure Configuration
  azureServiceConnection: 'azure-production'
  resourceGroupName: 'rg-django-template'
  location: 'East US'
  
  # Environment-specific variables
  ${{ if eq(variables['Build.SourceBranchName'], 'main') }}:
    environmentName: 'production'
    webAppName: 'django-template-prod'
    appServiceSku: 'B1'
  ${{ elseif eq(variables['Build.SourceBranchName'], 'develop') }}:
    environmentName: 'staging'
    webAppName: 'django-template-staging'
    appServiceSku: 'F1'
  ${{ else }}:
    environmentName: 'development'
    webAppName: 'django-template-dev-$(Build.BuildId)'
    appServiceSku: 'F1'

stages:
- stage: Validate
  displayName: 'Code Quality & Security'
  jobs:
  - job: CodeQuality
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: UsePythonVersion@0
      inputs:
        versionSpec: '$(pythonVersion)'
      displayName: 'Use Python $(pythonVersion)'

    - script: |
        python -m venv venv
        source venv/bin/activate
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install flake8 bandit safety black isort
      displayName: 'Install dependencies and linting tools'

    - script: |
        source venv/bin/activate
        echo "🔍 Running code formatting check..."
        black --check --diff .
        echo "📝 Running import sorting check..."
        isort --check-only --diff .
        echo "🧹 Running linting..."
        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
      displayName: 'Code quality checks'

    - script: |
        source venv/bin/activate
        echo "🔒 Running security scan..."
        bandit -r . -f json -o bandit-report.json || true
        echo "🛡️ Checking for known security vulnerabilities..."
        safety check --json --output safety-report.json || true
      displayName: 'Security scanning'

    - task: PublishTestResults@2
      condition: always()
      inputs:
        testResultsFormat: 'JUnit'
        testResultsFiles: '**/test-results.xml'
        failTaskOnFailedTests: false
      displayName: 'Publish security scan results'

- stage: Build
  displayName: 'Build Application'
  dependsOn: Validate
  jobs:
  - job: BuildJob
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: UsePythonVersion@0
      inputs:
        versionSpec: '$(pythonVersion)'
      displayName: 'Use Python $(pythonVersion)'

    - script: |
        echo "🐍 Setting up Python environment..."
        python -m venv venv
        source venv/bin/activate
        python -m pip install --upgrade pip
        pip install -r requirements.txt
      displayName: 'Install Python dependencies'

    - script: |
        echo "🧪 Running Django tests..."
        source venv/bin/activate
        python manage.py test --verbosity=2 --keepdb
      displayName: 'Run Django tests'

    - script: |
        echo "✅ Running Django system checks..."
        source venv/bin/activate
        python manage.py check --deploy --fail-level WARNING
      displayName: 'Django deployment checks'

    - script: |
        echo "📦 Collecting static files..."
        source venv/bin/activate
        python manage.py collectstatic --noinput --clear
      displayName: 'Collect static files'

    - script: |
        echo "📋 Creating deployment package..."
        # Remove unnecessary files from deployment
        rm -rf venv/
        rm -rf .git/
        rm -rf __pycache__/
        find . -name "*.pyc" -delete
        find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
      displayName: 'Clean up deployment package'

    - task: ArchiveFiles@2
      displayName: 'Archive application files'
      inputs:
        rootFolderOrFile: '$(System.DefaultWorkingDirectory)'
        includeRootFolder: false
        archiveType: zip
        archiveFile: $(Build.ArtifactStagingDirectory)/django-app-$(Build.BuildId).zip
        replaceExistingArchive: true

    - task: PublishBuildArtifacts@1
      displayName: 'Publish build artifact'
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: 'django-app'
        publishLocation: 'Container'

- stage: DeployInfrastructure
  displayName: 'Deploy Azure Infrastructure'
  dependsOn: Build
  condition: and(succeeded(), or(eq(variables['Build.SourceBranchName'], 'main'), eq(variables['Build.SourceBranchName'], 'develop')))
  jobs:
  - job: DeployInfra
    pool:
      vmImage: $(vmImageName)
    steps:
    - task: AzureCLI@2
      displayName: 'Deploy Azure App Service'
      inputs:
        azureSubscription: $(azureServiceConnection)
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          echo "🏗️ Creating Azure infrastructure..."
          
          # Create resource group
          az group create --name $(resourceGroupName) --location "$(location)"
          
          # Create App Service Plan
          az appservice plan create \
            --name asp-$(webAppName) \
            --resource-group $(resourceGroupName) \
            --sku $(appServiceSku) \
            --is-linux
          
          # Create Web App
          az webapp create \
            --name $(webAppName) \
            --resource-group $(resourceGroupName) \
            --plan asp-$(webAppName) \
            --runtime "PYTHON|3.11"
          
          # Configure Web App settings
          az webapp config appsettings set \
            --name $(webAppName) \
            --resource-group $(resourceGroupName) \
            --settings \
              DJANGO_SETTINGS_MODULE="hello_world.settings" \
              DJANGO_DEBUG="False" \
              WEBSITE_HTTPLOGGING_RETENTION_DAYS="3" \
              SCM_DO_BUILD_DURING_DEPLOYMENT="true"

- stage: Deploy
  displayName: 'Deploy to Azure App Service'
  dependsOn: DeployInfrastructure
  condition: succeeded()
  jobs:
  - deployment: DeployApp
    pool:
      vmImage: $(vmImageName)
    environment: '$(environmentName)'
    strategy:
      runOnce:
        deploy:
          steps:
          - download: current
            artifact: django-app

          - task: AzureWebApp@1
            displayName: 'Deploy Django application'
            inputs:
              azureSubscription: $(azureServiceConnection)
              appType: 'webAppLinux'
              appName: $(webAppName)
              package: $(Pipeline.Workspace)/django-app/django-app-$(Build.BuildId).zip
              runtimeStack: 'PYTHON|3.11'
              startUpCommand: 'bash deploy/startup.sh'

          - task: AzureCLI@2
            displayName: 'Post-deployment verification'
            inputs:
              azureSubscription: $(azureServiceConnection)
              scriptType: 'bash'
              scriptLocation: 'inlineScript'
              inlineScript: |
                echo "🏥 Running post-deployment health check..."
                APP_URL="https://$(webAppName).azurewebsites.net"
                
                # Wait for app to start
                sleep 60
                
                # Health check
                HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL || echo "000")
                
                if [ "$HTTP_STATUS" -eq 200 ]; then
                  echo "✅ Health check passed! App is running at: $APP_URL"
                  echo "##vso[task.setvariable variable=APP_URL;isOutput=true]$APP_URL"
                else
                  echo "❌ Health check failed! HTTP Status: $HTTP_STATUS"
                  echo "🔍 Checking application logs..."
                  az webapp log tail --name $(webAppName) --resource-group $(resourceGroupName) --timeout 30
                  exit 1
                fi

- stage: PostDeploy
  displayName: 'Post-Deployment Tasks'
  dependsOn: Deploy
  condition: succeeded()
  jobs:
  - job: Notifications
    pool:
      vmImage: $(vmImageName)
    steps:
    - script: |
        echo "🎉 Deployment completed successfully!"
        echo "🌐 Application URL: https://$(webAppName).azurewebsites.net"
        echo "📊 Environment: $(environmentName)"
        echo "🏷️ Build: $(Build.BuildNumber)"
        
        # You can add Slack/Teams notifications here
        echo "📧 Sending notifications..."
        
      displayName: 'Send deployment notifications'
```

### Крок 4.3: Збереження та запуск Pipeline

1. **Збережіть Pipeline**:
   - У редакторі Azure DevOps натисніть **"Save and run"**
   - **Commit message**: `Add Azure DevOps CI/CD pipeline`
   - **Commit directly to the main branch**
   - **"Save and run"**

2. **Моніторинг виконання**:
   - Pipeline запуститься автоматично
   - Слідкуйте за прогресом у **Pipelines** → **Runs**

---

## Частина 5: Планування роботи в Azure Boards

### Крок 5.1: Налаштування Azure Boards

1. **Перейдіть до Boards**:
   - **Boards** → **Work items**

2. **Налаштування команди**:
   - **Project Settings** → **Teams** → **Default Team** → **Settings**
   - Додайте учасників (якщо є)

### Крок 5.2: Створення структури роботи

#### Epic 1: Project Foundation & Setup
```
Title: Django Template Project Foundation
Area Path: Django-Template-Azure
Iteration Path: Django-Template-Azure
Priority: 1
Value Area: Business
Business Value: 100
Effort: 30

Description:
Establish foundational Django project structure with GitHub integration and 
basic Azure deployment capability. This epic covers initial setup, 
configuration, and environment preparation.

Acceptance Criteria:
- ✅ Django template successfully customized
- ✅ GitHub repository properly configured
- ✅ Codespace development environment working
- ✅ Basic Azure deployment functional
- ✅ Documentation created and maintained
```

#### Epic 2: CI/CD Pipeline Implementation  
```
Title: Azure DevOps CI/CD Pipeline
Priority: 1
Value Area: Business  
Business Value: 90
Effort: 25

Description:
Implement comprehensive CI/CD pipeline using Azure DevOps for automated 
testing, building, and deployment to Azure App Service.

Acceptance Criteria:
- ✅ Automated build pipeline functional
- ✅ Test automation integrated
- ✅ Security scanning implemented
- ✅ Multi-environment deployment working
- ✅ Monitoring and notifications configured
```

#### Epic 3: Azure Infrastructure & Scaling
```
Title: Azure Infrastructure Optimization
Priority: 2
Value Area: Business
Business Value: 75
Effort: 20

Description:
Optimize Azure infrastructure for production workloads including database 
integration, monitoring, and scaling capabilities.

Acceptance Criteria:
- ✅ Production-grade infrastructure deployed
- ✅ Database integration completed
- ✅ Monitoring and alerting configured
- ✅ Auto-scaling implemented
- ✅ Security hardening applied
```

### Krок 5.3: Створення User Stories

#### Для Epic 1 - Project Foundation:

**Feature 1.1: GitHub Template Customization**
```
Title: As a developer, I need a customized Django template
Story Points: 8
Priority: 1
Sprint: Sprint 1

Description:
Customize the GitHub Django template to meet project requirements and 
prepare it for Azure deployment.

Acceptance Criteria:
- ✅ Django template forked/templated from GitHub
- ✅ Project structure enhanced for Azure
- ✅ Requirements.txt updated for production
- ✅ Environment configuration added
- ✅ README and documentation updated

Tasks:
- Fork/template Django repository
- Enhance project structure
- Add Azure deployment files
- Update configuration files
- Create documentation
```

**Feature 1.2: Development Environment Setup**
```
Title: As a developer, I need a robust development environment
Story Points: 5
Priority: 1
Sprint: Sprint 1

Description:
Set up GitHub Codespace and local development environment for efficient 
Django development.

Acceptance Criteria:
- ✅ GitHub Codespace properly configured
- ✅ DevContainer optimized for Django
- ✅ VS Code extensions included
- ✅ Port forwarding working
- ✅ Local development guide created

Tasks:
- Configure DevContainer
- Add VS Code extensions
- Set up port forwarding
- Test Codespace functionality
- Document setup process
```

**Feature 1.3: Basic Azure Deployment**
```
Title: As a team, we need basic Azure deployment capability
Story Points: 8
Priority: 2
Sprint: Sprint 1

Description:
Establish basic Azure App Service deployment for the Django application.

Acceptance Criteria:
- ✅ Azure App Service created
- ✅ Django app successfully deployed
- ✅ Static files serving working
- ✅ Database configured
- ✅ Application accessible via HTTPS

Tasks:
- Create Azure App Service
- Configure deployment settings
- Set up static files handling
- Configure database connection
- Test deployment functionality
```

#### Для Epic 2 - CI/CD Pipeline:

**Feature 2.1: Build Pipeline**
```
Title: As a DevOps engineer, I need automated build pipeline
Story Points: 10
Priority: 1
Sprint: Sprint 2

Description:
Create automated build pipeline that handles code quality, testing, and 
artifact creation.

Acceptance Criteria:
- ✅ Azure DevOps pipeline created
- ✅ Python dependencies installation automated
- ✅ Django tests running automatically
- ✅ Code quality checks implemented
- ✅ Build artifacts generated

Tasks:
- Create Azure DevOps pipeline YAML
- Configure Python environment
- Add Django test execution
- Implement code quality checks
- Set up artifact generation
```

**Feature 2.2: Deployment Automation**
```
Title: As a DevOps engineer, I need automated deployment
Story Points: 12
Priority: 1
Sprint: Sprint 2

Description:
Implement automated deployment to Azure App Service with environment 
management and rollback capabilities.

Acceptance Criteria:
- ✅ Automated deployment to Azure
- ✅ Environment-specific configurations
- ✅ Blue-green deployment strategy
- ✅ Rollback mechanism implemented
- ✅ Post-deployment verification

Tasks:
- Configure Azure deployment tasks
- Set up environment management
- Implement deployment strategies
- Add rollback capabilities
- Create verification scripts
```

**Feature 2.3: Security & Quality Gates**
```
Title: As a security engineer, I need security scanning in pipeline
Story Points: 6
Priority: 2
Sprint: Sprint 2

Description:
Integrate security scanning and quality gates into the CI/CD pipeline.

Acceptance Criteria:
- ✅ Security vulnerability scanning
- ✅ Code quality gates
- ✅ Dependency checking
- ✅ SAST tools integrated
- ✅ Pipeline fails on critical issues

Tasks:
- Add Bandit security scanning
- Integrate Safety dependency checks
- Configure quality gates
- Set up failure thresholds
- Create security reports
```

### Крок 5.4: Створення Sprint планів

**Sprint 1 (Тиждень 1): Foundation**
```
Sprint Goal: Establish working Django project with basic Azure deployment

Capacity: 20 Story Points
Duration: 1 week

Planned Work:
- Feature 1.1: GitHub Template Customization (8 SP)
- Feature 1.2: Development Environment Setup (5 SP)
- Feature 1.3: Basic Azure Deployment (7 SP)

Success Criteria:
- Django app running in Codespace
- Basic Azure deployment working
- Documentation updated
```

**Sprint 2 (Тиждень 2): CI/CD Pipeline**
```
Sprint Goal: Implement complete CI/CD pipeline with automated deployment

Capacity: 25 Story Points
Duration: 1 week

Planned Work:
- Feature 2.1: Build Pipeline (10 SP)
- Feature 2.2: Deployment Automation (12 SP)
- Feature 2.3: Security & Quality Gates (3 SP) - partial

Success Criteria:
- Automated build working
- Deployment pipeline functional
- Code quality checks active
```

**Sprint 3 (Тиждень 3): Infrastructure & Polish**
```
Sprint Goal: Optimize infrastructure and complete security implementation

Capacity: 22 Story Points
Duration: 1 week

Planned Work:
- Feature 2.3: Security & Quality Gates (remaining 3 SP)
- Epic 3 features: Database, Monitoring, Scaling (19 SP)

Success Criteria:
- Production
