import 'package:flutter/material.dart';
import 'package:mltdah_frontend/screens/student/add_parent_view.dart';
import 'package:mltdah_frontend/screens/student/student_result_detail_view.dart';
import 'package:mltdah_frontend/widgets/test_result_card.dart';
import '../../widgets/line_chart_card.dart';
import '../../widgets/question_card.dart';
import '../main_layout.dart';
import 'liker_test.dart';

class StudentResultsView extends StatefulWidget {
  const StudentResultsView({super.key});

  @override
  State<StudentResultsView> createState() => _StudentResultsViewState();
}

class _StudentResultsViewState extends State<StudentResultsView> {
  int selectedTab = 0;
  bool showResults = false;

  final List<String> tabs = ["Línea de Tiempo", "En Lista"];

  Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar resultado?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Eliminar"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (!showResults) ...[
              _buildTabs(),
              const SizedBox(height: 20),
              Expanded(child: _buildTabContent()),
            ] else ...[
              Expanded(
                child: LikertTestView(
                  onFinish: () {
                    setState(() {
                      showResults = false;
                    });
                  },
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            // TODO: Acción del botón (puede ser filtrado)
          },
          icon: const Icon(Icons.filter_alt_outlined),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final isSelected = selectedTab == index;
              return GestureDetector(
                onTap: () => setState(() => selectedTab = index),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      tabs[index],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 2,
                      width: isSelected ? 30 : 0,
                      color: Colors.black,
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }


  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LineChartCard(
              values: [95, 75, 80, 80, 80, 75],
              months: ["Ene", "Feb", "Mar", "Abr", "May", "Jun"],
            ),
            // Puedes añadir más widgets aquí si lo necesitas
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TestResultCard(
              title: "Resultado N. 1",
              date: "15/05/2025 – 10:20 PM",
              probability: "95% Probabilidad",
              onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentResultDetailView(),
                ),
              );

              },
              onDelete: () async {
                final confirm = await showDeleteConfirmationDialog(context);
                if (confirm == true) {
                  // Eliminar el resultado aquí
                  // Por ejemplo: controller.deleteResult(index);
                }
              },

            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

}
