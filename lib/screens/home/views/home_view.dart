import 'package:flutter/material.dart';
import '../../main_layout.dart';
import '../../../widgets/config_card.dart';
import '../../../widgets/notification_card.dart';
import '../../../widgets/student_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        Text("Estudiantes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 8),
        StudentCard(
          name: 'Juan Lopez',
          grade: 'Quinto grado de Primaria',
          age: '10 años',
          imageUrl: 'assets/images/profile1.png',
        ),
        StudentCard(
          name: 'Juan Lopez',
          grade: 'Quinto grado de Primaria',
          age: '10 años',
          imageUrl: 'assets/images/profile1.png',
        ),
        SizedBox(height: 20),
        Text("Notificaciones", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 8),
        NotificationCard(
          title: 'Juan Lopez – Estudiantes',
          message: 'Se ha generado el resultado del Test N.1 del estudiante.',
          status: '95% Probabilidad',
        ),
        NotificationCard(
          title: 'Juan Lopez – Estudiantes',
          message: 'Se ha completado el test y se está generando el informe...',
          status: 'Generando',
        ),
        SizedBox(height: 20),
        Text("Configuración", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(height: 8),
        ConfigCard(
          icon: Icons.person_outline,
          title: 'Datos Personales',
          subtitle: 'Edita tus datos personales',
          onTap: () {
            final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
            mainLayoutState?.setState(() {
              mainLayoutState.goTo(4); // Ir a EditProfileView
            });
          },
        ),
      ],
    );
  }
}
