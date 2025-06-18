// lib/screens/progress_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/models/habit.dart'; // Mantido para uso direto da enum HabitFrequency

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final allHabits = habitProvider.habits;

    // Calcular estatísticas gerais
    int totalHabits = allHabits.length;
    int habitsCompletedToday = habitProvider
        .getTodayHabits(DateTime.now())
        .where((h) => h.isCompletedOn(DateTime.now()))
        .length;
    int totalTodayHabits = habitProvider.getTodayHabits(DateTime.now()).length;
    double dailyCompletionPercentage = totalTodayHabits > 0
        ? (habitsCompletedToday / totalTodayHabits) * 100
        : 0.0;

    // Calcular a melhor sequência geral entre todos os hábitos (baseado na streak atual)
    int overallBestStreak = 0;
    for (var habit in allHabits) {
      if (habit.calculateCurrentStreak() > overallBestStreak) {
        overallBestStreak = habit.calculateCurrentStreak();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Progresso')),
      body: allHabits.isEmpty
          ? const Center(
              child: Text(
                'Adicione hábitos para ver seu progresso aqui!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Cartão de Resumo Geral (Aprimorado)
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  color: Colors.blue[50],
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumo Geral',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${dailyCompletionPercentage.toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const Text(
                                  'Concluídos Hoje',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '🔥 $overallBestStreak dias',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                                const Text(
                                  'Melhor Sequência',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '⭐ $totalHabits hábitos ativos',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const Text(
                  'Progresso por Hábito',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 10),

                // Lista de progresso individual por hábito
                ...allHabits.map((habit) {
                  int completedLast7Days = 0;
                  int relevantDaysLast7Days = 0;
                  for (int i = 0; i < 7; i++) {
                    DateTime dateToCheck = DateTime.now().subtract(
                      Duration(days: i),
                    );

                    bool shouldBeDoneToday = true;
                    if (habit.frequency == HabitFrequency.specificDays) {
                      shouldBeDoneToday = habit.specificDays.contains(
                        dateToCheck.weekday,
                      );
                    }
                    // Para xTimesPerWeek, a lógica pode ser mais complexa
                    // considerando as X vezes dentro da semana. Para MVP, simplificado.

                    if (shouldBeDoneToday) {
                      relevantDaysLast7Days++;
                      if (habit.isCompletedOn(dateToCheck)) {
                        completedLast7Days++;
                      }
                    }
                  }
                  double habitCompletionRatio = relevantDaysLast7Days > 0
                      ? completedLast7Days / relevantDaysLast7Days
                      : 0.0;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: habitCompletionRatio,
                            backgroundColor: Colors.grey[300],
                            color: Colors.green,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(habitCompletionRatio * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                'Sequência atual: ${habit.calculateCurrentStreak()} dias',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }), // Removido .toList() desnecessário aqui
              ],
            ),
    );
  }
}
