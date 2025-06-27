import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_app_header.dart';
import '../../widgets/profile_photo_picker.dart';
import '../main_layout.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  int currentStep = 0;
  bool _isLoading = true;
  DateTime? _selectedDate;
  File? selectedProfileImage;

  // Controladores
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final docNumberController = TextEditingController();
  final _birthdateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _uploadProfileImage(String userId, String token) async {
    if (selectedProfileImage == null) return;

    final uri = Uri.parse(
      'http://ec2-18-119-143-32.us-east-2.compute.amazonaws.com:8080/api/v1/users/upload-image?id=$userId',
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('file', selectedProfileImage!.path));

    final response = await request.send();

    if (response.statusCode != 200) {
      final responseBody = await response.stream.bytesToString();
      debugPrint('Error al subir imagen: $responseBody');
      throw Exception('Error al subir la imagen: ${response.reasonPhrase}');
    } else {
      debugPrint('Imagen subida exitosamente. $response.body.photo');
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

  Future<void> _loadInitialData() async {
    final userData = await loadUserData();

    if (userData != null && mounted) {
      setState(() {
        nameController.text = userData['firstName'] ?? '';
        lastNameController.text = userData['lastName'] ?? '';
        docNumberController.text = userData['dni'] ?? '';
        if (userData['birthDate'] != null) {
          try {
            _selectedDate = DateTime.parse(userData['birthDate']);
            _birthdateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
            debugPrint('Fecha cargada correctamente: ${_selectedDate}');
          } catch (e) {
            debugPrint('Error parsing birthDate: ${userData['birthDate']} - $e');
            _selectedDate = DateTime(1990, 1, 1);
            _birthdateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
          }
        } else {
          _selectedDate = DateTime(1990, 1, 1);
          _birthdateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        }
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
    final userId = userData['id']?.toString();
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final formattedDate = _selectedDate?.toIso8601String();

      final result = await ApiService.putWithAuth(
        endpoint: '/api/v1/users',
        id: userId,
        body: {
          'firstName': nameController.text,
          'lastName': lastNameController.text,
          'dni': docNumberController.text,
          'birthDate': formattedDate,
        },
      );

      debugPrint('Respuesta del servidor: $result');

      final oldData = jsonDecode(prefs.getString('user_data') ?? '{}');
      final updatedData = {
        ...oldData,
        ...result,
      };
      await prefs.setString('user_data', jsonEncode(updatedData));

      if (mounted) setState(() => currentStep = 2);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBackToConfig() {
    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
    mainLayoutState?.setState(() => mainLayoutState.goTo(2));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }


    return Column(children: [
      CustomAppHeader(
        title: "Editar perfil",
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
              if (currentStep == 0) _buildPersonalInfoStep(),
              if (currentStep == 2) _buildSuccessStep(),
            ],
          )

      )
    ]);
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      children: [
        Center(
          child: ProfilePhotoPicker(
            onImageSelected: (image) {
              setState(() {
                selectedProfileImage = image;
              });
            },
          ),
        ),
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
          controller: docNumberController,
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
        const SizedBox(height: 24),
        CustomButton(
          text: "Actualizar",
          onPressed: _submit,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
            mainLayoutState?.setState(() {
              mainLayoutState.goTo(2);
            });
          },
          child: const Text("Volver"),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle, color: Colors.green, size: 100),
        const SizedBox(height: 24),
        const Text(
          "Tus datos se actualizaron correctamente.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 32),
        CustomButton(text: "Regresar", onPressed: _goBackToConfig),
      ],
    );
  }
}