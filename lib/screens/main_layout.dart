import 'package:flutter/material.dart';
import 'package:mltdah_frontend/screens/teacher/add_teacher_view.dart';
import '../widgets/custom_app_header.dart';
import '../widgets/custom_bottom_nav.dart';
import 'config_menu/edit_institution_view.dart';
import 'teacher/teacher_view.dart';
import 'home/views/config_view.dart';
import 'home/views/home_view.dart';
import 'home/views/notifications_view.dart';
import 'home/views/students_view.dart';
import 'config_menu/edit_profile_view.dart';
import 'student/add_student_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  void goTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _views = const [
    HomeView(),
    StudentsView(),
    ConfigView(),
    NotificationsView(),
    EditProfileView(),
    AddStudentView(),
    EditInstitutionView(),
    TeacherView(),
    AddTeacherView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppHeader(
            title: _getTitleForIndex(_selectedIndex),
            onNotificationsTap: () {
              setState(() {
                _selectedIndex = 3; // Mostrar notificaciones
              });
            },
            onProfileTap: () {
              // Ir al perfil
            },
            extraRightWidget: _selectedIndex == 1
                ? IconButton(
              icon: const Icon(Icons.filter_alt_outlined),
              onPressed: () {
                // TODO: Mostrar diálogo o menú de filtros
              },
            )
                : null,
          ),
          Expanded(
            child: _views[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex > 2 ? 0 : _selectedIndex, // Resalta "Inicio" si estás en notificaciones
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Inicio';
      case 1:
        return 'Estudiantes';
      case 2:
        return 'Configuración';
      case 3:
        return 'Notificaciones';
      case 4:
        return 'Editar perfil';
      case 5:
        return 'Añadir estudiante';
      case 6:
        return 'Actualizar datos institucionales';
      case 7:
        return 'Personal Docente';
      case 8:
        return 'Añadir Personal Docente';
      default:
        return '';
    }
  }
}
