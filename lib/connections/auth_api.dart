import 'dart:async';
import 'dart:convert';
import 'package:bachelor/models/user.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class AuthApi {
  final String _base = "${ApiConfig.baseUrl}/auth";

  Future<String> login(String email, String password) async {
    print(password);
    final url = Uri.parse('$_base/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(User(email: email, password: password).toLoginJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token'];
    } else {
      throw Exception(
        'Не вдалось увійти: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> register(String username, String email, String password) async {
    final url = Uri.parse('$_base/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        User(name: username, email: email, password: password).toCreateJson(),
      ),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Не вдалось зареєструватись: ${response.statusCode} ${response.body}',
      );
    }
  }
}
