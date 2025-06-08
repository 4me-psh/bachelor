import 'package:bachelor/controllers/clothing_item_controller.dart';
import 'package:bachelor/controllers/gallery_controller.dart';
import 'package:bachelor/views/home_page.dart';
import 'package:bachelor/widgets/temperature_ranges_block.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../widgets/image_card.dart';
import '../widgets/info_card.dart';
import '../widgets/editable_card.dart';

class ClothingItemPage extends StatefulWidget {
  final ClothingItem item;
  final int userId;

  const ClothingItemPage({super.key, required this.item, required this.userId});

  @override
  State<ClothingItemPage> createState() => _ClothingItemPageState();
}

class _ClothingItemPageState extends State<ClothingItemPage> {
  bool isEditing = false;
  late bool useRemovedBg;

  late TextEditingController _nameController;
  late TextEditingController _colorController;
  late TextEditingController _materialController;
  late TextEditingController _characteristicsController;

  late Set<Style> selectedStyles;
  late Set<TemperatureCategory> selectedTemps;
  late Category selectedCategory;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _nameController = TextEditingController(text: item.name);
    _colorController = TextEditingController(text: item.color);
    _materialController = TextEditingController(text: item.material);
    _characteristicsController = TextEditingController(
      text: item.characteristics.join(', '),
    );

    selectedStyles = Set.from(item.styles);
    selectedTemps = Set.from(item.temperatureCategories);
    selectedCategory = item.pieceCategory;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final controller = context.read<ClothingItemController>();
    final galleryController = context.watch<GalleryController>();
    useRemovedBg = galleryController.useRemovedBgFor(item.id);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: Center(child: Text(isEditing ? 'Редагування' : item.name)),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              ImageCard(
                imageUrl: item.getImage(useRemovedBg: useRemovedBg),
                useRemovedBg: useRemovedBg,
                onToggle: (val) {
                  setState(() => useRemovedBg = val);
                  galleryController.setRemovedBgFor(item.id, val);
                },
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isEditing
                    ? EditableCard(children: [_buildEditableFields()])
                    : InfoCard(
                        title: 'Інформація про річ',
                        data: {
                          'Назва': item.name,
                          'Колір': item.color,
                          'Матеріал': item.material,
                          'Стилі': item.styles.map((e) => e.nameUa).join(', '),
                          'Категорія': item.pieceCategory.nameUa,
                          'Температури': item.temperatureCategories.map((e) => e.nameUa).join(', '),
                          if (item.characteristics.isNotEmpty)
                            'Характеристики': item.characteristics.join(', '),
                        },
                      ),
              ),
              const SizedBox(height: 12),
              TemperatureRangesBlock(),
              const SizedBox(height: 12,),
              if (!isEditing)
                FilledButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Видалити'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    await controller.deleteClothingItem(item.id);
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          userId: widget.userId,
                          selectedPage: 1,
                        ),
                      ),
                    );
                  },
                ),
              
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.close : Icons.arrow_back),
                label: Text(isEditing ? 'Скасувати' : 'Назад'),
                onPressed: () {
                  if (isEditing) {
                    setState(() => isEditing = false);
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomePage(
                          userId: widget.userId,
                          selectedPage: 1,
                        ),
                      ),
                    );
                  }
                },
              ),
              ElevatedButton.icon(
                icon: Icon(isEditing ? Icons.check : Icons.edit),
                label: Text(isEditing ? 'Підтвердити' : 'Редагувати'),
                onPressed: () async {
                  if (isEditing) {
                    final updatedItem = ClothingItem(
                      id: item.id,
                      name: _nameController.text,
                      color: _colorController.text,
                      material: _materialController.text,
                      styles: selectedStyles.toList(),
                      pathToPhoto: item.pathToPhoto,
                      pathToRemovedBgPhoto: item.pathToRemovedBgPhoto,
                      pieceCategory: selectedCategory,
                      temperatureCategories: selectedTemps.toList(),
                      characteristics: _characteristicsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      useRemovedBg: useRemovedBg,
                    );

                    await controller.updateClothingItem(updatedItem);
                    final refreshed = await controller.getClothingItemById(item.id);
                    if (!mounted) return;

                    await galleryController.refreshItem(item.id);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClothingItemPage(
                          item: refreshed,
                          userId: widget.userId,
                        ),
                      ),
                    );
                  } else {
                    setState(() => isEditing = true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editableField('Назва', _nameController),
        _editableField('Колір', _colorController),
        _editableField('Матеріал', _materialController),
        _selectChips<Style>(
          title: 'Стилі',
          options: Style.values,
          selected: selectedStyles,
          labelOf: (s) => s.nameUa,
          onItemToggled: (style, selected) {
            selected ? selectedStyles.add(style) : selectedStyles.remove(style);
          },
        ),
        _dropdown<Category>(
          label: 'Категорія',
          value: selectedCategory,
          options: Category.values,
          labelOf: (c) => c.nameUa,
          onChanged: (val) => setState(() => selectedCategory = val),
        ),
        _selectChips<TemperatureCategory>(
          title: 'Температури',
          options: TemperatureCategory.values,
          selected: selectedTemps,
          labelOf: (t) => t.nameUa,
          onItemToggled: (temp, selected) {
            selected ? selectedTemps.add(temp) : selectedTemps.remove(temp);
          },
        ),
        SizedBox(height: 4,),
        _editableField('Характеристики (через кому)', _characteristicsController),
      ],
    );
  }

  Widget _editableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _selectChips<T>({
    required String title,
    required List<T> options,
    required Set<T> selected,
    required String Function(T) labelOf,
    required void Function(T item, bool selected) onItemToggled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, top: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Wrap(
          spacing: 8,
          children: options.map((opt) {
            return FilterChip(
              label: Text(labelOf(opt)),
              selected: selected.contains(opt),
              onSelected: (bool sel) {
                setState(() {
                  onItemToggled(opt, sel);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required List<T> options,
    required String Function(T) labelOf,
    required ValueChanged<T> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: options
            .map((opt) => DropdownMenuItem(value: opt, child: Text(labelOf(opt))))
            .toList(),
        onChanged: (val) => val != null ? onChanged(val) : null,
      ),
    );
  }
}
