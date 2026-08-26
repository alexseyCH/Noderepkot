#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root"
    echo "Этот скрипт должен быть запущен с правами root"
    exit 1
fi

TEMP_DIR=$(mktemp -d)

cd /tmp || cd / || exit 1

if [ -d "/opt/Noderepkot" ]; then
    echo "Removing existing Noderepkot installation..."
    echo "Удаление существующей установки Noderepkot..."
    rm -rf /opt/Noderepkot
fi

if ! command -v curl &> /dev/null; then
    echo "Installing curl..."
    echo "Установка curl..."
    if command -v apt-get &> /dev/null; then
        apt-get update -y && apt-get install -y curl
    elif command -v yum &> /dev/null; then
        yum install -y curl
    elif command -v dnf &> /dev/null; then
        dnf install -y curl
    else
        echo "Failed to install curl. Please install it manually."
        echo "Не удалось установить curl. Пожалуйста, установите его вручную."
        exit 1
    fi
fi

cd "$TEMP_DIR" || exit 1

echo "Downloading Noderepkot..."
echo "Загрузка Noderepkot..."
curl -L https://github.com/alexseyCH/Noderepkot/archive/refs/heads/main.zip -o Noderepkot.zip

if [ ! -f Noderepkot.zip ]; then
    echo "Error: Failed to download archive"
    echo "Ошибка: Не удалось загрузить архив"
    rm -rf "$TEMP_DIR"
    exit 1
fi

if ! command -v unzip &> /dev/null; then
    echo "Installing unzip..."
    echo "Установка unzip..."
    if command -v apt-get &> /dev/null; then
        echo "Updating package list..."
        echo "Обновление списка пакетов..."
        apt-get update -y && apt-get install -y unzip
    elif command -v yum &> /dev/null; then
        yum install -y unzip
    elif command -v dnf &> /dev/null; then
        dnf install -y unzip
    else
        echo "Failed to install unzip. Please install it manually."
        echo "Не удалось установить unzip. Пожалуйста, установите его вручную."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
fi

echo "Extracting files..."
echo "Распаковка файлов..."
unzip -q Noderepkot.zip

if [ ! -d "Noderepkot-main" ]; then
    echo "Error: Failed to extract archive"
    echo "Ошибка: Не удалось распаковать архив"
    rm -rf "$TEMP_DIR"
    exit 1
fi

mkdir -p /opt/Noderepkot

echo "Installing Noderepkot to /opt/Noderepkot..."
echo "Установка Noderepkot в /opt/Noderepkot..."
cp -r Noderepkot-main/* /opt/Noderepkot/

if [ ! -f "/opt/Noderepkot/Noderepkot.sh" ]; then
    echo "Error: Failed to copy files"
    echo "Ошибка: Не удалось скопировать файлы"
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "Setting permissions..."
echo "Установка прав доступа..."

if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
elif [ -n "$USER" ] && [ "$USER" != "root" ]; then
    REAL_USER="$USER"
else
    REAL_USER=$(getent passwd 2>/dev/null | awk -F: '$3 >= 1000 && $3 < 65534 && $1 != "nobody" {print $1; exit}')
    if [ -z "$REAL_USER" ]; then
        REAL_USER="root"
    fi
fi

chown -R "$REAL_USER:$REAL_USER" /opt/Noderepkot
chmod -R 755 /opt/Noderepkot
chmod +x /opt/Noderepkot/Noderepkot.sh
chmod +x /opt/Noderepkot/scripts/common/*.sh
chmod +x /opt/Noderepkot/scripts/remnawave/*.sh
chmod +x /opt/Noderepkot/scripts/remnanode/*.sh
chmod +x /opt/Noderepkot/scripts/backups/*.sh

rm -rf "$TEMP_DIR"

cd /opt/Noderepkot || exit 1

echo "Starting Noderepkot..."
echo "Запуск Noderepkot..."
bash /opt/Noderepkot/Noderepkot.sh "$@"

