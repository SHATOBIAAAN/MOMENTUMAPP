import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import 'api_service.dart';

/// Service for offline-first data synchronization
/// Manages sync between local database and remote server
class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final ApiService _apiService = ApiService();
  final Connectivity _connectivity = Connectivity();

  TaskRepository? _taskRepository;
  WorkspaceRepository? _workspaceRepository;
  TagRepository? _tagRepository;

  bool _isSyncing = false;
  bool _autoSyncEnabled = true;
  DateTime? _lastSyncTime;
  Timer? _autoSyncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final List<SyncOperation> _syncQueue = [];
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  /// Stream of sync status updates
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Check if sync is in progress
  bool get isSyncing => _isSyncing;

  /// Check if auto-sync is enabled
  bool get autoSyncEnabled => _autoSyncEnabled;

  /// Get last sync time
  DateTime? get lastSyncTime => _lastSyncTime;

  /// Initialize the sync service
  Future<void> initialize({
    required TaskRepository taskRepository,
    required WorkspaceRepository workspaceRepository,
    required TagRepository tagRepository,
    bool enableAutoSync = true,
  }) async {
    _taskRepository = taskRepository;
    _workspaceRepository = workspaceRepository;
    _tagRepository = tagRepository;
    _autoSyncEnabled = enableAutoSync;

    // Load last sync time
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString('last_sync_time');
    if (lastSyncString != null) {
      _lastSyncTime = DateTime.parse(lastSyncString);
    }

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _onConnectivityChanged(results);
    });

    // Start auto-sync timer if enabled
    if (_autoSyncEnabled) {
      _startAutoSync();
    }

    debugPrint('SyncService: Initialized');
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (hasConnection && _autoSyncEnabled && !_isSyncing) {
      debugPrint('SyncService: Network restored, starting sync');
      syncAll();
    }
  }

  /// Start automatic sync timer
  void _startAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(
      const Duration(minutes: 15), // Sync every 15 minutes
      (_) {
        if (_autoSyncEnabled && !_isSyncing) {
          syncAll();
        }
      },
    );
    debugPrint('SyncService: Auto-sync started (15 min interval)');
  }

  /// Stop automatic sync timer
  void _stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;
    debugPrint('SyncService: Auto-sync stopped');
  }

  /// Enable or disable auto-sync
  Future<void> setAutoSync(bool enabled) async {
    _autoSyncEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_sync_enabled', enabled);

    if (enabled) {
      _startAutoSync();
    } else {
      _stopAutoSync();
    }

    debugPrint('SyncService: Auto-sync ${enabled ? "enabled" : "disabled"}');
  }

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      return connectivityResults.any(
        (result) => result != ConnectivityResult.none,
      );
    } catch (e) {
      debugPrint('SyncService: Error checking connectivity: $e');
      return false;
    }
  }

  /// Sync all data (tasks, workspaces, tags)
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      debugPrint('SyncService: Sync already in progress');
      return SyncResult(success: false, message: 'Sync already in progress');
    }

    if (!await hasInternetConnection()) {
      debugPrint('SyncService: No internet connection');
      _syncStatusController.add(
        SyncStatus(state: SyncState.failed, message: 'No internet connection'),
      );
      return SyncResult(success: false, message: 'No internet connection');
    }

    if (!_apiService.isAuthenticated) {
      debugPrint('SyncService: User not authenticated');
      _syncStatusController.add(
        SyncStatus(state: SyncState.failed, message: 'User not authenticated'),
      );
      return SyncResult(success: false, message: 'User not authenticated');
    }

    _isSyncing = true;
    _syncStatusController.add(
      SyncStatus(state: SyncState.syncing, message: 'Syncing data...'),
    );

    try {
      // Sync tasks
      await _syncTasks();

      // Sync workspaces
      await _syncWorkspaces();

      // Sync tags
      await _syncTags();

      // Update last sync time
      _lastSyncTime = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_time', _lastSyncTime!.toIso8601String());

      _isSyncing = false;
      _syncStatusController.add(
        SyncStatus(
          state: SyncState.completed,
          message: 'Sync completed successfully',
          lastSyncTime: _lastSyncTime,
        ),
      );

      debugPrint('SyncService: Sync completed successfully');
      return SyncResult(success: true, message: 'Sync completed');
    } catch (e) {
      _isSyncing = false;
      debugPrint('SyncService: Sync failed: $e');
      _syncStatusController.add(
        SyncStatus(state: SyncState.failed, message: 'Sync failed: $e'),
      );
      return SyncResult(success: false, message: 'Sync failed: $e');
    }
  }

  /// Sync tasks with server
  Future<void> _syncTasks() async {
    if (_taskRepository == null) return;

    try {
      // Get local tasks
      final localTasks = await _taskRepository!.getAllTasks();

      // Send to server and get updated tasks
      final syncResult = await _apiService.syncTasks(localTasks);

      // Delete tasks that were deleted on server
      for (final deletedId in syncResult.deletedIds) {
        await _taskRepository!.deleteTask(deletedId);
      }

      // Update or create tasks from server
      for (final serverTask in syncResult.tasks) {
        final localTask = await _taskRepository!.getTaskById(serverTask.id);
        if (localTask != null) {
          // Resolve conflicts (server wins for now - can be improved)
          await _taskRepository!.updateTask(serverTask);
        } else {
          await _taskRepository!.createTask(serverTask);
        }
      }

      debugPrint('SyncService: Tasks synced successfully');
    } catch (e) {
      debugPrint('SyncService: Error syncing tasks: $e');
      rethrow;
    }
  }

  /// Sync workspaces with server
  Future<void> _syncWorkspaces() async {
    if (_workspaceRepository == null) return;

    try {
      // Get local workspaces
      final localWorkspaces = await _workspaceRepository!.getAllWorkspaces();

      // Send to server and get updated workspaces
      final serverWorkspaces = await _apiService.syncWorkspaces(
        localWorkspaces,
      );

      // Update local workspaces
      for (final serverWorkspace in serverWorkspaces) {
        final localWorkspace = await _workspaceRepository!.getWorkspaceById(
          serverWorkspace.id,
        );
        if (localWorkspace != null) {
          await _workspaceRepository!.updateWorkspace(serverWorkspace);
        } else {
          await _workspaceRepository!.createWorkspace(serverWorkspace);
        }
      }

      debugPrint('SyncService: Workspaces synced successfully');
    } catch (e) {
      debugPrint('SyncService: Error syncing workspaces: $e');
      rethrow;
    }
  }

  /// Sync tags with server
  Future<void> _syncTags() async {
    if (_tagRepository == null) return;

    try {
      // Get local tags
      final localTags = await _tagRepository!.getAllTags();

      // Send to server and get updated tags
      final serverTags = await _apiService.syncTags(localTags);

      // Update local tags
      for (final serverTag in serverTags) {
        final localTag = await _tagRepository!.getTagById(serverTag.id);
        if (localTag != null) {
          await _tagRepository!.updateTag(serverTag);
        } else {
          await _tagRepository!.createTag(serverTag);
        }
      }

      debugPrint('SyncService: Tags synced successfully');
    } catch (e) {
      debugPrint('SyncService: Error syncing tags: $e');
      rethrow;
    }
  }

  /// Queue a sync operation for later
  void queueOperation(SyncOperation operation) {
    _syncQueue.add(operation);
    debugPrint('SyncService: Operation queued: ${operation.type}');
  }

  /// Process queued operations
  Future<void> processQueue() async {
    if (_syncQueue.isEmpty) return;

    debugPrint(
      'SyncService: Processing ${_syncQueue.length} queued operations',
    );

    while (_syncQueue.isNotEmpty) {
      final operation = _syncQueue.removeAt(0);
      try {
        await _executeOperation(operation);
      } catch (e) {
        debugPrint('SyncService: Error executing operation: $e');
        // Re-queue operation for retry
        _syncQueue.add(operation);
      }
    }
  }

  /// Execute a single sync operation
  Future<void> _executeOperation(SyncOperation operation) async {
    switch (operation.type) {
      case SyncOperationType.createTask:
        if (operation.data is Task) {
          await _apiService.createTask(operation.data as Task);
        }
        break;
      case SyncOperationType.updateTask:
        if (operation.data is Task) {
          await _apiService.updateTask(operation.data as Task);
        }
        break;
      case SyncOperationType.deleteTask:
        if (operation.data is int) {
          await _apiService.deleteTask(operation.data as int);
        }
        break;
      default:
        debugPrint('SyncService: Unknown operation type: ${operation.type}');
    }
  }

  /// Force sync now (manual sync)
  Future<SyncResult> forceSyncNow() async {
    debugPrint('SyncService: Manual sync triggered');
    return await syncAll();
  }

  /// Upload only (push local changes to server)
  Future<void> uploadChanges() async {
    if (_taskRepository == null) return;

    try {
      final localTasks = await _taskRepository!.getAllTasks();
      await _apiService.batchUploadTasks(localTasks);
      debugPrint('SyncService: Changes uploaded successfully');
    } catch (e) {
      debugPrint('SyncService: Error uploading changes: $e');
      rethrow;
    }
  }

  /// Download only (pull server changes to local)
  Future<void> downloadChanges() async {
    if (_taskRepository == null) return;

    try {
      final serverTasks = await _apiService.fetchTasks();
      for (final task in serverTasks) {
        await _taskRepository!.updateTask(task);
      }
      debugPrint('SyncService: Changes downloaded successfully');
    } catch (e) {
      debugPrint('SyncService: Error downloading changes: $e');
      rethrow;
    }
  }

  /// Resolve sync conflict (strategy: server wins)
  Future<Task> _resolveConflict(Task local, Task server) async {
    // Simple strategy: server wins
    // Can be improved with:
    // - User choice
    // - Timestamp comparison
    // - Merge strategy
    debugPrint('SyncService: Conflict resolved (server wins)');
    return server;
  }

  /// Clear sync data
  Future<void> clearSyncData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_sync_time');
    _lastSyncTime = null;
    _syncQueue.clear();
    debugPrint('SyncService: Sync data cleared');
  }

  /// Get sync statistics
  Future<SyncStatistics> getSyncStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final totalSyncs = prefs.getInt('total_syncs') ?? 0;
    final failedSyncs = prefs.getInt('failed_syncs') ?? 0;

    return SyncStatistics(
      lastSyncTime: _lastSyncTime,
      totalSyncs: totalSyncs,
      failedSyncs: failedSyncs,
      queuedOperations: _syncQueue.length,
      autoSyncEnabled: _autoSyncEnabled,
    );
  }

  /// Dispose resources
  void dispose() {
    _stopAutoSync();
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
    debugPrint('SyncService: Disposed');
  }
}

/// Sync operation model
class SyncOperation {
  final SyncOperationType type;
  final dynamic data;
  final DateTime timestamp;

  SyncOperation({required this.type, required this.data, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

/// Sync operation types
enum SyncOperationType {
  createTask,
  updateTask,
  deleteTask,
  createWorkspace,
  updateWorkspace,
  deleteWorkspace,
  createTag,
  updateTag,
  deleteTag,
}

/// Sync state
enum SyncState { idle, syncing, completed, failed }

/// Sync status model
class SyncStatus {
  final SyncState state;
  final String message;
  final DateTime? lastSyncTime;

  SyncStatus({required this.state, required this.message, this.lastSyncTime});
}

/// Sync result model
class SyncResult {
  final bool success;
  final String message;
  final int? syncedItems;

  SyncResult({required this.success, required this.message, this.syncedItems});
}

/// Sync statistics model
class SyncStatistics {
  final DateTime? lastSyncTime;
  final int totalSyncs;
  final int failedSyncs;
  final int queuedOperations;
  final bool autoSyncEnabled;

  SyncStatistics({
    required this.lastSyncTime,
    required this.totalSyncs,
    required this.failedSyncs,
    required this.queuedOperations,
    required this.autoSyncEnabled,
  });

  double get successRate {
    if (totalSyncs == 0) return 0.0;
    return (totalSyncs - failedSyncs) / totalSyncs * 100;
  }
}
