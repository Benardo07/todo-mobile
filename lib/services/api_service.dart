import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import 'package:logger/logger.dart';

class ApiService {
  final String baseUrl = 'todo-website-alpha.vercel.app';
  final Logger logger = Logger();

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.https(baseUrl, path, queryParameters);
  }

  Future<List<Task>> fetchTasks() async {
  try {
    final uri = _buildUri('/api/trpc/task.getAll');
    logger.i('Fetching tasks from $uri');
    final response = await http.get(uri);
    logger.i('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      Map<String, dynamic> body = jsonDecode(response.body);
      if (body['result'] != null && body['result']['data'] != null && body['result']['data']['json'] != null) {
        List<dynamic> taskData = body['result']['data']['json'];  // Correct path according to your structure
        List<Task> tasks = taskData.map((dynamic item) => Task.fromJson(item)).toList();
        return tasks;
       } else {
        throw Exception('Unexpected JSON format: No data found');
      }
    } else {
      logger.w('Failed to load tasks with status code: ${response.statusCode}');
      logger.w('Response body: ${response.body}');
      throw Exception('Failed to load tasks');
    }
  } catch (e) {
    logger.e('Failed to load tasks: $e');
    throw Exception('Failed to load tasks: $e');
  }
}

  Future<bool> addTask(Task task) async {
    final uri = Uri.https(baseUrl, '/api/trpc/task.add', {'batch': '1'});

    final body = jsonEncode({
      '0': {
        'json': task.toJson()
      }
    });
    logger.i('Sending task to $uri with body $body');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    logger.i('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return true;
    } else {
      logger.w('Failed to add task with status code: ${response.statusCode}');
      logger.w('Response body: ${response.body}');
      return false;
    }
  }

   Future<bool> deleteTask(String taskId) async {
    final uri = _buildUri('/api/trpc/task.delete', {'batch': '1'});

    final body = jsonEncode({
      '0': {
        'json': {
          'id': taskId
        }
      }
    });
    logger.i('Sending delete request for task $taskId to $uri');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    logger.i('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return true;
    } else {
      logger.w('Failed to delete task with status code: ${response.statusCode}');
      logger.w('Response body: ${response.body}');
      return false;
    }
  }

  Future<bool> markTaskDone(String taskId) async {
    final uri = _buildUri('/api/trpc/task.markDone', {'batch': '1'});

    final body = jsonEncode({
      '0': {
        'json': {
          'id': taskId
        }
      }
    });
    logger.i('Sending mark done request for task $taskId to $uri');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    logger.i('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      return true;
    } else {
      logger.w('Failed to mark task done with status code: ${response.statusCode}');
      logger.w('Response body: ${response.body}');
      return false;
    }
  }

}
