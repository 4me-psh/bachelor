import 'package:bachelor/connections/api_config.dart';

import 'user.dart';

enum Gender {
  male('Чоловіча'),
  female('Жіноча');

  final String nameUa;
  const Gender(this.nameUa);
}

enum SkinTone {
  light('Світлий'),
  mediumLight('Середньо-світлий'),
  medium('Середній'),
  mediumDark('Середньо-темний'),
  dark('Темний');

  final String nameUa;
  const SkinTone(this.nameUa);
}

class Person {
  final int? id;
  final int? userId;
  final Gender gender;
  final SkinTone skinTone;
  final String hairColor;
  final double height;
  final int age;
  final String? pathToPerson;
  final User? user;

  Person({
    this.id,
    this.userId,
    required this.gender,
    required this.skinTone,
    required this.hairColor,
    required this.height,
    required this.age,
    required this.pathToPerson,
    this.user,
  });

  Map<String, dynamic> toCreateJson() {
    return {
      'userId': userId,
      'gender': _genderToString(gender),
      'skinTone': _skinToneToString(skinTone),
      'hairColor': hairColor,
      'height': height,
      'age': age,
      'pathToPerson': pathToPerson,
    };
  }

  Map<String, dynamic> toEditJson() {
    return {
      'gender': _genderToString(gender),
      'skinTone': _skinToneToString(skinTone),
      'hairColor': hairColor,
      'height': height,
      'age': age,
      'pathToPerson': pathToPerson,
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'],
      userId: json['userId'],
      gender: _genderFromString(json['gender']),
      skinTone: _skinToneFromString(json['skinTone']),
      hairColor: json['hairColor'],
      height: (json['height'] as num).toDouble(),
      age: json['age'],
      pathToPerson: json['pathToPerson'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  static Gender _genderFromString(String value) {
    switch (value.toUpperCase()) {
      case 'MALE':
        return Gender.male;
      case 'FEMALE':
        return Gender.female;
      default:
        throw Exception('Невідомо: $value');
    }
  }

  static String _genderToString(Gender gender) {
    return gender == Gender.male ? 'MALE' : 'FEMALE';
  }

  static SkinTone _skinToneFromString(String value) {
    switch (value.toUpperCase()) {
      case 'LIGHT':
        return SkinTone.light;
      case 'MEDIUMLIGHT':
        return SkinTone.mediumLight;
      case 'MEDIUM':
        return SkinTone.medium;
      case 'MEDIUMDARK':
        return SkinTone.mediumDark;
      case 'DARK':
        return SkinTone.dark;
      default:
        throw Exception('Невідомо: $value');
    }
  }

  static String _skinToneToString(SkinTone tone) {
    switch (tone) {
      case SkinTone.light:
        return 'LIGHT';
      case SkinTone.mediumLight:
        return 'MEDIUMLIGHT';
      case SkinTone.medium:
        return 'MEDIUM';
      case SkinTone.mediumDark:
        return 'MEDIUMDARK';
      case SkinTone.dark:
        return 'DARK';
    }
  }

  String getImage() {
    final path = Uri.encodeComponent(
      pathToPerson!,
    );
    return "${ApiConfig.baseUrl}/resources?path=$path";
  }

}
