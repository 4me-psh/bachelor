import 'package:flutter/material.dart';
import '../connections/clothing_api.dart';
import '../models/clothing_item.dart';

class GalleryController extends ChangeNotifier {
  final ClothingApi _api = ClothingApi();

  List<ClothingItem> _items = [];
  List<ClothingItem> get allItems => _items;

  final Map<int, bool> _showRemovedBgMap = {};

  Future<void> loadUserItems(int userId) async {
    _items = await _api.getUserClothing(userId);

    for (var item in _items) {
      _showRemovedBgMap[item.id] = item.useRemovedBg;
    }

    notifyListeners();
  }

  Future<void> refreshItem(int itemId) async {
    final updated = await _api.getClothingItemById(itemId);
    final index = _items.indexWhere((e) => e.id == itemId);
    if (index != -1) {
      _items[index] = updated;
      _showRemovedBgMap[itemId] = updated.useRemovedBg;
      notifyListeners();
    }
  }

  Map<Category, List<ClothingItem>> get groupedByCategory {
  final Map<Category, List<ClothingItem>> grouped = {};

  for (var item in _items) {
    grouped.putIfAbsent(item.pieceCategory, () => []).add(item);
  }

  final sortedEntries = grouped.entries.toList()
    ..sort((a, b) => a.key.index.compareTo(b.key.index));

  return Map.fromEntries(sortedEntries);
}



  bool useRemovedBgFor(int itemId) {
    return _showRemovedBgMap[itemId] ?? false;
  }

  void setRemovedBgFor(int itemId, bool use) {
    _showRemovedBgMap[itemId] = use;
    notifyListeners();
  }
}
