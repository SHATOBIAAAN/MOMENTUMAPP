import '../entities/task.dart';
import '../repositories/task_repository.dart';

/// Use case for getting tasks by workspace ID
/// Encapsulates the business logic for retrieving tasks for a specific workspace
class GetTasksByWorkspaceIdUseCase {
  final TaskRepository repository;

  GetTasksByWorkspaceIdUseCase(this.repository);

  /// Execute the use case
  /// Returns a list of tasks for the specified workspace
  Future<List<Task>> call(int workspaceId) async {
    return await repository.getTasksByWorkspaceId(workspaceId);
  }
}
