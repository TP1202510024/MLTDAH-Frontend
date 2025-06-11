import 'package:flutter/material.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../widgets/profile_photo_picker.dart';
import '../main_layout.dart';
import 'dart:io';

class EditStudentView extends StatefulWidget {
  const EditStudentView({super.key});

  @override
  State<EditStudentView> createState() => _EditStudentViewState();
}

class _EditStudentViewState extends State<EditStudentView> {
  int currentStep = 0;

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthdateController = TextEditingController();

  String selectedGrade = "Quinto grado de Primaria";
  String selectedGender = "Hombre";
  File? selectedImage;

  final List<String> grades = [
    "Primer grado de Primaria",
    "Segundo grado de Primaria",
    "Tercer grado de Primaria",
    "Cuarto grado de Primaria",
    "Quinto grado de Primaria",
    "Sexto grado de Primaria",
  ];

  final List<String> genders = [
    "Hombre",
    "Mujer",
    "Otro",
  ];

  void _submit() {
    print("Estudiante: ${nameController.text} ${lastNameController.text}");
    print("Grado: $selectedGrade, Género: $selectedGender");
    print("Foto: ${selectedImage?.path}");
    setState(() => currentStep = 1); // Mostrar éxito
  }

  void _goBackToStudents() {
    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
    mainLayoutState?.setState(() {
      mainLayoutState.goTo(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const SizedBox(height: 16),

        if (currentStep == 0) ...[
          Center(
            child: ProfilePhotoPicker(
              onImageSelected: (image) {
                setState(() {
                  selectedImage = image;
                });
              },
            ),
          ),
          const SizedBox(height: 24),
          CustomTextField(label: "Nombres", controller: nameController),
          const SizedBox(height: 16),
          CustomTextField(label: "Apellidos", controller: lastNameController),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedGrade,
            items: grades.map((grade) {
              return DropdownMenuItem(value: grade, child: Text(grade));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGrade = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: "Grado",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedGender,
            items: genders.map((gender) {
              return DropdownMenuItem(value: gender, child: Text(gender));
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
            decoration: const InputDecoration(
              labelText: "Género",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(label: "Fecha de Nacimiento", controller: birthdateController),
          const SizedBox(height: 24),
          CustomButton(text: "Actualizar", onPressed: _submit),
        ] else if (currentStep == 1) ...[
          const SizedBox(height: 40),
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Datos actualizados correctamente.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(text: "Regresar", onPressed: _goBackToStudents),
        ],
      ],
    );
  }
}
