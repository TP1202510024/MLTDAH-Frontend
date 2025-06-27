import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_app_header.dart';
import '../../../widgets/notification_card.dart';
import '../../main_layout.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<dynamic> notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _fetchNotifications(String institutionId) async {
    try {
      final response = await ApiService.getWithAuth(
          endpoint: '/api/v1/notifications/institution', id: institutionId);
      setState(() {
        notifications = (response as List<dynamic>);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar estudiantes: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadInitialData() async {
    final userData = await loadUserData();
    if (userData != null && mounted) {
      final id = userData['institution']['id'].toString();
      _fetchNotifications(id);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CustomAppHeader(
        title: "Notificaciones",
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
          child:
          ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return
                NotificationCard(
                  title: notification['title'],
                  message: notification['description'],
                  status: notification['tag'],
                );
            },
          ),
      )
    ]);
  }
}
