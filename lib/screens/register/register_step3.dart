import 'dart:io';
import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/profile_photo_picker.dart';
import '../../routes/app_routes.dart';

class RegisterStep3 extends StatefulWidget {
  const RegisterStep3({super.key});

  @override
  State<RegisterStep3> createState() => _RegisterStep3State();
}

class _RegisterStep3State extends State<RegisterStep3> {
  String? _selectedInstitution;
  String? _selectedRole;
  File? _credentialPhoto;

  final List<String> _institutions = [
    'IE 2045 San Juan',
    'IEP María Montessori',
    'Colegio Nacional El Saber',
  ];

  final List<String> _roles = [
    'Docente',
    'Directivo',
    'Orientador',
    'Otro',
  ];

  void _finishRegistration() {
    if (_selectedInstitution == null || _selectedRole == null || _credentialPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.registerSuccess);
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
                'Registro – Datos institucionales',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              const Text("Institución Educativa"),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: _selectedInstitution,
                items: _institutions
                    .map((inst) => DropdownMenuItem(
                  value: inst,
                  child: Text(inst),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedInstitution = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Rol en la Institución"),
              const SizedBox(height: 5),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: _roles
                    .map((role) => DropdownMenuItem(
                  value: role,
                  child: Text(role),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                ),
              ),
              const SizedBox(height: 30),

              const Text("Foto Adicional (Credencial/ID)", textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Center(
                child: ProfilePhotoPicker(
                  onImageSelected: (file) {
                    _credentialPhoto = file;
                  },
                ),
              ),
              const SizedBox(height: 40),

              CustomButton(
                text: "Finalizar Registro",
                onPressed: _finishRegistration,
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
