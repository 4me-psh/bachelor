import 'package:flutter/material.dart';
import '../models/recommendation.dart';
import '../models/clothing_item.dart';

class RecommendationBubble extends StatelessWidget {
  final Recommendation recommendation;
  final VoidCallback? onOpenDetails;

  const RecommendationBubble({
    super.key,
    required this.recommendation,
    this.onOpenDetails,
  });

  @override
  Widget build(BuildContext context) {
    final items = recommendation.recommendedClothes ?? [];
    final images = recommendation.generatedImages ?? [];

    return Align(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color.fromARGB(26, 212, 94, 40),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(62, 160, 107, 16),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (images.isNotEmpty) ...[
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      images[index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (items.isNotEmpty)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: items.map(_clothingPreview).toList(),
              ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onOpenDetails,
                child: const Text('Детальніше'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clothingPreview(ClothingItem item) {
    return SizedBox(
      width: 110,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.getImage(useRemovedBg: item.useRemovedBg),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.pieceCategory.nameUa,
            style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 41, 35, 35)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
