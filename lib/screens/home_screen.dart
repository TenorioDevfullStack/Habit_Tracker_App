// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
// Removidas importações desnecessárias de outras telas, pois MainScreen gerencia a navegação
// import 'package:habit_tracker_app/screens/habits_screen.dart';
// import 'package:habit_tracker_app/screens/progress_screen.dart';
// import 'package:habit_tracker_app/screens/settings_screen.dart';
import 'package:intl/intl.dart'; // Para formatar a data

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final todayHabits = habitProvider.getTodayHabits(DateTime.now());

    // Para o cabeçalho "Bom dia! X de Y concluídos"
    final int completedTodayCount = todayHabits
        .where((h) => h.isCompletedOn(DateTime.now()))
        .length;
    final int totalTodayCount = todayHabits.length;
    final String greeting = _getGreeting();
    // Usa a data atual formatada para exibição no título da AppBar
    final String formattedDate = DateFormat(
      'dd MMM yyyy',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text('Hoje - $formattedDate'), // Inclui a data formatada
        actions: [
          // Botão para adicionar um novo hábito
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddHabitScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '$greeting! $completedTodayCount de $totalTodayCount concluídos',
              style: const TextStyle(
                fontSize:
                    20, // Título principal: 24px, peso 600 (ajustado para ser um bom subtítulo aqui)
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: todayHabits.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum hábito para hoje! Adicione um novo hábito.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: todayHabits.length,
                    itemBuilder: (context, index) {
                      final habit = todayHabits[index];
                      final isCompleted = habit.isCompletedOn(DateTime.now());

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        // Animação de cor de fundo do Card
                        color: isCompleted
                            ? Colors.green[50]
                            : Theme.of(context).cardColor,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Alterna o status de conclusão do hábito
                            habitProvider.toggleHabitCompletion(
                              habit,
                              DateTime.now(),
                            );
                            // Opcional: Vibração háptica sutil
                            // Feedback.lightImpact(); // Necessitaria do pacote flutter_vibrate ou similar
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 16.0,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isCompleted
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isCompleted
                                      ? Colors.green
                                      : Colors.grey,
                                  size:
                                      30, // Ícone um pouco maior para destaque
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habit.name,
                                        style: TextStyle(
                                          fontSize:
                                              18, // Subtítulos: 18px, peso 500
                                          fontWeight: FontWeight.w500,
                                          decoration: isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: isCompleted
                                              ? Colors.grey
                                              : Colors.black,
                                        ),
                                      ),
                                      Text(
                                        'Sequência: ${habit.calculateCurrentStreak()} dias',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ), // Texto secundário: 14px
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      // Removido bottomNavigationBar, agora gerenciado por MainScreen
    );
  }

  // Função auxiliar para obter a saudação do dia
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bom dia';
    } else if (hour < 18) {
      return 'Boa tarde';
    } else {
      return 'Boa noite';
    }
  }
}
