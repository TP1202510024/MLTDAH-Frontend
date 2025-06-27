import 'package:flutter/material.dart';
import 'package:mltdah_frontend/screens/student/add_parent_view.dart';
import 'package:mltdah_frontend/screens/student/student_result_detail_view.dart';
import 'package:mltdah_frontend/screens/student/student_results_view.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_app_header.dart';
import '../../widgets/question_card.dart';
import '../main_layout.dart';
import 'liker_test.dart';

class StudentDetailView extends StatefulWidget {
  final dynamic extraData;

  const StudentDetailView({super.key, this.extraData});

  @override
  State<StudentDetailView> createState() => StudentDetailViewState();
}

class StudentDetailViewState extends State<StudentDetailView> {
  dynamic _selectedExam;
  List<dynamic> _exams = [];
  bool _isLoading = true;
  String? _error;
  int selectedTab = 0;
  bool showLikertTest = false;
  bool showResults = false;
  Map<String, dynamic> studentData = {};

  // Método para mostrar el detalle de un examen
  void showExamDetail(dynamic exam) {
    setState(() {
      debugPrint('exam: ${exam}');
      _selectedExam = exam;
      showResults = true;
      showLikertTest = false;
      debugPrint('Después de setState: _selectedExam = $_selectedExam');
    });
  }

  Future<void> _fetchExams(String studentId) async {
    try {
      final response = await ApiService.getWithAuth(
          endpoint: '/api/v1/users', id: studentId);
      setState(() {
        _exams = (response as List<dynamic>);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar examenes: $e';
        _isLoading = false;
      });
    }
  }

  final List<String> tabs = ["Test", "Resultados", "Apoderado"];

  @override
  void initState() {
    super.initState();
    if (widget.extraData != null && widget.extraData is Map<String, dynamic>) {
      try {
        final data = widget.extraData as Map<String, dynamic>;

        setState(() {
          studentData = data;
        });
      } catch (e) {
        debugPrint('Error procesando datos del estudiante: $e');
      }
    } else {
      debugPrint('Datos del estudiante no proporcionados o formato incorrecto');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomAppHeader(
        title: "Detalle Alumno",
        onNotificationsTap: () {
          final mainLayoutState =
              context.findAncestorStateOfType<MainLayoutState>();
          mainLayoutState?.setState(() {
            mainLayoutState?.goTo(3); // Ir a EditProfileView
          });
        },
        onProfileTap: () {
          // Ir al perfil
        },
      ),
      Expanded(
          child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              if (!showLikertTest && !showResults) ...[
                _buildTabs(),
                const SizedBox(height: 20),
                Expanded(child: _buildTabContent()),
              ] else if (showLikertTest) ...[
                Expanded(
                  child: LikertTestView(
                    onFinish: () {
                      setState(() {
                        showLikertTest = false;
                      });
                    },
                    extraData: widget.extraData,
                  ),
                ),
              ] else if (showResults) ...[
                Expanded(
                  child: StudentResultDetailView( // Asume que tienes un ResultsView
                    onFinish: () {
                      setState(() {
                        showResults = false;
                      });
                    },
                    studentData: widget.extraData,
                    examData: _selectedExam,
                  ),
                ),
              ]
            ],
          ),
        ),
      ))
    ]);
  }

  Widget _buildHeader() {
    final double probability = _selectedExam?['probability'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/profile1.png'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${studentData['firstName']} ${studentData['lastName']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          (studentData['birthDate']) != null
                              ? '${calculateAge(studentData['birthDate'])} años'
                              : 'Edad no disponible',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  Text(studentData['schoolGrade']['name']),
                ],
              ),
            ),
            if (showLikertTest || showResults) ...[
              if (showResults)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(probability * 100).toStringAsFixed(0)}% Probabilidad',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          showLikertTest = false;
                          showResults = false;
                        });
                      },
                    ),
                  ],
                )
              else
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      showLikertTest = false;
                      showResults = false;
                    });
                  },
                )
            ] else ...[
              IconButton(
                onPressed: () {
                  final mainLayoutState =
                  context.findAncestorStateOfType<MainLayoutState>();
                  mainLayoutState?.setState(() {
                    mainLayoutState.goTo(10, extraData: widget.extraData);
                  });
                },
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.delete),
              ),
            ],
          ],
        ),
        if (showResults && probability > 0.8)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade300),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El resultado obtenido sugiere una alta probabilidad de presentar indicios relacionados con el TDAH. Se recomienda considerar una evaluación profesional con un especialista en psicología para una valoración más precisa.',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(tabs.length, (index) {
        final isSelected = selectedTab == index;
        return GestureDetector(
          onTap: () => setState(() => selectedTab = index),
          child: Column(
            children: [
              Text(
                tabs[index],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 30,
                  color: Colors.black,
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QuestionCard(
              title: 'Test de Estudiante',
              subtitle: 'Comenzar el test del estudiante…',
              onTap: () {
                setState(() => showLikertTest = true);
              },
            ),
            QuestionCard(
              title: 'Preguntas para los padres de familia',
              subtitle: 'Click para visualizar y exportar o enviar por correo.',
            ),
            QuestionCard(
              title: 'Preguntas para los profesores',
              subtitle: 'Click para visualizar y exportar o enviar por correo.',
            ),
          ],
        );
      case 1:
        return StudentResultsView(extraData: widget.extraData,);
      case 2:
        return AddParentView(
          extraData: widget.extraData,
          onSuccess: () {
            setState(() {
              selectedTab = 0;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
