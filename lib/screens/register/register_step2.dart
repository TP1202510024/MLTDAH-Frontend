import 'dart:io';
import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/profile_photo_picker.dart';
import '../../routes/app_routes.dart';

class RegisterStep2 extends StatefulWidget {
  const RegisterStep2({super.key});

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  final _docNumberController = TextEditingController();
  String? _selectedDocType;
  File? _selectedPhoto;

  final List<String> _docTypes = ['DNI', 'Carné de Extranjería', 'Pasaporte'];

  void _goToNextStep() {
    if (_selectedDocType == null || _docNumberController.text.isEmpty || _selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.registerStep3);
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
                'Registro – Documento y Foto',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              const Text("Tipo de Documento"),
              const SizedBox(height: 5),
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                label: "Número de Documento",
                controller: _docNumberController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 30),

              const Text("Foto de Perfil", textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Center(
                child: ProfilePhotoPicker(
                  onImageSelected: (file) {
                    _selectedPhoto = file;
                  },
                ),
              ),
              const SizedBox(height: 40),

              CustomButton(
                text: "Siguiente",
                onPressed: _goToNextStep,
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Volver al paso anterior
                },
                child: const Text("Volver"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
