import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main_layout.dart';

class StudentDetailView extends StatefulWidget {
  const StudentDetailView({super.key});

  @override
  State<StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends State<StudentDetailView> {
  int selectedTab = 0;

  final List<String> tabs = ["Test", "Resultados", "Apoderado"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildTabs(),
          const SizedBox(height: 20),
          _buildTabContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/images/profile1.png'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Juan Lopez', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '10 años',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const Text('Quinto grado de Primaria'),
            ],
          ),
        ),
        IconButton(onPressed: () {
          final mainLayoutState = context.findAncestorStateOfType<MainLayoutState>();
          mainLayoutState?.setState(() {
            mainLayoutState.goTo(10);
          });
        }, icon: const Icon(Icons.edit)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(tabs.length, (index) {
        final isSelected = selectedTab == index;
        return GestureDetector(
          onTap: () => setState(() => selectedTab = index),
          child: Column(
            children: [
              Text(
                tabs[index],
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  height: 2,
                  width: 30,
                  color: Colors.black,
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab) {
      case 0:
        return const Center(child: Text("Tests..."));
      case 1:
        return const Center(child: Text("Resultados..."));
      case 2:
        return const Center(child: Text("Apoderado..."));
      default:
        return const SizedBox.shrink();
    }
  }
}
