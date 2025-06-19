// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/add_habit_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToAddHabit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddHabitScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final todayHabits = habitProvider.getTodayHabits(DateTime.now());

    // Para o cabeçalho "Bom dia! X de Y concluídos"
    final completedToday = todayHabits.where((h) => h.isCompletedOn(DateTime.now())).length;
    final totalToday = todayHabits.length;
    final completionPercentage = totalToday > 0 ? (completedToday / totalToday * 100) : 0.0;
    
    // Determinar saudação baseada na hora
    final now = DateTime.now();
    String greeting = 'Boa noite';
    if (now.hour < 12) {
      greeting = 'Bom dia';
    } else if (now.hour < 18) {
      greeting = 'Boa tarde';
    }

    return Scaffold(
      body: Column(
        children: [
          // Cabeçalho com gradiente
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade700, Colors.blue.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Data e saudação
                    Text(
                      DateFormat('EEEE, d MMMM', 'pt_BR').format(now),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$greeting! 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Card de progresso
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      totalToday > 0 
                                          ? '$completedToday de $totalToday concluídos'
                                          : 'Nenhum hábito para hoje',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      totalToday > 0 
                                          ? '${completionPercentage.toStringAsFixed(0)}% do progresso diário'
                                          : 'Que tal criar seu primeiro hábito?',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (totalToday > 0) ...[
                                const SizedBox(width: 16),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      CircularProgressIndicator(
                                        value: completionPercentage / 100,
                                        backgroundColor: Colors.white.withOpacity(0.2),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 4,
                                      ),
                                      Center(
                                        child: Text(
                                          '${completionPercentage.toStringAsFixed(0)}%',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          
                          if (totalToday > 0) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: completionPercentage / 100,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Lista de hábitos
          Expanded(
            child: todayHabits.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.track_changes,
                              size: 64,
                              color: Colors.blue.shade300,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Comece sua jornada!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crie seu primeiro hábito e\ncomece a construir uma rotina incrível',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToAddHabit(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text(
                              'Criar Primeiro Hábito',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: todayHabits.length,
                      itemBuilder: (context, index) {
                        final habit = todayHabits[index];
                        final isCompleted = habit.isCompletedOn(DateTime.now());
                        final currentStreak = habit.calculateCurrentStreak();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Card(
                            elevation: isCompleted ? 1 : 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                habitProvider.toggleHabitCompletion(habit, DateTime.now());
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: isCompleted
                                      ? LinearGradient(
                                          colors: [
                                            Colors.green.shade50,
                                            Colors.green.shade100,
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: [
                                      // Checkbox animado
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCompleted 
                                              ? Colors.green 
                                              : Colors.transparent,
                                          border: isCompleted 
                                              ? null 
                                              : Border.all(
                                                  color: Colors.grey.shade400, 
                                                  width: 2
                                                ),
                                        ),
                                        child: isCompleted
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 20,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Conteúdo do hábito
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              habit.name,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                decoration: isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: isCompleted
                                                    ? Colors.grey[600]
                                                    : Colors.grey[800],
                                              ),
                                            ),
                                            if (currentStreak > 0) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.local_fire_department,
                                                    size: 16,
                                                    color: currentStreak >= 7 
                                                        ? Colors.orange 
                                                        : Colors.orange.shade300,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '$currentStreak ${currentStreak == 1 ? "dia" : "dias"} seguidos',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            if (habit.reminderEnabled && habit.reminderTime != null) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.notifications_outlined,
                                                    size: 14,
                                                    color: Colors.blue.shade400,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${habit.reminderTime!.hour.toString().padLeft(2, '0')}:${habit.reminderTime!.minute.toString().padLeft(2, '0')}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      
                                      // Status visual
                                      if (isCompleted)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            '✓ Feito',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      
      // FloatingActionButton melhorado
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddHabit(context),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add, size: 24),
        label: const Text(
          'Novo Hábito',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
