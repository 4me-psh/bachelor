import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recommendation.dart';
import '../connections/api_config.dart';
import '../utils/jwt_storage.dart';

class RecommendationApi {
  final String _base = '${ApiConfig.baseUrl}/recommendations';

  Future<String?> _getToken() async {
    return await JwtStorage.getToken();
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Recommendation>> getAll() async {
    final response = await http.get(Uri.parse(_base), headers: await _headers());

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Recommendation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch all recommendations');
    }
  }

  Future<Recommendation> createRecommendation(Recommendation recommendation) async {
    final response = await http.post(
      Uri.parse(_base),
      headers: await _headers(),
      body: json.encode(recommendation.toCreateJson()),
    );

    if (response.statusCode == 200) {
      return Recommendation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create recommendation');
    }
  }

  Future<Recommendation> getById(int id) async {
    final response = await http.get(Uri.parse('$_base/$id'), headers: await _headers());

    if (response.statusCode == 200) {
      return Recommendation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to fetch recommendation by ID');
    }
  }

  Future<void> editRecommendation(Recommendation recommendation) async {
    final response = await http.put(
      Uri.parse('$_base/${recommendation.id}'),
      headers: await _headers(),
      body: json.encode(recommendation.toEditJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit recommendation');
    }
  }

  Future<void> deleteRecommendation(int id) async {
    final response = await http.delete(Uri.parse('$_base/$id'), headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to delete recommendation');
    }
  }

  Future<List<Recommendation>> getByPersonId(int personId) async {
    final response = await http.get(
      Uri.parse('$_base/person/$personId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Recommendation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch recommendations by personId');
    }
  }

  Future<void> generateImages(int id) async {
    final response = await http.put(Uri.parse('$_base/generate/$id'), headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Failed to generate images');
    }
  }

  Future<List<Recommendation>> getFavoritesByPersonId(int personId) async {
    final response = await http.get(
      Uri.parse('$_base/person/favorites/$personId'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Recommendation.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch favorite recommendations');
    }
  }
}
