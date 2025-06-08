import 'recommendation.dart';

class ChatMessage {
  final String? userMessage;
  final Recommendation? recommendation;

  ChatMessage({
    this.userMessage,
    this.recommendation,
  });

  bool get isUser => userMessage != null && recommendation == null;

  bool get isRecommendation => recommendation != null;

  static List<ChatMessage> fromRecommendations(List<Recommendation> recommendations) {
    final messages = <ChatMessage>[];
    for (final rec in recommendations) {
      messages.add(ChatMessage(userMessage: rec.userPrompt));
      messages.add(ChatMessage(recommendation: rec));
    }
    return messages;
  }
}
