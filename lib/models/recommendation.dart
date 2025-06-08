import 'package:bachelor/connections/api_config.dart';

import 'person.dart';
import 'clothing_item.dart';

class Recommendation {
  final int? id;
  final String userPrompt;
  final int? personId;
  final Person? person;
  final List<String>? generatedImages;
  final List<ClothingItem>? recommendedClothes;
  final bool? favorite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Recommendation({
    this.id,
    required this.userPrompt,
    this.personId,
    this.person,
    this.generatedImages,
    this.recommendedClothes,
    this.favorite,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toCreateJson() {
    return {
      'userPrompt': userPrompt,
      'personId': personId,
    };
  }

  Map<String, dynamic> toEditJson() {
    return {
      'userPrompt': userPrompt,
      'generatedImages': generatedImages,
      'recommendedClothes': recommendedClothes?.map((e) => e.toJson()).toList(),
      'favorite': favorite,
    };
  }

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    print(json);
    final prompt = (json['userPrompt'] as String?)?.trim() ?? '';
    return Recommendation(
      id: json['id'],
      userPrompt: prompt,
      personId: json['personId'],
      person: json['person'] != null ? Person.fromJson(json['person']) : null,
      generatedImages: json['generatedImages'] != null
          ? List<String>.from(json['generatedImages'])
          : null,
      recommendedClothes: json['recommendedClothes'] != null
          ? (json['recommendedClothes'] as List<dynamic>)
              .map((e) => ClothingItem.fromJson(e))
              .toList()
          : null,
      favorite: json['favorite'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  List<String> getImageUrls() {
  if (generatedImages == null) return [];

  return generatedImages!.map((path) {
    final encodedPath = Uri.encodeComponent(path);
    return "${ApiConfig.baseUrl}/resources?path=$encodedPath";
  }).toList();
  }

  @override
  String toString() {
    return 'Recommendation('
        'id: $id, '
        'userPrompt: "$userPrompt", '
        'personId: $personId, '
        'favorite: $favorite, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'generatedImages: ${generatedImages?.length ?? 0} зображень, '
        'recommendedClothes: ${recommendedClothes?.map((e) => e.name).toList()}'
        ')';
  }
}
