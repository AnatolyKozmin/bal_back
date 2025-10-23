#!/usr/bin/env python3
"""
Скрипт для генерации SECRET_KEY
"""

import secrets
import string

def generate_secret_key(length=32):
    """Генерирует безопасный SECRET_KEY"""
    alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
    return ''.join(secrets.choice(alphabet) for _ in range(length))

if __name__ == "__main__":
    secret_key = generate_secret_key(32)
    print(f"🔐 Ваш SECRET_KEY: {secret_key}")
    print(f"\n📝 Добавьте в .env файл:")
    print(f"SECRET_KEY={secret_key}")
