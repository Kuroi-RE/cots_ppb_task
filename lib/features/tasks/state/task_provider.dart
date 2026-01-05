import 'package:flutter/foundation.dart';
import '../data/datasources/task_api_service.dart';
import '../data/models/task.dart';

class TaskProvider extends ChangeNotifier {
  final TaskApiService _apiService = TaskApiService();

  // State variables
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String? _selectedStatus;
  String _searchQuery = '';

  // Getters
  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  // Get tasks filtered by current selected status and search query
  List<Task> get filteredTasks {
    List<Task> filtered = _tasks;

    // Filter by status
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered
          .where((task) => task.status == _selectedStatus)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((task) {
        final title = task.title.toLowerCase();
        final course = task.course.toLowerCase();
        final note = task.note.toLowerCase();
        return title.contains(query) ||
            course.contains(query) ||
            note.contains(query);
      }).toList();
    }

    return filtered;
  }

  // Get task counts by status
  int get totalTasks => _tasks.length;
  int get berjalaanCount =>
      _tasks.where((task) => task.status == 'BERJALAN').length;
  int get selesaiCount =>
      _tasks.where((task) => task.status == 'SELESAI').length;
  int get terlambatCount =>
      _tasks.where((task) => task.status == 'TERLAMBAT').length;

  // Get nearest tasks (H-1 to H-3: 1 to 3 days from now)
  List<Task> get nearestTasks {
    final now = DateTime.now();
    final startDate = now.add(const Duration(days: 1)); // H-1
    final endDate = now.add(const Duration(days: 3)); // H-3

    // Filter tasks with deadline between H-1 and H-3, excluding completed
    final filteredTasks = _tasks.where((task) {
      if (task.status == 'SELESAI') return false;

      try {
        final deadline = DateTime.parse(task.deadline);
        // Reset time to midnight for date comparison
        final deadlineDate = DateTime(
          deadline.year,
          deadline.month,
          deadline.day,
        );
        final startDateMidnight = DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
        );
        final endDateMidnight = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
        );

        return deadlineDate.isAfter(
              startDateMidnight.subtract(const Duration(days: 1)),
            ) &&
            deadlineDate.isBefore(endDateMidnight.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();

    // Sort by deadline (nearest first)
    filteredTasks.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.deadline);
        final dateB = DateTime.parse(b.deadline);
        return dateA.compareTo(dateB);
      } catch (e) {
        return 0;
      }
    });

    return filteredTasks;
  }

  // Set selected status for filtering
  void setSelectedStatus(String? status) {
    _selectedStatus = status;
    notifyListeners();
  }

  // Set search query for filtering
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Fetch all tasks
  Future<void> fetchTasks() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _tasks = await _apiService.getTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Fetch tasks by status
  Future<void> fetchTasksByStatus(String status) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _tasks = await _apiService.getTasksByStatus(status);
      _selectedStatus = status;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Add new task
  Future<bool> addTask(Task task) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newTask = await _apiService.addTask(task);
      _tasks.add(newTask);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Update task note
  Future<bool> updateTaskNote(int taskId, String note) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final updatedTask = await _apiService.updateTaskNote(taskId, note);
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(int taskId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _apiService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Toggle task completion
  Future<bool> toggleTaskCompletion(int taskId, bool isDone) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final updatedTask = await _apiService.toggleTaskCompletion(
        taskId,
        isDone,
      );
      final index = _tasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Refresh tasks (fetch all again)
  Future<void> refreshTasks() async {
    await fetchTasks();
  }
}
