import 'package:flutter/material.dart';
import '../widgets/custom_app_header.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home/views/config_view.dart';
import 'home/views/home_view.dart';
import 'home/views/notifications_view.dart';
import 'home/views/students_view.dart';
import 'user/edit_profile_view.dart';

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
      default:
        return '';
    }
  }
}
