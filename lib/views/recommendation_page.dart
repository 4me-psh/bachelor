import 'package:flutter/material.dart';
import 'package:bachelor/controllers/recommendation_controller.dart';
import 'package:bachelor/models/recommendation.dart';
import 'package:bachelor/models/clothing_item.dart';
import 'home_page.dart';

class RecommendationPage extends StatefulWidget {
  final int recommendationId;
  final int userId;
  final int selectedPage;

  const RecommendationPage({
    super.key,
    required this.recommendationId,
    required this.userId,
    required this.selectedPage,
  });

  @override
  State<RecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<RecommendationPage> {
  final RecommendationController recommendationController = RecommendationController();

  Recommendation? currentRecommendation;
  bool isFavorite = false;
  bool loading = true;
  bool generatingImages = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendation();
  }

  Future<void> _loadRecommendation() async {
    try {
      final rec = await recommendationController.getRecommendationById(widget.recommendationId);
      setState(() {
        currentRecommendation = rec;
        isFavorite = rec.favorite ?? false;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      debugPrint('Помилка при завантаженні рекомендації: \$e');
    }
  }

  Future<void> _generateImages() async {
    setState(() => generatingImages = true);
    await recommendationController.generateImages(widget.recommendationId);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendationPage(
          recommendationId: widget.recommendationId,
          userId: widget.userId,
          selectedPage: widget.selectedPage,
        ),
      ),
    );
  }

  Future<void> _deleteRecommendation() async {
    await recommendationController.deleteRecommendation(widget.recommendationId);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          userId: widget.userId,
          selectedPage: widget.selectedPage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (currentRecommendation == null) {
      return const Scaffold(
        body: Center(child: Text("Не вдалося завантажити рекомендацію.")),
      );
    }

    final items = currentRecommendation!.recommendedClothes ?? [];
    final imageUrls = currentRecommendation!.getImageUrls();

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Рекомендація"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Згенеровані зображення:', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              imageUrls.isEmpty
                ? const Center(child: Text('Поки нема згенерованих зображень'))
                : SizedBox(
                    height: 500,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          imageUrls[i],
                          width: 300,
                          height: 350,
                          fit: BoxFit.cover,
                        ),
                      ),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                    ),
                  ),
              const SizedBox(height: 12),
              generatingImages
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _generateImages,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Згенерувати зображення'),
                  ),
              const Divider(height: 32),
      
              Text('Запит користувача:', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(currentRecommendation!.userPrompt, style: Theme.of(context).textTheme.bodyMedium),
              ),
      
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isFavorite,
                    onChanged: (value) async {
                      setState(() => isFavorite = value ?? false);
                      await recommendationController.editRecommendation(
                        Recommendation(
                          userPrompt: currentRecommendation!.userPrompt,
                          id: currentRecommendation!.id,
                          generatedImages: currentRecommendation!.generatedImages,
                          recommendedClothes: items,
                          favorite: value,
                        ),
                      );
                    },
                  ),
                  const Text("Додати до улюблених", style: TextStyle(fontSize: 16)),
                ],
              ),
      
              const SizedBox(height: 16),
              Text('Рекомендований одяг:', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              items.isEmpty
                ? const Text("Немає речей у цій рекомендації.")
                : GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) => _clothingCard(items[index]),
                  ),
      
              const SizedBox(height: 24),
            ],
          ),
        ),
        bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomePage(
                            userId: widget.userId,
                            selectedPage: widget.selectedPage,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Назад'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _deleteRecommendation,
                    icon: const Icon(Icons.delete),
                    label: const Text('Видалити'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _clothingCard(ClothingItem item) => Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                item.getImage(useRemovedBg: item.useRemovedBg),
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                  ),
                  Text(
                    item.pieceCategory.nameUa,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
}
