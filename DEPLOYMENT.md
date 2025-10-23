# 🚀 Гайд по развертыванию Bal Bot Backend

Полное руководство по развертыванию вашего телеграм бота на удаленном сервере.

## 📋 Предварительные требования

### На сервере должно быть установлено:
- **Ubuntu 20.04+** или **CentOS 8+**
- **Docker** (версия 20.10+)
- **Docker Compose** (версия 2.0+)
- **Git**
- **Nginx** (для проксирования)
- **SSL сертификат** (Let's Encrypt)

## 🔧 Шаг 1: Подготовка сервера

### 1.1 Обновление системы
```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# CentOS/RHEL
sudo yum update -y
```

### 1.2 Установка Docker
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# CentOS/RHEL
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

### 1.3 Установка Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### 1.4 Установка Nginx
```bash
# Ubuntu/Debian
sudo apt install nginx -y

# CentOS/RHEL
sudo yum install nginx -y
```

## 📁 Шаг 2: Клонирование проекта

```bash
# Создаем директорию для проекта
mkdir -p /opt/bal_bot
cd /opt/bal_bot

# Клонируем репозиторий
git clone <your-repo-url> backend
cd backend
```

## 🔐 Шаг 3: Настройка переменных окружения

### 3.1 Создание файла .env
```bash
cp env.docker .env
nano .env
```

### 3.2 Заполните переменные:
```env
# Telegram Bot
TELEGRAM_BOT_TOKEN=your_actual_bot_token_here
WEBHOOK_URL=https://yourdomain.com
SECRET_KEY=your_very_secure_secret_key_here
MINI_APP_URL=https://yourdomain.com/mini-app
```

## 🐳 Шаг 4: Настройка Docker

### 4.1 Сборка и запуск контейнеров
```bash
# Собираем образы
docker-compose build

# Запускаем в фоновом режиме
docker-compose up -d
```

### 4.2 Проверка статуса
```bash
docker-compose ps
```

## 🗄️ Шаг 5: Настройка базы данных

### 5.1 Применение миграций
```bash
# Создаем первую миграцию
./scripts/migrate.sh create "Initial migration"

# Применяем миграции
./scripts/migrate.sh
```

### 5.2 Проверка базы данных
```bash
# Подключаемся к PostgreSQL
docker-compose exec postgres psql -U bal_bot_user -d bal_bot_db

# Проверяем таблицы
\dt
```

## 🧪 Шаг 6: Тестирование

### 6.1 Запуск тестов
```bash
./scripts/test.sh
```

### 6.2 Проверка эндпоинтов
```bash
# Главная страница
curl http://localhost:8000/

# API документация
curl http://localhost:8000/docs

# Создание анкеты
curl -X POST "http://localhost:8000/api/form-data/" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 123456789,
    "form_data": {"name": "Test User"},
    "status": "draft"
  }'
```

## 🌐 Шаг 7: Настройка Nginx

### 7.1 Создание конфигурации Nginx
```bash
sudo nano /etc/nginx/sites-available/bal_bot
```

### 7.2 Конфигурация:
```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 7.3 Активация сайта
```bash
sudo ln -s /etc/nginx/sites-available/bal_bot /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 🔒 Шаг 8: Настройка SSL (Let's Encrypt)

### 8.1 Установка Certbot
```bash
# Ubuntu/Debian
sudo apt install certbot python3-certbot-nginx -y

# CentOS/RHEL
sudo yum install certbot python3-certbot-nginx -y
```

### 8.2 Получение SSL сертификата
```bash
sudo certbot --nginx -d yourdomain.com
```

## 🤖 Шаг 9: Настройка Telegram бота

### 9.1 Установка webhook
```bash
curl "https://yourdomain.com/telegram/set-webhook"
```

### 9.2 Проверка webhook
```bash
curl "https://yourdomain.com/telegram/webhook-info"
```

## 📊 Шаг 10: Мониторинг и логи

### 10.1 Просмотр логов
```bash
# Логи приложения
docker-compose logs -f app

# Логи базы данных
docker-compose logs -f postgres

# Логи Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 10.2 Мониторинг ресурсов
```bash
# Использование ресурсов
docker stats

# Статус контейнеров
docker-compose ps
```

## 🔄 Шаг 11: Обновление приложения

### 11.1 Обновление кода
```bash
cd /opt/bal_bot/backend
git pull origin main
```

### 11.2 Пересборка и перезапуск
```bash
./scripts/deploy.sh
```

## 🛠️ Полезные команды

### Управление контейнерами
```bash
# Запуск
docker-compose up -d

# Остановка
docker-compose down

# Перезапуск
docker-compose restart

# Просмотр логов
docker-compose logs -f
```

### Управление базой данных
```bash
# Создание миграции
./scripts/migrate.sh create "Описание миграции"

# Применение миграций
./scripts/migrate.sh

# Откат миграций
docker-compose exec app alembic downgrade -1
```

### Резервное копирование
```bash
# Создание бэкапа базы данных
docker-compose exec postgres pg_dump -U bal_bot_user bal_bot_db > backup.sql

# Восстановление из бэкапа
docker-compose exec -T postgres psql -U bal_bot_user bal_bot_db < backup.sql
```

## 🚨 Устранение неполадок

### Проблема: Контейнеры не запускаются
```bash
# Проверяем логи
docker-compose logs

# Проверяем статус
docker-compose ps
```

### Проблема: База данных недоступна
```bash
# Проверяем подключение
docker-compose exec app python -c "from database import engine; print('DB OK')"
```

### Проблема: Telegram webhook не работает
```bash
# Проверяем webhook
curl "https://yourdomain.com/telegram/webhook-info"

# Устанавливаем webhook заново
curl "https://yourdomain.com/telegram/set-webhook"
```

## 📈 Масштабирование

### Горизонтальное масштабирование
```yaml
# В docker-compose.yml
services:
  app:
    deploy:
      replicas: 3
```

### Настройка балансировщика нагрузки
```nginx
upstream app {
    server app_1:8000;
    server app_2:8000;
    server app_3:8000;
}
```

## 🔐 Безопасность

### 1. Настройка файрвола
```bash
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

### 2. Регулярные обновления
```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Обновление Docker образов
docker-compose pull
docker-compose up -d
```

### 3. Мониторинг безопасности
```bash
# Проверка уязвимостей
docker scan bal_bot_app
```

## ✅ Проверочный список

- [ ] Docker и Docker Compose установлены
- [ ] Проект склонирован на сервер
- [ ] Переменные окружения настроены
- [ ] Контейнеры запущены
- [ ] Миграции применены
- [ ] Тесты пройдены
- [ ] Nginx настроен
- [ ] SSL сертификат получен
- [ ] Telegram webhook установлен
- [ ] Мониторинг настроен

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи: `docker-compose logs -f`
2. Проверьте статус: `docker-compose ps`
3. Проверьте конфигурацию: `nginx -t`
4. Проверьте webhook: `curl "https://yourdomain.com/telegram/webhook-info"`
