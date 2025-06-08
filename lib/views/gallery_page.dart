import 'package:bachelor/controllers/clothing_item_controller.dart';
import 'package:bachelor/models/clothing_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/gallery_controller.dart';
import 'clothing_item_page.dart';
import 'add_clothing_page.dart';

class GalleryPage extends StatefulWidget {
  final int userId;
  const GalleryPage({super.key, required this.userId});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  bool _loading = true;
  

  @override
  void initState() {
    super.initState();
    _loadClothing();
  }

  Future<void> _loadClothing() async {
    final provider = Provider.of<GalleryController>(context, listen: false);
    await provider.loadUserItems(widget.userId);
    setState(() => _loading = false);
  }

  void _goToAddClothing() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddClothingPage(userId: widget.userId)),
    );
    if (result == true) {
      setState(() {
        _loading = true;
      });
      await _loadClothing();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GalleryController>(context);
    final ClothingItemController _clothingItemController = Provider.of<ClothingItemController>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Гардероб'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : provider.allItems.isEmpty
              ? const Center(child: Text('Ще нема доданого одягу'))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: provider.groupedByCategory.entries.map((entry) {
                    final category = entry.key;
                    final items = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.nameUa,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return GestureDetector(
                              onTap: () async {
                                ClothingItem neededClothingItem = await _clothingItemController.getClothingItemById(item.id);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ClothingItemPage(item: neededClothingItem, userId: widget.userId),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        item.getImage(
                                          useRemovedBg: provider.useRemovedBgFor(item.id),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(item.name, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }).toList(),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddClothing,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
