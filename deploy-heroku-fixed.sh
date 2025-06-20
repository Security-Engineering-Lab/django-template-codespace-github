#!/bin/bash

echo "🚀 Deploying Django to Heroku (FREE alternative to Azure)..."

# Перевіряємо чи встановлено Heroku CLI
if ! command -v heroku &> /dev/null; then
    echo "📦 Installing Heroku CLI..."
    curl https://cli-assets.heroku.com/install.sh | sh
fi

APP_NAME="django-template-$(date +%s)"

echo "📋 Configuration:"
echo "   App Name: $APP_NAME"
echo "   Platform: Heroku"
echo "   Cost: FREE"

# Створюємо Procfile для Heroku з правильними налаштуваннями
cat > Procfile << 'EOF'
web: gunicorn hello_world.wsgi --bind 0.0.0.0:$PORT --workers 1 --timeout 120 --log-file -
release: python manage.py migrate
EOF

# Створюємо runtime.txt
echo "python-3.12.1" > runtime.txt

# Додаємо gunicorn до requirements.txt якщо його немає
if ! grep -q "gunicorn" requirements.txt; then
    echo "gunicorn>=21.2.0" >> requirements.txt
fi

# Створюємо .env файл для Heroku
cat > .env << 'EOF'
DEBUG=False
DJANGO_SETTINGS_MODULE=hello_world.settings
EOF

# Створюємо окремий файл налаштувань для Heroku
cat > hello_world/heroku_settings.py << 'EOF'
# Heroku-specific settings
import os
import dj_database_url
from .settings import *

# DEBUG from environment
DEBUG = os.getenv('DEBUG', 'False').lower() == 'true'

# Allowed hosts for Heroku - ВАЖЛИВО для IP mismatch
ALLOWED_HOSTS = [
    '.herokuapp.com',
    '.heroku.com',
    'localhost',
    '127.0.0.1',
    '0.0.0.0',
    '*'  # Тільки для розробки
]

# Trusted origins для CSRF
CSRF_TRUSTED_ORIGINS = [
    'https://*.herokuapp.com',
    'https://*.heroku.com',
]

# Database for Heroku (PostgreSQL)
if 'DATABASE_URL' in os.environ:
    DATABASES = {
        'default': dj_database_url.parse(
            os.environ.get('DATABASE_URL'),
            conn_max_age=600,
            conn_health_checks=True,
        )
    }

# Static files for Heroku
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# Media files
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Middleware для Heroku
MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',  # Для статичних файлів
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

# Security settings для production
if not DEBUG:
    # SSL/HTTPS налаштування
    SECURE_SSL_REDIRECT = True
    SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')
    SECURE_HSTS_SECONDS = 31536000
    SECURE_HSTS_INCLUDE_SUBDOMAINS = True
    SECURE_HSTS_PRELOAD = True
    
    # Session security
    SESSION_COOKIE_SECURE = True
    CSRF_COOKIE_SECURE = True
    
    # Content type sniffing
    SECURE_CONTENT_TYPE_NOSNIFF = True
    SECURE_BROWSER_XSS_FILTER = True
    X_FRAME_OPTIONS = 'DENY'

# Logging
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'verbose',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
            'propagate': False,
        },
    },
}
EOF

# Додаємо необхідні пакети
cat > requirements.txt << 'EOF'
asgiref~=3.8.1
Django~=5.0.8
django-browser-reload~=1.13.0
python-decouple~=3.8
sqlparse~=0.5.1
gunicorn>=21.2.0
whitenoise>=6.5.0
dj-database-url>=2.1.0
psycopg2-binary>=2.9.0
EOF

echo "🔐 Login to Heroku..."
echo "📝 Note: If you have MFA enabled, use browser login"
# Використовуємо browser login замість interactive для MFA
heroku login

echo "🏗️ Creating Heroku app..."
heroku create $APP_NAME

# Перевіряємо чи створився додаток
if [ $? -ne 0 ]; then
    echo "❌ Failed to create Heroku app. Please check your authentication."
    echo "💡 Try running: heroku auth:token"
    echo "💡 Or visit: https://dashboard.heroku.com/account"
    exit 1
fi

echo "📦 Setting up buildpacks..."
heroku buildpacks:set heroku/python --app $APP_NAME

echo "⚙️ Setting environment variables..."
heroku config:set DEBUG=False --app $APP_NAME
heroku config:set DJANGO_SETTINGS_MODULE=hello_world.heroku_settings --app $APP_NAME
heroku config:set PYTHONPATH=/app --app $APP_NAME
heroku config:set WEB_CONCURRENCY=1 --app $APP_NAME
# Отримуємо APP_URL для CSRF налаштувань
APP_URL="https://$APP_NAME.herokuapp.com"
heroku config:set HEROKU_APP_URL=$APP_URL --app $APP_NAME

echo "🗄️ Adding PostgreSQL database..."
# Використовуємо безкоштовний план postgres
heroku addons:create heroku-postgresql:essential-0 --app $APP_NAME || \
heroku addons:create heroku-postgresql:mini --app $APP_NAME || \
echo "⚠️ Could not add PostgreSQL addon. You may need to verify your account."

echo "📝 Preparing Git repository..."
if [ ! -d ".git" ]; then
    git init
    git add .
    git commit -m "Initial commit for Heroku deployment"
fi

echo "🚀 Deploying to Heroku..."
heroku git:remote --app $APP_NAME

# Додаємо всі файли та комітимо
git add .
git commit -m "Deploy to Heroku" || echo "No changes to commit"

# Перевіряємо чи існує remote
if git remote get-url heroku &> /dev/null; then
    echo "📤 Pushing to Heroku..."
    git push heroku main || git push heroku master
else
    echo "❌ Heroku remote not found. Adding manually..."
    git remote add heroku https://git.heroku.com/$APP_NAME.git
    git push heroku main || git push heroku master
fi

# Перевіряємо успішність деплою
if [ $? -eq 0 ]; then
    echo "🔧 Running database migrations..."
    heroku run python manage.py migrate --app $APP_NAME
    
    echo "📊 Collecting static files..."
    heroku run python manage.py collectstatic --noinput --app $APP_NAME
    
    echo "🔄 Restarting dyno..."
    heroku restart --app $APP_NAME
    
    # Перевіряємо здоров'я додатку
    echo "🏥 Health check..."
    sleep 10
    
    # Отримуємо URL додатку
    APP_URL="https://$APP_NAME.herokuapp.com"
    
    # Тестуємо доступність
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" $APP_URL || echo "000")
    
    echo ""
    echo "✅ Deployment completed successfully!"
    echo "🌐 Your Django app: $APP_URL"
    echo "📊 HTTP Status: $HTTP_STATUS"
    echo "💰 Cost: FREE (with limitations)"
    echo "🏷️ App Name: $APP_NAME"
    echo ""
    
    if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "301" ] || [ "$HTTP_STATUS" = "302" ]; then
        echo "🎉 App is running successfully!"
    else
        echo "⚠️ App might have issues. Check logs:"
        echo "   heroku logs --tail --app $APP_NAME"
    fi
    echo "📝 Useful commands:"
    echo "   View logs: heroku logs --tail --app $APP_NAME"
    echo "   Run shell: heroku run python manage.py shell --app $APP_NAME"
    echo "   Scale down: heroku ps:scale web=0 --app $APP_NAME"
    echo "   Delete app: heroku apps:destroy $APP_NAME"
    echo "   Open app: heroku open --app $APP_NAME"
    echo "   Check dyno status: heroku ps --app $APP_NAME"
    echo ""
    echo "🔍 Next steps:"
    echo "   1. Visit your app at: $APP_URL"
    echo "   2. Check logs if needed: heroku logs --tail --app $APP_NAME"
    echo "   3. Set up custom domain (optional): heroku domains:add yourdomain.com --app $APP_NAME"
    echo ""
    echo "🐛 If you see 'IP address mismatch' error:"
    echo "   1. Wait 5-10 minutes for DNS propagation"
    echo "   2. Try accessing via: heroku open --app $APP_NAME"
    echo "   3. Check ALLOWED_HOSTS in settings"
    echo "   4. Restart app: heroku restart --app $APP_NAME"
else
    echo "❌ Deployment failed!"
    echo "📋 Troubleshooting:"
    echo "   1. Check Heroku status: https://status.heroku.com"
    echo "   2. Verify authentication: heroku auth:whoami"
    echo "   3. Check logs: heroku logs --app $APP_NAME"
    echo "   4. Verify app exists: heroku apps:info $APP_NAME"
fi



