import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/question_item.dart';

class LikertTestView extends StatefulWidget {
  final VoidCallback onFinish;

  const LikertTestView({super.key, required this.onFinish});

  @override
  State<LikertTestView> createState() => _LikertTestViewState();
}

class _LikertTestViewState extends State<LikertTestView> {
  List<int?> selectedAnswers = List.filled(33, null);
  int currentSection = 0;
  bool isFinished = false;
  final ScrollController _scrollController = ScrollController();

  final List<String> sectionTitles = [
    'Inatención',
    'Hiperactividad',
    'Impulsividad',
    'Regulación emocional y conducta',
    'Relaciones sociales y comportamiento grupal',
  ];

  // Preguntas separadas por sección
  final List<List<String>> sectionQuestions = [
    [
      "1. ¿Comete errores por descuido al hacer tareas o trabajos escolares?",
      "2. ¿Le cuesta mantener la atención durante clases, juegos o conversaciones?",
      "3. ¿Parece que no escucha cuando se le habla directamente?",
      "4. ¿Le cuesta seguir instrucciones y suele dejar tareas sin terminar?",
      "5. ¿Tiene dificultades para organizar su tiempo, tareas o materiales escolares?",
      "6. ¿Evita o se niega a hacer tareas que requieren esfuerzo mental (como estudiar o hacer deberes)?",
      "7. ¿Pierde frecuentemente cosas que necesita (como cuadernos, lápices, tareas)?",
      "8. ¿Se distrae fácilmente con cosas que pasan a su alrededor?",
      "9. ¿Se olvida de hacer cosas importantes, como entregar tareas o seguir indicaciones?",
    ],
    [
      "1. ¿Se mueve constantemente en su asiento, se retuerce o no puede quedarse quieto?",
      "2. ¿Se levanta del asiento en momentos donde debería permanecer sentado?",
      "3. ¿Corre o salta en lugares donde no es apropiado, como el aula o la casa?",
      "4. ¿Le cuesta jugar o hacer actividades en silencio?",
      "5. ¿Parece estar siempre en movimiento, como si tuviera un motor encendido?",
      "6. ¿Habla más de lo normal o interrumpe cuando otros están hablando?"
    ],
    [
      "1. ¿Contesta antes de que terminen de hacerle una pregunta?",
      "2. ¿Le cuesta esperar su turno en juegos, filas o conversaciones?",
      "3. ¿Interrumpe o se mete en conversaciones o juegos sin ser invitado?",
      "4. ¿Interrumpe con frecuencia a los adultos cuando están hablando o dando instrucciones?",
      "5. ¿Dice cosas sin pensar, incluso cuando pueden ser ofensivas o inapropiadas?",
      "6. ¿Toma decisiones impulsivas que luego lamenta, como romper algo o escapar de clase?"
    ],
    [
      "1. ¿Se enoja con facilidad cuando algo no le sale como quiere?",
      "2. ¿Pasa rápidamente de estar tranquilo a estar molesto o triste sin motivo claro?",
      "3. ¿Tiene reacciones más intensas que otros niños ante pequeñas frustraciones?",
      "4. ¿Discute con adultos o desobedece reglas con frecuencia?",
      "5. ¿Actúa sin pensar en las consecuencias, incluso si puede salir lastimado o meter en problemas?",
      "6. ¿Se muestra muy sensible a críticas, correcciones o comentarios negativos?"
    ],
    [
      "1. ¿Le cuesta llevarse bien con otros niños o hacer amigos?",
      "2. ¿Los demás niños suelen evitarlo o quejarse de su comportamiento?",
      "3. ¿Se mete en peleas o discute con otros niños con frecuencia?",
      "4. ¿Le cuesta entender o respetar turnos en juegos o actividades grupales?",
      "5. ¿Le cuesta adaptarse a nuevas reglas o dinámicas cuando cambia de grupo o actividad?",
      "6. ¿Tiene dificultad para identificar cómo se sienten los demás (falta de empatía)?",
    ],
  ];

  // Calcula el índice global en selectedAnswers según la sección y pregunta
  int _getGlobalIndex(int sectionIndex, int questionIndex) {
    int offset = 0;
    for (int i = 0; i < sectionIndex; i++) {
      offset += sectionQuestions[i].length;
    }
    return offset + questionIndex;
  }

  void _nextSection() {
    if (currentSection < sectionTitles.length - 1) {
      setState(() => currentSection++);
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      setState(() => isFinished = true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ← Limpieza
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isFinished) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 24),
            const Text(
              "El cuestionario se ha registrado correctamente.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            CustomButton(text: "Regresar", onPressed: widget.onFinish),
          ],
        ),
      );
    }

    final questions = sectionQuestions[currentSection];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitles[currentSection],
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final globalIndex = _getGlobalIndex(currentSection, index);
                return QuestionItem(
                  question: questions[index],
                  selectedValue: selectedAnswers[globalIndex],
                  onChanged: (val) {
                    setState(() {
                      selectedAnswers[globalIndex] = val;
                    });
                  },
                );
              },
            ),
          ),
          CustomButton(text: "Siguiente Sección", onPressed: _nextSection),
        ],
      ),
    );
  }
}
