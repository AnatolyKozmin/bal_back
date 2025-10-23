# 🌐 Настройка домена REG.RU с виртуальной машиной

## 🎯 План настройки

```
yourdomain.ru          # Фронтенд (Nginx)
yourdomain.ru/api      # Бекенд (FastAPI)
yourdomain.ru/telegram # Webhook
```

## 📋 Пошаговая настройка

### 1. 🔧 Подготовка виртуальной машины

#### Подключение к VPS:
```bash
ssh root@YOUR_VPS_IP
```

#### Обновление системы:
```bash
apt update && apt upgrade -y
```

#### Установка необходимых пакетов:
```bash
# Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker $USER

# Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Nginx
apt install nginx -y

# Certbot для SSL
apt install certbot python3-certbot-nginx -y
```

### 2. 🌐 Настройка DNS в REG.RU

#### В панели управления REG.RU:

1. **Зайдите в панель управления** доменом
2. **Перейдите в раздел "DNS"**
3. **Добавьте A-записи:**

```
Тип: A
Имя: @
Значение: IP_ВАШЕЙ_ВМ
TTL: 3600

Тип: A  
Имя: www
Значение: IP_ВАШЕЙ_ВМ
TTL: 3600
```

#### Пример настроек:
```
@        A    IP_ВАШЕЙ_ВМ    3600
www      A    IP_ВАШЕЙ_ВМ    3600
```

### 3. 📁 Развертывание проекта

#### Клонирование проекта:
```bash
# Создаем директорию
mkdir -p /var/www/bal-bot
cd /var/www/bal-bot

# Клонируем репозиторий
git clone <your-repo-url> backend
cd backend

# Настраиваем переменные
cp env.docker .env
nano .env
```

#### Настройка .env файла:
```env
TELEGRAM_BOT_TOKEN=your_bot_token_here
WEBHOOK_URL=https://yourdomain.ru/api
SECRET_KEY=your_generated_secret
MINI_APP_URL=https://yourdomain.ru
DATABASE_URL=postgresql+asyncpg://bal_bot_user:bal_bot_password@postgres:5432/bal_bot_db
```

### 4. 🐳 Запуск бекенда

```bash
# Сборка и запуск
docker-compose -f docker-compose.vps.yml build
docker-compose -f docker-compose.vps.yml up -d

# Применение миграций
./scripts/migrate.sh

# Проверка статуса
docker-compose -f docker-compose.vps.yml ps
```

### 5. 🌐 Настройка Nginx

#### Создание конфигурации:
```bash
nano /etc/nginx/sites-available/bal-bot
```

#### Конфигурация Nginx:
```nginx
server {
    listen 80;
    server_name yourdomain.ru www.yourdomain.ru;
    
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
# Активируем сайт
ln -sf /etc/nginx/sites-available/bal-bot /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# Проверяем конфигурацию
nginx -t

# Перезапускаем Nginx
systemctl reload nginx
```

### 6. 📱 Создание фронтенда

```bash
# Создаем директорию для фронтенда
mkdir -p /var/www/bal-bot/frontend

# Создаем базовый index.html
cat > /var/www/bal-bot/frontend/index.html << 'EOF'
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
        }, 1000);
    </script>
</body>
</html>
EOF
```

### 7. 🔒 Настройка SSL сертификата

```bash
# Получаем SSL сертификат
certbot --nginx -d yourdomain.ru -d www.yourdomain.ru

# Проверяем автообновление
certbot renew --dry-run

# Настраиваем автообновление
crontab -e
# Добавьте строку:
# 0 12 * * * /usr/bin/certbot renew --quiet
```

### 8. 🤖 Настройка Telegram webhook

```bash
# Установка webhook
curl "https://yourdomain.ru/telegram/set-webhook"

# Проверка webhook
curl "https://yourdomain.ru/telegram/webhook-info"
```

## 🔧 Автоматический скрипт развертывания

Создайте файл `deploy_reg_ru.sh`:

```bash
#!/bin/bash

# Замените на ваш домен
DOMAIN="yourdomain.ru"

echo "🚀 Развертывание Bal Bot на REG.RU домене..."

# Обновляем систему
apt update && apt upgrade -y

# Устанавливаем зависимости
curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
apt install nginx certbot python3-certbot-nginx -y

# Создаем директории
mkdir -p /var/www/bal-bot/{frontend,backend,logs}

# Копируем проект
cp -r . /var/www/bal-bot/backend/
cd /var/www/bal-bot/backend

# Настраиваем переменные
if [ ! -f .env ]; then
    cp env.docker .env
    echo "📝 Настройте .env файл: nano /var/www/bal-bot/backend/.env"
fi

# Создаем конфигурацию Nginx
cat > /etc/nginx/sites-available/bal-bot << EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    
    location / {
        root /var/www/bal-bot/frontend;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }
    
    location /api/ {
        proxy_pass http://localhost:8000/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
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
nginx -t && systemctl reload nginx

# Запускаем бекенд
docker-compose -f docker-compose.vps.yml build
docker-compose -f docker-compose.vps.yml up -d

# Ждем запуска
sleep 15

# Применяем миграции
docker-compose -f docker-compose.vps.yml exec app alembic upgrade head

echo "✅ Развертывание завершено!"
echo "🌐 Сайт: https://$DOMAIN"
echo "🔧 API: https://$DOMAIN/api"
echo "📝 Настройте .env файл и получите SSL сертификат"
```

## 📋 Чек-лист настройки

### ✅ DNS настройки в REG.RU:
- [ ] A-запись для @ (основной домен)
- [ ] A-запись для www
- [ ] TTL: 3600
- [ ] IP адрес вашей VPS

### ✅ На VPS:
- [ ] Docker установлен
- [ ] Nginx настроен
- [ ] Проект развернут
- [ ] SSL сертификат получен
- [ ] Webhook установлен

## 🔧 Полезные команды

```bash
# Проверка DNS
nslookup yourdomain.ru
dig yourdomain.ru

# Проверка статуса
systemctl status nginx
docker-compose -f docker-compose.vps.yml ps

# Логи
tail -f /var/log/nginx/access.log
docker-compose -f docker-compose.vps.yml logs -f

# Обновление проекта
cd /var/www/bal-bot/backend
git pull
docker-compose -f docker-compose.vps.yml build
docker-compose -f docker-compose.vps.yml up -d
```

## 🆘 Устранение неполадок

### Проблема: Домен не работает
1. Проверьте DNS записи в REG.RU
2. Подождите 24-48 часов
3. Проверьте: `nslookup yourdomain.ru`

### Проблема: SSL не работает
1. Проверьте: `certbot certificates`
2. Обновите: `certbot renew`
3. Проверьте Nginx: `nginx -t`

### Проблема: Бекенд не отвечает
1. Проверьте: `docker-compose -f docker-compose.vps.yml ps`
2. Логи: `docker-compose -f docker-compose.vps.yml logs -f`
3. Проверьте: `curl http://localhost:8000/`

Теперь у вас будет профессиональный сайт на вашем домене! 🚀
