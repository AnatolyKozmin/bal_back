# Bal Bot Backend

Бекенд для телеграм мини-апп с анкетой для билетов.

## Технологии

- **FastAPI** - асинхронный веб-фреймворк
- **SQLAlchemy** - асинхронный ORM для работы с базой данных
- **Alembic** - миграции базы данных
- **Aiogram** - асинхронная библиотека для Telegram бота
- **Pydantic** - валидация данных
- **AsyncPG** - асинхронный драйвер PostgreSQL
- **aiosqlite** - асинхронный драйвер SQLite

## Установка и запуск

### 🐳 Запуск с Docker (Рекомендуется)

```bash
# Клонируйте репозиторий
git clone <your-repo-url>
cd backend

# Настройте переменные окружения
cp env.docker .env
nano .env  # Заполните реальные значения

# Запустите с Docker Compose
make deploy
# или
docker-compose up -d
```

### 🐍 Локальная установка

```bash
# Активируйте виртуальное окружение
source venv/bin/activate

# Установите зависимости
pip install -r requirements.txt
```

### 2. Настройка переменных окружения

Создайте файл `.env` в корне проекта:

```env
# Для SQLite (по умолчанию)
DATABASE_URL=sqlite+aiosqlite:///./bal_bot.db

# Для PostgreSQL
# DATABASE_URL=postgresql+asyncpg://user:password@localhost/bal_bot_db

TELEGRAM_BOT_TOKEN=your_bot_token_here
WEBHOOK_URL=https://yourdomain.com
SECRET_KEY=your_secret_key_here
MINI_APP_URL=https://yourdomain.com/mini-app
```

### 3. Настройка базы данных

```bash
# Создайте первую миграцию
alembic revision --autogenerate -m "Initial migration"

# Примените миграции
alembic upgrade head
```

### 4. Запуск приложения

```bash
# Запуск в режиме разработки
python main.py

# Или с uvicorn
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## API Endpoints

### Основные эндпоинты

- `GET /` - Главная страница
- `GET /docs` - Swagger документация
- `GET /redoc` - ReDoc документация

### API для анкет

- `POST /api/form-data/` - Создать новую анкету
- `GET /api/form-data/{user_id}` - Получить все анкеты пользователя
- `GET /api/form-data/{user_id}/latest` - Получить последнюю анкету пользователя
- `PUT /api/form-data/{form_id}` - Обновить анкету
- `DELETE /api/form-data/{form_id}` - Удалить анкету
- `GET /api/form-data/` - Получить все анкеты (для админов)

### Telegram Webhook

- `POST /telegram/webhook` - Обработчик вебхуков от Telegram
- `GET /telegram/set-webhook` - Установить вебхук
- `GET /telegram/delete-webhook` - Удалить вебхук
- `GET /telegram/webhook-info` - Информация о вебхуке

## Структура данных

### Формат JSON для анкеты

```json
{
  "user_id": 123456789,
  "form_data": {
    "name": "Иван Иванов",
    "email": "ivan@example.com",
    "phone": "+7 (999) 123-45-67",
    "ticket_type": "VIP",
    "quantity": 2,
    "preferences": {
      "dietary_requirements": "Вегетарианец",
      "accessibility_needs": "Нет"
    }
  },
  "status": "draft"
}
```

## Настройка Telegram бота

### 1. Создание бота

1. Найдите @BotFather в Telegram
2. Отправьте команду `/newbot`
3. Следуйте инструкциям для создания бота
4. Получите токен бота

### 2. Настройка вебхука

После запуска сервера установите вебхук:

```bash
curl "https://yourdomain.com/telegram/set-webhook"
```

### 3. Команды бота

- `/start` - Начать работу с ботом (показывает кнопку для мини-апп)
- `/help` - Справка по командам

## Разработка

### Структура проекта

```
backend/
├── main.py              # Основной файл приложения
├── api.py               # FastAPI эндпоинты
├── bot.py               # Telegram бот (polling режим)
├── webhook.py           # Telegram бот (webhook режим)
├── database.py          # Модели SQLAlchemy
├── schemas.py           # Pydantic схемы
├── config.py            # Конфигурация
├── alembic/             # Миграции базы данных
├── requirements.txt     # Зависимости
└── README.md           # Документация
```

## Особенности асинхронной архитектуры

### Преимущества асинхронной работы:

- **Высокая производительность** - обработка множества запросов одновременно
- **Эффективное использование ресурсов** - неблокирующие операции с БД
- **Масштабируемость** - поддержка большого количества пользователей
- **Современный подход** - использование async/await паттернов

### Асинхронные компоненты:

- **FastAPI** - все эндпоинты работают асинхронно
- **SQLAlchemy** - асинхронные запросы к базе данных
- **Aiogram** - асинхронная обработка сообщений Telegram
- **База данных** - неблокирующие операции с подключениями

## 🐳 Docker команды

### Основные команды
```bash
# Сборка и запуск
make deploy

# Остановка
make down

# Просмотр логов
make logs

# Запуск тестов
make test

# Применение миграций
make migrate

# Просмотр статуса
make status
```

### Ручное управление
```bash
# Сборка образов
docker-compose build

# Запуск контейнеров
docker-compose up -d

# Остановка контейнеров
docker-compose down

# Просмотр логов
docker-compose logs -f

# Подключение к контейнеру
docker-compose exec app bash

# Подключение к базе данных
docker-compose exec postgres psql -U bal_bot_user -d bal_bot_db
```
