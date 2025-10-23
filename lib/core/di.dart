import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../data/datasources/task_local_data_source.dart';
import '../data/datasources/workspace_local_data_source.dart';
import '../data/datasources/tag_local_data_source.dart';
import '../data/models/task_model.dart';
import '../data/models/workspace_model.dart';
import '../data/models/tag_model.dart';
import '../data/repositories/task_repository_impl.dart';
import '../data/repositories/workspace_repository_impl.dart';
import '../data/repositories/tag_repository_impl.dart';
import '../domain/repositories/task_repository.dart';
import '../domain/repositories/workspace_repository.dart';
import '../domain/repositories/tag_repository.dart';
import '../domain/usecases/create_task_use_case.dart';
import '../domain/usecases/create_workspace_use_case.dart';
import '../domain/usecases/create_tag_use_case.dart';
import '../domain/usecases/delete_task_use_case.dart';
import '../domain/usecases/delete_workspace_use_case.dart';
import '../domain/usecases/delete_tag_use_case.dart';
import '../domain/usecases/get_all_tasks_use_case.dart';
import '../domain/usecases/get_all_workspaces_use_case.dart';
import '../domain/usecases/get_all_tags_use_case.dart';
import '../domain/usecases/get_tasks_by_workspace_id_use_case.dart';
import '../domain/usecases/update_task_use_case.dart';
import '../domain/usecases/update_workspace_use_case.dart';
import '../presentation/blocs/task_bloc.dart';
import '../presentation/blocs/workspace_bloc.dart';
import '../presentation/blocs/tag_bloc.dart';
import 'app_state_provider.dart';

/// Dependency Injection Container
/// Manages all app dependencies using a simple service locator pattern
/// Initializes Isar database and provides instances of repositories, use cases, and BLoCs
class DI {
  static late Isar _isar;
  static late TaskLocalDataSource _taskLocalDataSource;
  static late WorkspaceLocalDataSource _workspaceLocalDataSource;
  static late TagLocalDataSource _tagLocalDataSource;
  static late TaskRepository _taskRepository;
  static late WorkspaceRepository _workspaceRepository;
  static late TagRepository _tagRepository;
  static late AppStateProvider _appStateProvider;
  static late GetAllTasksUseCase _getAllTasksUseCase;
  static late GetAllWorkspacesUseCase _getAllWorkspacesUseCase;
  static late GetAllTagsUseCase _getAllTagsUseCase;
  static late GetTasksByWorkspaceIdUseCase _getTasksByWorkspaceIdUseCase;
  static late CreateTaskUseCase _createTaskUseCase;
  static late CreateWorkspaceUseCase _createWorkspaceUseCase;
  static late CreateTagUseCase _createTagUseCase;
  static late UpdateTaskUseCase _updateTaskUseCase;
  static late UpdateWorkspaceUseCase _updateWorkspaceUseCase;
  static late DeleteTaskUseCase _deleteTaskUseCase;
  static late DeleteWorkspaceUseCase _deleteWorkspaceUseCase;
  static late DeleteTagUseCase _deleteTagUseCase;

  /// Initialize all dependencies
  /// Must be called before using any dependencies
  static Future<void> init() async {
    // Initialize Isar database
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [TaskModelSchema, WorkspaceModelSchema, TagModelSchema],
      directory: dir.path,
      inspector: true, // Enable Isar Inspector for debugging
    );

    // Initialize data sources
    _taskLocalDataSource = TaskLocalDataSource(_isar);
    _workspaceLocalDataSource = WorkspaceLocalDataSource(_isar);
    _tagLocalDataSource = TagLocalDataSourceImpl(_isar);

    // Initialize repositories
    _workspaceRepository = WorkspaceRepositoryImpl(localDataSource: _workspaceLocalDataSource);
    _taskRepository = TaskRepositoryImpl(
      localDataSource: _taskLocalDataSource,
      workspaceRepository: _workspaceRepository,
    );
    _tagRepository = TagRepositoryImpl(localDataSource: _tagLocalDataSource);
    _appStateProvider = AppStateProvider();

    // Initialize use cases
    _getAllTasksUseCase = GetAllTasksUseCase(_taskRepository);
    _getAllWorkspacesUseCase = GetAllWorkspacesUseCase(_workspaceRepository);
    _getAllTagsUseCase = GetAllTagsUseCase(_tagRepository);
    _getTasksByWorkspaceIdUseCase = GetTasksByWorkspaceIdUseCase(_taskRepository);
    _createTaskUseCase = CreateTaskUseCase(_taskRepository);
    _createWorkspaceUseCase = CreateWorkspaceUseCase(_workspaceRepository);
    _createTagUseCase = CreateTagUseCase(_tagRepository);
    _updateTaskUseCase = UpdateTaskUseCase(_taskRepository);
    _updateWorkspaceUseCase = UpdateWorkspaceUseCase(_workspaceRepository);
    _deleteTaskUseCase = DeleteTaskUseCase(_taskRepository);
    _deleteWorkspaceUseCase = DeleteWorkspaceUseCase(_workspaceRepository, _taskRepository);
    _deleteTagUseCase = DeleteTagUseCase(_tagRepository);

    // Initialize seed data if database is empty (disabled for now)
    // await _initializeSeedData();
  }

  /// Get Isar instance
  static Isar get isar => _isar;

  /// Get Task Local Data Source
  static TaskLocalDataSource get taskLocalDataSource => _taskLocalDataSource;

  /// Get Workspace Local Data Source
  static WorkspaceLocalDataSource get workspaceLocalDataSource => _workspaceLocalDataSource;

  /// Get Tag Local Data Source
  static TagLocalDataSource get tagLocalDataSource => _tagLocalDataSource;

  /// Get Task Repository
  static TaskRepository get taskRepository => _taskRepository;

  /// Get Workspace Repository
  static WorkspaceRepository get workspaceRepository => _workspaceRepository;

  /// Get Tag Repository
  static TagRepository get tagRepository => _tagRepository;

  /// Get App State Provider
  static AppStateProvider get appStateProvider => _appStateProvider;

  /// Get All Tasks Use Case
  static GetAllTasksUseCase get getAllTasksUseCase => _getAllTasksUseCase;

  /// Get All Workspaces Use Case
  static GetAllWorkspacesUseCase get getAllWorkspacesUseCase => _getAllWorkspacesUseCase;

  /// Get All Tags Use Case
  static GetAllTagsUseCase get getAllTagsUseCase => _getAllTagsUseCase;

  /// Get Tasks By Workspace ID Use Case
  static GetTasksByWorkspaceIdUseCase get getTasksByWorkspaceIdUseCase => _getTasksByWorkspaceIdUseCase;

  /// Get Create Task Use Case
  static CreateTaskUseCase get createTaskUseCase => _createTaskUseCase;

  /// Get Create Workspace Use Case
  static CreateWorkspaceUseCase get createWorkspaceUseCase => _createWorkspaceUseCase;

  /// Get Create Tag Use Case
  static CreateTagUseCase get createTagUseCase => _createTagUseCase;

  /// Get Update Task Use Case
  static UpdateTaskUseCase get updateTaskUseCase => _updateTaskUseCase;

  /// Get Update Workspace Use Case
  static UpdateWorkspaceUseCase get updateWorkspaceUseCase => _updateWorkspaceUseCase;

  /// Get Delete Task Use Case
  static DeleteTaskUseCase get deleteTaskUseCase => _deleteTaskUseCase;

  /// Get Delete Workspace Use Case
  static DeleteWorkspaceUseCase get deleteWorkspaceUseCase => _deleteWorkspaceUseCase;

  /// Get Delete Tag Use Case
  static DeleteTagUseCase get deleteTagUseCase => _deleteTagUseCase;

  /// Create Task BLoC instance
  /// Creates a new instance each time (for BlocProvider)
  static TaskBloc createTaskBloc() {
    return TaskBloc(
      getAllTasksUseCase: _getAllTasksUseCase,
      getTasksByWorkspaceIdUseCase: _getTasksByWorkspaceIdUseCase,
      createTaskUseCase: _createTaskUseCase,
      updateTaskUseCase: _updateTaskUseCase,
      deleteTaskUseCase: _deleteTaskUseCase,
      taskRepository: _taskRepository,
      tagRepository: _tagRepository,
      appStateProvider: _appStateProvider,
    );
  }

  /// Create Workspace BLoC instance
  /// Creates a new instance each time (for BlocProvider)
  static WorkspaceBloc createWorkspaceBloc() {
    return WorkspaceBloc(
      getAllWorkspacesUseCase: _getAllWorkspacesUseCase,
      createWorkspaceUseCase: _createWorkspaceUseCase,
      updateWorkspaceUseCase: _updateWorkspaceUseCase,
      deleteWorkspaceUseCase: _deleteWorkspaceUseCase,
      workspaceRepository: _workspaceRepository,
    );
  }

  /// Create Tag BLoC instance
  /// Creates a new instance each time (for BlocProvider)
  static TagBloc createTagBloc() {
    return TagBloc(
      getAllTagsUseCase: _getAllTagsUseCase,
      createTagUseCase: _createTagUseCase,
      deleteTagUseCase: _deleteTagUseCase,
    );
  }


  /// Dispose resources
  /// Call this when the app is closing
  static Future<void> dispose() async {
    await _isar.close();
  }
}
