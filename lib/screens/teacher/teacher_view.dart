import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mltdah_frontend/widgets/teacher_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_app_header.dart';
import '../main_layout.dart';

class TeacherView extends StatefulWidget {
  const TeacherView({super.key});

  @override
  State<TeacherView> createState() => _TeacherViewState();
}

class _TeacherViewState extends State<TeacherView> {
  List<dynamic> _teachers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }
  Future<void> _fetchTeachers(String institutionId) async {
    try {
      final response = await ApiService.getWithAuth(endpoint: '/api/v1/users/institution',id: institutionId);
      debugPrint("test2");
      setState(() {
        _teachers = (response is List)
            ? response
            : [response]; // Si es un solo item, lo convertimos a lista
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar profesores: $e';
        _isLoading = false;
      });
    }
  }
  Future<void> _loadInitialData() async {
    final userData = await loadUserData();
    if (userData != null && mounted) {
      final id = userData['institution']['id'].toString();
      _fetchTeachers(id);
    }
  }


  @override
  Widget build(BuildContext context) {

    return Column(children: [
      CustomAppHeader(
        title: "Personal Docente",
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
          child:  Stack(
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Center(child: Text(_error!))
              else
                ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: _teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = _teachers[index];
                    final birthDate = teacher['birthDate'] as String?;
                    final age = birthDate != null
                        ? '${calculateAge(birthDate)} años'
                        : 'Edad no disponible';

                    return TeacherCard(
                      name: '${teacher['firstName']} ${teacher['lastName']}',
                      grade: teacher['grade'] ?? 'Grado',
                      age: age,
                      imageUrl: teacher['photo'] ?? 'assets/images/profile1.png',
                      onTap: () {
                        final mainLayoutState =
                        context.findAncestorStateOfType<MainLayoutState>();
                        mainLayoutState?.setState(() {
                          mainLayoutState?.goTo(11,
                              extraData: teacher); // Ir a EditProfileView
                        });
                      },
                    );
                  },
                ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: () {
                    final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
                    mainLayoutState?.setState(() {
                      mainLayoutState.goTo(8); // Ir a crear profesor
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          )


      )
    ]);
  }
}
