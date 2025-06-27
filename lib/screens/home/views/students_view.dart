import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_app_header.dart';
import '../../main_layout.dart';
import '../../../widgets/student_card.dart';

class StudentsView extends StatefulWidget {
  const StudentsView({super.key});

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  List<dynamic> _students = [];
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _gradeTypes = [];
  List<Map<String, dynamic>> _genderTypes = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userData = await loadUserData();
    if (userData != null && mounted) {
      final role = userData['role']['name'];
      final id = role=="PARENT"?userData['id']:userData['institution']['id'].toString();
      _fetchStudents(id, userData['role']['name']);
    }
    final responses = await Future.wait([
      _fetchGrades(),
      _fetchGenders(),
    ]);
    setState(() {
      _gradeTypes = responses[0];
      _genderTypes = responses[1];
      _isLoading = false;
    });
  }

  Future<void> _fetchStudents(String institutionId, String role) async {
    try {
      if( role == 'PARENT'){
        final response = await ApiService.getWithAuth(
            endpoint: '/api/v1/parents/parent', id: institutionId);
        setState(() {
          _students = (response as List<dynamic>);
          _isLoading = false;
        });
      } else{
        final response = await ApiService.getWithAuth(
            endpoint: '/api/v1/students/institution', id: institutionId);
        setState(() {
          _students = (response as List<dynamic>);
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

  Future<List<Map<String, dynamic>>> _fetchGrades() async {
    try {
      final response = await ApiService.getWithAuth(
        endpoint: '/api/v1/school-grades',
      );
      return (response as List)
          .map<Map<String, dynamic>>(
              (grade) => {'id': grade['id'], 'name': grade['name'].toString()})
          .toList();
    } catch (e) {
      debugPrint('Error cargando grade: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchGenders() async {
    try {
      final response = await ApiService.getWithAuth(
        endpoint: '/api/v1/gender',
      );
      return (response as List)
          .map<Map<String, dynamic>>((gender) =>
              {'id': gender['id'], 'name': gender['name'].toString()})
          .toList();
    } catch (e) {
      debugPrint('Error cargando gender: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomAppHeader(
        title: "Estudiantes",
        extraRightWidget: IconButton(
          icon: const Icon(Icons.filter_alt_outlined),
          onPressed: () {
            // TODO: Mostrar diálogo o menú de filtros
          },
        ),
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
          child: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(child: Text(_error!))
          else
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: _students.length,
              itemBuilder: (context, index) {
                final student = _students[index];
                final birthDate = student['birthDate'] as String?;
                final age = birthDate != null
                    ? '${calculateAge(birthDate)} años'
                    : 'Edad no disponible';

                return StudentCard(
                  name: '${student['firstName']} ${student['lastName']}',
                  grade: student['schoolGrade']['name'],
                  age: age,
                  imageUrl: student['photo'] ?? 'assets/images/profile1.png',
                  onTap: () {
                    final mainLayoutState =
                        context.findAncestorStateOfType<MainLayoutState>();
                    mainLayoutState?.setState(() {
                      mainLayoutState?.goTo(9,
                          extraData: student); // Ir a EditProfileView
                    });
                  },
                );
              },
            ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onPressed: () {
                final mainLayoutState =
                    context.findAncestorStateOfType<MainLayoutState>();
                mainLayoutState?.setState(() {
                  mainLayoutState.goTo(5);
                });
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ))
    ]);
  }
}
