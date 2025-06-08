import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/person.dart';
import '../connections/api_config.dart';
import '../utils/jwt_storage.dart';

class PersonApi {
  final String _base = '${ApiConfig.baseUrl}/persons';

  Future<Map<String, String>> _headers() async {
    final token = await JwtStorage.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Person> getPersonById(int id) async {
    final response = await http.get(Uri.parse('$_base/$id'), headers: await _headers());

    if (response.statusCode == 200) {
      return Person.fromJson(json.decode(response.body));
    } else {
      throw Exception('Не вдалося отримати персону за ID');
    }
  }

  Future<Person> createPerson(Person person) async {
    final response = await http.post(
      Uri.parse(_base),
      headers: await _headers(),
      body: json.encode(person.toCreateJson()),
    );

    if (response.statusCode == 200) {
      return Person.fromJson(json.decode(response.body));
    } else {
      throw Exception('Не вдалося створити персону');
    }
  }

  Future<void> updatePerson(Person person) async {
    final response = await http.put(
      Uri.parse('$_base/${person.id}'),
      headers: await _headers(),
      body: json.encode(person.toEditJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Не вдалося оновити персону');
    }
  }

  Future<void> deletePerson(int id) async {
    final response = await http.delete(Uri.parse('$_base/$id'), headers: await _headers());

    if (response.statusCode != 200) {
      throw Exception('Не вдалося видалити персону');
    }
  }

  Future<Person> createPersonWithPhoto(Person person, File imageFile) async {
    final token = await JwtStorage.getToken();
    final uri = Uri.parse('$_base/photo');

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile.fromString(
          'personDto',
          json.encode(person.toCreateJson()),
          contentType: MediaType('application', 'json'),
        ),
      )
      ..files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return Person.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Не вдалося створити персону з фото: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> updatePersonWithPhoto(Person person, File imageFile) async {
  final token = await JwtStorage.getToken();
  final uri = Uri.parse('$_base/photo/${person.id}');

  final request = http.MultipartRequest('PUT', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..files.add(
      http.MultipartFile.fromString(
        'personDto',
        json.encode(person.toEditJson()),
        contentType: MediaType('application', 'json'),
      ),
    )
    ..files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

  final streamed = await request.send();
  final response = await http.Response.fromStream(streamed);

  if (response.statusCode != 200) {
    throw Exception(
      'Не вдалося оновити персону з фото: ${response.statusCode} ${response.body}',
    );
  }
}


  Future<Person> getPersonByUserId(int id) async {
    final response = await http.get(Uri.parse('$_base/user/$id'), headers: await _headers());

    if (response.statusCode == 200) {
      return Person.fromJson(json.decode(response.body));
    } else {
      throw Exception('Не вдалося отримати персону за ID');
    }
  }
}
