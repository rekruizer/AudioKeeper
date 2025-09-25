#!/bin/bash

# Скрипт для настройки удобных алиасов для Homebrew

echo "Настраиваю алиасы для Homebrew..."

# Добавляем алиасы в .zshrc (для zsh) или .bash_profile (для bash)
SHELL_CONFIG=""

if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
fi

if [ -n "$SHELL_CONFIG" ]; then
    # Проверяем, не добавлены ли уже алиасы
    if ! grep -q "alias binstall" "$SHELL_CONFIG"; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Homebrew aliases for Launchpad integration" >> "$SHELL_CONFIG"
        echo "alias binstall='brew install --cask'" >> "$SHELL_CONFIG"
        echo "alias bupdate='brew update && brew upgrade'" >> "$SHELL_CONFIG"
        echo "alias bclean='brew cleanup'" >> "$SHELL_CONFIG"
        echo "alias bsearch='brew search'" >> "$SHELL_CONFIG"
        echo "" >> "$SHELL_CONFIG"
        echo "# Функция для автоматического перемещения приложений в Launchpad" >> "$SHELL_CONFIG"
        echo "function move_to_launchpad() {" >> "$SHELL_CONFIG"
        echo "    local app_name=\"\$1\"" >> "$SHELL_CONFIG"
        echo "    if [ -d \"\$HOME/Applications/\$app_name.app\" ]; then" >> "$SHELL_CONFIG"
        echo "        echo \"Перемещаю \$app_name в /Applications...\"" >> "$SHELL_CONFIG"
        echo "        sudo mv \"\$HOME/Applications/\$app_name.app\" \"/Applications/\"" >> "$SHELL_CONFIG"
        echo "        killall Dock 2>/dev/null" >> "$SHELL_CONFIG"
        echo "        echo \"✅ \$app_name добавлен в Launchpad\"" >> "$SHELL_CONFIG"
        echo "    else" >> "$SHELL_CONFIG"
        echo "        echo \"⚠️  Приложение \$app_name не найдено в ~/Applications\"" >> "$SHELL_CONFIG"
        echo "    fi" >> "$SHELL_CONFIG"
        echo "}" >> "$SHELL_CONFIG"
        echo "" >> "$SHELL_CONFIG"
        echo "✅ Алиасы добавлены в $SHELL_CONFIG"
        echo "Перезапустите терминал или выполните: source $SHELL_CONFIG"
    else
        echo "✅ Алиасы уже настроены в $SHELL_CONFIG"
    fi
else
    echo "❌ Не найден файл конфигурации shell (.zshrc, .bash_profile или .bashrc)"
fi

echo ""
echo "Теперь вы можете использовать:"
echo "  binstall название_приложения  - для установки с автоматическим добавлением в Launchpad"
echo "  move_to_launchpad название_приложения  - для ручного перемещения в Launchpad"