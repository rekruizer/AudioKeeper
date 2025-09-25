#!/bin/bash

# Функция для установки приложений через Homebrew с автоматическим добавлением в Launchpad
# Добавьте эту функцию в ваш .zshrc или .bash_profile

function brew_install_launchpad() {
    local app_name="$1"
    
    if [ -z "$app_name" ]; then
        echo "Использование: brew_install_launchpad название_приложения"
        return 1
    fi
    
    echo "🚀 Устанавливаю $app_name через Homebrew Cask..."
    
    # Устанавливаем приложение
    brew install --cask "$app_name"
    
    if [ $? -eq 0 ]; then
        echo "✅ Установка завершена"
        
        # Проверяем, где установилось приложение
        local home_apps="$HOME/Applications/$app_name.app"
        local system_apps="/Applications/$app_name.app"
        
        if [ -d "$home_apps" ]; then
            echo "📁 Приложение найдено в ~/Applications, перемещаю в /Applications..."
            sudo mv "$home_apps" "/Applications/"
            
            if [ $? -eq 0 ]; then
                echo "✅ $app_name успешно перемещен в /Applications"
                # Обновляем Dock для отображения в Launchpad
                killall Dock 2>/dev/null
                echo "🎉 $app_name теперь доступен в Launchpad!"
            else
                echo "❌ Ошибка при перемещении $app_name"
            fi
            
        elif [ -d "$system_apps" ]; then
            echo "✅ $app_name уже находится в /Applications и доступен в Launchpad"
            
        else
            echo "⚠️  Приложение $app_name не найдено в стандартных папках"
            echo "Проверьте установку командой: brew list --cask | grep $app_name"
        fi
        
    else
        echo "❌ Ошибка при установке $app_name"
        return 1
    fi
}

# Алиас для удобства
alias binstall='brew_install_launchpad'

echo "Функция brew_install_launchpad готова к использованию!"
echo "Использование: brew_install_launchpad название_приложения"
echo "Или: binstall название_приложения"