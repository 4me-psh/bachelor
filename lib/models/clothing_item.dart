import 'package:bachelor/connections/api_config.dart';

enum Category {
  Headwear('Головний убір'),
  Outerlayer('Верхній шар'),
  Innerlayer('Внутрішній шар'),
  Bottom('Низ'),
  Footwear('Взуття'),
  Single('Одинарний одяг'),
  Accessories('Аксесуари');

  final String nameUa;
  const Category(this.nameUa);
}

enum Style {
  Sporty('Спортивний'),
  Casual('Повсякденний'),
  Business('Діловий'),
  Evening('Вечірній');

  final String nameUa;
  const Style(this.nameUa);
}

enum TemperatureCategory {
  ExtremeHeat('Сильна спека'),
  Hot('Жарко'),
  Warm('Тепло'),
  MildWarm('Помірно тепло'),
  Cool('Прохолодно'),
  Cold('Холодно'),
  LightFrost('Легкий мороз'),
  ChillyFrost('Зимно'),
  Frost('Мороз'),
  SevereFrost('Сильний мороз'),
  ExtremeCold('Суворий холод');

  final String nameUa;
  const TemperatureCategory(this.nameUa);
}

class ClothingItem {
  final int id;
  final String name;
  final String color;
  final String material;
  final List<Style> styles;
  final String pathToPhoto;
  final String pathToRemovedBgPhoto;
  final Category pieceCategory;
  final List<TemperatureCategory> temperatureCategories;
  final List<String> characteristics;
  final bool useRemovedBg;

  ClothingItem({
    required this.id,
    required this.name,
    required this.color,
    required this.material,
    required this.styles,
    required this.pathToPhoto,
    required this.pathToRemovedBgPhoto,
    required this.pieceCategory,
    required this.temperatureCategories,
    required this.characteristics,
    required this.useRemovedBg,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      material: json['material'],
      styles:
          (json['styles'] as List)
              .map(
                (s) => Style.values.firstWhere(
                  (e) => e.name == s || e.toString().split('.').last == s,
                  orElse: () => Style.Casual,
                ),
              )
              .toList(),
      pathToPhoto: json['pathToPhoto'],
      pathToRemovedBgPhoto: json['pathToRemovedBgPhoto'],
      pieceCategory: Category.values.firstWhere(
        (e) =>
            e.name == json['pieceCategory'] ||
            e.toString().split('.').last == json['pieceCategory'],
        orElse: () => Category.Single,
      ),
      temperatureCategories:
          (json['temperatureCategories'] as List)
              .map(
                (e) => TemperatureCategory.values.firstWhere(
                  (t) => t.name == e || t.toString().split('.').last == e,
                  orElse: () => TemperatureCategory.Warm,
                ),
              )
              .toList(),
      characteristics: List<String>.from(json['characteristics'] ?? []),
      useRemovedBg: json['useRemovedBg'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'material': material,
      'styles': styles.map((e) => e.name).toList(),
      'pathToPhoto': pathToPhoto,
      'pathToRemovedBgPhoto': pathToRemovedBgPhoto,
      'pieceCategory': pieceCategory.name,
      'temperatureCategories':
          temperatureCategories.map((e) => e.name).toList(),
      'characteristics': characteristics,
      'useRemovedBg': useRemovedBg,
    };
  }

  String getImage({bool useRemovedBg = false}) {
    final path = Uri.encodeComponent(
      useRemovedBg ? pathToRemovedBgPhoto : pathToPhoto,
    );
    return "${ApiConfig.baseUrl}/resources?path=$path";
  }

  @override
  String toString() {
    return 'ClothingItem(id: $id, name: $name, color: $color, material: $material, '
        'styles: ${styles.map((e) => e.name).toList()}, '
        'pathToPhoto: $pathToPhoto, pathToRemovedBgPhoto: $pathToRemovedBgPhoto, '
        'pieceCategory: ${pieceCategory.name}, '
        'temperatureCategories: ${temperatureCategories.map((e) => e.name).toList()}, '
        'characteristics: $characteristics, useRemovedBg: $useRemovedBg)';
  }
}
