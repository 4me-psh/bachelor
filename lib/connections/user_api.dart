import 'dart:convert';
import 'package:bachelor/models/user.dart';
import 'package:http/http.dart' as http;
import '../connections/api_config.dart';
import '../utils/jwt_storage.dart';

class UserApi {
  final String _base = "${ApiConfig.baseUrl}/users";

  Future<User> getUserByEmail(String email) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(
      Uri.parse('$_base/email/$email'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      User user = User.fromJson(data);
      return user;
    } else {
      throw Exception('Не вдалося отримати userId за email');
    }
  }

  Future<void> updateUser(User user) async {
  final token = await JwtStorage.getToken();
  if (user.id == null) {
    throw Exception('User ID не може бути null при оновленні');
  }

  final response = await http.put(
    Uri.parse('$_base/${user.id}'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(user.toEditJson()),
  );

  if (response.statusCode != 200) {
    throw Exception('Не вдалося оновити користувача: ${response.statusCode} ${response.body}');
  }
}

}
