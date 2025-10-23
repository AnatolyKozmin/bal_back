#!/usr/bin/env python3
"""
Скрипт для запуска Telegram бота в режиме polling
Используйте этот файл для тестирования бота локально
"""

import asyncio
import logging
from bot import main

if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    print("Запуск Telegram бота в режиме polling...")
    print("Для остановки нажмите Ctrl+C")
    
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print("\nБот остановлен")
