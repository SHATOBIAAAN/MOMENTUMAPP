import '../repositories/task_repository.dart';

/// Use case for deleting a task
/// Encapsulates the business logic for task deletion
class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  /// Execute the use case
  /// Deletes a task from the repository
  /// [id] - The ID of the task to be deleted
  Future<void> call(int id) async {
    // Validate task ID (business logic)
    if (id <= 0) {
      throw ArgumentError('Invalid task ID');
    }

    await repository.deleteTask(id);
  }
}
