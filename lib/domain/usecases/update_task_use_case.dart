import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for updating an existing task
/// Encapsulates the business logic for task updates
class UpdateTaskUseCase {
  final TaskRepository repository;

  UpdateTaskUseCase(this.repository);

  /// Execute the use case
  /// Updates an existing task in the repository
  /// [task] - The task to be updated
  Future<void> call(Task task) async {
    // Validate task before updating (business logic)
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title cannot be empty');
    }

    if (task.dueDate.isBefore(
      DateTime.now().subtract(const Duration(days: 1)),
    )) {
      throw ArgumentError('Task due date cannot be in the past');
    }

    await repository.updateTask(task);
  }
}
