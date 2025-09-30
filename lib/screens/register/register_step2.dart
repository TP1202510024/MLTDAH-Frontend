import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/register_data.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/profile_photo_picker.dart';
import '../../routes/app_routes.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class RegisterStep2 extends StatefulWidget {
  const RegisterStep2({super.key});

  @override
  State<RegisterStep2> createState() => _RegisterStep2State();
}

class _RegisterStep2State extends State<RegisterStep2> {
  final _formKey = GlobalKey<FormState>();
  final _docNumberController = TextEditingController();
  String? _selectedDocType;
  final _address = TextEditingController();
  final _selectedInstitution = TextEditingController();
  final _creationdateController = TextEditingController();
  File? _selectedPhoto;
  DateTime? _selectedDate;

  final List<String> _docTypes = ['DNI', 'Carné de Extranjería', 'Pasaporte'];

  late RegisterData _registerData; // <-- aquí guardamos la data previa

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is RegisterData) {
      _registerData = args;
    } else {
      throw Exception("RegisterData no fue pasado correctamente.");
    }
  }

  Future<void> _finishRegistration() async {
    if (_formKey.currentState?.validate() != true) return;
    if (_selectedInstitution == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completa todos los campos")),
      );
      return;
    }

    final RegisterData? data = ModalRoute.of(context)!.settings.arguments as RegisterData?;

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Datos incompletos")),
      );
      return;
    }

    data.dni = _docNumberController.text;
    data.address = _address.text; // o donde el usuario ingrese la dirección
    data.name = _selectedInstitution.text;
    data.creationDate = _selectedDate!.toUtc().toIso8601String();
    try {
      final response = await http.post(
        Uri.parse("http://ec2-18-207-118-50.compute-1.amazonaws.com:8080/api/v1/authentication/sign-up"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Response: ${jsonEncode(response.body)}');
        Navigator.pushNamed(context, AppRoutes.registerSuccess);
      } else {
        print('Response: ${jsonEncode(response.body)}');
        print("Error de API: ${response.statusCode} ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al registrar: ${response.body}")),
        );
      }
    } catch (e) {
      print("Excepción: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo conectar al servidor")),
      );
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
        _creationdateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Registro – Documento y Foto',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  label: "Número de Documento",
                  controller: _docNumberController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresa el número de documento";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  label: "Institución Educativa",
                  controller: _selectedInstitution,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresa el nombre de la institucion";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  label: "Dirección",
                  controller: _address,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Ingresa la dirección de la institucion";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: _selectDate,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      label: "Fecha de creación",
                      hintText: "10/10/1990",
                      controller: _creationdateController,
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                CustomButton(
                  text: "Finalizar Registro",
                  onPressed: _finishRegistration,
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
      ),
    );
  }
}
