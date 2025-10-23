#!/bin/bash

# Скрипт для развертывания на VPS
echo "🚀 Развертывание Bal Bot Backend на VPS..."

# Проверяем права root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Запустите скрипт с правами root: sudo ./scripts/deploy_vps.sh"
    exit 1
fi

# Обновляем систему
echo "📦 Обновление системы..."
apt update && apt upgrade -y

# Устанавливаем Docker если не установлен
if ! command -v docker &> /dev/null; then
    echo "🐳 Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
fi

# Устанавливаем Docker Compose если не установлен
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Установка Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Устанавливаем Nginx если не установлен
if ! command -v nginx &> /dev/null; then
    echo "🌐 Установка Nginx..."
    apt install nginx -y
fi

# Устанавливаем Certbot если не установлен
if ! command -v certbot &> /dev/null; then
    echo "🔒 Установка Certbot..."
    apt install certbot python3-certbot-nginx -y
fi

# Создаем директории
echo "📁 Создание директорий..."
mkdir -p /var/www/bal-bot/frontend
mkdir -p /var/www/bal-bot/backend
mkdir -p /var/www/bal-bot/logs

# Копируем файлы бекенда
echo "📋 Копирование файлов бекенда..."
cp -r . /var/www/bal-bot/backend/
cd /var/www/bal-bot/backend

# Настраиваем переменные окружения
if [ ! -f .env ]; then
    echo "⚙️ Настройка переменных окружения..."
    cp env.docker .env
    echo "📝 Отредактируйте файл .env: nano /var/www/bal-bot/backend/.env"
fi

# Создаем конфигурацию Nginx
echo "🌐 Настройка Nginx..."
cat > /etc/nginx/sites-available/bal-bot << 'EOF'
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
EOF

# Активируем сайт
ln -sf /etc/nginx/sites-available/bal-bot /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Проверяем конфигурацию Nginx
nginx -t
if [ $? -eq 0 ]; then
    systemctl reload nginx
    echo "✅ Nginx настроен"
else
    echo "❌ Ошибка в конфигурации Nginx"
    exit 1
fi

# Запускаем бекенд
echo "🐳 Запуск бекенда..."
docker-compose -f docker-compose.vps.yml build
docker-compose -f docker-compose.vps.yml up -d

# Ждем запуска базы данных
echo "⏳ Ожидание запуска базы данных..."
sleep 15

# Применяем миграции
echo "🔄 Применение миграций..."
docker-compose -f docker-compose.vps.yml exec app alembic upgrade head

# Создаем базовый фронтенд
echo "📱 Создание базового фронтенда..."
cat > /var/www/bal-bot/frontend/index.html << 'EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bal Bot - Анкета для билетов</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
        .container { max-width: 400px; margin: 0 auto; background: white; padding: 20px; border-radius: 10px; }
        h1 { text-align: center; color: #007AFF; }
        .loading { text-align: center; color: #666; }
    </style>
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
</head>
<body>
    <div class="container">
        <h1>🎫 Bal Bot</h1>
        <div class="loading">Загрузка приложения...</div>
    </div>
    <script>
        // Инициализация Telegram WebApp
        const tg = window.Telegram.WebApp;
        tg.ready();
        tg.expand();
        
        // Показываем что приложение работает
        document.querySelector('.loading').innerHTML = 'Приложение готово к работе!';
    </script>
</body>
</html>
EOF

echo "✅ Развертывание завершено!"
echo ""
echo "📋 Следующие шаги:"
echo "1. Отредактируйте .env файл: nano /var/www/bal-bot/backend/.env"
echo "2. Обновите домен в конфигурации Nginx: nano /etc/nginx/sites-available/bal-bot"
echo "3. Получите SSL сертификат: certbot --nginx -d yourdomain.com"
echo "4. Установите webhook: curl 'https://yourdomain.com/telegram/set-webhook'"
echo ""
echo "🌐 Ваш сайт будет доступен по адресу: http://yourdomain.com"
echo "🔧 API будет доступен по адресу: http://yourdomain.com/api"
