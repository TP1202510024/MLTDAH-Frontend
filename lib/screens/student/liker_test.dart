import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/question_item.dart';

class LikertTestView extends StatefulWidget {
  final VoidCallback onFinish;
  final dynamic extraData;

  const LikertTestView({super.key, required this.onFinish,
    this.extraData});

  @override
  State<LikertTestView> createState() => _LikertTestViewState();
}

class _LikertTestViewState extends State<LikertTestView> {
  int studentId = 0;
  Map<int, int?> selectedAnswers = {};
  int currentSection = 0;
  bool isFinished = false;
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  // Datos del examen
  Map<String, dynamic>? _examData;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _questionsByCategory = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    studentId = widget.extraData['id'] ?? 0;
  }

  Future<void> _loadInitialData() async {
    try {
      await _fetchQuestions();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar preguntas: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchQuestions() async {
    final response = await ApiService.getWithAuth(
        endpoint: '/api/v1/exams',
        id: "3"
    );
    debugPrint('Datos recibidos: ${response.toString()}');

    if (response != null && mounted) {
      // Usar un Map para almacenar categorías únicas (excluyendo "VC")
      final categoriesMap = <String, Map<String, dynamic>>{};

      // Organizar preguntas por categoría (excluyendo "VC")
      final questionsByCategory = <Map<String, dynamic>>[];

      for (var question in response['questions']) {
        final category = question['category'];
        final categoryId = category['id'].toString();
        final categoryName = category['name'];

        // Saltar preguntas de la categoría "VC"
        if (categoryName == 'VC') continue;

        // Agregar categoría si no existe
        if (!categoriesMap.containsKey(categoryId)) {
          categoriesMap[categoryId] = category;

          questionsByCategory.add({
            'category': category,
            'questions': []
          });
        }

        // Agregar pregunta a su categoría correspondiente
        final categoryIndex = questionsByCategory.indexWhere(
                (item) => item['category']['id'] == category['id']
        );

        if (categoryIndex != -1) {
          questionsByCategory[categoryIndex]['questions'].add(question);
        }
      }

      if (mounted) {
        setState(() {
          _examData = response;
          _categories = categoriesMap.values.toList();
          _questionsByCategory = questionsByCategory;
          selectedAnswers = {
            for (var category in questionsByCategory)
              for (var question in category['questions'])
                question['id']: null
          };
        });
      }
    }
  }

  void _nextSection() {
    // Obtener todas las preguntas de la categoría actual
    final currentQuestions = _questionsByCategory[currentSection]['questions'];

    // Verificar si todas las preguntas están respondidas
    bool allAnswered = true;
    for (var question in currentQuestions) {
      if (selectedAnswers[question['id']] == null) {
        allAnswered = false;
        break;
      }
    }

    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor responde todas las preguntas antes de continuar'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (currentSection < _categories.length - 1) {
      setState(() => currentSection++);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _submitAnswers();
    }
  }

  int calculateAge(String birthDateString) {
    try {
      final birthDate = DateTime.parse(birthDateString);
      final currentDate = DateTime.now();

      int age = currentDate.year - birthDate.year;

      // Ajustar si aún no ha pasado el cumpleaños este año
      if (currentDate.month < birthDate.month ||
          (currentDate.month == birthDate.month && currentDate.day < birthDate.day)) {
        age--;
      }

      return age;
    } catch (e) {
      debugPrint('Error calculando edad: $e');
      return 0; // O maneja el error como prefieras
    }
  }

  Future<void> _submitAnswers() async {
    try {
      // Validación de datos requeridos
      if (widget.extraData == null ||
          widget.extraData['gender'] == null ||
          widget.extraData['birthDate'] == null) {
        throw Exception('Datos del estudiante incompletos');
      }

      // 1. Convertir todas las respuestas a strings
      final List<Map<String, dynamic>> formattedAnswers = selectedAnswers.entries
          .where((entry) => entry.value != null)
          .map((entry) => {
        "questionId": entry.key.toString(), // Asegurar string
        "value": entry.value.toString(),
      }).toList();

      debugPrint('Respuestas del test: $formattedAnswers');

      // 2. Respuestas fijas (género y edad)
      final fixedAnswers = [
        {
          "questionId": "5", // Como string
          "value": widget.extraData['gender']['name'] == "Masculino" ? 1 : 0
        },
        {
          "questionId": "6",
          "value": calculateAge(widget.extraData['birthDate']).toString()
        }
      ];
      final allAnswers = [...fixedAnswers, ...formattedAnswers];

      final response = await ApiService.postWithAuth(
        endpoint: '/api/v1/tests',
        body: {
          "studentId": studentId.toString(),
          "examId": '3',
          "answers": allAnswers,
        },
      );

      debugPrint('Respuesta del servidor: $response');

      // Mostrar feedback al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Respuestas enviadas correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        widget.onFinish(); // Cerrar el test después de enviar
      }

    } catch (e) {
      debugPrint('Error al enviar respuestas: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (isFinished) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            const Text(
              "El cuestionario se ha registrado correctamente.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            CustomButton(text: "Regresar", onPressed: widget.onFinish),
          ],
        ),
      );
    }

    final currentCategory = _categories[currentSection];
    final currentQuestions = _questionsByCategory[currentSection]['questions'];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentCategory['name'],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: currentQuestions.length,
              // En el ListView.builder, ya no necesitas calcular el índice global
              itemBuilder: (context, index) {
                final question = currentQuestions[index];
                return QuestionItem(
                  question: "${index + 1}. ${question['text']}",
                  selectedValue: selectedAnswers[question['id']],
                  onChanged: (val) {
                    setState(() {
                      selectedAnswers[question['id']] = val;
                    });
                  },
                );
              },
            ),
          ),
          CustomButton(
            text: currentSection < _categories.length - 1
                ? "Siguiente Sección"
                : "Finalizar Cuestionario",
            onPressed: _nextSection,
          ),
        ],
      ),
    );
  }
}