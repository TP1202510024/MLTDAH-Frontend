import 'package:flutter/material.dart';
import '../widgets/config_card.dart';

class ConfigView extends StatelessWidget {
  const ConfigView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const SizedBox(height: 16),
        ConfigCard(
          icon: Icons.person_outline,
          title: 'Datos Personales',
          subtitle: 'Edita tus datos personales',
          onTap: () {
            // TODO: Navegar a pantalla de edición de perfil
          },
        ),
        ConfigCard(
          icon: Icons.lock_outline,
          title: 'Cambiar Contraseña',
          subtitle: 'Actualiza tu contraseña',
          onTap: () {
            // TODO: Navegar a cambiar contraseña
          },
        ),
        ConfigCard(
          icon: Icons.school_outlined,
          title: 'Datos Institucionales',
          subtitle: 'Modifica los datos de la institución',
          onTap: () {
            // TODO: Navegar a edición de institución
          },
        ),
        ConfigCard(
          icon: Icons.logout,
          title: 'Cerrar Sesión',
          subtitle: 'Sal de tu cuenta actual',
          onTap: () {
            // TODO: Implementar cierre de sesión
          },
        ),
      ],
    );
  }
}
