import 'package:flutter/material.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../widgets/profile_photo_picker.dart';
import 'dart:io';

class AddParentView extends StatefulWidget {
  final VoidCallback? onSuccess; // ← función opcional

  const AddParentView({super.key, this.onSuccess});

  @override
  State<AddParentView> createState() => _AddParentViewState();
}

class _AddParentViewState extends State<AddParentView> {
  int currentStep = 0;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _docNumberController = TextEditingController();

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthdateController = TextEditingController();

  File? selectedImage;
  String? _selectedDocType;

  final List<String> _docTypes = ['DNI', 'Carné de Extranjería', 'Pasaporte'];

  void _submit() {
    setState(() => currentStep = 1); // Mostrar éxito
  }

  void _goBackToParents() {
    widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const SizedBox(height: 10),
        if (currentStep == 0) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // ← centrado vertical
            children: [
              // Imagen con tamaño fijo
              SizedBox(
                width: 100,
                height: 100,
                child: ProfilePhotoPicker(
                  onImageSelected: (image) {
                    setState(() {
                      selectedImage = image;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Campos apilados verticalmente
              Expanded(
                child: Column(
                  children: [
                    CustomTextField(
                      label: "Nombres",
                      controller: nameController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: "Apellidos",
                      controller: lastNameController,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomTextField(
            label: "Correo",
            hintText: "example@gmail.com",
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          CustomTextField(
              label: "Fecha de Nacimiento", controller: birthdateController),
          const SizedBox(height: 10),
          CustomTextField(
            label: "Contraseña",
            hintText: "**********",
            controller: _passwordController,
            obscureText: true,
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          CustomTextField(
            label: "Número de Documento",
            controller: _docNumberController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          CustomButton(text: "Agregar", onPressed: _submit),
        ] else if (currentStep == 1) ...[
          const SizedBox(height: 40),
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "Apoderado agregado correctamente.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(text: "Regresar", onPressed: _goBackToParents),
        ],
      ],
    );
  }
}
