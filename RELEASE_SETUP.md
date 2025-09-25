# 🚀 Настройка релизов AudioKeeper

## Быстрый старт

### 1. Создание первого релиза

```bash
# 1. Соберите приложение
cd AudioKeeper
./Scripts/build_release.sh

# 2. Создайте DMG
./Scripts/create_dmg.sh

# 3. Создайте тег и пушните
git tag v1.0.0
git push origin v1.0.0
```

### 2. GitHub Actions автоматически создаст релиз

После пушения тега, GitHub Actions:
- Соберет приложение
- Создаст DMG
- Загрузит в GitHub Releases

## 🔐 Настройка подписи кода (Notarization)

### Получение сертификатов Apple

1. **Зарегистрируйтесь в Apple Developer Program** ($99/год)
2. **Создайте сертификаты:**
   - Developer ID Application (для подписи приложения)
   - Developer ID Installer (для подписи DMG)

### Настройка GitHub Secrets

Добавьте в Settings → Secrets and variables → Actions:

```
APPLE_CERTIFICATE: [base64 encoded .p12 file]
APPLE_CERTIFICATE_PASSWORD: [password for .p12 file]
APPLE_TEAM_ID: [your team ID]
APPLE_USERNAME: [your Apple ID]
APPLE_APP_PASSWORD: [app-specific password]
```

### Экспорт сертификата

```bash
# Экспортируйте .p12 файл из Keychain Access
# Затем конвертируйте в base64:
base64 -i certificate.p12 | pbcopy
```

## 📦 Создание релиза вручную

### Через GitHub UI

1. Перейдите в **Releases** → **Create a new release**
2. Выберите тег (например, `v1.0.0`)
3. Заполните описание изменений
4. Загрузите DMG файл
5. Нажмите **Publish release**

### Через командную строку

```bash
# Установите GitHub CLI
brew install gh

# Создайте релиз
gh release create v1.0.0 AudioKeeper-v1.0.0.dmg \
  --title "AudioKeeper v1.0.0" \
  --notes "First release of AudioKeeper"
```

## 🏷️ Управление версиями

### Семантическое версионирование

Используйте формат `MAJOR.MINOR.PATCH`:
- **MAJOR**: Критические изменения, несовместимые с предыдущими версиями
- **MINOR**: Новая функциональность, обратно совместимая
- **PATCH**: Исправления багов, обратно совместимые

### Примеры тегов

```bash
git tag v1.0.0    # Первый стабильный релиз
git tag v1.1.0    # Новая функция
git tag v1.1.1    # Исправление бага
git tag v2.0.0    # Критические изменения
```

## 📊 Аналитика релизов

### GitHub Insights

- Перейдите в **Insights** → **Releases**
- Просматривайте статистику скачиваний
- Анализируйте популярность версий

### Добавление бейджей в README

```markdown
![GitHub release (latest by date)](https://img.shields.io/github/v/release/rekruizer/AudioKeeper)
![GitHub downloads](https://img.shields.io/github/downloads/rekruizer/AudioKeeper/total)
```

## 🔄 Автоматические обновления

### В приложении

Добавьте проверку обновлений:

```swift
// Проверка новой версии
func checkForUpdates() {
    // Получить последний релиз с GitHub API
    // Сравнить с текущей версией
    // Показать уведомление о доступности обновления
}
```

### GitHub API

```bash
# Получить информацию о последнем релизе
curl https://api.github.com/repos/rekruizer/AudioKeeper/releases/latest
```

## 🛠️ Troubleshooting

### Проблемы с подписью кода

```bash
# Проверить подпись приложения
codesign -dv --verbose=4 AudioKeeper.app

# Проверить подпись DMG
codesign -dv --verbose=4 AudioKeeper-v1.0.0.dmg
```

### Проблемы с GitHub Actions

1. Проверьте логи в **Actions** табе
2. Убедитесь, что все secrets настроены
3. Проверьте права доступа к репозиторию

### Проблемы с DMG

```bash
# Проверить DMG
hdiutil verify AudioKeeper-v1.0.0.dmg

# Монтировать DMG для проверки
hdiutil mount AudioKeeper-v1.0.0.dmg
```

## 📝 Changelog

Ведите файл `CHANGELOG.md`:

```markdown
# Changelog

## [1.0.0] - 2024-01-15

### Added
- Initial release
- Menu bar interface
- Automatic audio device management

### Changed
- Nothing

### Fixed
- Nothing
```

## 🎯 Лучшие практики

1. **Всегда тестируйте** релиз перед публикацией
2. **Ведите changelog** для каждой версии
3. **Используйте семантическое версионирование**
4. **Подписывайте код** для доверия пользователей
5. **Автоматизируйте процесс** через GitHub Actions
6. **Документируйте изменения** в описании релиза
