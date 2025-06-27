import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String status; // ej: "Generando", "95% Probabilidad"

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.status,
  });

  bool _isNumericStatus() {
    return double.tryParse(status) != null;
  }

  String _getStatusText() {
    if (_isNumericStatus()) {
      final numericValue = double.parse(status);
      return '${(numericValue * 100).toStringAsFixed(0)}% Probabilidad';
    }
    return status;
  }

  Color _getStatusColor() {
    if (!_isNumericStatus()) {
      return Colors.green; // Para textos no numéricos
    }

    final numericValue = double.parse(status);
    final percentage = numericValue * 100;

    if (percentage > 80) {
      return Colors.red;
    } else if (percentage < 20) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  Color _getStatusBackground() {
    return _getStatusColor().withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _getStatusText();
    final statusColor = _getStatusColor();
    final statusBackground = _getStatusBackground();
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
