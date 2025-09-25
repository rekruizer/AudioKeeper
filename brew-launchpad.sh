#!/bin/bash

# Скрипт для установки приложений через Homebrew с автоматическим добавлением в Launchpad
# Использование: ./brew-launchpad.sh install --cask название_приложения

# Функция для перемещения приложения в /Applications
move_to_applications() {
    local app_name="$1"
    local home_apps="$HOME/Applications/$app_name.app"
    local system_apps="/Applications/$app_name.app"
    
    if [ -d "$home_apps" ]; then
        echo "Перемещаю $app_name из ~/Applications в /Applications..."
        sudo mv "$home_apps" "/Applications/"
        if [ $? -eq 0 ]; then
            echo "✅ $app_name успешно перемещен в /Applications"
            # Обновляем Dock для отображения в Launchpad
            killall Dock 2>/dev/null
        else
            echo "❌ Ошибка при перемещении $app_name"
        fi
    elif [ -d "$system_apps" ]; then
        echo "✅ $app_name уже находится в /Applications"
    else
        echo "⚠️  Приложение $app_name не найдено в ~/Applications или /Applications"
    fi
}

# Функция для установки через brew
brew_install() {
    echo "Устанавливаю приложение через Homebrew..."
    brew "$@"
    
    if [ $? -eq 0 ] && [[ "$*" == *"--cask"* ]]; then
        # Извлекаем название приложения из аргументов
        local app_name=""
        for arg in "$@"; do
            if [[ "$arg" != "--cask" && "$arg" != "install" ]]; then
                app_name="$arg"
                break
            fi
        done
        
        if [ -n "$app_name" ]; then
            echo "Проверяю расположение приложения $app_name..."
            move_to_applications "$app_name"
        fi
    fi
}

# Основная логика
if [ "$1" = "install" ] && [[ "$*" == *"--cask"* ]]; then
    brew_install "$@"
else
    # Если это не установка cask, просто передаем команду в brew
    brew "$@"
fi