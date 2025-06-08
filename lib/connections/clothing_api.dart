import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/clothing_item.dart';
import '../utils/jwt_storage.dart';
import 'api_config.dart';

class ClothingApi {
  final String _base = ApiConfig.baseUrl;

  Future<List<ClothingItem>> getUserClothing(int userId) async {
    final token = await JwtStorage.getToken();
    final response = await http.get(Uri.parse('$_base/clothes/user/$userId'), headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      return data.map((e) => ClothingItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch user clothing items');
    }
  }

  Future<ClothingItem> uploadClothingItem(int userId, File file) async {
    final token = await JwtStorage.getToken();
    final request = http.MultipartRequest('POST', Uri.parse('$_base/clothes'))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['userId'] = userId.toString()
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseBody = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      return ClothingItem.fromJson(json.decode(responseBody.body));
    } else {
      throw Exception('Upload failed: ${response.statusCode}');
    }
  }

  Future<void> updateClothingItem(ClothingItem item) async {
    final token = await JwtStorage.getToken();
    final response = await http.put(
      Uri.parse('$_base/clothes/${item.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(item.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update item');
    }
  }

  Future<void> deleteClothingItem(int itemId) async {
    final token = await JwtStorage.getToken();
    final response = await http.delete(
      Uri.parse('$_base/clothes/$itemId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete item: ${response.statusCode}');
    }
  }

  Future<ClothingItem> getClothingItemById(int itemId) async {
  final token = await JwtStorage.getToken();
  final response = await http.get(
    Uri.parse('$_base/clothes/$itemId'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return ClothingItem.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to fetch clothing item');
  }
}

}
