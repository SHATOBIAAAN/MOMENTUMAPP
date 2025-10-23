import '../repositories/workspace_repository.dart';
import '../repositories/task_repository.dart';

/// Delete Workspace Use Case
/// Deletes a workspace and all associated tasks from the repository
class DeleteWorkspaceUseCase {
  final WorkspaceRepository _workspaceRepository;
  final TaskRepository _taskRepository;

  DeleteWorkspaceUseCase(this._workspaceRepository, this._taskRepository);

  /// Execute the use case
  Future<void> call(int workspaceId) async {
    try {
      // Check if workspace exists
      final workspace = await _workspaceRepository.getWorkspaceById(workspaceId);
      if (workspace == null) {
        throw Exception('Workspace not found');
      }

      // First, delete all tasks associated with this workspace
      final tasks = await _taskRepository.getTasksByWorkspaceId(workspaceId);
      for (final task in tasks) {
        await _taskRepository.deleteTask(task.id);
      }

      // Then delete the workspace
      await _workspaceRepository.deleteWorkspace(workspaceId);
    } catch (e) {
      throw Exception('Failed to delete workspace: $e');
    }
  }
}
