# 🛠️ Руководство по разработке

## 🎯 Обзор

Этот документ содержит подробную информацию о том, как разрабатывать и вносить вклад в проект Momentum.

## 🏗️ Архитектура проекта

### 📁 Структура проекта

```
lib/
├── core/                    # Основная логика приложения
│   ├── app_state_provider.dart    # Провайдер состояния приложения
│   ├── di.dart                    # Dependency Injection
│   ├── router.dart                # Навигация
│   └── theme_provider.dart        # Провайдер тем
├── data/                    # Слой данных
│   ├── datasources/               # Источники данных
│   │   ├── task_local_data_source.dart
│   │   ├── workspace_local_data_source.dart
│   │   └── tag_local_data_source.dart
│   ├── models/                    # Модели данных
│   │   ├── task_model.dart
│   │   ├── workspace_model.dart
│   │   └── tag_model.dart
│   ├── repositories/               # Репозитории
│   │   ├── task_repository_impl.dart
│   │   ├── workspace_repository_impl.dart
│   │   └── tag_repository_impl.dart
│   └── services/                  # Сервисы
│       ├── github_sync_service.dart
│       ├── notification_service.dart
│       └── storage_service.dart
├── domain/                  # Бизнес-логика
│   ├── entities/                 # Сущности
│   │   ├── task.dart
│   │   ├── workspace.dart
│   │   └── tag.dart
│   ├── repositories/             # Интерфейсы репозиториев
│   │   ├── task_repository.dart
│   │   ├── workspace_repository.dart
│   │   └── tag_repository.dart
│   └── usecases/                 # Use Cases
│       ├── get_all_tasks_use_case.dart
│       ├── create_task_use_case.dart
│       └── update_task_use_case.dart
└── presentation/            # UI слой
    ├── blocs/                   # BLoC для управления состоянием
    │   ├── task_bloc.dart
    │   ├── workspace_bloc.dart
    │   └── tag_bloc.dart
    ├── screens/                  # Экраны
    │   ├── home_page.dart
    │   ├── create_task_page.dart
    │   └── settings_page.dart
    ├── widgets/                   # Переиспользуемые виджеты
    │   ├── task_card.dart
    │   ├── workspace_card.dart
    │   └── tag_chip.dart
    └── themes/                    # Темы оформления
        ├── app_theme.dart
        └── color_scheme.dart
```

### 🎯 Принципы архитектуры

- **Clean Architecture** - четкое разделение слоев
- **SOLID принципы** - следование принципам SOLID
- **Dependency Injection** - инверсия зависимостей
- **Repository Pattern** - абстракция источников данных
- **BLoC Pattern** - управление состоянием

## 🛠️ Настройка окружения разработки

### 📋 Предварительные требования

```bash
# Flutter SDK
flutter --version  # >= 3.16.0

# Dart SDK
dart --version      # >= 3.0.0

# Git
git --version      # >= 2.30.0
```

### 🔧 Установка

```bash
# Клонирование репозитория
git clone https://github.com/your-username/momentum.git
cd momentum

# Установка зависимостей
flutter pub get

# Генерация кода
flutter pub run build_runner build --delete-conflicting-outputs

# Запуск приложения
flutter run
```

### 🧪 Тестирование

```bash
# Запуск всех тестов
flutter test

# Запуск с покрытием
flutter test --coverage

# Анализ кода
flutter analyze
```

## 🎯 Стандарты разработки

### 📝 Стиль кода

#### Dart Style Guide
```dart
// ✅ Хорошо
class TaskRepository {
  final TaskLocalDataSource _localDataSource;
  
  const TaskRepository({
    required TaskLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;
  
  Future<List<Task>> getAllTasks() async {
    try {
      final tasks = await _localDataSource.getAllTasks();
      return tasks.map((task) => task.toEntity()).toList();
    } catch (e) {
      throw TaskRepositoryException('Failed to get tasks: $e');
    }
  }
}

// ❌ Плохо
class taskRepo {
  final TaskLocalDataSource localDataSource;
  
  taskRepo({required this.localDataSource});
  
  Future<List<Task>> getTasks() async {
    return localDataSource.getTasks();
  }
}
```

#### Именование
```dart
// ✅ Хорошо
class TaskRepository {}
final taskTitle = 'My Task';
const maxTaskCount = 100;

// ❌ Плохо
class taskRepo {}
final TaskTitle = 'My Task';
const MAXTASKCOUNT = 100;
```

### 📚 Комментарии

```dart
/// Создает новую задачу с указанными параметрами
/// 
/// [title] - название задачи (обязательно)
/// [description] - описание задачи (опционально)
/// [priority] - приоритет задачи
/// 
/// Возвращает [Task] объект с уникальным ID
/// 
/// Пример:
/// ```dart
/// final task = await createTask(
///   title: 'My Task',
///   description: 'Task description',
///   priority: TaskPriority.high,
/// );
/// ```
Future<Task> createTask({
  required String title,
  String? description,
  TaskPriority priority = TaskPriority.medium,
}) async {
  // Реализация...
}
```

### 🧪 Тестирование

#### Unit тесты
```dart
// test/domain/usecases/create_task_use_case_test.dart
void main() {
  group('CreateTaskUseCase', () {
    late CreateTaskUseCase useCase;
    late MockTaskRepository mockRepository;
    
    setUp(() {
      mockRepository = MockTaskRepository();
      useCase = CreateTaskUseCase(mockRepository);
    });
    
    test('должен создавать задачу с валидными данными', () async {
      // Arrange
      final task = Task(
        id: 0,
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        priority: TaskPriority.medium,
        dueDate: DateTime.now().add(Duration(days: 1)),
        category: 'Work',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      when(mockRepository.createTask(any))
          .thenAnswer((_) async {});
      
      // Act
      await useCase.call(task);
      
      // Assert
      verify(mockRepository.createTask(task)).called(1);
    });
  });
}
```

#### Widget тесты
```dart
// test/presentation/widgets/task_card_test.dart
void main() {
  group('TaskCard Widget Tests', () {
    testWidgets('должен отображать заголовок задачи', (tester) async {
      // Arrange
      final task = Task(
        id: 1,
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: false,
        priority: TaskPriority.medium,
        dueDate: DateTime.now().add(Duration(days: 1)),
        category: 'Work',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskCard(
              task: task,
              onToggle: () {},
              onDelete: () {},
              onTap: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Test Task'), findsOneWidget);
    });
  });
}
```

## 🎯 Процесс разработки

### 🔄 Git Workflow

#### Ветки
```bash
# Основные ветки
main        # Стабильная версия
develop     # Разработка
feature/*   # Новые функции
bugfix/*    # Исправления багов
hotfix/*    # Критические исправления
```

#### Commit сообщения
```bash
# Формат: type(scope): description
feat(task): add task creation functionality
fix(ui): resolve task card display issue
docs(readme): update installation instructions
test(task): add unit tests for task use cases
refactor(bloc): simplify task bloc logic
```

### 📋 Pull Request процесс

1. **Создание ветки**
```bash
git checkout -b feature/new-feature
```

2. **Разработка**
```bash
# Внесение изменений
git add .
git commit -m "feat: add new feature"
```

3. **Тестирование**
```bash
flutter test
flutter analyze
```

4. **Push и PR**
```bash
git push origin feature/new-feature
# Создать Pull Request на GitHub
```

### 🔍 Code Review

#### Критерии ревью
- **Функциональность** - код работает как ожидается
- **Архитектура** - следует принципам Clean Architecture
- **Тестирование** - покрыт тестами
- **Производительность** - оптимизирован
- **Безопасность** - безопасен
- **Документация** - документирован

#### Процесс ревью
1. **Автоматические проверки** - CI/CD
2. **Code review** - минимум 1 одобрение
3. **Тестирование** - все тесты проходят
4. **Merge** - после одобрения

## 🎯 Инструменты разработки

### 🔧 Основные инструменты

| Инструмент | Назначение | Версия |
|------------|------------|--------|
| **Flutter** | UI фреймворк | 3.16.0+ |
| **Dart** | Язык программирования | 3.0.0+ |
| **VS Code** | IDE | Latest |
| **Android Studio** | IDE | Latest |
| **Xcode** | iOS разработка | 14.0+ |

### 📦 Полезные расширения

#### VS Code
- **Flutter** - поддержка Flutter
- **Dart** - поддержка Dart
- **BLoC** - поддержка BLoC
- **GitLens** - расширенная работа с Git
- **Error Lens** - подсветка ошибок
- **Bracket Pair Colorizer** - цветные скобки

#### Android Studio
- **Flutter Plugin** - поддержка Flutter
- **Dart Plugin** - поддержка Dart
- **Git Integration** - интеграция с Git

### 🧪 Инструменты тестирования

```bash
# Анализ кода
flutter analyze

# Тестирование
flutter test

# Покрытие тестами
flutter test --coverage

# Генерация отчетов
genhtml coverage/lcov.info -o coverage/html
```

## 🎯 Производительность

### 📊 Метрики

| Метрика | Целевое значение | Текущее значение |
|---------|------------------|------------------|
| **Startup Time** | < 2 сек | 1.5 сек |
| **Memory Usage** | < 100MB | 85MB |
| **Database Queries** | < 50ms | 30ms |
| **Sync Time** | < 5 сек | 3 сек |

### 🔧 Оптимизация

#### Код
```dart
// ✅ Хорошо - ленивая загрузка
ListView.builder(
  itemCount: tasks.length,
  itemBuilder: (context, index) => TaskCard(task: tasks[index]),
)

// ❌ Плохо - загрузка всех элементов
Column(
  children: tasks.map((task) => TaskCard(task: task)).toList(),
)
```

#### База данных
```dart
// ✅ Хорошо - индексы для быстрого поиска
@Index()
String get title => title;

// ❌ Плохо - поиск без индексов
final tasks = await isar.tasks.where().filter().findAll();
```

## 🎯 Безопасность

### 🔒 Принципы

- **Валидация входных данных** - проверка всех входных данных
- **Шифрование чувствительных данных** - защита конфиденциальной информации
- **Безопасное хранение токенов** - использование secure storage
- **HTTPS для всех соединений** - защищенные соединения

### 🛡️ Практики

```dart
// ✅ Хорошо - валидация входных данных
class TaskValidator {
  static String? validateTitle(String? title) {
    if (title == null || title.isEmpty) {
      return 'Title is required';
    }
    if (title.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }
}

// ✅ Хорошо - безопасное хранение
class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  static Future<void> storeToken(String token) async {
    await _storage.write(key: 'github_token', value: token);
  }
}
```

## 🎯 Документация

### 📚 Типы документации

- **API Documentation** - документация API
- **Architecture Guide** - руководство по архитектуре
- **User Guide** - руководство пользователя
- **Developer Guide** - руководство разработчика
- **Testing Guide** - руководство по тестированию

### 📝 Стандарты документации

```dart
/// Создает новую задачу с указанными параметрами
/// 
/// [title] - название задачи (обязательно)
/// [description] - описание задачи (опционально)
/// [priority] - приоритет задачи
/// 
/// Возвращает [Task] объект с уникальным ID
/// 
/// Пример:
/// ```dart
/// final task = await createTask(
///   title: 'My Task',
///   description: 'Task description',
///   priority: TaskPriority.high,
/// );
/// ```
/// 
/// Исключения:
/// - [TaskValidationException] если данные невалидны
/// - [TaskRepositoryException] если ошибка репозитория
Future<Task> createTask({
  required String title,
  String? description,
  TaskPriority priority = TaskPriority.medium,
}) async {
  // Реализация...
}
```

## 🎯 Контакты

### 📞 Команда разработки

- **Tech Lead**: tech@example.com
- **Product Manager**: product@example.com
- **QA Lead**: qa@example.com
- **DevOps**: devops@example.com

### 🔗 Полезные ссылки

- **GitHub**: [Репозиторий](https://github.com/your-username/momentum)
- **Discord**: [Сервер сообщества](https://discord.gg/your-server)
- **Twitter**: [@momentum_app](https://twitter.com/momentum_app)
- **Reddit**: [r/momentum](https://reddit.com/r/momentum)

---

**Удачной разработки! 🚀**

