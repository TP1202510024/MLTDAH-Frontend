import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSession = prefs.getString('user_data')?.isNotEmpty ?? false;

  runApp(MyApp(initialRoute: hasSession ? AppRoutes.home : AppRoutes.login));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema Educativo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
