import 'package:flutter/material.dart';
import '../../widgets/result_section_card.dart';

class StudentResultDetailView extends StatelessWidget {
  const StudentResultDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => Navigator.pop(context)),
        title: const Text("Resultado N.° 1"),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text("95% Probabilidad",
                  style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text("Fecha de generación: 15/05/2025 – 10:20 PM",
                style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(height: 20),
            ResultSectionCard(
              title: "Inatención",
              description: "Texto de ejemplo largo para probar el contenido.",
              score: 10,
              total: 10,
              badgeColor: Colors.red,
              warning:
              "Advertencia: El estudiante ha obtenido un puntaje elevado en las preguntas de inatención.",
            ),
            ResultSectionCard(
              title: "Hiperactividad",
              description: "Descripción de hiperactividad...",
              score: 5,
              total: 10,
              badgeColor: Colors.yellow,
              borderColor: Colors.blue,
            ),
            ResultSectionCard(
              title: "Impulsividad",
              description: "Descripción de impulsividad...",
              score: 5,
              total: 10,
              badgeColor: Colors.yellow,
            ),
            // Agrega más secciones si lo necesitas
          ],
        ),
      ),
    );
  }
}
