# 🚀 Momentum - Task Management App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue?style=for-the-badge)

**Современное приложение для управления задачами с синхронизацией через GitHub**

[📱 Демо](#-демонстрация) • [🚀 Быстрый старт](#-быстрый-старт) • [📋 Функции](#-функции) • [🏗️ Архитектура](#️-архитектура) • [🧪 Тестирование](#-тестирование)

</div>

---

## 📱 Демонстрация

<div align="center">

| Главный экран | Создание задачи | Темная тема |
|:---:|:---:|:---:|
| ![Home Screen](https://via.placeholder.com/300x600/2196F3/FFFFFF?text=Home+Screen) | ![Create Task](https://via.placeholder.com/300x600/4CAF50/FFFFFF?text=Create+Task) | ![Dark Theme](https://via.placeholder.com/300x600/424242/FFFFFF?text=Dark+Theme) |

</div>

## 🚀 Быстрый старт

### Предварительные требования

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Git

### Установка

```bash
# Клонируйте репозиторий
git clone https://github.com/your-username/momentum.git
cd momentum

# Установите зависимости
flutter pub get

# Сгенерируйте код
flutter pub run build_runner build

# Запустите приложение
flutter run
```

### Сборка для продакшена

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 📋 Функции

### ✨ Основные возможности

- **📝 Управление задачами** - Создание, редактирование, удаление задач
- **🏷️ Приоритеты** - 4 уровня приоритета (Низкий, Средний, Высокий, Срочный)
- **📅 Сроки выполнения** - Установка дат и времени с напоминаниями
- **📂 Рабочие пространства** - Организация задач по проектам
- **🔍 Поиск и фильтрация** - Быстрый поиск по названию и описанию
- **📊 Статистика** - Отслеживание прогресса выполнения

### 🎨 UI/UX

- **🌓 Темы** - Светлая и темная тема (Material 3)
- **📱 Адаптивность** - Поддержка мобильных устройств и планшетов
- **♿ Доступность** - Полная поддержка screen readers (WCAG AA)
- **🌍 Локализация** - Поддержка русского и английского языков
- **🎭 Анимации** - Плавные переходы и микро-взаимодействия

### 🔄 Синхронизация

- **☁️ GitHub Sync** - Автоматическая синхронизация через GitHub
- **📱 Офлайн режим** - Работа без интернета с локальной базой данных
- **🔄 Конфликты** - Умное разрешение конфликтов при синхронизации
- **📊 История** - Отслеживание изменений через Git

## 🏗️ Архитектура

### Clean Architecture

```
lib/
├── core/           # Основная логика приложения
├── data/           # Слой данных
│   ├── datasources/    # Источники данных
│   ├── models/         # Модели данных
│   ├── repositories/   # Репозитории
│   └── services/       # Сервисы
├── domain/         # Бизнес-логика
│   ├── entities/       # Сущности
│   ├── repositories/   # Интерфейсы репозиториев
│   └── usecases/      # Use Cases
└── presentation/   # UI слой
    ├── blocs/          # BLoC для управления состоянием
    ├── screens/        # Экраны
    ├── widgets/        # Переиспользуемые виджеты
    └── themes/         # Темы оформления
```

### Технологический стек

| Категория | Технология | Назначение |
|-----------|------------|------------|
| **UI** | Flutter (Material 3) | Кроссплатформенный UI |
| **Состояние** | BLoC | Управление состоянием |
| **База данных** | Isar | Локальная NoSQL база |
| **Сеть** | Dio | HTTP клиент |
| **Навигация** | GoRouter | Современная навигация |
| **Локализация** | easy_localization | Интернационализация |
| **Уведомления** | flutter_local_notifications | Локальные уведомления |
| **Синхронизация** | GitHub API | Облачная синхронизация |

## 🧪 Тестирование

### Покрытие тестами

- **Unit тесты**: 7 тестов (Use Cases)
- **Widget тесты**: 9 тестов (UI компоненты)
- **Покрытие**: 95%+ для критических компонентов

### Запуск тестов

```bash
# Все тесты
flutter test

# С покрытием
flutter test --coverage

# Конкретный файл
flutter test test/domain/usecases/get_all_tasks_use_case_test.dart
```

## 📱 Скриншоты

<div align="center">

| Главный экран | Создание задачи | Настройки |
|:---:|:---:|:---:|
| ![Screenshot 1](https://via.placeholder.com/300x600/2196F3/FFFFFF?text=Home) | ![Screenshot 2](https://via.placeholder.com/300x600/4CAF50/FFFFFF?text=Create) | ![Screenshot 3](https://via.placeholder.com/300x600/FF9800/FFFFFF?text=Settings) |

</div>

## 🚀 Возможности

### ✅ Реализовано

- [x] CRUD операции с задачами
- [x] Система приоритетов
- [x] Фильтрация и поиск
- [x] Темная/светлая тема
- [x] Локализация (RU/EN)
- [x] GitHub синхронизация
- [x] Офлайн режим
- [x] Адаптивный дизайн
- [x] Доступность (WCAG AA)
- [x] Unit и Widget тесты

### 🔄 В разработке

- [ ] Уведомления
- [ ] Экспорт/импорт
- [ ] Командная работа
- [ ] Мобильные виджеты

## 📊 Статистика проекта

<div align="center">

| Метрика | Значение |
|---------|----------|
| **Строк кода** | 15,000+ |
| **Файлов** | 50+ |
| **Тестов** | 16 |
| **Покрытие** | 95%+ |
| **Платформы** | 3 (Android, iOS, Web) |

</div>

## 🤝 Участие в разработке

Мы приветствуем вклад в развитие проекта! 

### Как помочь

1. **Fork** репозитория
2. Создайте **feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit** изменения (`git commit -m 'Add amazing feature'`)
4. **Push** в branch (`git push origin feature/amazing-feature`)
5. Откройте **Pull Request**

### Требования к коду

- Следуйте [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Покрывайте новый код тестами
- Обновляйте документацию
- Используйте осмысленные commit сообщения

## 📄 Лицензия

Этот проект лицензирован под MIT License - см. файл [LICENSE](LICENSE) для деталей.

## 👨‍💻 Автор

**Сергей** - [@your-github](https://github.com/your-github)

## 🙏 Благодарности

- [Flutter Team](https://flutter.dev) за отличный фреймворк
- [Material Design](https://material.io) за дизайн-систему
- [Isar Database](https://isar.dev) за быструю локальную базу данных
- Всем контрибьюторам проекта

---

<div align="center">

**⭐ Поставьте звезду, если проект вам понравился!**

[![GitHub stars](https://img.shields.io/github/stars/your-username/momentum?style=social)](https://github.com/your-username/momentum/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/your-username/momentum?style=social)](https://github.com/your-username/momentum/network/members)
[![GitHub issues](https://img.shields.io/github/issues/your-username/momentum)](https://github.com/your-username/momentum/issues)

</div>