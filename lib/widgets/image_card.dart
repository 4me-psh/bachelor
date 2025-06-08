import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String imageUrl;
  final bool showSwitch;
  final bool useRemovedBg;
  final ValueChanged<bool> onToggle;

  const ImageCard({
    super.key,
    required this.imageUrl,
    required this.useRemovedBg,
    required this.onToggle,
    this.showSwitch = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              imageUrl,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          if (showSwitch)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Показати без фону'),
                  Switch(value: useRemovedBg, onChanged: onToggle),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
