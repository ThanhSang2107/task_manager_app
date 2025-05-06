import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task_model.dart';

class TaskService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/tasks';

  static Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('Token authentication null');
    }
    return token;
  }

  static Future<List<TaskModel>> getTasks() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => TaskModel.fromJson(item)).toList();
      } else {
        throw Exception('Không thể tải danh sách công việc. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  static Future<TaskModel> getTaskById(String id) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TaskModel.fromJson(data);
      } else {
        throw Exception('Không thể lấy công việc. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi lấy chi tiết công việc: $e');
    }
  }

  static Future<void> addTask(TaskModel task) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(task.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Không thể thêm công việc. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  static Future<void> updateTask(
      String id,
      String title,
      String description,
      bool completed,
      String status,
      int priority,
      ) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'description': description,
          'completed': completed,
          'status': status,
          'priority': priority,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Không thể cập nhật công việc. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  static Future<void> deleteTask(String id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Không thể xoá công việc. Mã lỗi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối API: $e');
    }
  }

  static Future<void> toggleTaskDone(TaskModel task) async {
    await updateTask(
      task.id,
      task.title,
      task.description,
      !task.completed,
      task.status,
      task.priority,
    );
  }
}
