import 'package:isar/isar.dart';

part 'workspace_model.g.dart';

/// WorkspaceModel - Data model for workspace entity
/// Represents a workspace in the Isar database
@collection
class WorkspaceModel {
  /// Unique identifier
  Id id = Isar.autoIncrement;

  /// Workspace name
  @Index()
  late String name;

  /// Optional description
  String? description;

  /// Icon name for the workspace
  late String iconName;

  /// Color hex code for the workspace
  late String colorHex;

  /// Creation timestamp
  @Index()
  late DateTime createdAt;

  /// Order for sorting workspaces
  @Index()
  late int order;

  /// Total number of tasks in this workspace
  late int totalTasks;

  /// Number of completed tasks in this workspace
  late int completedTasks;

  /// Default constructor
  WorkspaceModel();

  /// Named constructor with all parameters
  WorkspaceModel.create({
    required this.name,
    this.description,
    required this.iconName,
    required this.colorHex,
    required this.order,
    this.totalTasks = 0,
    this.completedTasks = 0,
  }) : createdAt = DateTime.now();

  /// Copy with method
  WorkspaceModel copyWith({
    Id? id,
    String? name,
    String? description,
    String? iconName,
    String? colorHex,
    DateTime? createdAt,
    int? order,
    int? totalTasks,
    int? completedTasks,
  }) {
    return WorkspaceModel.create(
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      order: order ?? this.order,
    )
      ..id = id ?? this.id
      ..createdAt = createdAt ?? this.createdAt
      ..totalTasks = totalTasks ?? this.totalTasks
      ..completedTasks = completedTasks ?? this.completedTasks;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'createdAt': createdAt.toIso8601String(),
      'order': order,
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
    };
  }

  /// Create from JSON
  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    final model = WorkspaceModel.create(
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['iconName'] as String,
      colorHex: json['colorHex'] as String,
      order: json['order'] as int,
    );
    model.id = json['id'] as Id;
    model.createdAt = DateTime.parse(json['createdAt'] as String);
    model.totalTasks = json['totalTasks'] as int? ?? 0;
    model.completedTasks = json['completedTasks'] as int? ?? 0;
    return model;
  }

  @override
  String toString() {
    return 'WorkspaceModel(id: $id, name: $name, iconName: $iconName, colorHex: $colorHex)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkspaceModel &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.iconName == iconName &&
        other.colorHex == colorHex &&
        other.createdAt == createdAt &&
        other.order == order &&
        other.totalTasks == totalTasks &&
        other.completedTasks == completedTasks;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      iconName,
      colorHex,
      createdAt,
      order,
      totalTasks,
      completedTasks,
    );
  }
}
