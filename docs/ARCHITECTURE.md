


### Повна структура проекту
```
secureweb-capstone/
├── .devcontainer/
│   └── devcontainer.json
├── .github/
│   └── workflows/
│       └── ci.yml
├── secureweb/
│   ├── __init__.py
│   ├── settings.py
│   ├── urls.py
│   ├── wsgi.py
│   └── celery.py
├── accounts/
│   ├── __init__.py
│   ├── models.py
│   ├── views.py
│   ├── forms.py
│   ├── urls.py
│   └── admin.py
├── security/
│   ├── __init__.py
│   ├── middleware.py
│   ├── monitoring.py
│   ├── views.py
│   ├── urls.py
│   └── utils.py
├── templates/
│   ├── base.html
│   ├── home.html
│   ├── accounts/
│   │   ├── login.html
│   │   └── dashboard.html
│   └── security/
│       └── dashboard.html
├── static/
│   ├── css/
│   │   └── dashboard.css
│   ├── js/
│   │   └── dashboard.js
│   └── images/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── docs/
│   ├── README.md
│   ├── ARCHITECTURE.md
│   └── DEPLOYMENT.md
├── requirements.txt
├── .env.example
├── .gitignore
├── manage.py
├── Dockerfile
├── docker-compose.yml
├── azure-pipelines.yml
└── README.md
```

