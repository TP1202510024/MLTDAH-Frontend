import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../services/api_service.dart';
import '../../widgets/profile_photo_picker.dart';
import 'dart:io';

class AddParentView extends StatefulWidget {
  final dynamic extraData;
  final VoidCallback? onSuccess;

  const AddParentView({super.key, this.onSuccess, this.extraData});

  @override
  State<AddParentView> createState() => _AddParentViewState();
}

class _AddParentViewState extends State<AddParentView> {
  int currentStep = 0;
  bool _isLoading = true;
  bool _isEditMode = false;
  String? _error;
  DateTime? _selectedDate;
  String? _existingParentId;

  final _passwordController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _birthdateController = TextEditingController();
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  String selectedGender = "Hombre";
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    _loadParentData();
  }

  Future<void> _loadParentData() async {
    try {
      setState(() => _isLoading = true);

      // Verificar si el estudiante ya tiene un apoderado
      final response = await ApiService.getWithAuth(
        endpoint: '/api/v1/parents/student/${widget.extraData['id']}',
      );

      if (response != null && response['parent'] != null) {
        // Modo edición
        setState(() {
          _isEditMode = true;
          _existingParentId = response['parent']['id'].toString();
          _fillFormWithExistingData(response['parent']);
        });
      }
    } catch (e) {
      debugPrint('Error al cargar datos del apoderado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _fillFormWithExistingData(Map<String, dynamic> parentData) {
    nameController.text = parentData['firstName'] ?? '';
    lastNameController.text = parentData['lastName'] ?? '';
    _emailController.text = parentData['email'] ?? '';
    _docNumberController.text = parentData['dni'] ?? '';

    if (parentData['birthDate'] != null) {
      try {
        _selectedDate = DateTime.parse(parentData['birthDate']);
        _birthdateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      } catch (e) {
        debugPrint('Error al parsear fecha: $e');
      }
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990, 1, 1),
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
    // Validación de campos obligatorios
    final requiredFields = [
      nameController.text.isEmpty ? 'Nombres' : null,
      lastNameController.text.isEmpty ? 'Apellidos' : null,
      _docNumberController.text.isEmpty ? 'Número de documento' : null,
      _emailController.text.isEmpty ? 'Correo electrónico' : null,
      (!_isEditMode && _passwordController.text.isEmpty) ? 'Contraseña' : null,
      _birthdateController.text.isEmpty ? 'Fecha de nacimiento' : null,
    ].whereType<String>().toList();

    if (requiredFields.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Complete los campos: ${requiredFields.join(', ')}')),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un email válido')),
      );
      return;
    }

    if (!_isEditMode && _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña debe tener al menos 6 caracteres')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(prefs.getString('user_data') ?? '{}');

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        // Lógica para editar
        await _updateParent();
      } else {
        // Lógica para crear
        await _createParent();
      }

      if (mounted) setState(() => currentStep = 1);
    } catch (e) {
      debugPrint('Error al ${_isEditMode ? 'editar' : 'crear'} apoderado: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createParent() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
    final result = await ApiService.postWithAuth(
      endpoint: '/api/v1/users',
      body: {
        "firstName": nameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "dni": _docNumberController.text.trim(),
        "birthDate": _selectedDate!.toIso8601String(),
        "email": _emailController.text.trim(),
        "password": _passwordController.text,
        "institutionId": userData['institution']['id'],
        "roleId": 4,
      },
    );

    await ApiService.postWithAuth(
      endpoint: '/api/v1/parents',
      body: {
        "parentId": result['id'].toString(),
        "studentId": widget.extraData['id'].toString(),
      },
    );
  }

  Future<void> _updateParent() async {
    final updateData = {
      "firstName": nameController.text.trim(),
      "lastName": lastNameController.text.trim(),
      "dni": _docNumberController.text.trim(),
      "birthDate": _selectedDate!.toIso8601String(),
      "email": _emailController.text.trim(),
      // No incluimos password en la actualización
    };

    await ApiService.putWithAuth(
      endpoint: '/api/v1/users/${_existingParentId}',
      body: updateData,
    );
  }

  void _goBackToParents() {
    widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      children: [
        const SizedBox(height: 10),
        if (currentStep == 0) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
          if (!_isEditMode) ...[
            CustomTextField(
              label: "Contraseña",
              hintText: "**********",
              controller: _passwordController,
              obscureText: true,
            ),
            const SizedBox(height: 10),
          ],
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
          const SizedBox(height: 10),
          CustomTextField(
            label: "Número de Documento",
            controller: _docNumberController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: _isEditMode ? "Actualizar" : "Agregar",
            onPressed: _submit,
          ),
        ] else if (currentStep == 1) ...[
          const SizedBox(height: 40),
          const Icon(Icons.check_circle, color: Colors.green, size: 100),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              _isEditMode
                  ? "Apoderado actualizado correctamente."
                  : "Apoderado agregado correctamente.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(text: "Regresar", onPressed: _goBackToParents),
        ],
      ],
    );
  }
}