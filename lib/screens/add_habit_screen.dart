// lib/screens/habits_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/models/habit.dart'; // Mantido para uso direto da enum HabitFrequency e construção de UI
import 'package:habit_tracker_app/screens/edit_habit_screen.dart'; // Importado para navegação

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessa a instância de HabitProvider para obter a lista completa de hábitos
    final habitProvider = Provider.of<HabitProvider>(context);
    final allHabits = habitProvider.habits; // Obtém todos os hábitos

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Hábitos'), // Título da barra superior
      ),
      body: allHabits.isEmpty
          ? const Center(
              // Mensagem exibida quando não há nenhum hábito cadastrado
              child: Text(
                'Você ainda não tem nenhum hábito cadastrado. Adicione um na tela "Hoje"!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              // Constrói uma lista rolável de todos os hábitos
              itemCount: allHabits.length,
              itemBuilder: (context, index) {
                final habit = allHabits[index];
                String frequencyText;
                switch (habit.frequency) {
                  case HabitFrequency.daily:
                    frequencyText = 'Diariamente';
                    break;
                  case HabitFrequency.specificDays:
                    final days = habit.specificDays
                        .map((dayIndex) {
                          return [
                            'Seg',
                            'Ter',
                            'Qua',
                            'Qui',
                            'Sex',
                            'Sáb',
                            'Dom',
                          ][dayIndex - 1];
                        })
                        .join(', ');
                    frequencyText = 'Dias específicos: $days';
                    break;
                  case HabitFrequency.xTimesPerWeek:
                    frequencyText = '${habit.xTimesCount} vezes por semana';
                    break;
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.list_alt, color: Colors.blueGrey),
                    title: Text(habit.name),
                    subtitle: Text(
                      'Frequência: $frequencyText',
                    ), // Exibe a frequência detalhada
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ocupa o mínimo de espaço horizontal
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Navega para a tela de edição, passando o hábito
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditHabitScreen(habit: habit),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Lógica para deletar o hábito
                            habitProvider.deleteHabit(habit.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${habit.name} excluído!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
