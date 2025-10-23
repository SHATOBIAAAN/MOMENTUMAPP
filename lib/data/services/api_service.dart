import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/entities/tag.dart';

/// API Service for backend synchronization
/// Handles all network requests with error handling, retries, and timeouts
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  String? _authToken;
  String _baseUrl = 'https://api.momentum.app'; // Replace with your API URL
  bool _isInitialized = false;

  /// Initialize the API service
  void initialize({String? baseUrl, String? authToken}) {
    if (_isInitialized) return;

    if (baseUrl != null) {
      _baseUrl = baseUrl;
    }

    _authToken = authToken;

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_createInterceptor());
    _dio.interceptors.add(_createRetryInterceptor());

    _isInitialized = true;
    debugPrint('ApiService: Initialized with base URL: $_baseUrl');
  }

  /// Create request/response interceptor
  Interceptor _createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token to requests
        if (_authToken != null) {
          options.headers['Authorization'] = 'Bearer $_authToken';
        }

        debugPrint('API Request: ${options.method} ${options.path}');
        debugPrint('Headers: ${options.headers}');
        debugPrint('Data: ${options.data}');

        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          'API Response: ${response.statusCode} ${response.requestOptions.path}',
        );
        debugPrint('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint('API Error: ${error.message}');
        debugPrint('Response: ${error.response?.data}');
        return handler.next(error);
      },
    );
  }

  /// Create retry interceptor
  Interceptor _createRetryInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          try {
            debugPrint('Retrying request...');
            final response = await _retry(error.requestOptions);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    );
  }

  /// Check if request should be retried
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError ||
        (error.response?.statusCode ?? 0) >= 500;
  }

  /// Retry failed request
  Future<Response> _retry(
    RequestOptions requestOptions, {
    int retryCount = 3,
  }) async {
    int attempts = 0;
    while (attempts < retryCount) {
      try {
        attempts++;
        debugPrint('Retry attempt $attempts/$retryCount');
        await Future.delayed(Duration(seconds: attempts));
        return await _dio.request(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
        );
      } catch (e) {
        if (attempts >= retryCount) rethrow;
      }
    }
    throw Exception('Max retry attempts reached');
  }

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
    debugPrint('ApiService: Auth token set');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    debugPrint('ApiService: Auth token cleared');
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null;

  // ==================== AUTHENTICATION ====================

  /// Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.data['token'] != null) {
        setAuthToken(response.data['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Register new user
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );

      if (response.data['token'] != null) {
        setAuthToken(response.data['token']);
      }

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
      clearAuthToken();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh auth token
  Future<String> refreshToken() async {
    try {
      final response = await _dio.post('/auth/refresh');
      final newToken = response.data['token'];
      setAuthToken(newToken);
      return newToken;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== TASKS SYNC ====================

  /// Sync tasks with server
  Future<SyncResult> syncTasks(List<Task> localTasks) async {
    try {
      final response = await _dio.post(
        '/sync/tasks',
        data: {
          'tasks': localTasks.map((task) => _taskToJson(task)).toList(),
          'last_sync': DateTime.now().toIso8601String(),
        },
      );

      final serverTasks = (response.data['tasks'] as List)
          .map((json) => _taskFromJson(json))
          .toList();

      final deletedIds =
          (response.data['deleted_ids'] as List?)
              ?.map((id) => id as int)
              .toList() ??
          [];

      return SyncResult(
        tasks: serverTasks,
        deletedIds: deletedIds,
        lastSync: DateTime.parse(response.data['last_sync']),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch all tasks from server
  Future<List<Task>> fetchTasks() async {
    try {
      final response = await _dio.get('/tasks');
      return (response.data['tasks'] as List)
          .map((json) => _taskFromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create task on server
  Future<Task> createTask(Task task) async {
    try {
      final response = await _dio.post('/tasks', data: _taskToJson(task));
      return _taskFromJson(response.data['task']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update task on server
  Future<Task> updateTask(Task task) async {
    try {
      final response = await _dio.put(
        '/tasks/${task.id}',
        data: _taskToJson(task),
      );
      return _taskFromJson(response.data['task']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete task on server
  Future<void> deleteTask(int taskId) async {
    try {
      await _dio.delete('/tasks/$taskId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Batch upload tasks
  Future<List<Task>> batchUploadTasks(List<Task> tasks) async {
    try {
      final response = await _dio.post(
        '/tasks/batch',
        data: {'tasks': tasks.map((task) => _taskToJson(task)).toList()},
      );
      return (response.data['tasks'] as List)
          .map((json) => _taskFromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== WORKSPACES SYNC ====================

  /// Sync workspaces with server
  Future<List<Workspace>> syncWorkspaces(
    List<Workspace> localWorkspaces,
  ) async {
    try {
      final response = await _dio.post(
        '/sync/workspaces',
        data: {
          'workspaces': localWorkspaces
              .map((ws) => _workspaceToJson(ws))
              .toList(),
        },
      );
      return (response.data['workspaces'] as List)
          .map((json) => _workspaceFromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch workspaces from server
  Future<List<Workspace>> fetchWorkspaces() async {
    try {
      final response = await _dio.get('/workspaces');
      return (response.data['workspaces'] as List)
          .map((json) => _workspaceFromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== TAGS SYNC ====================

  /// Sync tags with server
  Future<List<Tag>> syncTags(List<Tag> localTags) async {
    try {
      final response = await _dio.post(
        '/sync/tags',
        data: {'tags': localTags.map((tag) => _tagToJson(tag)).toList()},
      );
      return (response.data['tags'] as List)
          .map((json) => _tagFromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== HELPER METHODS ====================

  /// Convert Task to JSON
  Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id == 0 ? null : task.id,
      'title': task.title,
      'description': task.description,
      'due_date': task.dueDate.toIso8601String(),
      'is_completed': task.isCompleted,
      'priority': task.priority.index,
      'created_at': task.createdAt.toIso8601String(),
      'category': task.category,
      'workspace_id': task.workspaceId,
      'progress': task.progress,
      'estimated_hours': task.estimatedHours,
      'tag_ids': task.tagIds,
    };
  }

  /// Convert JSON to Task
  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      isCompleted: json['is_completed'] ?? false,
      priority: TaskPriority.values[json['priority'] ?? 1],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at']),
      category: json['category'],
      workspaceId: json['workspace_id'],
      progress: json['progress']?.toDouble(),
      estimatedHours: json['estimated_hours'],
      tagIds: (json['tag_ids'] as List?)?.map((id) => id as int).toList(),
    );
  }

  /// Convert Workspace to JSON
  Map<String, dynamic> _workspaceToJson(Workspace workspace) {
    return {
      'id': workspace.id == 0 ? null : workspace.id,
      'name': workspace.name,
      'description': workspace.description,
      'icon': workspace.iconName,
      'color': workspace.colorHex,
      'created_at': workspace.createdAt.toIso8601String(),
      'total_tasks': workspace.totalTasks,
      'completed_tasks': workspace.completedTasks,
    };
  }

  /// Convert JSON to Workspace
  Workspace _workspaceFromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      iconName: json['icon'] ?? 'work',
      colorHex: json['color'] ?? 'blue',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at'] ?? json['created_at']),
      order: json['order'] ?? 0,
      totalTasks: json['total_tasks'] ?? 0,
      completedTasks: json['completed_tasks'] ?? 0,
    );
  }

  /// Convert Tag to JSON
  Map<String, dynamic> _tagToJson(Tag tag) {
    return {
      'id': tag.id == 0 ? null : tag.id,
      'name': tag.name,
      'color': tag.colorHex,
      'created_at': tag.createdAt.toIso8601String(),
    };
  }

  /// Convert JSON to Tag
  Tag _tagFromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      colorHex: json['color'] ?? '#45B7D1',
      createdAt: DateTime.parse(json['created_at']),
      usageCount: json['usage_count'] ?? 0,
    );
  }

  /// Handle API errors
  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.sendTimeout:
        return ApiException('Send timeout. Please try again.');
      case DioExceptionType.receiveTimeout:
        return ApiException('Receive timeout. Server is not responding.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.data['message'] ?? 'Unknown error';
        return ApiException('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return ApiException('Request cancelled');
      case DioExceptionType.connectionError:
        return ApiException(
          'No internet connection. Please check your network.',
        );
      default:
        return ApiException('An unexpected error occurred: ${error.message}');
    }
  }

  /// Check network connectivity
  Future<bool> checkConnectivity() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get server status
  Future<Map<String, dynamic>> getServerStatus() async {
    try {
      final response = await _dio.get('/status');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel all pending requests
  void cancelAllRequests() {
    _dio.close(force: true);
    debugPrint('ApiService: All requests cancelled');
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
    _isInitialized = false;
    debugPrint('ApiService: Disposed');
  }
}

/// Sync result model
class SyncResult {
  final List<Task> tasks;
  final List<int> deletedIds;
  final DateTime lastSync;

  SyncResult({
    required this.tasks,
    required this.deletedIds,
    required this.lastSync,
  });
}

/// Custom API exception
class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
