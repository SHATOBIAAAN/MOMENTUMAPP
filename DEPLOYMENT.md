# 🚀 Руководство по развертыванию Momentum

## 📋 Предварительные требования

### Системные требования
- **Flutter SDK**: >= 3.16.0
- **Dart SDK**: >= 3.0.0
- **Android Studio** или **VS Code**
- **Git**: для версионного контроля
- **Node.js**: для web сборки (опционально)

### Платформо-специфичные требования

#### Android
- **Android SDK**: API 21+ (Android 5.0+)
- **Java**: JDK 11 или выше
- **Gradle**: 7.0+

#### iOS
- **Xcode**: 14.0+
- **iOS Deployment Target**: 12.0+
- **macOS**: для разработки iOS

#### Web
- **Chrome**: 90+ (рекомендуется)
- **Firefox**: 88+
- **Safari**: 14+

## 🛠️ Установка и настройка

### 1. Клонирование репозитория

```bash
git clone https://github.com/your-username/momentum.git
cd momentum
```

### 2. Установка зависимостей

```bash
# Установка Flutter зависимостей
flutter pub get

# Генерация кода (Isar, моки)
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Настройка окружения

#### Android
```bash
# Проверка Android SDK
flutter doctor --android-licenses

# Создание keystore для релиза
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### iOS
```bash
# Установка CocoaPods
sudo gem install cocoapods

# Установка iOS зависимостей
cd ios && pod install && cd ..
```

## 🏗️ Сборка приложения

### Development сборка

```bash
# Debug сборка для разработки
flutter run

# Hot reload для быстрой разработки
flutter run --hot
```

### Production сборка

#### Android APK
```bash
# Сборка APK
flutter build apk --release

# Сборка App Bundle (рекомендуется для Play Store)
flutter build appbundle --release

# Файлы будут в:
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

#### iOS
```bash
# Сборка для iOS
flutter build ios --release

# Архивация для App Store
flutter build ipa --release
```

#### Web
```bash
# Сборка для web
flutter build web --release

# Файлы будут в build/web/
```

## ☁️ Развертывание

### Android - Google Play Store

1. **Подготовка релиза**
```bash
# Увеличение версии
flutter build appbundle --release --build-name=1.0.0 --build-number=1
```

2. **Загрузка в Play Console**
   - Войдите в [Google Play Console](https://play.google.com/console)
   - Создайте новое приложение
   - Загрузите AAB файл
   - Заполните метаданные
   - Отправьте на ревью

### iOS - App Store

1. **Подготовка релиза**
```bash
# Сборка для App Store
flutter build ipa --release
```

2. **Загрузка в App Store Connect**
   - Войдите в [App Store Connect](https://appstoreconnect.apple.com)
   - Создайте новое приложение
   - Загрузите IPA через Xcode или Transporter
   - Заполните метаданные
   - Отправьте на ревью

### Web - GitHub Pages

1. **Настройка GitHub Pages**
```bash
# Сборка для web
flutter build web --release

# Копирование в docs папку
cp -r build/web/* docs/
```

2. **Настройка репозитория**
   - Перейдите в Settings → Pages
   - Выберите Source: Deploy from a branch
   - Выберите Branch: main, Folder: /docs

### Web - Firebase Hosting

```bash
# Установка Firebase CLI
npm install -g firebase-tools

# Инициализация проекта
firebase init hosting

# Сборка и деплой
flutter build web --release
firebase deploy
```

## 🔧 Конфигурация

### Переменные окружения

Создайте файл `.env` в корне проекта:

```env
# GitHub API
GITHUB_TOKEN=your_github_token
GITHUB_REPO=your_username/momentum-sync

# Firebase (опционально)
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_API_KEY=your_api_key

# Analytics (опционально)
ANALYTICS_ENABLED=true
```

### Настройка GitHub Sync

1. **Создание репозитория для синхронизации**
```bash
# Создайте новый репозиторий на GitHub
# Например: your-username/momentum-sync
```

2. **Настройка токена**
```bash
# Создайте Personal Access Token
# Settings → Developer settings → Personal access tokens
# Права: repo (полный доступ к репозиториям)
```

## 🧪 Тестирование

### Локальное тестирование

```bash
# Запуск всех тестов
flutter test

# Запуск с покрытием
flutter test --coverage

# Анализ кода
flutter analyze
```

### CI/CD тестирование

```bash
# GitHub Actions автоматически запускают:
# - Unit тесты
# - Widget тесты
# - Code analysis
# - Build проверки
```

## 📊 Мониторинг

### Crashlytics (Firebase)

```bash
# Добавление Firebase Crashlytics
flutter pub add firebase_crashlytics

# Настройка в main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  runApp(MyApp());
}
```

### Analytics

```bash
# Добавление Firebase Analytics
flutter pub add firebase_analytics

# Настройка отслеживания
import 'package:firebase_analytics/firebase_analytics.dart';
```

## 🔒 Безопасность

### Защита API ключей

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String githubToken = String.fromEnvironment('GITHUB_TOKEN');
  static const String githubRepo = String.fromEnvironment('GITHUB_REPO');
}
```

### Подписание приложений

#### Android
```bash
# Создание keystore
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Настройка в android/key.properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

#### iOS
```bash
# Создание сертификата в Xcode
# Preferences → Accounts → Manage Certificates
# Создайте iOS Distribution certificate
```

## 📈 Оптимизация

### Размер приложения

```bash
# Анализ размера APK
flutter build apk --analyze-size

# Оптимизация для релиза
flutter build apk --release --obfuscate --split-debug-info=debug-info/
```

### Производительность

```bash
# Профилирование производительности
flutter run --profile

# Анализ памяти
flutter run --trace-startup
```

## 🚨 Troubleshooting

### Частые проблемы

1. **Ошибка сборки Android**
```bash
# Очистка и пересборка
flutter clean
flutter pub get
flutter build apk --release
```

2. **Ошибка iOS сборки**
```bash
# Обновление CocoaPods
cd ios && pod update && cd ..
flutter clean
flutter build ios --release
```

3. **Проблемы с web сборкой**
```bash
# Очистка web кэша
flutter clean
flutter build web --release --web-renderer html
```

### Логи и отладка

```bash
# Подробные логи
flutter run --verbose

# Отладка на устройстве
flutter run --debug

# Логи релизной сборки
flutter logs
```

## 📞 Поддержка

Если у вас возникли проблемы с развертыванием:

1. **Проверьте документацию** Flutter
2. **Создайте issue** в репозитории
3. **Обратитесь к сообществу** Flutter

---

**Удачного развертывания! 🚀**

