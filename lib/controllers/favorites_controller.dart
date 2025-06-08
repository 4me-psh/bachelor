import '../models/clothing_item.dart';

class FavoritesController {
  final List<ClothingItem> favorites = [];

  void addToFavorites(ClothingItem item) {
    if (!favorites.any((i) => i.id == item.id)) {
      favorites.add(item);
    }
  }

  void removeFromFavorites(ClothingItem item) {
    favorites.removeWhere((i) => i.id == item.id);
  }

  bool isFavorite(ClothingItem item) {
    return favorites.any((i) => i.id == item.id);
  }
}
