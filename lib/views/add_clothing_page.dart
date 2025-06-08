import 'dart:io';
import 'package:bachelor/controllers/clothing_item_controller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'clothing_item_page.dart';

class AddClothingPage extends StatefulWidget {
  final int userId;
  const AddClothingPage({required this.userId});

  @override
  State<AddClothingPage> createState() => _AddClothingPageState();
}

class _AddClothingPageState extends State<AddClothingPage> {
  final ClothingItemController _clothingItemController = ClothingItemController();
  File? _imageFile;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _upload() async {
    if (_imageFile == null) return;

    setState(() => _loading = true);
    try {
      final item = await _clothingItemController.uploadClothingItem(widget.userId, _imageFile!);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ClothingItemPage(item: item,userId: widget.userId,)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Помилка: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Додати одяг")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _imageFile != null
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _imageFile!,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  )
                  : Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(child: Text("Фото не обрано")),
                  ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.photo),
                label: const Text("Вибрати фото"),
                onPressed: _loading ? null : _pickImage,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.upload),
                label: const Text("Завантажити"),
                onPressed: _imageFile == null || _loading ? null : _upload,
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
