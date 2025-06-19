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

    // Calcular a melhor sequência geral
    int overallBestStreak = 0;
    for (var habit in allHabits) {
      if (habit.calculateCurrentStreak() > overallBestStreak) {
        overallBestStreak = habit.calculateCurrentStreak();
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progresso'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: allHabits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nenhum progresso ainda!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione hábitos para ver\nseu progresso aqui',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                // Simula refresh
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Cartão de Resumo Geral (Responsivo)
                  Card(
                    margin: const EdgeInsets.only(bottom: 20),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  color: Colors.blue.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Resumo Geral',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Layout responsivo usando Column em vez de Row para evitar overflow
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 400) {
                                  // Layout vertical em telas pequenas
                                  return Column(
                                    children: [
                                      _buildPercentageCard(dailyCompletionPercentage),
                                      const SizedBox(height: 16),
                                      _buildStatsRow(overallBestStreak, totalHabits),
                                    ],
                                  );
                                } else {
                                  // Layout horizontal em telas maiores
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: _buildPercentageCard(dailyCompletionPercentage),
                                      ),
                                      const SizedBox(width: 16),
                                      Flexible(
                                        flex: 1,
                                        child: _buildStatsRow(overallBestStreak, totalHabits),
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Título da seção
                  Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: Colors.grey[700],
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Progresso por Hábito',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Lista de progresso individual por hábito
                  ...allHabits.map((habit) {
                    int completedLast7Days = 0;
                    int relevantDaysLast7Days = 0;
                    
                    for (int i = 0; i < 7; i++) {
                      DateTime dateToCheck = DateTime.now().subtract(Duration(days: i));
                      
                      bool shouldBeDoneToday = true;
                      if (habit.frequency == HabitFrequency.specificDays) {
                        shouldBeDoneToday = habit.specificDays.contains(dateToCheck.weekday);
                      }
                      
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
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.track_changes,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    habit.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            
                            // Barra de progresso
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.grey[300],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: habitCompletionRatio,
                                  backgroundColor: Colors.transparent,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    habitCompletionRatio > 0.8 
                                        ? Colors.green 
                                        : habitCompletionRatio > 0.5 
                                            ? Colors.orange 
                                            : Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            // Estatísticas responsivas
                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth < 300) {
                                  // Layout vertical para telas muito pequenas
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${(habitCompletionRatio * 100).toStringAsFixed(0)}% concluído',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_fire_department,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Sequência: ${habit.calculateCurrentStreak()} dias',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  // Layout horizontal para telas maiores
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(habitCompletionRatio * 100).toStringAsFixed(0)}% concluído',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.local_fire_department,
                                            size: 16,
                                            color: Colors.orange,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Sequência: ${habit.calculateCurrentStreak()} dias',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildPercentageCard(double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const Text(
          'Concluídos Hoje',
          style: TextStyle(
            fontSize: 14,
            color: Colors.blueGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int bestStreak, int totalHabits) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              color: Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              '$bestStreak dias',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
          ],
        ),
        const Text(
          'Melhor Sequência',
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '$totalHabits hábitos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
