import 'dart:io';

import 'package:flutter/material.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../widgets/profile_photo_picker.dart';
import '../main_layout.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  int currentStep = 0;
  File? selectedProfileImage;

  // Controladores para los datos
  final nameController = TextEditingController(text: 'Pedro');
  final lastNameController = TextEditingController(text: 'Lopez');
  final emailController = TextEditingController();
  final birthdateController = TextEditingController();
  final passwordController = TextEditingController();

  final docTypeController = TextEditingController();
  final docNumberController = TextEditingController();

  void _goToNextStep() {
    setState(() => currentStep++);
  }

  void _submit() {
    // TODO: Aquí va la lógica para enviar los datos
    print('Enviando: ${nameController.text}, ${docNumberController.text}');
    setState(() => currentStep = 2); // Mostrar success
  }

  void _goBackToConfig() {
    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
    mainLayoutState?.setState(() {
      mainLayoutState.goTo(2); // Ir a EditProfileView
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const SizedBox(height: 16),
        if (currentStep < 2)
          Center(
            child: ProfilePhotoPicker(
              onImageSelected: (image) {
                setState(() {
                  selectedProfileImage = image;
                });
              },
            ),
          ),
        const SizedBox(height: 24),
        if (currentStep == 0) ...[
          Row(
            children: [
              Expanded(
                  child: CustomTextField(
                      label: "Nombres", controller: nameController)),
              const SizedBox(width: 12),
              Expanded(
                  child: CustomTextField(
                      label: "Apellidos", controller: lastNameController)),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(label: "Correo", controller: emailController),
          const SizedBox(height: 16),
          CustomTextField(
              label: "Fecha de Nacimiento", controller: birthdateController),
          const SizedBox(height: 16),
          CustomTextField(
              label: "Contraseña",
              controller: passwordController,
              obscureText: true),
          const SizedBox(height: 24),
          CustomButton(text: "Siguiente", onPressed: _goToNextStep),
        ] else if (currentStep == 1) ...[
          CustomTextField(
              label: "Tipo de Documento", controller: docTypeController),
          const SizedBox(height: 16),
          CustomTextField(
              label: "Número de Documento", controller: docNumberController),
          const SizedBox(height: 24),
          CustomButton(text: "Actualizar", onPressed: _submit),
        ] else if (currentStep == 2) ...[
          const SizedBox(height: 40),
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 24),
          const Text(
            "Tus datos se actualizaron correctamente.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          CustomButton(text: "Regresar", onPressed: _goBackToConfig),
        ],
      ],
    );
  }
}
