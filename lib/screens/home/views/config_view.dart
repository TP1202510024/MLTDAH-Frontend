import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_app_header.dart';
import '../../main_layout.dart';
import '../../../widgets/config_card.dart';

class ConfigView extends StatefulWidget {
  const ConfigView({super.key});

  @override
  State<ConfigView> createState() => _ConfigView();
}

class _ConfigView extends State<ConfigView> {
  String role = "";

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userData = await loadUserData();
    setState(() {
      role = userData?['role']['name'];
    });
    debugPrint('Error en _loadInitialData: $role');
  }

  Future<void> logoutUser(BuildContext context) async {
    // Mostrar diálogo de confirmación
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      // Limpiar los datos de usuario almacenados
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data'); // Elimina solo los datos de usuario
      // await prefs.clear(); // Opción nuclear: elimina TODOS los datos

      // Navegar a la pantalla de login con reemplazo para evitar volver atrás
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login, // Asegúrate que esta ruta está definida en AppRoutes
        (route) => false, // Elimina todas las rutas anteriores
      );

      // Opcional: Mostrar confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesión cerrada correctamente')),
      );
    } catch (e) {
      // Manejar errores (poco probable, pero buenas prácticas)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
      );
      debugPrint('Error en logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomAppHeader(
        title: "Configuración",
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
          child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          const SizedBox(height: 16),
          ConfigCard(
            icon: Icons.person_outline,
            title: 'Datos Personales',
            subtitle: 'Edita tus datos personales',
            onTap: () {
              final mainLayoutState =
                  context.findAncestorStateOfType<MainLayoutState>();
              mainLayoutState?.setState(() {
                mainLayoutState.goTo(4);
              });
            },
          ),
          if (role == 'REPRESENTATIVE' || role == 'ADMIN')
            ConfigCard(
              icon: Icons.school_outlined,
              title: 'Datos Institucionales',
              subtitle: 'Modifica los datos de la institución',
              onTap: () {
                final mainLayoutState =
                    context.findAncestorStateOfType<MainLayoutState>();
                mainLayoutState?.setState(() {
                  mainLayoutState.goTo(6);
                });
              },
            ),
          if (role == 'REPRESENTATIVE' || role == 'ADMIN')
            ConfigCard(
              icon: Icons.school_outlined,
              title: 'Personal Docente',
              subtitle: 'A{ade, modifica o elimina al personal educativo.',
              onTap: () {
                final mainLayoutState =
                    context.findAncestorStateOfType<MainLayoutState>();
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
              logoutUser(context);
            },
          ),
        ],
      ))
    ]);
  }
}
