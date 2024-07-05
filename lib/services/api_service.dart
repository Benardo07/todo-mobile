import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl = "http://your-api-url.com/api"; // Change this URL to your API's base URL

  Future<List<dynamic>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tasks')); // Adjust the endpoint as necessary
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load tasks');
      }
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }
}
