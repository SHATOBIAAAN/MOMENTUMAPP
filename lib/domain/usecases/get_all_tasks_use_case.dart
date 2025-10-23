import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for getting all tasks
/// Encapsulates the business logic for retrieving all tasks
class GetAllTasksUseCase {
  final TaskRepository repository;

  GetAllTasksUseCase(this.repository);

  /// Execute the use case
  /// Returns a list of all tasks from the repository
  Future<List<Task>> call() async {
    return await repository.getAllTasks();
  }
}
