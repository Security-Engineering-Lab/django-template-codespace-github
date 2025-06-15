

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

