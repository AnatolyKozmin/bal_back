# 🖥️ Полная настройка на VPS с доменом

## 🎯 Архитектура

```
yourdomain.com          # Фронтенд (Nginx)
yourdomain.com/api      # Бекенд (FastAPI)
yourdomain.com/admin    # Админка (опционально)
```

## 📋 Пошаговая настройка

### 1. 🖥️ Подготовка VPS

#### Требования:
- **Ubuntu 20.04+** или **CentOS 8+**
- **1GB RAM** минимум
- **20GB SSD** минимум
- **Домен** настроен на IP сервера

#### Подключение к серверу:
```bash
ssh root@YOUR_SERVER_IP
```

### 2. 🔧 Установка системных зависимостей

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Установка Nginx
sudo apt install nginx -y

# Установка Certbot для SSL
sudo apt install certbot python3-certbot-nginx -y
```

### 3. 📁 Настройка проекта

```bash
# Создание директории
mkdir -p /var/www/bal-bot
cd /var/www/bal-bot

# Клонирование репозитория
git clone <your-repo-url> backend
cd backend

# Настройка переменных
cp env.docker .env
nano .env
```

### 4. 🔧 Настройка переменных окружения

```env
# В .env файле
TELEGRAM_BOT_TOKEN=your_bot_token_here
WEBHOOK_URL=https://yourdomain.com/api
SECRET_KEY=your_generated_secret
MINI_APP_URL=https://yourdomain.com

# База данных
DATABASE_URL=postgresql+asyncpg://bal_bot_user:bal_bot_password@postgres:5432/bal_bot_db
```

### 5. 🐳 Запуск бекенда

```bash
# Сборка и запуск
docker-compose build
docker-compose up -d

# Применение миграций
./scripts/migrate.sh

# Проверка статуса
docker-compose ps
```

### 6. 🌐 Настройка Nginx

#### Создание конфигурации:
```bash
sudo nano /etc/nginx/sites-available/bal-bot
```

#### Конфигурация Nginx:
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    # Фронтенд (статичные файлы)
    location / {
        root /var/www/bal-bot/frontend;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # Бекенд API
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Telegram webhook
    location /telegram/ {
        proxy_pass http://localhost:8000/telegram/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Активация сайта:
```bash
sudo ln -s /etc/nginx/sites-available/bal-bot /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 7. 🔒 Настройка SSL

```bash
# Получение SSL сертификата
sudo certbot --nginx -d yourdomain.com

# Автообновление
sudo crontab -e
# Добавьте: 0 12 * * * /usr/bin/certbot renew --quiet
```

### 8. 📱 Настройка фронтенда

#### Создание директории:
```bash
mkdir -p /var/www/bal-bot/frontend
cd /var/www/bal-bot/frontend
```

#### Создание базового index.html:
```html
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bal Bot - Анкета для билетов</title>
    <link rel="stylesheet" href="style.css">
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
</head>
<body>
    <div class="app">
        <header class="header">
            <h1>🎫 Анкета для билетов</h1>
            <div class="progress-bar">
                <div class="progress" id="progress"></div>
            </div>
        </header>
        
        <main class="main">
            <div id="app-content">
                <!-- Контент приложения -->
            </div>
        </main>
    </div>
    
    <script src="script.js"></script>
</body>
</html>
```

### 9. 🤖 Настройка Telegram webhook

```bash
# Установка webhook
curl "https://yourdomain.com/telegram/set-webhook"

# Проверка webhook
curl "https://yourdomain.com/telegram/webhook-info"
```

## 🎯 Итоговая структура

```
/var/www/bal-bot/
├── backend/                 # Бекенд (Docker)
│   ├── docker-compose.yml
│   ├── .env
│   └── ...
├── frontend/                # Фронтенд (статичные файлы)
│   ├── index.html
│   ├── style.css
│   ├── script.js
│   └── assets/
└── nginx/                   # Конфигурация Nginx
    └── bal-bot.conf
```

## 🔧 Обновленный docker-compose.yml

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    container_name: bal_bot_postgres
    environment:
      POSTGRES_DB: bal_bot_db
      POSTGRES_USER: bal_bot_user
      POSTGRES_PASSWORD: bal_bot_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - bal_bot_network
    restart: unless-stopped

  app:
    build: .
    container_name: bal_bot_app
    environment:
      - DATABASE_URL=postgresql+asyncpg://bal_bot_user:bal_bot_password@postgres:5432/bal_bot_db
      - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
      - WEBHOOK_URL=${WEBHOOK_URL}
      - SECRET_KEY=${SECRET_KEY}
      - MINI_APP_URL=${MINI_APP_URL}
    ports:
      - "8000:8000"
    depends_on:
      - postgres
    networks:
      - bal_bot_network
    restart: unless-stopped

volumes:
  postgres_data:

networks:
  bal_bot_network:
    driver: bridge
```

## 🚀 Преимущества VPS подхода

### ✅ Плюсы:
1. **Полный контроль** над сервером
2. **Один домен** для всего проекта
3. **Лучшая производительность** (нет ограничений GitHub Pages)
4. **Гибкость** в настройке
5. **Профессиональный вид** (yourdomain.com)
6. **Безопасность** (собственный SSL)

### ⚠️ Минусы:
1. **Сложнее настройка** (нужно управлять сервером)
2. **Больше ответственности** (обновления, мониторинг)
3. **Стоимость** ($5-10/месяц за VPS)

## 💰 Стоимость

- **VPS**: $5-10/месяц
- **Домен**: $10-15/год (уже есть)
- **SSL**: Бесплатно (Let's Encrypt)
- **Итого**: $5-10/месяц

## 🔧 Полезные команды

```bash
# Управление проектом
cd /var/www/bal-bot/backend
make deploy
make logs
make status

# Управление Nginx
sudo systemctl status nginx
sudo systemctl reload nginx
sudo nginx -t

# Управление SSL
sudo certbot certificates
sudo certbot renew --dry-run

# Мониторинг
docker-compose logs -f
sudo tail -f /var/log/nginx/access.log
```

## 🆘 Устранение неполадок

### Проблема: Nginx не работает
```bash
sudo nginx -t
sudo systemctl status nginx
sudo systemctl restart nginx
```

### Проблема: SSL не работает
```bash
sudo certbot certificates
sudo certbot renew
```

### Проблема: Бекенд не отвечает
```bash
docker-compose ps
docker-compose logs -f app
curl http://localhost:8000/
```

## 📊 Мониторинг

```bash
# Статус сервисов
sudo systemctl status nginx
docker-compose ps

# Логи
sudo tail -f /var/log/nginx/error.log
docker-compose logs -f

# Ресурсы
htop
df -h
free -h
```

Этот подход даст вам полный контроль над проектом и профессиональный вид!
