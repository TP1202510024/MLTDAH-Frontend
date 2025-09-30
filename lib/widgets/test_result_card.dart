import 'package:flutter/material.dart';

class TestResultCard extends StatelessWidget {
  final String title;
  final String date;
  final String probability;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const TestResultCard({
    super.key,
    required this.title,
    required this.date,
    required this.probability,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String numericPart = probability.split('%').first;
    final int percentage = int.tryParse(numericPart) ?? 0;
    final Color containerColor = (percentage < 50) ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Expanded content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18),
                          onPressed: onDelete,
                          splashRadius: 20,
                        ),
                      ],
                    ),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // Probabilidad label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  probability,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
