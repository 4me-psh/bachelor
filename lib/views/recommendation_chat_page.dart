import 'package:bachelor/views/recommendation_page.dart';
import 'package:flutter/material.dart';

import '../controllers/recommendation_controller.dart';
import '../controllers/weather_controller.dart';
import '../models/chat_message.dart';
import '../models/weather_info.dart';
import '../widgets/chat_message_bubble.dart';

class RecommendationChatPage extends StatefulWidget {
  final int userId;

  const RecommendationChatPage({required this.userId, super.key});

  @override
  State<RecommendationChatPage> createState() => _RecommendationChatPageState();
}

class _RecommendationChatPageState extends State<RecommendationChatPage> {
  final _controller = RecommendationController();
  final _weatherController = WeatherController();

  final _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  WeatherInfo? _weather;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _loadInitialMessages();
  }

  Future<void> _loadWeather() async {
    try {
      final info = await _weatherController.loadWeatherAuto();
      if (!mounted) return;
      setState(() => _weather = info);
    } catch (e) {
      debugPrint('Не вдалося отримати погоду: $e');
    }
  }

  Future<void> _loadInitialMessages() async {
    try {
      final recs = await _controller.getRecommendationsByPersonId(
        widget.userId,
      );

      print(recs);

      recs.sort((a, b) {
        final dateA =
            a.updatedAt ??
            a.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final dateB =
            b.updatedAt ??
            b.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return dateA.compareTo(dateB);
      });

      setState(() {
        _controller.messages
          ..clear()
          ..addAll(
            recs.expand(
              (rec) => [
                ChatMessage(userMessage: rec.userPrompt),
                ChatMessage(recommendation: rec),
              ],
            ),
          );
      });

      _scrollToBottom();
    } catch (e) {
      debugPrint('Не вдалося завантажити історію повідомлень: $e');
    }
  }

  Future<void> _sendQuery() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _inputController.clear();
      _loading = true;
    });

    await _controller.submitPrompt(text, widget.userId);

    if (!mounted) return;
    setState(() => _loading = false);
    _scrollToBottom();
  }

  Future<void> _repeatSpecific(int recommendationId) async {
    setState(() => _loading = true);
    await _controller.repeatRecommendationById(recommendationId, widget.userId);
    if (!mounted) return;
    setState(() => _loading = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formattedDate() {
    final now = DateTime.now();
    const weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Нд'];
    const months = [
      'січня',
      'лютого',
      'березня',
      'квітня',
      'травня',
      'червня',
      'липня',
      'серпня',
      'вересня',
      'жовтня',
      'листопада',
      'грудня',
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, ${now.day} $month';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title:
            _weather == null
                ? const CircularProgressIndicator(color: Colors.white)
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formattedDate(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _weather!.city,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${_weather!.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Image.network(_weather!.iconUrl, width: 24, height: 24),
                      ],
                    ),
                    Text(
                      _weather!.condition,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _controller.messages.length,
              itemBuilder: (context, index) {
                final message = _controller.messages[index];
                return GestureDetector(
                  onTap:
                      message.recommendation != null
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => RecommendationPage(
                                      recommendationId:
                                          message.recommendation!.id!,
                                      userId: widget.userId,
                                      selectedPage: 0,
                                    ),
                              ),
                            );
                          }
                          : null,
                  child: ChatMessageBubble(
                    message: message,
                    onRepeat:
                        () => _repeatSpecific(message.recommendation!.id!),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: InputDecoration(
                      hintText: 'Напиши запит...',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.indigo),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 2,
                        ),
                      ),
                    ),
                    onSubmitted: (_) => _sendQuery(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _loading ? null : _sendQuery,
                  color: Theme.of(context).primaryColor,
                  tooltip: 'Надіслати',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
