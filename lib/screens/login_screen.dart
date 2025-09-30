import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../routes/app_routes.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<bool> _saveUserData(String responseBody) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('user_data', responseBody);
    } catch (e) {
      print("Error guardando datos: $e");
      return false;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    const timeoutDuration = Duration(seconds: 30);
    final url = Uri.parse("http://ec2-18-207-118-50.compute-1.amazonaws.com:8080/api/v1/authentication/sign-in");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(timeoutDuration);

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final saved = await _saveUserData(response.body);

        if (saved) {
          if (!mounted) return;
          Navigator.pushReplacementNamed(context, AppRoutes.home);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inicio de sesión exitoso")),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error al guardar datos localmente")),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tiempo de espera agotado")),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión")),
      );
      print("Excepción: $e");
    }
  }
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return "El correo es obligatorio";
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return "Correo inválido";
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return "La contraseña es obligatoria";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),

                CustomTextField(
                  label: "Correo",
                  hintText: "example@gmail.com",
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 20),

                CustomTextField(
                  label: "Contraseña",
                  hintText: "**********",
                  controller: _passwordController,
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    child: const Text("¿Olvidaste tu contraseña?"),
                  ),
                ),

                const SizedBox(height: 10),
                CustomButton(
                  text: _isLoading ? "Ingresando..." : "Ingresar",
                  onPressed: () =>{
                    if(!_isLoading) _login()
                  }
                ),
                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("¿No tienes una cuenta? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.registerStep1);
                      },
                      child: const Text(
                        "Crear Cuenta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
