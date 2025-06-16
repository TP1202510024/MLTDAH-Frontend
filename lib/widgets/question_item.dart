import 'package:flutter/material.dart';

class QuestionItem extends StatelessWidget {
  final String question;
  final String? description;
  final int? selectedValue;
  final Function(int) onChanged;

  const QuestionItem({
    super.key,
    required this.question,
    this.description,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = ["Nunca", "Un poco", "Bastante", "Mucho"];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text("Consideraciones: $description", style: const TextStyle(color: Colors.black54)),
            ],
            const SizedBox(height: 16),

            // Fila 0 y 1
            Row(
              children: List.generate(2, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('$index - ${labels[index]}', textAlign: TextAlign.center),
                      selected: selectedValue == index,
                      onSelected: (_) => onChanged(index),
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: selectedValue == index ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Fila 2 y 3
            Row(
              children: List.generate(2, (i) {
                final index = i + 2;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text('$index - ${labels[index]}', textAlign: TextAlign.center),
                      selected: selectedValue == index,
                      onSelected: (_) => onChanged(index),
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(
                        color: selectedValue == index ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
