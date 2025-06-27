import 'package:flutter/material.dart';
import '../../widgets/result_section_card.dart';

class StudentResultDetailView extends StatefulWidget {
  final dynamic examData;
  final dynamic studentData;
  final VoidCallback onFinish;

  const StudentResultDetailView({
    super.key,
    required this.examData,
    required this.studentData,
    required this.onFinish,
  });

  @override
  State<StudentResultDetailView> createState() => _StudentResultDetailViewState();
}

class _StudentResultDetailViewState extends State<StudentResultDetailView> {
  int viewstate = 0;
  late Map<String, dynamic> _processedData;
  late String _generationDate;
  String? _selectedCategoryId;
  Map<String, dynamic>? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _processedData = {};
    _generationDate = "No disponible";

    if (widget.examData != null) {
      try {
        _processExamData();
      } catch (e) {
        debugPrint('Error procesando datos del examen: $e');
      }
    } else {
      debugPrint('Datos del examen no proporcionados');
    }
  }

  void _showCategoryDetail(String categoryId) {
    setState(() {
      viewstate = 1;
      _selectedCategoryId = categoryId;
      _selectedCategory = _processedData[categoryId];
    });
  }

  void _showSummary() {
    setState(() {
      viewstate = 0;
      _selectedCategoryId = null;
      _selectedCategory = null;
    });
  }

  void _processExamData() {
    // 1. Extraer fecha de creación
    final createdAt = widget.examData['createdAt']?.toString() ?? "No disponible";
    _generationDate = _formatDate(createdAt);

    // 2. Procesar respuestas por categoría (excluyendo VC)
    final answers = (widget.examData['answers'] as List<dynamic>?) ?? [];
    final Map<String, Map<String, dynamic>> categories = {};

    for (final answer in answers) {
      final Map<String, dynamic> question = answer['question'] as Map<String, dynamic>;
      final Map<String, dynamic> category = question['category'] as Map<String, dynamic>;
      final String categoryId = category['id'].toString();
      final String categoryName = category['name'].toString();
      final int value = int.tryParse(answer['value'].toString()) ?? 0;

      // Excluir categoría VC
      if (categoryName == "VC") continue;

      if (!categories.containsKey(categoryId)) {
        categories[categoryId] = {
          'name': categoryName,
          'description': category['description']?.toString() ?? '',
          'totalScore': 0,
          'maxPossibleScore': 0,
          'questions': <Map<String, dynamic>>[],
        };
      }

      categories[categoryId]!['totalScore'] = (categories[categoryId]!['totalScore'] as int) + value;
      categories[categoryId]!['maxPossibleScore'] = (categories[categoryId]!['maxPossibleScore'] as int) + 3;
      (categories[categoryId]!['questions'] as List<Map<String, dynamic>>).add({
        'questionText': question['text'].toString(),
        'answerValue': value,
      });
    }

    _processedData = categories;
    debugPrint('Datos procesados: $_processedData');
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Fecha no disponible";
    }
  }

  Color _getBadgeColor(double percentage) {
    if (percentage >= 0.8) return Colors.red;
    if (percentage >= 0.6) return Colors.orange;
    if (percentage >= 0.4) return Colors.yellow;
    return Colors.green;
  }

  String? _getWarning(double percentage) {
    if (percentage >= 0.7) {
      return "Advertencia: El estudiante ha obtenido un puntaje elevado en esta categoría.";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: viewstate == 0 ? _buildSummaryView() : _buildCategoryDetailView(),
      ),
    );
  }
  Widget _buildCategoryDetailView() {
    if (_selectedCategory == null) return const Center(child: Text("Categoría no encontrada"));

    final questions = _selectedCategory!['questions'] as List<dynamic>;
    final percentage = _selectedCategory!['totalScore'] / _selectedCategory!['maxPossibleScore'];
    final badgeColor = _getBadgeColor(percentage);

    return ListView(
      padding: const EdgeInsets.all(16), // Padding general aumentado
      children: [
        // Botón de regreso arriba

        // Card principal de la categoría
        Card(
          color: badgeColor.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: badgeColor.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCategory!['name'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedCategory!['description'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (_getWarning(percentage) != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getWarning(percentage)!,
                          style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                // Badge de puntaje en esquina superior derecha
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedCategory!['totalScore']}/${_selectedCategory!['maxPossibleScore']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Título de preguntas y respuestas
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Preguntas y respuestas:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Lista de preguntas con más padding
        ...questions.map((question) => Padding(
          padding: const EdgeInsets.only(bottom: 16), // Más espacio entre preguntas
          child: Card(
            elevation: 1,
            margin: EdgeInsets.zero, // Elimina el margin por defecto
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16), // Más padding interno
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['questionText'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[100], // Verde para todas las respuestas
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Respuesta: ${question['answerValue']}',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        )).toList(),
      ],
    );
  }
  Color _getAnswerColor(int value) {
    if (value >= 2) return Colors.red;
    if (value >= 1) return Colors.orange;
    return Colors.green;
  }

  Widget _buildSummaryView() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: ListView(
          children: [
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: 'Resultado: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: 'Número ${widget.examData['index'] + 1}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  TextSpan(
                    text: 'Fecha de generación: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${_generationDate}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mostrar tarjetas por categoría
            if (_processedData.isNotEmpty)
              ..._processedData.entries.map((entry) {
                final category = entry.value;
                final percentage = category['totalScore'] / category['maxPossibleScore'];

                return GestureDetector(
                  onTap: () => _showCategoryDetail(entry.key),
                  child: ResultSectionCard(
                    title: category['name'],
                    description: category['description'],
                    score: category['totalScore'],
                    total: category['maxPossibleScore'],
                    badgeColor: _getBadgeColor(percentage),
                    borderColor: Colors.grey,
                    warning: _getWarning(percentage),
                  ),
                );
              }).toList(),

            if (_processedData.isEmpty)
              const Center(child: Text("No hay datos de categorías disponibles")),
          ],
        ),
      ),
    );
  }
}