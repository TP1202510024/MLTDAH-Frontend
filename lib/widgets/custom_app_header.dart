import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomAppHeader extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            if (title != null)
              Text(
                title!,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            const Spacer(),
            if (extraRightWidget != null) extraRightWidget!,
            IconButton(
              onPressed: onNotificationsTap,
              icon: const Icon(Icons.notifications_outlined),
            ),
            GestureDetector(
              onTap: onProfileTap,
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
