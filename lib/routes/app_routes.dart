import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register/register_step1.dart';
import '../screens/register/register_step2.dart';
import '../screens/register/register_step3.dart';
import '../screens/register/register_success.dart';

class AppRoutes {
  static const String login = '/';
  static const String registerStep1 = '/register-step1';
  static const String registerStep2 = '/register-step2';
  static const String registerStep3 = '/register-step3';
  static const String registerSuccess = '/register-success';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    registerStep1: (context) => const RegisterStep1(),
    registerStep2: (context) => const RegisterStep2(),
    registerStep3: (context) => const RegisterStep3(),
    registerSuccess: (context) => const RegisterSuccess(),
  };
}
