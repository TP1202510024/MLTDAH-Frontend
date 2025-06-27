import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_app_header.dart';
import '../../widgets/profile_photo_picker.dart';
import '../main_layout.dart';
import 'dart:io';

class EditTeacherView extends StatefulWidget {
  final dynamic extraData;
  const EditTeacherView({super.key, this.extraData});

  @override
  State<EditTeacherView> createState() => _EditTeacherViewState();
}

class _EditTeacherViewState extends State<EditTeacherView> {
  int currentStep = 0;
  bool _isLoading = true;
  String? _error;
  DateTime? _selectedDate;

  final _docNumberController = TextEditingController();
  final _birthdateController = TextEditingController();

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final birthdateController = TextEditingController();
  String selectedGender = "Hombre";
  File? selectedImage;


  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        debugPrint('Imagen subida exitosamente. ${widget.extraData.toString()}');
        _isLoading = false;
        _docNumberController.text = widget.extraData['dni'].toString();

        nameController.text = widget.extraData['firstName'] ?? '';
        lastNameController.text = widget.extraData['lastName'] ?? '';
        _selectedDate = DateTime.parse(widget.extraData['birthDate'].toString());
        _birthdateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error en _loadInitialData: $e');
    }
  }

  void _goBackToTeachers() {
    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
    mainLayoutState?.setState(() {
      mainLayoutState.goTo(7);
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _birthdateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }
  Future<void> _submit() async {
    final fields = [
      nameController.text.isEmpty ? 'Nombres' : null,
      lastNameController.text.isEmpty ? 'Apellidos' : null,
      _docNumberController.text.isEmpty ? 'Número de documento' : null,
      _birthdateController.text.isEmpty ? 'Fecha de nacimiento' : null,
    ].whereType<String>().toList();

    if (fields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete los campos: ${fields.join(', ')}')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.putWithAuth(
        endpoint: '/api/v1/users',
        id: widget.extraData['id']?.toString(),
        body: {
          "firstName": nameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "dni": _docNumberController.text.trim(),
          "birthDate": _selectedDate!.toIso8601String(),
        },
      );

      debugPrint('Usuario creado: $result');
      if (mounted) setState(() => currentStep = 1);
    } catch (e) {
      debugPrint('Error al crear usuario: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear usuario: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    return Column(children: [
      CustomAppHeader(
        title: "Editar Personal Docente",
        onNotificationsTap: () {
          final mainLayoutState =
          context.findAncestorStateOfType<MainLayoutState>();
          mainLayoutState?.setState(() {
            mainLayoutState?.goTo(3); // Ir a EditProfileView
          });
        },
        onProfileTap: () {
          // Ir al perfil
        },
      ),
      Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            children: [
              const SizedBox(height: 16),
              if (currentStep == 0) ...[
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: "Nombres", controller: nameController)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(label: "Apellidos", controller: lastNameController)),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Número de Documento",
                  controller: _docNumberController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Ingresa el número de documento";
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: "Fecha de Nacimiento",
                      hintText: "DD/MM/AAAA",
                      controller: _birthdateController,
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Selecciona una fecha";
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
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
          )
      )
    ]);
  }
}
