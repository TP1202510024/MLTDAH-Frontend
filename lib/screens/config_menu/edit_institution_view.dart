import 'dart:io';

import 'package:flutter/material.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../widgets/profile_photo_picker.dart';
import '../main_layout.dart';

class EditInstitutionView extends StatefulWidget {
  const EditInstitutionView({super.key});

  @override
  State<EditInstitutionView> createState() => _EditInstitutionViewState();
}

class _EditInstitutionViewState extends State<EditInstitutionView> {
  int currentStep = 0;
  File? selectedProfileImage;

  // Controladores para los datos
  final nameController = TextEditingController(text: 'IEE');
  final emailController = TextEditingController();
  final birthdateController = TextEditingController();
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
        if (currentStep < 1)
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
          CustomTextField(  label: "Nombre de la institución", controller: nameController),
          const SizedBox(height: 16),
          CustomTextField(label: "Fecha de creación", controller: emailController),
          const SizedBox(height: 16),
          CustomTextField(label: "Dirección", controller: birthdateController),
          const SizedBox(height: 16),
          CustomButton(text: "Actualizar", onPressed: _goToNextStep),
        ] else if (currentStep == 1) ...[
          const SizedBox(height: 40),
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 24),
          const Text(
            "Los datos de la institución se actualizaron correctamente.",
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
