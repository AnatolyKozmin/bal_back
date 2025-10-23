#!/usr/bin/env python3
"""
Скрипт для инициализации базы данных без Alembic
"""

import asyncio
import sys
import os

# Добавляем путь к проекту
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from database import create_tables

async def main():
    """Создание таблиц в базе данных"""
    try:
        print("🔄 Создание таблиц в базе данных...")
        await create_tables()
        print("✅ Таблицы успешно созданы!")
    except Exception as e:
        print(f"❌ Ошибка создания таблиц: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
