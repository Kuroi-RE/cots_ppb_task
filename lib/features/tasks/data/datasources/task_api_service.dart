import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/task.dart';

class TaskApiService {
  // GET all tasks
  Future<List<Task>> getTasks() async {
    try {
      final url = Uri.parse('${ApiConfig.tasksUrl}?select=*');
      final response = await http.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat daftar tugas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data tugas: $e');
    }
  }

  // GET tasks by status
  Future<List<Task>> getTasksByStatus(String status) async {
    try {
      final url = Uri.parse('${ApiConfig.tasksUrl}?select=*&status=eq.$status');
      final response = await http.get(url, headers: ApiConfig.headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Task.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat tugas dengan status $status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saat mengambil data tugas: $e');
    }
  }

  // POST new task
  Future<Task> addTask(Task task) async {
    try {
      final url = Uri.parse(ApiConfig.tasksUrl);
      final response = await http.post(
        url,
        headers: ApiConfig.headersWithContentType,
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Task.fromJson(data[0]);
        } else {
          throw Exception('Tidak ada data yang dikembalikan setelah menambah tugas');
        }
      } else {
        throw Exception('Gagal menambah tugas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat menambah tugas: $e');
    }
  }

  // PATCH update task note
  Future<Task> updateTaskNote(int taskId, String note) async {
    try {
      final url = Uri.parse('${ApiConfig.tasksUrl}?id=eq.$taskId');
      final response = await http.patch(
        url,
        headers: ApiConfig.headersWithContentType,
        body: json.encode({'note': note}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Task.fromJson(data[0]);
        } else {
          throw Exception('Tidak ada data yang dikembalikan setelah update');
        }
      } else {
        throw Exception('Gagal update catatan: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat update catatan: $e');
    }
  }

  // PATCH toggle task completion
  Future<Task> toggleTaskCompletion(int taskId, bool isDone) async {
    try {
      final url = Uri.parse('${ApiConfig.tasksUrl}?id=eq.$taskId');
      
      // Set status based on isDone
      final String newStatus = isDone ? 'SELESAI' : 'BERJALAN';
      
      final response = await http.patch(
        url,
        headers: ApiConfig.headersWithContentType,
        body: json.encode({
          'is_done': isDone,
          'status': newStatus,
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Task.fromJson(data[0]);
        } else {
          throw Exception('Tidak ada data yang dikembalikan setelah update');
        }
      } else {
        throw Exception('Gagal toggle status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat toggle status: $e');
    }
  }

  // PATCH update entire task (for more complex updates if needed)
  Future<Task> updateTask(int taskId, Map<String, dynamic> updates) async {
    try {
      final url = Uri.parse('${ApiConfig.tasksUrl}?id=eq.$taskId');
      final response = await http.patch(
        url,
        headers: ApiConfig.headersWithContentType,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return Task.fromJson(data[0]);
        } else {
          throw Exception('Tidak ada data yang dikembalikan setelah update');
        }
      } else {
        throw Exception('Gagal update tugas: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error saat update tugas: $e');
    }
  }
}
