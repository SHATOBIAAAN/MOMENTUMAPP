# 🤝 Руководство по участию в разработке

Спасибо за интерес к проекту Momentum! Мы приветствуем любой вклад в развитие приложения.

## 🚀 Быстрый старт

### 1. Fork и клонирование

```bash
# Fork репозитория на GitHub, затем:
git clone https://github.com/YOUR_USERNAME/momentum.git
cd momentum
```

### 2. Настройка окружения

```bash
# Установка зависимостей
flutter pub get

# Генерация кода
flutter pub run build_runner build

# Запуск тестов
flutter test
```

### 3. Создание ветки

```bash
git checkout -b feature/your-feature-name
```

## 📋 Процесс разработки

### 1. Выбор задачи

- Посмотрите [Issues](https://github.com/your-username/momentum/issues) для доступных задач
- Выберите задачу с лейблом `good first issue` для новичков
- Напишите в комментариях, что берете задачу в работу

### 2. Разработка

- Следуйте архитектуре проекта (Clean Architecture)
- Покрывайте новый код тестами
- Используйте осмысленные имена переменных и функций
- Добавляйте комментарии для сложной логики

### 3. Тестирование

```bash
# Запуск всех тестов
flutter test

# Запуск с покрытием
flutter test --coverage

# Проверка стиля кода
flutter analyze
```

### 4. Commit и Push

```bash
# Добавление изменений
git add .

# Commit с описательным сообщением
git commit -m "feat: add new task filtering feature"

# Push в вашу ветку
git push origin feature/your-feature-name
```

## 📝 Стандарты кода

### Dart Style Guide

- Следуйте [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Используйте `flutter analyze` для проверки
- Максимальная длина строки: 80 символов

### Именование

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

### Комментарии

```dart
/// Создает новую задачу с указанными параметрами
/// 
/// [title] - название задачи (обязательно)
/// [description] - описание задачи (опционально)
/// [priority] - приоритет задачи
/// 
/// Возвращает [Task] объект с уникальным ID
Future<Task> createTask({
  required String title,
  String? description,
  TaskPriority priority = TaskPriority.medium,
}) async {
  // Реализация...
}
```

## 🧪 Тестирование

### Unit тесты

```dart
// test/domain/usecases/create_task_use_case_test.dart
void main() {
  group('CreateTaskUseCase', () {
    test('должен создавать задачу с валидными данными', () async {
      // Arrange
      final useCase = CreateTaskUseCase(mockRepository);
      final task = Task(/* ... */);
      
      // Act
      final result = await useCase.call(task);
      
      // Assert
      expect(result, isA<Task>());
      verify(mockRepository.createTask(task)).called(1);
    });
  });
}
```

### Widget тесты

```dart
// test/presentation/widgets/task_card_test.dart
testWidgets('должен отображать заголовок задачи', (tester) async {
  // Arrange
  final task = Task(/* ... */);
  
  // Act
  await tester.pumpWidget(
    MaterialApp(home: TaskCard(task: task)),
  );
  
  // Assert
  expect(find.text('Task Title'), findsOneWidget);
});
```

## 📋 Pull Request

### Шаблон PR

```markdown
## 📝 Описание
Краткое описание изменений

## 🔄 Тип изменений
- [ ] 🐛 Bug fix
- [ ] ✨ New feature
- [ ] 💥 Breaking change
- [ ] 📚 Documentation
- [ ] 🧪 Tests

## ✅ Чеклист
- [ ] Код покрыт тестами
- [ ] Все тесты проходят
- [ ] Код соответствует style guide
- [ ] Обновлена документация
- [ ] Нет breaking changes

## 🧪 Тестирование
Опишите как тестировали изменения

## 📸 Скриншоты (если применимо)
Добавьте скриншоты UI изменений
```

### Процесс ревью

1. **Автоматические проверки** - CI/CD должен пройти
2. **Code review** - минимум 1 одобрение
3. **Тестирование** - все тесты должны проходить
4. **Merge** - после одобрения изменения мержатся

## 🐛 Сообщение об ошибках

### Шаблон Bug Report

```markdown
## 🐛 Описание ошибки
Четкое описание проблемы

## 🔄 Шаги воспроизведения
1. Перейти к '...'
2. Нажать на '...'
3. Прокрутить до '...'
4. Увидеть ошибку

## 📱 Окружение
- OS: [e.g. iOS 16.0]
- Flutter: [e.g. 3.10.0]
- Device: [e.g. iPhone 14]

## 📸 Скриншоты
Если применимо, добавьте скриншоты

## 📋 Дополнительная информация
Любая другая информация об ошибке
```

## 💡 Предложения улучшений

### Feature Request

```markdown
## 💡 Описание функции
Четкое описание желаемой функции

## 🎯 Проблема
Какую проблему решает эта функция?

## 💭 Предлагаемое решение
Как вы видите реализацию?

## 🔄 Альтернативы
Какие альтернативы рассматривали?

## 📋 Дополнительная информация
Любая другая информация
```

## 📞 Связь

- **Issues**: [GitHub Issues](https://github.com/your-username/momentum/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/momentum/discussions)
- **Email**: your-email@example.com

## 🙏 Благодарности

Спасибо всем контрибьюторам, которые помогают развивать Momentum! 

---

**Удачной разработки! 🚀**

