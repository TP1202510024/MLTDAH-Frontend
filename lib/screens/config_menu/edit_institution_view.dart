import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_app_header.dart';
import '../../widgets/profile_photo_picker.dart';
import '../main_layout.dart';
import 'package:http/http.dart' as http;

class EditInstitutionView extends StatefulWidget {
  const EditInstitutionView({super.key});

  @override
  State<EditInstitutionView> createState() => _EditInstitutionViewState();
}

class _EditInstitutionViewState extends State<EditInstitutionView> {
  int currentStep = 0;
  File? selectedProfileImage;
  bool _isLoading = true;
  DateTime? _selectedDate;

  // Controladores para los datos
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final creationdateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final userData = await loadUserData();

    if (userData != null && mounted) {
      setState(() {
        nameController.text = userData['institution']['name'] ?? '';
        addressController.text = userData['institution']['address'] ?? '';
        if (userData['institution']['creationDate'] != null) {
          try {
            _selectedDate = DateTime.parse(userData['creationDate']);
            creationdateController.text =
                DateFormat('dd/MM/yyyy').format(_selectedDate!);
            debugPrint('Fecha cargada correctamente: ${_selectedDate}');
          } catch (e) {
            debugPrint(
                'Error parsing creationDate: ${userData['creationDate']} - $e');
            _selectedDate = DateTime(1990, 1, 1);
            creationdateController.text =
                DateFormat('dd/MM/yyyy').format(_selectedDate!);
          }
        } else {
          _selectedDate = DateTime(1990, 1, 1);
          creationdateController.text =
              DateFormat('dd/MM/yyyy').format(_selectedDate!);
        }
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _goBackToConfig() {
    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
    mainLayoutState?.setState(() {
      mainLayoutState.goTo(2); // Ir a EditProfileView
    });
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
        creationdateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      final institutionId = userData['institution']['id']?.toString();
      final creationDate = userData['institution']['creationDate'];

      if (institutionId == null) {
        throw Exception('ID de institución no encontrado');
      }

      final formattedDate = _selectedDate?.toIso8601String() ?? creationDate;

      final result = await ApiService.putWithAuth(
        endpoint: '/api/v1/institutions',
        id: institutionId,
        body: {
          "name": nameController.text,
          "address": addressController.text,
          "creationDate": formattedDate,
        },
      );

      final updatedUserData = {
        ...userData,
        'institution': result,
      };

      debugPrint('Error en _submit: $result');
      debugPrint('Error en _submit: $updatedUserData');
      await prefs.setString('user_data', jsonEncode(updatedUserData));

      if (mounted) setState(() => currentStep = 1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      debugPrint('Error en _submit: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {

    return Column(children: [
      CustomAppHeader(
        title: "Actualizar datos institucionales",
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
                CustomTextField(
                    label: "Nombre de la institución", controller: nameController),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: "Fecha de creación",
                      hintText: "DD/MM/AAAA",
                      controller: creationdateController,
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Selecciona una fecha";
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                    label: "Nombre de la institución", controller: addressController),
                const SizedBox(height: 16),
                CustomButton(text: "Actualizar", onPressed: _submit),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    final mainLayoutState =
                    context.findAncestorStateOfType<MainLayoutState>();
                    mainLayoutState?.setState(() {
                      mainLayoutState.goTo(2);
                    });
                  },
                  child: const Text("Volver"),
                ),
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
          )


      )
    ]);
  }
}
