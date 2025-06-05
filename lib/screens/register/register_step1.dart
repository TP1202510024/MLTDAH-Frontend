import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class RegisterStep1 extends StatefulWidget {
  const RegisterStep1({super.key});

  @override
  State<RegisterStep1> createState() => _RegisterStep1State();
}

class _RegisterStep1State extends State<RegisterStep1> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController(); // "Dioses"
  final _birthdateController = TextEditingController();

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      _birthdateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  void _goToNextStep() {
    // Aquí puedes guardar temporalmente los datos o pasarlos por argumentos
    Navigator.pushNamed(context, '/register-step2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Registro – Datos personales',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),

              CustomTextField(
                label: "Correo",
                hintText: "example@gmail.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: "Contraseña",
                hintText: "**********",
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: "Nombres",
                hintText: "Lorem Ipsum",
                controller: _nameController,
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: "Dioses", // Ajusta el label si "Dioses" no es correcto
                hintText: "Lorem Ipsum",
                controller: _lastNameController,
              ),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: CustomTextField(
                    label: "Fecha de Nacimiento",
                    hintText: "10/10/1990",
                    controller: _birthdateController,
                    keyboardType: TextInputType.datetime,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              CustomButton(
                text: "Siguiente",
                onPressed: _goToNextStep,
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("¿Ya tienes una cuenta? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.login);
                    },
                    child: const Text(
                      "Inicia Sesión",
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
    );
  }
}
