#!/bin/bash

# Скрипт для настройки домена REG.RU
echo "🌐 Настройка Bal Bot на домене REG.RU"

# Проверяем права root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Запустите с правами root: sudo ./scripts/setup_reg_ru.sh"
    exit 1
fi

# Получаем домен от пользователя
read -p "Введите ваш домен (например: mydomain.ru): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "❌ Домен не указан"
    exit 1
fi

echo "🚀 Настройка для домена: $DOMAIN"

# Обновляем систему
echo "📦 Обновление системы..."
apt update && apt upgrade -y

# Устанавливаем Docker
if ! command -v docker &> /dev/null; then
    echo "🐳 Установка Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    usermod -aG docker $USER
fi

# Устанавливаем Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "🐳 Установка Docker Compose..."
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Устанавливаем Nginx
if ! command -v nginx &> /dev/null; then
    echo "🌐 Установка Nginx..."
    apt install nginx -y
fi

# Устанавливаем Certbot
if ! command -v certbot &> /dev/null; then
    echo "🔒 Установка Certbot..."
    apt install certbot python3-certbot-nginx -y
fi

# Создаем директории
echo "📁 Создание директорий..."
mkdir -p /var/www/bal-bot/{frontend,backend,logs}

# Копируем проект
echo "📋 Копирование проекта..."
cp -r . /var/www/bal-bot/backend/
cd /var/www/bal-bot/backend

# Настраиваем переменные
if [ ! -f .env ]; then
    echo "⚙️ Настройка переменных окружения..."
    cp env.docker .env
    
    # Обновляем домен в .env
    sed -i "s/yourdomain.ru/$DOMAIN/g" .env
    sed -i "s/WEBHOOK_URL=https:\/\/yourdomain.ru\/api/WEBHOOK_URL=https:\/\/$DOMAIN\/api/" .env
    sed -i "s/MINI_APP_URL=https:\/\/yourdomain.ru/MINI_APP_URL=https:\/\/$DOMAIN/" .env
    
    echo "📝 Переменные настроены для домена: $DOMAIN"
    echo "🔧 Отредактируйте .env файл: nano /var/www/bal-bot/backend/.env"
fi

# Создаем конфигурацию Nginx
echo "🌐 Настройка Nginx..."
cat > /etc/nginx/sites-available/bal-bot << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    # Фронтенд
    location / {
        root /var/www/bal-bot/frontend;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }
    
    # API
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    # Telegram webhook
    location /telegram/ {
        proxy_pass http://localhost:8000/telegram/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Активируем сайт
ln -sf /etc/nginx/sites-available/bal-bot /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Проверяем конфигурацию
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

# Ждем запуска
echo "⏳ Ожидание запуска..."
sleep 15

# Применяем миграции
echo "🔄 Применение миграций..."
docker-compose -f docker-compose.vps.yml exec app alembic upgrade head

# Создаем базовый фронтенд
echo "📱 Создание фронтенда..."
cat > /var/www/bal-bot/frontend/index.html << EOF
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bal Bot - Анкета для билетов</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0; 
            padding: 20px; 
            background: #f5f5f5; 
        }
        .container { 
            max-width: 400px; 
            margin: 0 auto; 
            background: white; 
            padding: 20px; 
            border-radius: 10px; 
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { 
            text-align: center; 
            color: #007AFF; 
            margin-bottom: 20px;
        }
        .loading { 
            text-align: center; 
            color: #666; 
            font-size: 16px;
        }
        .status {
            background: #e8f5e8;
            border: 1px solid #4caf50;
            color: #2e7d32;
            padding: 10px;
            border-radius: 5px;
            margin-top: 20px;
        }
        .info {
            background: #e3f2fd;
            border: 1px solid #2196f3;
            color: #1565c0;
            padding: 10px;
            border-radius: 5px;
            margin-top: 10px;
            font-size: 14px;
        }
    </style>
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
</head>
<body>
    <div class="container">
        <h1>🎫 Bal Bot</h1>
        <div class="loading">Загрузка приложения...</div>
        <div class="status" id="status" style="display: none;">
            ✅ Приложение готово к работе!
        </div>
        <div class="info" id="info" style="display: none;">
            🌐 Домен: $DOMAIN<br>
            🔧 API: $DOMAIN/api<br>
            📱 Telegram Mini App активен
        </div>
    </div>
    <script>
        // Инициализация Telegram WebApp
        const tg = window.Telegram.WebApp;
        tg.ready();
        tg.expand();
        
        // Показываем статус
        setTimeout(() => {
            document.querySelector('.loading').style.display = 'none';
            document.getElementById('status').style.display = 'block';
            document.getElementById('info').style.display = 'block';
        }, 1000);
    </script>
</body>
</html>
EOF

echo ""
echo "✅ Настройка завершена!"
echo ""
echo "📋 Следующие шаги:"
echo "1. 🔧 Настройте DNS в REG.RU:"
echo "   - A-запись: @ -> IP_ВАШЕЙ_ВМ"
echo "   - A-запись: www -> IP_ВАШЕЙ_ВМ"
echo ""
echo "2. 📝 Настройте переменные:"
echo "   nano /var/www/bal-bot/backend/.env"
echo ""
echo "3. 🔒 Получите SSL сертификат:"
echo "   certbot --nginx -d $DOMAIN -d www.$DOMAIN"
echo ""
echo "4. 🤖 Установите webhook:"
echo "   curl 'https://$DOMAIN/telegram/set-webhook'"
echo ""
echo "🌐 Ваш сайт будет доступен по адресу: http://$DOMAIN"
echo "🔧 API будет доступен по адресу: http://$DOMAIN/api"
echo ""
echo "⏳ DNS изменения могут занять до 48 часов"
