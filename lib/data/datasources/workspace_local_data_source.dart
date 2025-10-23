import 'package:isar/isar.dart';
import '../models/workspace_model.dart';

/// Workspace Local Data Source
/// Handles local database operations for workspaces using Isar
class WorkspaceLocalDataSource {
  final Isar _isar;

  WorkspaceLocalDataSource(this._isar);

  /// Get all workspaces ordered by order field
  Future<List<WorkspaceModel>> getAllWorkspaces() async {
    try {
      return await _isar.workspaceModels
          .where()
          .sortByOrder()
          .findAll();
    } catch (e) {
      throw Exception('Failed to get all workspaces: $e');
    }
  }

  /// Get workspace by ID
  Future<WorkspaceModel?> getWorkspaceById(int id) async {
    try {
      return await _isar.workspaceModels.get(id);
    } catch (e) {
      throw Exception('Failed to get workspace by ID: $e');
    }
  }

  /// Create a new workspace
  Future<WorkspaceModel> createWorkspace(WorkspaceModel workspace) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.workspaceModels.put(workspace);
      });
      return workspace;
    } catch (e) {
      throw Exception('Failed to create workspace: $e');
    }
  }

  /// Update an existing workspace
  Future<WorkspaceModel> updateWorkspace(WorkspaceModel workspace) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.workspaceModels.put(workspace);
      });
      return workspace;
    } catch (e) {
      throw Exception('Failed to update workspace: $e');
    }
  }

  /// Delete a workspace
  Future<void> deleteWorkspace(int id) async {
    try {
      await _isar.writeTxn(() async {
        await _isar.workspaceModels.delete(id);
      });
    } catch (e) {
      throw Exception('Failed to delete workspace: $e');
    }
  }

  /// Get workspace by order
  Future<WorkspaceModel?> getWorkspaceByOrder(int order) async {
    try {
      final workspaces = await _isar.workspaceModels
          .where()
          .orderEqualTo(order)
          .findAll();
      return workspaces.isNotEmpty ? workspaces.first : null;
    } catch (e) {
      throw Exception('Failed to get workspace by order: $e');
    }
  }

  /// Update workspace order
  Future<void> updateWorkspaceOrder(int workspaceId, int newOrder) async {
    try {
      final workspace = await getWorkspaceById(workspaceId);
      if (workspace != null) {
        workspace.order = newOrder;
        await updateWorkspace(workspace);
      }
    } catch (e) {
      throw Exception('Failed to update workspace order: $e');
    }
  }

  /// Update workspace task counts
  Future<void> updateWorkspaceTaskCounts(int workspaceId, int totalTasks, int completedTasks) async {
    try {
      final workspace = await getWorkspaceById(workspaceId);
      if (workspace != null) {
        workspace.totalTasks = totalTasks;
        workspace.completedTasks = completedTasks;
        await updateWorkspace(workspace);
      }
    } catch (e) {
      throw Exception('Failed to update workspace task counts: $e');
    }
  }

  /// Get workspace statistics
  Future<Map<String, int>> getWorkspaceStatistics() async {
    try {
      final workspaces = await getAllWorkspaces();
      int totalWorkspaces = workspaces.length;
      int totalTasks = workspaces.fold(0, (sum, workspace) => sum + workspace.totalTasks);
      int completedTasks = workspaces.fold(0, (sum, workspace) => sum + workspace.completedTasks);
      
      return {
        'totalWorkspaces': totalWorkspaces,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
      };
    } catch (e) {
      throw Exception('Failed to get workspace statistics: $e');
    }
  }

  /// Watch all workspaces for changes
  Stream<List<WorkspaceModel>> watchAllWorkspaces() {
    return _isar.workspaceModels.where().watch(fireImmediately: true);
  }
}
