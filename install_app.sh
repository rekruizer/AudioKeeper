#!/bin/bash

echo "🎧 AudioKeeper - Установка приложения"
echo "======================================"

# Находим последнее собранное приложение
LATEST_APP=$(find ~/Library/Developer/Xcode/DerivedData -name "AudioKeeper.app" -type d -exec stat -f "%m %N" {} \; | sort -nr | head -1 | cut -d' ' -f2-)

if [ -z "$LATEST_APP" ]; then
    echo "❌ Приложение AudioKeeper.app не найдено!"
    echo "💡 Сначала соберите приложение в Xcode (Cmd + R)"
    exit 1
fi

echo "📍 Найдено приложение: $LATEST_APP"
echo "📏 Размер: $(du -sh "$LATEST_APP" | cut -f1)"

# Проверяем, есть ли уже приложение в Applications
if [ -d "/Applications/AudioKeeper.app" ]; then
    echo "⚠️  Приложение уже установлено в /Applications/"
    read -p "Заменить существующее приложение? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Установка отменена"
        exit 0
    fi
    echo "🗑️  Удаляем старое приложение..."
    rm -rf "/Applications/AudioKeeper.app"
fi

# Копируем приложение
echo "📦 Копируем приложение в /Applications/..."
cp -R "$LATEST_APP" "/Applications/"

if [ $? -eq 0 ]; then
    echo "✅ Приложение успешно установлено!"
    echo ""
    echo "🎯 Что дальше:"
    echo "1. Откройте /Applications/AudioKeeper.app"
    echo "2. Или найдите иконку наушников в строке меню"
    echo "3. Настройте предпочитаемые аудиоустройства"
    echo ""
    echo "💡 Для автозапуска:"
    echo "   System Settings → General → Login Items → Добавьте AudioKeeper"
else
    echo "❌ Ошибка при установке приложения"
    exit 1
fi
