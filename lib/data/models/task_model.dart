import 'package:isar/isar.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

/// Task Model for Isar Database
/// This is the data layer representation of a Task
/// Uses Isar annotations for database operations
@collection
class TaskModel {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  @Index()
  late DateTime dueDate;

  late bool isCompleted;

  @Enumerated(EnumType.ordinal)
  late TaskPriority priority;

  late DateTime createdAt;

  String? category;

  @Index()
  int? workspaceId;

  double? progress;

  int? estimatedHours;

  List<int>? tagIds;

  /// Default constructor required by Isar
  TaskModel();

  /// Constructor from domain entity
  TaskModel.fromEntity(Task task) {
    // Only set ID if it's not 0 (new task)
    if (task.id != 0) {
      id = task.id;
      print('TaskModel.fromEntity: Using existing ID ${task.id}');
    } else {
      id = Isar.autoIncrement;
      print('TaskModel.fromEntity: Using autoIncrement for new task');
    }
    title = task.title;
    description = task.description;
    dueDate = task.dueDate;
    isCompleted = task.isCompleted;
    priority = task.priority;
    createdAt = task.createdAt;
    category = task.category;
    workspaceId = task.workspaceId;
    progress = task.progress;
    estimatedHours = task.estimatedHours;
    tagIds = task.tagIds;
    print('TaskModel.fromEntity: Final ID = $id, title = $title');
  }

  /// Update existing model with new data
  void updateFromEntity(Task task) {
    title = task.title;
    description = task.description;
    dueDate = task.dueDate;
    isCompleted = task.isCompleted;
    priority = task.priority;
    category = task.category;
    workspaceId = task.workspaceId;
    progress = task.progress;
    estimatedHours = task.estimatedHours;
    tagIds = task.tagIds;
    print('TaskModel.updateFromEntity: Updated ID = $id, title = $title');
  }

  /// Convert model to domain entity
  Task toEntity() {
    print('TaskModel.toEntity: ID = $id, title = $title');
    
    return Task(
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      isCompleted: isCompleted,
      updatedAt: createdAt,
      priority: priority,
      createdAt: createdAt,
      category: category,
      workspaceId: workspaceId,
      progress: progress,
      estimatedHours: estimatedHours,
      tagIds: tagIds,
    );
  }

  /// Create a new task model for insertion
  factory TaskModel.create({
    required String title,
    String? description,
    required DateTime dueDate,
    TaskPriority priority = TaskPriority.medium,
    String? category,
    int? workspaceId,
    double? progress,
    int? estimatedHours,
    List<int>? tagIds,
  }) {
    return TaskModel()
      ..id = Isar.autoIncrement
      ..title = title
      ..description = description
      ..dueDate = dueDate
      ..isCompleted = false
      ..priority = priority
      ..createdAt = DateTime.now()
      ..category = category
      ..workspaceId = workspaceId
      ..progress = progress
      ..estimatedHours = estimatedHours
      ..tagIds = tagIds;
  }

  /// Copy with method for updates
  TaskModel copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
    String? category,
    int? workspaceId,
    double? progress,
    int? estimatedHours,
    List<int>? tagIds,
  }) {
    return TaskModel()
      ..id = id ?? this.id
      ..title = title ?? this.title
      ..description = description ?? this.description
      ..dueDate = dueDate ?? this.dueDate
      ..isCompleted = isCompleted ?? this.isCompleted
      ..priority = priority ?? this.priority
      ..createdAt = createdAt ?? this.createdAt
      ..category = category ?? this.category
      ..workspaceId = workspaceId ?? this.workspaceId
      ..progress = progress ?? this.progress
      ..estimatedHours = estimatedHours ?? this.estimatedHours
      ..tagIds = tagIds ?? this.tagIds;
  }
}
