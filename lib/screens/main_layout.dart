import 'package:flutter/material.dart';
import 'package:mltdah_frontend/screens/student/edit_student_view.dart';
import 'package:mltdah_frontend/screens/student/student_detail_view.dart';
import 'package:mltdah_frontend/screens/teacher/add_teacher_view.dart';
import 'package:mltdah_frontend/screens/teacher/edit_teacher_view.dart';
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
  dynamic _extraData;

  void goTo(int index, {dynamic extraData}) {
    setState(() {
      _selectedIndex = index;
      _extraData = extraData;
    });
  }

  Widget _getCurrentView() {
    switch (_selectedIndex) {
      case 0: return const HomeView();
      case 1: return const StudentsView();
      case 2: return const ConfigView();
      case 3: return const NotificationsView();
      case 4: return EditProfileView();
      case 5: return AddStudentView();
      case 6: return EditInstitutionView();
      case 7: return const TeacherView();
      case 8: return const AddTeacherView();
      case 9: return StudentDetailView(extraData: _extraData);
      case 10: return EditStudentView(extraData: _extraData);
      case 11: return EditTeacherView(extraData: _extraData);
      default: return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: _getCurrentView(),
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
}
