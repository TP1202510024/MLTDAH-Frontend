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

  List<String> selectedGrades = ["5to"];
  String selectedGender = "Hombre";
  File? selectedImage;

  final List<String> grades = [
    "1ro",
    "2do",
    "3ro",
    "4to",
    "5to",
    "6to",
  ];

  final List<String> _docTypes = ['DNI', 'Carné de Extranjería', 'Pasaporte'];
  final List<String> genders = [
    "Hombre",
    "Mujer",
    "Otro",
  ];

  void _submit() {
    print("Estudiante: ${nameController.text} ${lastNameController.text}");
    print("Foto: ${selectedImage?.path}");
    setState(() => currentStep = 1); // Mostrar éxito
  }

  void _goBackToTeachers() {
    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
    mainLayoutState?.setState(() {
      mainLayoutState.goTo(7);
    });
  }

  void _showGradeSelectionDialog() async {
    final selected = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        final tempSelected = List<String>.from(selectedGrades);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Selecciona uno o más grados"),
              content: SingleChildScrollView(
                child: Column(
                  children: grades.map((grade) {
                    final isSelected = tempSelected.contains(grade);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(grade),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            tempSelected.add(grade);
                          } else {
                            tempSelected.remove(grade);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text("Cancelar"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: const Text("Aceptar"),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() {
        selectedGrades = selected;
      });
    }
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
                child: CustomTextField(
                    label: "Nombres", controller: nameController),
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
          GestureDetector(
            onTap: _showGradeSelectionDialog,
            child: AbsorbPointer(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Grados",
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                  text: selectedGrades.join(', '),
                ),
                readOnly: true,
              ),
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
