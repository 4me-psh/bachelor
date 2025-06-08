import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import '../models/weather_info.dart';
import '../utils/jwt_storage.dart';

class WeatherApi {
  final String _base = ApiConfig.baseUrl;

  Future<WeatherInfo> fetchWeatherByCity(String city) async {
    final token = await JwtStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Користувач не авторизований (токен відсутній)');
    }

    final url = Uri.parse('$_base/weather/$city');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return WeatherInfo.fromJson(jsonBody);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw Exception('Помилка авторизації: ${response.statusCode}');
    } else {
      throw Exception('Не вдалося отримати погоду (${response.statusCode})');
    }
  }

  Future<WeatherInfo> fetchWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    final token = await JwtStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Користувач не авторизований (токен відсутній)');
    }
    final url = Uri.parse('$_base/weather/coordinates/$latitude,$longitude');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return WeatherInfo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Не вдалося завантажити погоду за координатами');
    }
  }
}
