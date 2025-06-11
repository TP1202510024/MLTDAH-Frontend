import 'package:flutter/material.dart';
import '../../main_layout.dart';
import '../../../widgets/config_card.dart';

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
            final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
            mainLayoutState?.setState(() {
              mainLayoutState.goTo(4);
            });
          },
        ),
        ConfigCard(
          icon: Icons.school_outlined,
          title: 'Datos Institucionales',
          subtitle: 'Modifica los datos de la institución',
          onTap: () {
            final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
            mainLayoutState?.setState(() {
              mainLayoutState.goTo(6);
            });
          },
        ),
        ConfigCard(
          icon: Icons.school_outlined,
          title: 'Personal Docente',
          subtitle: 'A{ade, modifica o elimina al personal educativo.',
          onTap: () {
            final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
            mainLayoutState?.setState(() {
              mainLayoutState.goTo(7);
            });
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
