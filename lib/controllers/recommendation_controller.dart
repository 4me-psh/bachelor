import '../connections/recommendation_api.dart';
import '../models/chat_message.dart';
import '../models/recommendation.dart';

class RecommendationController {
  final RecommendationApi _api = RecommendationApi();
  final List<ChatMessage> messages = [];

  Future<void> submitPrompt(String text, int personId) async {
    messages.add(ChatMessage(userMessage: text));

    final recommendation = Recommendation(userPrompt: text, personId: personId);
    final created = await _api.createRecommendation(recommendation);

    messages.add(ChatMessage(recommendation: created));
  }

  Future<void> repeatRecommendationById(
    int recommendationId,
    int personId,
  ) async {
    final rec = messages.firstWhere(
      (m) => m.recommendation?.id == recommendationId,
      orElse: () => ChatMessage(),
    );

    if (rec.recommendation?.userPrompt != null) {
      await submitPrompt(rec.recommendation!.userPrompt, personId);
    }
  }

  Future<List<Recommendation>> getAllRecommendations() async {
    return await _api.getAll();
  }

  Future<Recommendation> getRecommendationById(int id) async {
    return await _api.getById(id);
  }

  Future<List<Recommendation>> getRecommendationsByPersonId(
    int personId,
  ) async {
    return await _api.getByPersonId(personId);
  }

  Future<List<Recommendation>> getFavoriteRecommendationsByPersonId(
    int personId,
  ) async {
    return await _api.getFavoritesByPersonId(personId);
  }

  Future<void> editRecommendation(Recommendation recommendation) async {
    await _api.editRecommendation(recommendation);
  }

  Future<void> deleteRecommendation(int id) async {
    await _api.deleteRecommendation(id);
  }

  Future<void> generateImages(int recommendationId) async {
    await _api.generateImages(recommendationId);
  }
}
