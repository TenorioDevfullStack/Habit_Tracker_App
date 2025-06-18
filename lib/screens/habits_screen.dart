// lib/screens/habits_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/edit_habit_screen.dart'; // Importa a tela de edição

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final allHabits = habitProvider.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Hábitos'), // Apenas o título
        // NENHUM 'actions' AQUI, para evitar botão de adição duplicado ou navegação da AppBar
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
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ListTile(
                    // Podemos adicionar um ícone mais personalizado aqui no futuro, conforme o mockup
                    leading: const Icon(Icons.list_alt, color: Colors.blueGrey),
                    title: Text(habit.name),
                    subtitle: Text(
                      'Frequência: ${habit.frequency.name}',
                    ), // Exibe a frequência
                    trailing: Row(
                      mainAxisSize: MainAxisSize
                          .min, // Ocupa o mínimo de espaço horizontal
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Lógica para navegar para a tela de edição (futuro)
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
      // A BottomNavigationBar é gerenciada na Home Screen para manter o estado da aba
      // mas precisamos atualizar o onTap da Home Screen para navegar para cá.
    );
  }
}
