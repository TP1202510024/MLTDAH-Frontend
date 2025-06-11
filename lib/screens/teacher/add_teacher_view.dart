import 'package:flutter/material.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../widgets/profile_photo_picker.dart';
import '../main_layout.dart';
import 'dart:io';

class AddTeacherView extends StatefulWidget {
  const AddTeacherView({super.key});

  @override
  State<AddTeacherView> createState() => _AddTeacherViewState();
}

class _AddTeacherViewState extends State<AddTeacherView> {
  int currentStep = 0;
  String? _selectedDocType;
  final _passwordController = TextEditingController();
  final _docNumberController = TextEditingController();

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthdateController = TextEditingController();
  final _emailController = TextEditingController();

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

  final List<String> _docTypes = ['DNI', 'Carné de Extranjería', 'Pasaporte'];
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

  void _goBackToTeachers() {
    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
    mainLayoutState?.setState(() {
      mainLayoutState.goTo(7);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const SizedBox(height: 16),
        if (currentStep == 0) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfilePhotoPicker(
                onImageSelected: (image) {
                  setState(() {
                    selectedImage = image;
                  });
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(label: "Nombres", controller: nameController),
              ),
            ],
          ),

          const SizedBox(height: 16),
          CustomTextField(label: "Apellidos", controller: lastNameController),
          const SizedBox(height: 16),
          CustomTextField(
              label: "Correo",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          CustomTextField(
            label: "Contraseña",
            hintText: "**********",
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 16),
          CustomTextField(
              label: "Fecha de Nacimiento", controller: birthdateController),
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
            value: _selectedDocType,
            items: _docTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedDocType = value;
              });
            },
            decoration: InputDecoration(
              labelText: "Tipo de Documento",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            ),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: "Número de Documento",
            controller: _docNumberController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          CustomButton(text: "Agregar", onPressed: _submit),
        ] else if (currentStep == 1) ...[
          const SizedBox(height: 40),
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Estudiante agregado correctamente.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(text: "Regresar", onPressed: _goBackToTeachers),
        ],
      ],
    );
  }
}
