// user_helpers.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

int calculateAge(String birthDate) {
  try {
    final birthday = DateTime.parse(birthDate);
    final today = DateTime.now();

    int age = today.year - birthday.year;
    final monthDifference = today.month - birthday.month;

    if (monthDifference < 0 || (monthDifference == 0 && today.day < birthday.day)) {
      age--;
    }

    return age;
  } catch (e) {
    debugPrint('Error calculando edad: $e');
    return 0;
  }
}

Future<Map<String, dynamic>?> loadUserData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    return userDataString != null ? jsonDecode(userDataString) : null;
  } catch (e) {
    debugPrint('Error loading user data: $e');
    return null;
  }
}