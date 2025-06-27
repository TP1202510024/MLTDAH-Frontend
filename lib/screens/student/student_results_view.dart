import 'package:flutter/material.dart';
import 'package:mltdah_frontend/screens/student/add_parent_view.dart';
import 'package:mltdah_frontend/screens/student/student_detail_view.dart';
import 'package:mltdah_frontend/screens/student/student_result_detail_view.dart';
import 'package:mltdah_frontend/widgets/test_result_card.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widgets/line_chart_card.dart';
import '../../widgets/question_card.dart';
import '../main_layout.dart';
import 'liker_test.dart';

class StudentResultsView extends StatefulWidget {
  final dynamic extraData;
  const StudentResultsView({super.key,this.extraData});

  @override
  State<StudentResultsView> createState() => _StudentResultsViewState();
}

class _StudentResultsViewState extends State<StudentResultsView> {
  int selectedTab = 0;
  bool showResults = false;
  bool _isLoading = true;
  String? _error;
  List<dynamic> _exams = [];

  final List<String> tabs = ["Línea de Tiempo", "En Lista"];


  @override
  void initState() {
    super.initState();
    if (widget.extraData != null && widget.extraData is Map<String, dynamic>) {
      try {
        debugPrint('Error entro datos del estudiante:');
        _fetchStudentsExams(widget.extraData['id'].toString());
      } catch (e) {
        debugPrint('Error procesando datos del estudiante: $e');
      }
    } else {
      debugPrint('Datos del estudiante no proporcionados o formato incorrecto');
    }
  }

  Future<void> _fetchStudentsExams(String id) async {
    try {
      final response = await ApiService.getWithAuth(
          endpoint: '/api/v1/tests/student', id: id);
      debugPrint('resultados: $response');
      if (response is List) {
        setState(() {
          _exams = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Formato de respuesta inesperado';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar estudiantes: $e';
        _isLoading = false;
      });
    }
  }

  Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar resultado?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!showResults) ...[
              _buildTabs(),
              const SizedBox(height: 20),
              Expanded(child: _buildTabContent()),
            ] else ...[
              Expanded(
                child: LikertTestView(
                  onFinish: () {
                    setState(() {
                      showResults = false;
                    });
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // TODO: Acción del botón (puede ser filtrado)
          },
          icon: const Icon(Icons.filter_alt_outlined),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final isSelected = selectedTab == index;
              return GestureDetector(
                onTap: () => setState(() => selectedTab = index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      tabs[index],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: isSelected ? 30 : 0,
                      color: Colors.black,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString; // Si hay error al parsear, devolver el string original
    }
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LineChartCard(
              values: _exams.map((e) => (e['probability'] as num).toDouble() * 100).toList(),
              months: _exams.map((e) {
                final date = DateTime.parse(e['createdAt']);
                return '${date.day}/${date.month}';
              }).toList(),
            ),
          ],
        );
      case 1:
        return ListView.builder(
          itemCount: _exams.length,
          itemBuilder: (context, index) {
            final exam = _exams[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TestResultCard(
                title: "Resultado N. ${index + 1}",
                date: _formatDate(exam['createdAt']),
                probability: "${((exam?['probability'] ?? 0) * 100).toStringAsFixed(0)}% Probabilidad",
                //result: exam['result'] == "NO" ? "Negativo" : "Positivo",
                onTap: () {
                  final examWithIndex = {...exam, 'index': index}; // Crear una copia con el índice
                  final parentState = context.findAncestorStateOfType<StudentDetailViewState>();
                  parentState?.showExamDetail(examWithIndex);
                },
                onDelete: () async {
                  final confirm = await showDeleteConfirmationDialog(context);
                  if (confirm == true) {
                    // TODO: Implementar eliminación del examen
                    // Puedes llamar a una función para eliminar el examen con exam['id']
                  }
                },
              ),
            );
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

}
