import 'package:bachelor/widgets/recommendation_bubble.dart';
import 'package:flutter/material.dart';
import 'package:bachelor/controllers/recommendation_controller.dart';
import 'package:bachelor/models/recommendation.dart';
import 'package:bachelor/views/recommendation_page.dart';

class FavoriteRecommendationBubble extends StatelessWidget {
  final Recommendation recommendation;

  const FavoriteRecommendationBubble({required this.recommendation, super.key});

  @override
  Widget build(BuildContext context) {
    return RecommendationBubble(recommendation: recommendation);
  }
}

class FavoritesPage extends StatefulWidget {
  final int userId;
  const FavoritesPage({required this.userId, super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final RecommendationController _controller = RecommendationController();
  late Future<List<Recommendation>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _favoritesFuture = _controller.getFavoriteRecommendationsByPersonId(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Улюблені рекомендації'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Recommendation>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Помилка завантаження: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Немає улюблених рекомендацій'));
          }

          final favorites = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final recommendation = favorites[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecommendationPage(
                      recommendationId: recommendation.id!,
                      userId: widget.userId,
                      selectedPage: 2,
                    ),
                  ),
                ),
                child: FavoriteRecommendationBubble(recommendation: recommendation),
              );
            },
          );
        },
      ),
    );
  }
}