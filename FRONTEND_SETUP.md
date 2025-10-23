# 🎨 Настройка фронтенда на GitHub Pages

## 🎯 План развертывания

### Бекенд (HTTPS обязательно):
- **Railway** - https://your-app.railway.app
- **Render** - https://your-app.onrender.com  
- **Heroku** - https://your-app.herokuapp.com
- **VPS + домен** - https://yourdomain.com

### Фронтенд (GitHub Pages):
- **GitHub Pages** - https://yourusername.github.io/bal-bot-frontend

## 🚀 Быстрый старт с Railway (Рекомендуется)

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
# Сгенерируйте SECRET_KEY
python scripts/generate_secret.py

# Установите переменные
railway variables set TELEGRAM_BOT_TOKEN=your_bot_token
railway variables set SECRET_KEY=your_generated_secret
railway variables set WEBHOOK_URL=https://your-app.railway.app
railway variables set MINI_APP_URL=https://yourusername.github.io/bal-bot-frontend
```

### 5. Разверните:
```bash
railway up
```

### 6. Получите URL:
```bash
railway domain
```

## 📱 Настройка GitHub Pages для фронтенда

### 1. Создайте репозиторий для фронтенда:
```bash
# Создайте новый репозиторий на GitHub
# Название: bal-bot-frontend
```

### 2. Клонируйте и настройте:
```bash
git clone https://github.com/yourusername/bal-bot-frontend.git
cd bal-bot-frontend
```

### 3. Создайте базовую структуру:
```
bal-bot-frontend/
├── index.html
├── style.css
├── script.js
└── README.md
```

### 4. Настройте GitHub Pages:
1. Перейдите в Settings репозитория
2. Найдите раздел "Pages"
3. Выберите источник: "Deploy from a branch"
4. Выберите ветку: "main"
5. Нажмите "Save"

### 5. Ваш фронтенд будет доступен по адресу:
```
https://yourusername.github.io/bal-bot-frontend
```

## 🔗 Интеграция фронтенда с бекендом

### В вашем фронтенде (script.js):
```javascript
// URL вашего бекенда
const API_URL = 'https://your-app.railway.app';

// Функция для отправки данных анкеты
async function submitForm(formData) {
    try {
        const response = await fetch(`${API_URL}/api/form-data/`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                user_id: getUserId(), // Получить из Telegram
                form_data: formData,
                status: 'draft'
            })
        });
        
        if (response.ok) {
            console.log('Анкета сохранена!');
        }
    } catch (error) {
        console.error('Ошибка:', error);
    }
}
```

## 📋 Полная последовательность действий

### Шаг 1: Настройка бекенда
```bash
# В папке backend
./scripts/setup_env.sh
nano .env  # Заполните переменные

# Разверните на Railway
railway login
railway init
railway variables set TELEGRAM_BOT_TOKEN=your_token
railway variables set SECRET_KEY=your_secret
railway up
```

### Шаг 2: Создание Telegram бота
1. Найдите @BotFather в Telegram
2. Отправьте `/newbot`
3. Следуйте инструкциям
4. Получите токен
5. Добавьте токен в Railway переменные

### Шаг 3: Настройка webhook
```bash
# После развертывания бекенда
curl "https://your-app.railway.app/telegram/set-webhook"
```

### Шаг 4: Создание фронтенда
```bash
# Создайте репозиторий на GitHub
# Название: bal-bot-frontend
git clone https://github.com/yourusername/bal-bot-frontend.git
cd bal-bot-frontend

# Создайте файлы фронтенда
# Настройте GitHub Pages
```

### Шаг 5: Обновление переменных
```bash
# В Railway
railway variables set MINI_APP_URL=https://yourusername.github.io/bal-bot-frontend
```

## 🎯 Итоговая архитектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Telegram Bot  │    │  GitHub Pages   │    │   Railway App   │
│                 │    │   (Frontend)    │    │   (Backend)     │
│  /start command │───▶│  Mini App UI   │───▶│  FastAPI + DB  │
│  WebApp button  │    │  Form handling │    │  Webhook handler│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 💰 Стоимость

- **Railway**: $5/месяц (бесплатный план доступен)
- **GitHub Pages**: Бесплатно
- **Telegram Bot**: Бесплатно
- **Итого**: $0-5/месяц

## 🔧 Полезные команды

```bash
# Настройка переменных
./scripts/setup_env.sh

# Генерация SECRET_KEY
python scripts/generate_secret.py

# Проверка Railway статуса
railway status

# Просмотр логов Railway
railway logs

# Обновление переменных
railway variables set KEY=value
```

## 🚨 Устранение неполадок

### Проблема: Railway не запускается
```bash
railway logs
railway status
```

### Проблема: GitHub Pages не работает
1. Проверьте настройки в Settings → Pages
2. Убедитесь, что файл index.html существует
3. Проверьте ветку (должна быть main)

### Проблема: Telegram webhook не работает
```bash
curl "https://your-app.railway.app/telegram/webhook-info"
```
