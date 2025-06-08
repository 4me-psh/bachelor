import 'package:flutter/material.dart';

class TemperatureRangesBlock extends StatelessWidget {
  final Map<String, String> categories = {
    "🔥 Сильна спека": "30°C і вище",
    "🌡️ Жарко": "25°C до 29°C",
    "🌤️ Тепло": "20°C до 24°C",
    "🌥️ Помірно тепло": "15°C до 19°C",
    "🌬️ Прохолодно": "10°C до 14°C",
    "❄️ Холодно": "5°C до 9°C",
    "🥶 Легкий мороз": "0°C до 4°C",
    "🌨️ Зимно": "-5°C до -1°C",
    "🧊 Мороз": "-10°C до -6°C",
    "⛄ Сильний мороз": "-19°C до -11°C",
    "⛷️ Суворий холод": "-20°C і нижче",
  };

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Температурні категорії',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...categories.entries.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
