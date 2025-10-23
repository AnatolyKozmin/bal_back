# 🌐 Настройка HTTPS для Bal Bot Backend

## 🎯 Варианты развертывания с HTTPS

### 1. 🖥️ VPS с доменом (Рекомендуется)

#### Провайдеры VPS:
- **DigitalOcean** - $5/месяц
- **Linode** - $5/месяц  
- **Vultr** - $3.50/месяц
- **Hetzner** - €3.29/месяц
- **Timeweb** - от 200₽/месяц

#### Шаги:
1. **Купите VPS** (Ubuntu 20.04+)
2. **Купите домен** (например, balbot.xyz)
3. **Настройте DNS** записи:
   ```
   A    balbot.xyz        -> IP_ВАШЕГО_СЕРВЕРА
   A    api.balbot.xyz    -> IP_ВАШЕГО_СЕРВЕРА
   ```
4. **Разверните бекенд** на сервере
5. **Настройте SSL** с Let's Encrypt

### 2. ☁️ Облачные платформы

#### Railway (Простой вариант):
```bash
# Установите Railway CLI
npm install -g @railway/cli

# Войдите в аккаунт
railway login

# Разверните проект
railway deploy
```

#### Render:
1. Подключите GitHub репозиторий
2. Выберите "Web Service"
3. Настройте переменные окружения
4. Получите HTTPS URL автоматически

#### Heroku:
```bash
# Установите Heroku CLI
# Создайте приложение
heroku create your-app-name

# Настройте переменные
heroku config:set TELEGRAM_BOT_TOKEN=your_token
heroku config:set SECRET_KEY=your_secret

# Разверните
git push heroku main
```

### 3. 🐳 Docker с Nginx + SSL

#### Настройка Nginx с SSL:
```nginx
server {
    listen 80;
    server_name yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com;

    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;

    location / {
        proxy_pass http://app:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## 🔧 Автоматическая настройка SSL

### С Let's Encrypt:
```bash
# Установите Certbot
sudo apt install certbot python3-certbot-nginx

# Получите сертификат
sudo certbot --nginx -d yourdomain.com

# Автообновление
sudo crontab -e
# Добавьте: 0 12 * * * /usr/bin/certbot renew --quiet
```

## 📋 Пошаговая инструкция для VPS

### Шаг 1: Покупка VPS и домена
1. Зарегистрируйтесь на DigitalOcean/Linode
2. Создайте VPS (Ubuntu 20.04, 1GB RAM)
3. Купите домен (например, на Namecheap/GoDaddy)

### Шаг 2: Настройка DNS
```
A    yourdomain.com     -> IP_СЕРВЕРА
A    api.yourdomain.com -> IP_СЕРВЕРА
```

### Шаг 3: Подключение к серверу
```bash
ssh root@YOUR_SERVER_IP
```

### Шаг 4: Установка Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

### Шаг 5: Клонирование проекта
```bash
git clone <your-repo-url>
cd backend
```

### Шаг 6: Настройка переменных
```bash
cp env.docker .env
nano .env
```

Заполните:
```env
TELEGRAM_BOT_TOKEN=your_bot_token
WEBHOOK_URL=https://yourdomain.com
SECRET_KEY=your_generated_secret
MINI_APP_URL=https://yourdomain.com/mini-app
```

### Шаг 7: Развертывание
```bash
make deploy
```

### Шаг 8: Настройка SSL
```bash
sudo apt install nginx certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

## 🚀 Быстрый старт с Railway

### 1. Установите Railway CLI:
```bash
npm install -g @railway/cli
```

### 2. Войдите в аккаунт:
```bash
railway login
```

### 3. Создайте проект:
```bash
railway init
```

### 4. Настройте переменные:
```bash
railway variables set TELEGRAM_BOT_TOKEN=your_token
railway variables set SECRET_KEY=your_secret
railway variables set WEBHOOK_URL=https://your-app.railway.app
```

### 5. Разверните:
```bash
railway up
```

## 💰 Сравнение вариантов

| Вариант | Стоимость | Сложность | HTTPS | Домен |
|---------|-----------|-----------|-------|-------|
| VPS + домен | $5-10/мес | Средняя | ✅ | ✅ |
| Railway | $5/мес | Низкая | ✅ | ✅ |
| Render | $7/мес | Низкая | ✅ | ✅ |
| Heroku | $7/мес | Низкая | ✅ | ✅ |

## 🎯 Рекомендация

Для вашего случая рекомендую **Railway** или **Render** - они:
- Автоматически предоставляют HTTPS
- Простая настройка
- Низкая стоимость
- Хорошая производительность
