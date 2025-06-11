import 'package:flutter/material.dart';
import '../../../widgets/notification_card.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
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
        NotificationCard(
          title: 'Juan Lopez – Estudiantes',
          message: 'Se ha agregado correctamente al estudiante',
          status: 'Agregado',
        ),
      ],
    );
  }
}
