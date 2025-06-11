import 'package:flutter/material.dart';
import 'package:mltdah_frontend/widgets/teacher_card.dart';
import '../main_layout.dart';

class TeacherView extends StatelessWidget {
  const TeacherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          children: const [
            TeacherCard(
              name: 'Juan Lopez',
              grade: 'Quinto grado de Primaria',
              age: '10 años',
              imageUrl: 'assets/images/profile1.png',
            ),
          ],
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
                mainLayoutState.goTo(8);
              });
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
