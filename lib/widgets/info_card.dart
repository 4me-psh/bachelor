import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final Map<String, String> data;

  const InfoCard({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...data.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${e.key}: ',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  Expanded(child: Text(e.value)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
