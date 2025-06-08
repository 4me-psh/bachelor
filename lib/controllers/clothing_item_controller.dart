import 'dart:io';
import 'package:flutter/material.dart';
import '../connections/clothing_api.dart';
import '../models/clothing_item.dart';

class ClothingItemController extends ChangeNotifier {
  final ClothingApi _api = ClothingApi();

  Future<ClothingItem> uploadClothingItem(int userId, File photo) async {
    final item = await _api.uploadClothingItem(userId, photo);
    return item;
  }

  Future<void> updateClothingItem(ClothingItem item) async {
    await _api.updateClothingItem(item);
  }

  Future<void> deleteClothingItem(int id) async {
    await _api.deleteClothingItem(id);
  }

  Future<ClothingItem> getClothingItemById(int id) async {
    return await _api.getClothingItemById(id);
  }
}
