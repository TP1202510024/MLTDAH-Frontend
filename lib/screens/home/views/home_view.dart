import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_app_header.dart';
import '../../main_layout.dart';
import '../../../widgets/config_card.dart';
import '../../../widgets/notification_card.dart';
import '../../../widgets/student_card.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List<dynamic> _students = [];
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _error;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final userData = await loadUserData();
      if (userData != null && mounted) {
        setState(() {
          _userRole = userData['role']['name'];
        });

        final id = _userRole == "PARENT" ? userData['id'] : userData['institution']['id'].toString();

        // Cargar estudiantes (máximo 2)
        final studentsResponse = _userRole == "PARENT"
            ? await ApiService.getWithAuth(endpoint: '/api/v1/parents/parent', id: id)
            : await ApiService.getWithAuth(endpoint: '/api/v1/students/institution', id: id);

        // Cargar notificaciones solo si no es PARENT (máximo 2)
        List<dynamic> notificationsResponse = [];
        if (_userRole != "PARENT") {
          notificationsResponse = await ApiService.getWithAuth(
              endpoint: '/api/v1/notifications/institution',
              id: id
          );
        }

        setState(() {
          _students = (studentsResponse as List<dynamic>).take(2).toList();
          _notifications = (notificationsResponse as List<dynamic>).take(2).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomAppHeader(
        title: "Inicio",
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
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!))
              : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              // Sección de Estudiantes
              Text("Estudiantes",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              ..._students.map((student) {
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
                      mainLayoutState.goTo(9, extraData: student);
                    });
                  },
                );
              }).toList(),

              // Sección de Notificaciones (solo si no es PARENT)
              if (_userRole != "PARENT") ...[
                SizedBox(height: 20),
                Text("Notificaciones",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 8),
                ..._notifications.map((notification) => NotificationCard(
                  title: notification['title'],
                  message: notification['description'],
                  status: notification['tag'],
                )).toList(),
              ],

              // Sección de Configuración
              SizedBox(height: 20),
              Text("Configuración",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 8),
              ConfigCard(
                icon: Icons.person_outline,
                title: 'Datos Personales',
                subtitle: 'Edita tus datos personales',
                onTap: () {
                  final mainLayoutState =
                  context.findAncestorStateOfType<MainLayoutState>();
                  mainLayoutState?.setState(() {
                    mainLayoutState.goTo(4); // Ir a EditProfileView
                  });
                },
              ),
            ],
          ))
    ]);
  }
}