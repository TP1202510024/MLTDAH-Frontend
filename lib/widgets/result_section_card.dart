import 'package:flutter/material.dart';

class ResultSectionCard extends StatelessWidget {
  final String title;
  final String description;
  final int score;
  final int total;
  final Color badgeColor;
  final Color? borderColor;
  final String? warning;

  const ResultSectionCard({
    super.key,
    required this.title,
    required this.description,
    required this.score,
    required this.total,
    required this.badgeColor,
    this.borderColor,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderColor ?? Colors.transparent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$score / $total",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),
          Text(description),
          if (warning != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                border: Border.all(color: Colors.red),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                warning!,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w500),
              ),
            )
          ]
        ],
      ),
    );
  }
}
