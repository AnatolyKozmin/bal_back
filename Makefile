# Makefile для управления Bal Bot Backend

.PHONY: help build up down restart logs test migrate deploy clean

# Показать справку
help:
	@echo "Доступные команды:"
	@echo "  build     - Собрать Docker образы"
	@echo "  up        - Запустить контейнеры"
	@echo "  down      - Остановить контейнеры"
	@echo "  restart   - Перезапустить контейнеры"
	@echo "  logs      - Показать логи"
	@echo "  test      - Запустить тесты"
	@echo "  migrate   - Применить миграции"
	@echo "  deploy    - Полное развертывание"
	@echo "  clean     - Очистить неиспользуемые ресурсы"
	@echo ""
	@echo "Настройка:"
	@echo "  setup     - Настроить переменные окружения"
	@echo "  secret    - Сгенерировать SECRET_KEY"
	@echo "  webhook   - Установить Telegram webhook"
	@echo ""
	@echo "Railway:"
	@echo "  railway   - Развернуть на Railway"
	@echo "  status    - Показать статус Railway"

# Собрать образы
build:
	docker-compose build --no-cache

# Запустить контейнеры
up:
	docker-compose up -d

# Остановить контейнеры
down:
	docker-compose down

# Перезапустить контейнеры
restart:
	docker-compose restart

# Показать логи
logs:
	docker-compose logs -f

# Запустить тесты
test:
	./scripts/test.sh

# Применить миграции
migrate:
	./scripts/migrate.sh

# Полное развертывание
deploy:
	./scripts/deploy.sh

# Очистить неиспользуемые ресурсы
clean:
	docker system prune -f
	docker volume prune -f

# Показать статус
status:
	docker-compose ps

# Подключиться к контейнеру приложения
shell:
	docker-compose exec app bash

# Подключиться к базе данных
db:
	docker-compose exec postgres psql -U bal_bot_user -d bal_bot_db

# Настройка переменных окружения
setup:
	./scripts/setup_env.sh

# Генерация SECRET_KEY
secret:
	python scripts/generate_secret.py

# Установка Telegram webhook
webhook:
	@echo "Установка webhook..."
	@read -p "Введите URL вашего бекенда: " url; \
	curl "$$url/telegram/set-webhook"

# Развертывание на Railway
railway:
	@echo "Развертывание на Railway..."
	@if ! command -v railway &> /dev/null; then \
		echo "Установите Railway CLI: npm install -g @railway/cli"; \
		exit 1; \
	fi
	railway login
	railway init
	railway up

# Статус Railway
status:
	@if command -v railway &> /dev/null; then \
		railway status; \
	else \
		echo "Railway CLI не установлен"; \
	fi
