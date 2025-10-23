import '../entities/workspace.dart';
import '../repositories/workspace_repository.dart';

/// Get All Workspaces Use Case
/// Retrieves all workspaces from the repository
class GetAllWorkspacesUseCase {
  final WorkspaceRepository _repository;

  GetAllWorkspacesUseCase(this._repository);

  /// Execute the use case
  Future<List<Workspace>> call() async {
    try {
      return await _repository.getAllWorkspaces();
    } catch (e) {
      throw Exception('Failed to get all workspaces: $e');
    }
  }
}
