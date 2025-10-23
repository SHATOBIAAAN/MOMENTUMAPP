import 'package:isar/isar.dart';
import '../models/task_model.dart';
import '../../domain/entities/task.dart';

/// Local Data Source for Task operations using Isar
/// Handles all direct database interactions
class TaskLocalDataSource {
  final Isar isar;

  TaskLocalDataSource(this.isar);

  /// Get all tasks from the database
  Future<List<TaskModel>> getAllTasks() async {
    return await isar.taskModels.where().sortByDueDateDesc().findAll();
  }

  /// Get task by ID
  Future<TaskModel?> getTaskById(int id) async {
    return await isar.taskModels.get(id);
  }

  /// Get tasks by date range
  Future<List<TaskModel>> getTasksByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await isar.taskModels
        .filter()
        .dueDateBetween(start, end)
        .sortByDueDate()
        .findAll();
  }

  /// Get completed tasks
  Future<List<TaskModel>> getCompletedTasks() async {
    return await isar.taskModels
        .filter()
        .isCompletedEqualTo(true)
        .sortByDueDateDesc()
        .findAll();
  }

  /// Get pending (not completed) tasks
  Future<List<TaskModel>> getPendingTasks() async {
    return await isar.taskModels
        .filter()
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .findAll();
  }

  /// Get tasks by priority
  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
    return await isar.taskModels
        .filter()
        .priorityEqualTo(priority)
        .sortByDueDate()
        .findAll();
  }

  /// Get tasks by category
  Future<List<TaskModel>> getTasksByCategory(String category) async {
    return await isar.taskModels
        .filter()
        .categoryEqualTo(category)
        .sortByDueDate()
        .findAll();
  }

  /// Get tasks by workspace ID
  Future<List<TaskModel>> getTasksByWorkspaceId(int workspaceId) async {
    return await isar.taskModels
        .filter()
        .workspaceIdEqualTo(workspaceId)
        .sortByDueDate()
        .findAll();
  }


  /// Create a new task
  Future<int> createTask(TaskModel task) async {
    return await isar.writeTxn(() async {
      print('Creating task with ID: ${task.id}, title: ${task.title}');
      final result = await isar.taskModels.put(task);
      print('Task created with result ID: $result');
      return result;
    });
  }

  /// Update an existing task
  Future<void> updateTask(TaskModel task) async {
    await isar.writeTxn(() async {
      // Use putAll to ensure the task is updated properly
      await isar.taskModels.putAll([task]);
      print('Task updated in database: ID=${task.id}, title=${task.title}');
    });
  }

  /// Delete a task by ID
  Future<bool> deleteTask(int id) async {
    return await isar.writeTxn(() async {
      return await isar.taskModels.delete(id);
    });
  }

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(int id) async {
    await isar.writeTxn(() async {
      final task = await isar.taskModels.get(id);
      if (task != null) {
        task.isCompleted = !task.isCompleted;
        await isar.taskModels.put(task);
      }
    });
  }

  /// Delete all completed tasks
  Future<int> deleteCompletedTasks() async {
    return await isar.writeTxn(() async {
      return await isar.taskModels
          .filter()
          .isCompletedEqualTo(true)
          .deleteAll();
    });
  }

  /// Get total tasks count
  Future<int> getTasksCount() async {
    return await isar.taskModels.count();
  }

  /// Search tasks by title or description
  Future<List<TaskModel>> searchTasks(String query) async {
    final lowerQuery = query.toLowerCase();

    return await isar.taskModels
        .filter()
        .titleContains(lowerQuery, caseSensitive: false)
        .or()
        .descriptionContains(lowerQuery, caseSensitive: false)
        .sortByDueDate()
        .findAll();
  }

  /// Get tasks for today
  Future<List<TaskModel>> getTasksForToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return await getTasksByDateRange(startOfDay, endOfDay);
  }

  /// Get overdue tasks
  Future<List<TaskModel>> getOverdueTasks() async {
    final now = DateTime.now();

    return await isar.taskModels
        .filter()
        .dueDateLessThan(now)
        .and()
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .findAll();
  }

  /// Delete all tasks (use with caution!)
  Future<void> deleteAllTasks() async {
    await isar.writeTxn(() async {
      await isar.taskModels.clear();
    });
  }

  /// Watch all tasks for changes
  Stream<List<TaskModel>> watchAllTasks() {
    return isar.taskModels.where().watch(fireImmediately: true);
  }
}
