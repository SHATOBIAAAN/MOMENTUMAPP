import '../entities/workspace.dart';
import '../repositories/workspace_repository.dart';

/// Create Workspace Use Case
/// Creates a new workspace in the repository
class CreateWorkspaceUseCase {
  final WorkspaceRepository _repository;

  CreateWorkspaceUseCase(this._repository);

  /// Execute the use case
  Future<Workspace> call(Workspace workspace) async {
    try {
      // Validate workspace data
      if (workspace.name.trim().isEmpty) {
        throw Exception('Workspace name cannot be empty');
      }
      
      if (workspace.name.trim().length < 2) {
        throw Exception('Workspace name must be at least 2 characters');
      }

      // Create workspace with current timestamp and order
      final now = DateTime.now();
      final workspaces = await _repository.getAllWorkspaces();
      final nextOrder = workspaces.isNotEmpty ? workspaces.length : 0;
      
      final newWorkspace = workspace.copyWith(
        createdAt: now,
        order: nextOrder,
      );

      return await _repository.createWorkspace(newWorkspace);
    } catch (e) {
      throw Exception('Failed to create workspace: $e');
    }
  }
}
