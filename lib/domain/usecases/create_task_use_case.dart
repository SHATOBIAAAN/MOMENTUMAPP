import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for creating a new task
/// Encapsulates the business logic for task creation
class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  /// Execute the use case
  /// Creates a new task in the repository
  /// [task] - The task to be created
  Future<void> call(Task task) async {
    // Validate task before creation (business logic)
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty');
    }

    if (task.dueDate.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    )) {
      throw ArgumentError('Task due date cannot be in the past');
    }

    await repository.createTask(task);
  }
}
