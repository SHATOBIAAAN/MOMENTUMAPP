# 🚀 Quick Start Guide - Momentum

Быстрое руководство по запуску и использованию Momentum Task Management App.

---

## 📋 Предварительные требования

- **Flutter SDK**: 3.9.2 или выше
- **Dart SDK**: 3.9.2 или выше
- **IDE**: VS Code, Android Studio, или IntelliJ IDEA
- **Устройство**: Android emulator, iOS Simulator, или физическое устройство

---

## ⚡ Быстрый старт (5 минут)

### 1. Клонирование и установка зависимостей

```bash
cd Momentum/momentum
flutter pub get
```

### 2. Генерация кода (Isar и Mocks)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Запуск приложения

```bash
flutter run
```

Вот и всё! Приложение должно запуститься на вашем устройстве.

---

## 🧪 Запуск тестов

### Все тесты одной командой

**Linux/macOS:**
```bash
./run_tests.sh
```

**Windows:**
```bash
run_tests.bat
```

### Отдельные команды

```bash
# Только unit и widget тесты
flutter test

# С отчётом о покрытии
flutter test --coverage

# Только integration тесты (требуется подключенное устройство)
flutter test integration_test/

# Конкретный тест
flutter test test/domain/usecases/get_all_tasks_use_case_test.dart

# Анализ кода
flutter analyze

# Проверка форматирования
dart format --set-exit-if-changed .
```

### Просмотр покрытия кода

```bash
# Установить lcov (если ещё не установлен)
# macOS: brew install lcov
# Linux: sudo apt-get install lcov

# Генерировать HTML отчёт
genhtml coverage/lcov.info -o coverage/html

# Открыть в браузере
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
start coverage/html/index.html  # Windows
```

---

## 🔔 Использование уведомлений

### Инициализация (уже настроено в main.dart)

```dart
final notificationService = NotificationService();
await notificationService.initialize(
  onNotificationTapped: (payload) {
    // Обработка нажатия на уведомление
    if (payload?.startsWith('task_') == true) {
      final taskId = int.parse(payload!.split('_')[1]);
      // Навигация к деталям задачи
    }
  },
);
```

### Создание напоминания о задаче

```dart
// Одно напоминание за 1 час до дедлайна
await notificationService.scheduleTaskReminder(
  task: myTask,
  beforeDueDate: Duration(hours: 1),
);

// Множественные напоминания
await notificationService.scheduleMultipleReminders(
  task: myTask,
  reminderDurations: [
    Duration(days: 1),    // За день
    Duration(hours: 3),   // За 3 часа
    Duration(hours: 1),   // За час
  ],
);
```

### Отмена уведомлений

```dart
// Отменить все уведомления задачи
await notificationService.cancelTaskReminders(taskId);

// Отменить все уведомления
await notificationService.cancelAllNotifications();
```

---

## 🔄 Работа с синхронизацией

### Инициализация Sync Service

```dart
final syncService = SyncService();
await syncService.initialize(
  taskRepository: taskRepository,
  workspaceRepository: workspaceRepository,
  tagRepository: tagRepository,
  enableAutoSync: true,  // Авто-синхронизация каждые 15 мин
);
```

### Настройка API

В `lib/data/services/api_service.dart`:

```dart
apiService.initialize(
  baseUrl: 'https://your-api-url.com',
  authToken: 'your_auth_token',
);
```

### Синхронизация

```dart
// Ручная синхронизация
final result = await syncService.forceSyncNow();

// Подписка на статус синхронизации
syncService.syncStatusStream.listen((status) {
  print('Sync: ${status.state} - ${status.message}');
});

// Включить/выключить авто-синхронизацию
await syncService.setAutoSync(true);

// Статистика синхронизации
final stats = await syncService.getSyncStatistics();
print('Last sync: ${stats.lastSyncTime}');
print('Success rate: ${stats.successRate}%');
```

---

## ♿ Accessibility Features

### Проверка screen reader

```dart
if (AccessibilityHelper.isScreenReaderEnabled(context)) {
  // Упрощённый UI для screen reader
}
```

### Добавление семантических меток

```dart
AccessibilityHelper.makeAccessible(
  child: MyWidget(),
  label: 'Task: Meeting with team',
  hint: 'Double tap to open',
  button: true,
);
```

### Анонсирование действий

```dart
// При создании задачи
AccessibilityHelper.announceTaskCreated(context, 'New meeting task');

// При завершении задачи
AccessibilityHelper.announceTaskCompleted(context, 'Meeting task');
```

### Проверка контраста цветов

```dart
final isAccessible = AccessibilityHelper.isContrastAccessible(
  textColor,
  backgroundColor,
);

// Получить подходящий цвет текста
final textColor = AccessibilityHelper.getAccessibleForegroundColor(
  backgroundColor,
);
```

---

## 📱 Responsive Design

### Определение типа устройства

```dart
if (ResponsiveHelper.isMobile(context)) {
  // Mobile layout
} else if (ResponsiveHelper.isTablet(context)) {
  // Tablet layout
} else {
  // Desktop layout
}

// Или через extension
if (context.isMobile) {
  // Mobile code
}
```

### Адаптивные значения

```dart
// Адаптивный размер шрифта
final fontSize = ResponsiveHelper.responsiveFontSize(
  context,
  mobile: 14,
  tablet: 16,
  desktop: 18,
);

// Адаптивные отступы
final padding = ResponsiveHelper.responsivePadding(
  context,
  mobile: EdgeInsets.all(16),
  tablet: EdgeInsets.all(24),
  desktop: EdgeInsets.all(32),
);

// Количество колонок в Grid
final columns = ResponsiveHelper.responsiveGridColumns(context);
// mobile: 2, tablet: 3, desktop: 4
```

### Адаптивный layout builder

```dart
ResponsiveHelper.responsiveBuilder(
  context,
  mobile: (context) => MobileLayout(),
  tablet: (context) => TabletLayout(),
  desktop: (context) => DesktopLayout(),
);
```

---

## ⚡ Paginated Lists (для больших данных)

### Базовое использование

```dart
PaginatedListView<Task>(
  items: tasks,
  itemBuilder: (context, task, index) {
    return TaskCard(task: task);
  },
  
  // Загрузка следующей страницы
  onLoadMore: (page) async {
    return await taskRepository.getTasksPage(page, pageSize: 20);
  },
  
  // Pull-to-refresh
  onRefresh: () async {
    await refreshTasks();
  },
  
  hasMore: hasMoreTasks,
  isLoading: isLoading,
  itemsPerPage: 20,
);
```

### Grid вариант

```dart
PaginatedGridView<Task>(
  items: tasks,
  crossAxisCount: ResponsiveHelper.responsiveGridColumns(context),
  itemBuilder: (context, task, index) {
    return TaskCard(task: task);
  },
  onLoadMore: (page) async {
    return await loadMoreTasks(page);
  },
);
```

---

## 🏗️ Структура проекта

```
lib/
├── core/
│   ├── di.dart                  # Dependency Injection
│   ├── router.dart              # GoRouter navigation
│   └── theme_provider.dart      # Theme management
│
├── data/
│   ├── datasources/             # Isar data sources
│   ├── models/                  # Isar models with @collection
│   ├── repositories/            # Repository implementations
│   └── services/
│       ├── api_service.dart         # 🆕 REST API client
│       ├── notification_service.dart # 🆕 Local notifications
│       └── sync_service.dart        # 🆕 Offline-first sync
│
├── domain/
│   ├── entities/                # Business entities
│   ├── repositories/            # Repository interfaces
│   └── usecases/                # Business logic
│
└── presentation/
    ├── blocs/                   # BLoC state management
    ├── screens/                 # UI screens
    ├── widgets/
    │   ├── task_card.dart
    │   └── paginated_list_view.dart  # 🆕 Optimized lists
    ├── themes/                  # Light/Dark themes
    └── utils/
        ├── accessibility_helper.dart  # 🆕 Accessibility utils
        └── responsive_helper.dart     # 🆕 Responsive design
```

---

## 🔧 Полезные команды

### Разработка

```bash
# Запуск в режиме hot reload
flutter run

# Запуск с конкретным устройством
flutter run -d chrome         # Web
flutter run -d macos           # macOS
flutter run -d android         # Android

# Очистка кэша
flutter clean

# Обновление зависимостей
flutter pub get
flutter pub upgrade

# Генерация кода
flutter pub run build_runner build --delete-conflicting-outputs
flutter pub run build_runner watch  # Watch mode
```

### Сборка

```bash
# Android APK
flutter build apk --release

# Android App Bundle (для Google Play)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release
```

### Анализ

```bash
# Анализ кода
flutter analyze

# Форматирование
dart format .

# Проверка устаревших зависимостей
flutter pub outdated
```

---

## 🐛 Troubleshooting

### Проблема: Ошибки при генерации кода

**Решение:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Проблема: Уведомления не работают на Android 13+

**Решение:** Убедитесь, что в `AndroidManifest.xml` есть разрешение:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Проблема: Integration тесты не запускаются

**Решение:** Убедитесь, что устройство/эмулятор подключен:
```bash
flutter devices
# Должно показать список устройств
```

### Проблема: Ошибки компиляции после обновления

**Решение:**
```bash
flutter clean
rm -rf build/
rm pubspec.lock
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 📚 Дополнительная документация

- **[README.md](README.md)** - Полное описание проекта
- **[IMPROVEMENTS.md](IMPROVEMENTS.md)** - Подробная документация новых фич
- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)** - Детали архитектуры
- **[IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md)** - Список реализованных фич

---

## 🎯 Следующие шаги

1. ✅ Запустите приложение: `flutter run`
2. ✅ Запустите тесты: `./run_tests.sh` или `run_tests.bat`
3. ✅ Изучите код в `lib/` директории
4. ✅ Прочитайте [IMPROVEMENTS.md](IMPROVEMENTS.md) для деталей
5. ✅ Настройте backend API для синхронизации
6. ✅ Настройте CI/CD с GitHub Actions

---

## 💡 Tips & Best Practices

### Производительность
- Используйте `PaginatedListView` для списков > 50 элементов
- Генерируйте код только при изменении моделей
- Используйте `const` конструкторы где возможно

### Accessibility
- Всегда добавляйте semantic labels к интерактивным элементам
- Проверяйте контраст цветов
- Тестируйте с включенным screen reader

### Тестирование
- Пишите тесты для новых use cases
- Используйте `bloc_test` для BLoC тестов
- Добавляйте integration тесты для критичных flow'ов

### Код-стиль
- Запускайте `dart format .` перед коммитом
- Проверяйте `flutter analyze` на ошибки
- Следуйте Clean Architecture принципам

---

**Готово! Начните разработку с Momentum! 🚀**

*Версия: 1.0.0*  
*Последнее обновление: 2024*