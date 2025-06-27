import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CustomAppHeader extends StatefulWidget {
  final String? title;
  final VoidCallback? onNotificationsTap;
  final VoidCallback? onProfileTap;
  final Widget? extraRightWidget;

  const CustomAppHeader({
    super.key,
    this.title,
    this.onNotificationsTap,
    this.onProfileTap,
    this.extraRightWidget,
  });

  @override
  State<CustomAppHeader> createState() => _CustomAppHeaderState();
}

class _CustomAppHeaderState extends State<CustomAppHeader> {
  bool _isParent = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        if (mounted) {
          setState(() {
            _isParent = userData['role']['name'] == 'PARENT';
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint('Error checking user role: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Spacer(),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            if (widget.title != null)
              Text(
                widget.title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Spacer(),
            if (widget.extraRightWidget != null) widget.extraRightWidget!,
            // Mostrar icono de notificaciones solo si no es PARENT
            if (!_isParent)
              IconButton(
                onPressed: widget.onNotificationsTap,
                icon: const Icon(Icons.notifications_outlined),
              ),
            GestureDetector(
              onTap: widget.onProfileTap,
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('assets/images/profile1.png'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}