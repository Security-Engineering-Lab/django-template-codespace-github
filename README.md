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

