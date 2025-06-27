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

class EditStudentView extends StatefulWidget {
  final dynamic extraData;
  const EditStudentView({super.key, this.extraData});

  @override
  State<EditStudentView> createState() => _EditStudentViewState();
}

class _EditStudentViewState extends State<EditStudentView> {
  int currentStep = 0;
  DateTime? _selectedDate;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _gradeTypes = [];
  List<Map<String, dynamic>> _genderTypes = [];
  String? _selectedSchoolGradeId;
  String? _selectedGenderId;

  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final _birthdateController = TextEditingController();

  void initState() {
    super.initState();
    _loadInitialData();
  }
  Future<void> _loadInitialData() async {
    try {
      if (widget.extraData != null) {
        setState(() {
          _selectedSchoolGradeId = widget.extraData['schoolGrade']['id'].toString();
          _selectedGenderId = widget.extraData['gender']['id'].toString();

          nameController.text = widget.extraData['firstName'] ?? '';
          lastNameController.text = widget.extraData['lastName'] ?? '';
          _selectedDate = DateTime.parse(widget.extraData['birthDate'].toString());
          _birthdateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        });
      }
      final responses = await Future.wait([
        _fetchGrades(),
        _fetchGenders(),
      ]);

      setState(() {
        _gradeTypes = responses[0];
        _genderTypes = responses[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar datos iniciales: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('Error en _loadInitialData: $e');
    }
  }

  Future<void> _submit() async {
    final fields = [
      nameController.text.isEmpty ? 'Nombres' : null,
      lastNameController.text.isEmpty ? 'Apellidos' : null,
      _birthdateController.text.isEmpty ? 'Fecha de nacimiento' : null,
      _selectedSchoolGradeId == null ? 'Grado' : null,
      _selectedGenderId == null ? 'Género' : null,
    ].whereType<String>().toList();

    if (fields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete los campos: ${fields.join(', ')}')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      debugPrint('Estudiante editado:');
      final result = await ApiService.putWithAuth(
        endpoint: '/api/v1/students',
        id: widget.extraData['id']?.toString(),
        body: {
          "firstName": nameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "birthDate": _selectedDate!.toIso8601String(),
          "genderId": int.parse(_selectedGenderId!),
          "schoolGradeId": int.parse(_selectedSchoolGradeId!),
        },
      );

      debugPrint('Estudiante editado: $result');
      if (mounted) setState(() => currentStep = 1);
    } catch (e) {
      debugPrint('Error al editar Estudiante: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al ediat Estudiante: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  void _goBackToStudents() {
    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
    mainLayoutState?.setState(() {
      mainLayoutState?.setState(() {
        mainLayoutState.goTo(1);
      });
    });
  }

  Future<List<Map<String, dynamic>>> _fetchGrades() async {
    try {
      final response = await ApiService.getWithAuth(
        endpoint: '/api/v1/school-grades',
      );
      return (response as List).map<Map<String, dynamic>>((grade) => {
        'id': grade['id'],
        'name': grade['name'].toString()
      }).toList();
    } catch (e) {
      debugPrint('Error cargando grade: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchGenders() async {
    try {
      final response = await ApiService.getWithAuth(
        endpoint: '/api/v1/gender',
      );
      return (response as List).map<Map<String, dynamic>>((gender) => {
        'id': gender['id'],
        'name': gender['name'].toString()
      }).toList();
    } catch (e) {
      debugPrint('Error cargando gender: $e');
      return [];
    }
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

  @override
  Widget build(BuildContext context) {

    return Column(children: [
      CustomAppHeader(
        title: "Editar Detalles del Alumno",
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
                CustomTextField(
                  label: "Nombres",
                  controller: nameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: "Apellidos",
                  controller: lastNameController,
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
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSchoolGradeId,
                  items: _gradeTypes
                      .map((grade) => DropdownMenuItem(
                    value: grade['id'].toString(),
                    child: Text(grade['name']),
                  ))
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedSchoolGradeId = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Grado",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Seleccione un grado';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGenderId,
                  items: _genderTypes
                      .map((gender) => DropdownMenuItem(
                    value: gender['id'].toString(),
                    child: Text(gender['name']),
                  ))
                      .toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedGenderId = value;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: "Género",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Seleccione un género';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                CustomButton(text: "Editar", onPressed: _submit),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
                    mainLayoutState?.setState(() {
                      mainLayoutState.goTo(9, extraData: widget.extraData);
                    });
                  },
                  child: const Text("Volver"),
                ),
              ] else if (currentStep == 1) ...[
                const SizedBox(height: 40),
                const Icon(Icons.check_circle, color: Colors.green, size: 100),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Estudiante editado correctamente.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(text: "Regresar", onPressed: _goBackToStudents),
              ],
            ],
          )
      )
    ]);
  }
}
