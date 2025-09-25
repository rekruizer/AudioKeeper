# Homebrew Cask Setup для AudioKeeper

## 🍺 Настройка Homebrew Cask

### 1. Получение SHA256 хеша

После каждого релиза нужно обновить SHA256 хеш в `audiokeeper.rb`:

```bash
# Скачайте DMG файл из релиза
curl -L -o AudioKeeper-1.0.11.dmg "https://github.com/rekruizer/AudioKeeper/releases/download/v1.0.11/AudioKeeper-1.0.11.dmg"

# Получите SHA256 хеш
shasum -a 256 AudioKeeper-1.0.11.dmg

# Скопируйте полученный хеш и замените PLACEHOLDER_SHA256 в audiokeeper.rb
```

### 2. Обновление формулы

1. Обновите версию в `audiokeeper.rb`
2. Замените `PLACEHOLDER_SHA256` на реальный хеш
3. Зафиксируйте изменения:

```bash
git add audiokeeper.rb
git commit -m "Update Homebrew Cask to v1.0.11"
git push origin main
```

### 3. Тестирование локально

```bash
# Установите Homebrew (если не установлен)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Установите tap (ваш репозиторий)
brew tap rekruizer/audiokeeper

# Установите приложение
brew install --cask audiokeeper
```

### 4. Отправка в официальный Homebrew

Для публичного доступа через `brew install audiokeeper`:

1. **Форкните репозиторий**: https://github.com/Homebrew/homebrew-cask
2. **Скопируйте формулу** в `Casks/audiokeeper.rb`
3. **Создайте Pull Request** с описанием приложения

### 5. Автоматизация

Можно добавить в GitHub Actions автоматическое обновление SHA256:

```yaml
- name: Update Homebrew Cask SHA256
  run: |
    DMG_SHA256=$(shasum -a 256 *.dmg | cut -d' ' -f1)
    sed -i "s/PLACEHOLDER_SHA256/$DMG_SHA256/g" audiokeeper.rb
```

## 📋 Текущий статус

- ✅ Формула создана: `audiokeeper.rb`
- ✅ Версия обновлена: v1.0.11
- ⏳ SHA256 нужно получить из релиза
- ⏳ Тестирование локально
- ⏳ Отправка в официальный Homebrew

## 🔗 Полезные ссылки

- [Homebrew Cask Documentation](https://docs.brew.sh/Cask-Cookbook)
- [Creating a Cask](https://docs.brew.sh/Adding-Software-to-Homebrew)
- [Homebrew Cask Repository](https://github.com/Homebrew/homebrew-cask)
