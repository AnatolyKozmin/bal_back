# 🚀 Быстрый старт Bal Bot Backend

## 📋 Минимальные требования

- Docker и Docker Compose
- Telegram Bot Token
- Домен (для webhook)

## ⚡ Быстрый запуск

### 1. Клонирование и настройка
```bash
git clone <your-repo-url>
cd backend
cp env.docker .env
```

### 2. Настройка переменных
Отредактируйте `.env`:
```env
TELEGRAM_BOT_TOKEN=your_bot_token_here
WEBHOOK_URL=https://yourdomain.com
SECRET_KEY=your_secret_key_here
MINI_APP_URL=https://yourdomain.com/mini-app
```

### 3. Запуск
```bash
make deploy
```

### 4. Проверка
```bash
# Проверка статуса
make status

# Запуск тестов
make test

# Просмотр логов
make logs
```

## 🔧 Основные команды

```bash
# Полное развертывание
make deploy

# Остановка
make down

# Перезапуск
make restart

# Миграции
make migrate

# Тесты
make test

# Логи
make logs
```

## 🌐 Доступ к приложению

- **API**: http://localhost:8000
- **Документация**: http://localhost:8000/docs
- **Telegram Webhook**: http://localhost:8000/telegram/webhook

## 🤖 Настройка Telegram бота

```bash
# Установка webhook
curl "https://yourdomain.com/telegram/set-webhook"

# Проверка webhook
curl "https://yourdomain.com/telegram/webhook-info"
```

## 📊 Мониторинг

```bash
# Статус контейнеров
docker-compose ps

# Использование ресурсов
docker stats

# Логи приложения
docker-compose logs -f app
```

## 🆘 Устранение неполадок

### Контейнеры не запускаются
```bash
docker-compose logs
```

### База данных недоступна
```bash
docker-compose exec app python -c "from database import engine; print('DB OK')"
```

### Webhook не работает
```bash
curl "https://yourdomain.com/telegram/webhook-info"
```

## 📚 Полная документация

Смотрите [DEPLOYMENT.md](DEPLOYMENT.md) для подробного гайда по развертыванию на продакшн сервере.
