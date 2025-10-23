# 🌐 Настройка одного домена для фронтенда и бекенда

## 🎯 Рекомендуемая архитектура

```
yourdomain.com          # Фронтенд (GitHub Pages)
api.yourdomain.com      # Бекенд (Railway/VPS)
```

## 📋 Пошаговая настройка

### 1. 🏠 Настройка фронтенда на GitHub Pages

#### Вариант A: Основной домен
1. Создайте репозиторий `bal-bot-frontend`
2. Загрузите файлы фронтенда
3. В Settings → Pages:
   - Source: "Deploy from a branch"
   - Branch: "main"
   - Custom domain: `yourdomain.com`
4. Настройте DNS:
   ```
   CNAME  yourdomain.com  -> yourusername.github.io
   ```

#### Вариант B: Поддомен
1. Создайте репозиторий `bal-bot-frontend`
2. Загрузите файлы фронтенда
3. В Settings → Pages:
   - Source: "Deploy from a branch"
   - Branch: "main"
   - Custom domain: `app.yourdomain.com`
4. Настройте DNS:
   ```
   CNAME  app.yourdomain.com  -> yourusername.github.io
   ```

### 2. 🔧 Настройка бекенда

#### Вариант A: Railway с поддоменом
```bash
# Разверните на Railway
railway login
railway init
railway up

# Получите URL
railway domain

# Настройте поддомен в Railway
railway domain add api.yourdomain.com
```

#### Вариант B: VPS с поддоменом
```bash
# На VPS
git clone <your-repo>
cd backend
make deploy

# Настройте Nginx
sudo nano /etc/nginx/sites-available/api.yourdomain.com
```

**Конфигурация Nginx:**
```nginx
server {
    listen 80;
    server_name api.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. 🔒 Настройка SSL сертификатов

#### Для GitHub Pages:
- SSL настраивается автоматически
- Просто добавьте домен в настройках

#### Для бекенда:
```bash
# Установите Certbot
sudo apt install certbot python3-certbot-nginx

# Получите сертификат
sudo certbot --nginx -d api.yourdomain.com
```

## 📝 Обновление переменных окружения

### В .env файле:
```env
# Бекенд URL
WEBHOOK_URL=https://api.yourdomain.com

# Фронтенд URL  
MINI_APP_URL=https://yourdomain.com

# Остальные переменные
TELEGRAM_BOT_TOKEN=your_bot_token
SECRET_KEY=your_secret_key
```

### В Railway:
```bash
railway variables set WEBHOOK_URL=https://api.yourdomain.com
railway variables set MINI_APP_URL=https://yourdomain.com
```

## 🔧 Настройка DNS записей

### В панели управления доменом:
```
A     yourdomain.com        -> IP_GITHUB_PAGES
CNAME api.yourdomain.com    -> your-app.railway.app
```

### Или для VPS:
```
A     yourdomain.com        -> IP_GITHUB_PAGES  
A     api.yourdomain.com    -> IP_VPS
```

## 🎯 Итоговая архитектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Telegram Bot  │    │  yourdomain.com │    │ api.yourdomain.com│
│                 │    │   (Frontend)    │    │   (Backend)     │
│  /start command │───▶│  Mini App UI   │───▶│  FastAPI + DB  │
│  WebApp button  │    │  GitHub Pages  │    │  Railway/VPS   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 💰 Стоимость

- **Домен**: $10-15/год (уже есть у вас)
- **GitHub Pages**: Бесплатно
- **Railway**: $0-5/месяц
- **Итого**: $0-5/месяц

## 🚀 Преимущества одного домена

1. **SEO**: Лучше для поисковых систем
2. **Брендинг**: Единый домен для проекта
3. **SSL**: Один сертификат для всех поддоменов
4. **Удобство**: Легче запомнить URL
5. **Профессиональность**: Выглядит как полноценный продукт

## 🔧 Полезные команды

```bash
# Проверка DNS
nslookup yourdomain.com
nslookup api.yourdomain.com

# Проверка SSL
curl -I https://yourdomain.com
curl -I https://api.yourdomain.com

# Проверка webhook
curl "https://api.yourdomain.com/telegram/webhook-info"
```

## 🆘 Устранение неполадок

### Проблема: Домен не работает
1. Проверьте DNS записи
2. Подождите 24-48 часов для распространения
3. Проверьте настройки в панели управления доменом

### Проблема: SSL не работает
1. Проверьте сертификаты: `curl -I https://yourdomain.com`
2. Обновите сертификаты: `sudo certbot renew`
3. Проверьте настройки Nginx

### Проблема: Webhook не работает
1. Проверьте URL: `curl "https://api.yourdomain.com/telegram/webhook-info"`
2. Установите webhook: `curl "https://api.yourdomain.com/telegram/set-webhook"`
3. Проверьте логи: `railway logs`
