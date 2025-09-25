# 🍺 Отправка AudioKeeper в официальный Homebrew Cask

## 📋 Пошаговая инструкция

### Шаг 1: Форкнуть репозиторий Homebrew Cask

1. Перейдите на https://github.com/Homebrew/homebrew-cask
2. Нажмите кнопку **"Fork"** (справа вверху)
3. Дождитесь создания форка

### Шаг 2: Клонировать ваш форк

```bash
cd ~/Desktop  # или любая другая папка
git clone https://github.com/rekruizer/homebrew-cask.git
cd homebrew-cask
```

### Шаг 3: Добавить формулу

```bash
# Скопировать формулу в папку Casks
cp /Users/rekruizer/Xcode/AudioKeeper/audiokeeper.rb Casks/audiokeeper.rb
```

### Шаг 4: Проверить формулу

```bash
# Проверить синтаксис
brew audit --cask audiokeeper

# Проверить установку
brew install --cask audiokeeper
```

### Шаг 5: Создать Pull Request

```bash
# Создать ветку
git checkout -b add-audiokeeper

# Добавить файл
git add Casks/audiokeeper.rb
git commit -m "Add AudioKeeper cask

AudioKeeper is a macOS menu bar application that automatically 
maintains your preferred audio input/output devices.

- Automatically switches to preferred devices when connected
- Remembers device preferences
- Clean and simple interface
- Open source and free

Closes #XXXXX"  # замените на номер issue, если есть

# Отправить
git push origin add-audiokeeper
```

### Шаг 6: Создать Pull Request на GitHub

1. Перейдите на https://github.com/rekruizer/homebrew-cask
2. Нажмите **"Compare & pull request"**
3. Заполните описание:
   - **Title**: `Add AudioKeeper cask`
   - **Description**: 
     ```
     AudioKeeper is a macOS menu bar application that automatically 
     maintains your preferred audio input/output devices.
     
     Features:
     - Automatically switches to preferred devices when connected
     - Remembers device preferences  
     - Clean and simple interface
     - Open source and free
     
     The app is signed and ready for distribution.
     ```

### Шаг 7: Дождаться ревью

- Модераторы проверят формулу
- Могут попросить внести изменения
- После одобрения формула будет добавлена в официальный Homebrew

## ✅ Требования для Homebrew Cask

- [x] Приложение подписанное (или с инструкциями для unsigned)
- [x] Стабильная версия
- [x] Публичный репозиторий
- [x] Правильный SHA256 хеш
- [x] Корректный URL для скачивания
- [x] Описание приложения
- [x] Домашняя страница

## 🔗 Полезные ссылки

- [Homebrew Cask Cookbook](https://docs.brew.sh/Cask-Cookbook)
- [Contributing to Homebrew Cask](https://github.com/Homebrew/homebrew-cask/blob/master/CONTRIBUTING.md)
- [Cask Style Guide](https://github.com/Homebrew/homebrew-cask/blob/master/doc/cask_language_reference/README.md)

## 📝 Готовая формула

Файл `audiokeeper.rb` уже готов и содержит:
- Версию v1.0.12
- Правильный SHA256 хеш
- Корректный URL
- Описание и домашнюю страницу
- Настройки для очистки данных

**Готово к отправке!** 🚀
