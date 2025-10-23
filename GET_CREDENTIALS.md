# 🔑 Получение всех необходимых данных

## 1. 🔐 SECRET_KEY

### Автоматическая генерация:
```bash
python scripts/generate_secret.py
```

### Ручная генерация:
```bash
# В Python
import secrets
import string
alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
secret = ''.join(secrets.choice(alphabet) for _ in range(32))
print(secret)
```

## 2. 🤖 TELEGRAM_BOT_TOKEN

### Шаги:
1. Откройте Telegram
2. Найдите @BotFather
3. Отправьте `/newbot`
4. Введите имя бота (например: "Bal Bot")
5. Введите username бота (например: "bal_bot_username")
6. Скопируйте полученный токен

### Пример токена:
```
1234567890:ABCdefGHIjklMNOpqrsTUVwxyz123456789
```

## 3. 🌐 WEBHOOK_URL

### Вариант A: Railway (Рекомендуется)
```bash
# Установите Railway CLI
npm install -g @railway/cli

# Войдите в аккаунт
railway login

# Создайте проект
railway init

# Разверните
railway up

# Получите URL
railway domain
```

**Результат**: `https://your-app.railway.app`

### Вариант B: Render
1. Зарегистрируйтесь на render.com
2. Подключите GitHub репозиторий
3. Выберите "Web Service"
4. Получите URL: `https://your-app.onrender.com`

### Вариант C: Heroku
```bash
# Установите Heroku CLI
# Создайте приложение
heroku create your-app-name

# Разверните
git push heroku main

# Получите URL: https://your-app-name.herokuapp.com
```

## 4. 📱 MINI_APP_URL

### Настройка GitHub Pages:
1. Создайте репозиторий на GitHub: `bal-bot-frontend`
2. Загрузите файлы фронтенда
3. В Settings → Pages выберите источник: "Deploy from a branch"
4. Выберите ветку: "main"
5. Получите URL: `https://yourusername.github.io/bal-bot-frontend`

## 5. 📝 Финальная настройка .env

```bash
# Запустите скрипт настройки
./scripts/setup_env.sh

# Отредактируйте .env файл
nano .env
```

### Заполните .env:
```env
# Токен от @BotFather
TELEGRAM_BOT_TOKEN=1234567890:ABCdefGHIjklMNOpqrsTUVwxyz123456789

# URL вашего бекенда (после развертывания)
WEBHOOK_URL=https://your-app.railway.app

# Сгенерированный SECRET_KEY
SECRET_KEY=SM3drObpBJzUkS89wzvRWMP5c9uSVonH

# URL вашего фронтенда на GitHub Pages
MINI_APP_URL=https://yourusername.github.io/bal-bot-frontend
```

## 🚀 Быстрый чек-лист

### ✅ Что нужно сделать:

1. **Создать Telegram бота:**
   - [ ] Найти @BotFather
   - [ ] Отправить `/newbot`
   - [ ] Получить токен

2. **Развернуть бекенд:**
   - [ ] Установить Railway CLI
   - [ ] Создать проект
   - [ ] Развернуть приложение
   - [ ] Получить URL

3. **Создать фронтенд:**
   - [ ] Создать GitHub репозиторий
   - [ ] Загрузить файлы фронтенда
   - [ ] Настроить GitHub Pages
   - [ ] Получить URL

4. **Настроить переменные:**
   - [ ] Запустить `./scripts/setup_env.sh`
   - [ ] Заполнить `.env` файл
   - [ ] Установить webhook

## 🔧 Полезные команды

```bash
# Настройка всех переменных
./scripts/setup_env.sh

# Генерация SECRET_KEY
python scripts/generate_secret.py

# Проверка Railway
railway status
railway logs

# Проверка webhook
curl "https://your-app.railway.app/telegram/webhook-info"

# Установка webhook
curl "https://your-app.railway.app/telegram/set-webhook"
```

## 💡 Советы

1. **Начните с Railway** - самый простой способ получить HTTPS
2. **Используйте GitHub Pages** для фронтенда - бесплатно и просто
3. **Сохраните все токены** в безопасном месте
4. **Тестируйте каждый шаг** перед переходом к следующему
