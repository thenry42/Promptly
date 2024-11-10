import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<String> getBotResponse(String message) async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:5000/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'message': message}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body)['response'];
    } else {
      return 'Error: ${response.statusCode}';
    }
  }
}
