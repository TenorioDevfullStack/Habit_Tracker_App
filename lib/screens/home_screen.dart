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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                colors: isDarkMode
                    ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                    : [Colors.blue.shade700, Colors.blue.shade400],
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
                      style: TextStyle(
                        color: isDarkMode ? Colors.grey[400] : Colors.white70,
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
                        color: isDarkMode 
                            ? Colors.white.withOpacity(0.05)
                            : Colors.white.withOpacity(0.15),
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
                                          ? 'Continue assim! Você está indo bem! 🚀'
                                          : 'Que tal criar seu primeiro hábito?',
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.grey[300] : Colors.white70,
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
                            LinearProgressIndicator(
                              value: completionPercentage / 100,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                              minHeight: 6,
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
                              color: isDarkMode 
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.blue.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.track_changes,
                              size: 64,
                              color: isDarkMode
                                  ? Colors.blue[300]
                                  : Colors.blue.shade300,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Comece sua jornada!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.headlineLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crie seu primeiro hábito e\ncomece a construir uma rotina incrível',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
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
                                          colors: isDarkMode
                                              ? [
                                                  Colors.green.withOpacity(0.1),
                                                  Colors.green.withOpacity(0.05),
                                                ]
                                              : [
                                                  Colors.green.shade50,
                                                  Colors.green.shade100,
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    // Círculo de status
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isCompleted
                                            ? Colors.green.shade100
                                            : (isDarkMode ? const Color(0xFF2A2A2A) : Colors.grey.shade100),
                                        border: Border.all(
                                          color: isCompleted
                                              ? Colors.green.shade400
                                              : (isDarkMode ? Colors.grey[600]! : Colors.grey.shade300),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        isCompleted ? Icons.check : Icons.radio_button_unchecked,
                                        color: isCompleted
                                            ? Colors.green.shade600
                                            : (isDarkMode ? Colors.grey[400] : Colors.grey.shade400),
                                        size: 24,
                                      ),
                                    ),
                                    
                                    const SizedBox(width: 16),
                                    
                                    // Informações do hábito
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
                                                  ? (isDarkMode ? Colors.grey[400] : Colors.grey[600])
                                                  : Theme.of(context).textTheme.bodyLarge?.color,
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 4),
                                          
                                          Row(
                                            children: [
                                              // Status de conclusão
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isCompleted
                                                      ? Colors.green.withOpacity(0.2)
                                                      : (isDarkMode 
                                                          ? Colors.orange.withOpacity(0.2)
                                                          : Colors.orange.shade100),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  isCompleted ? 'Concluído ✅' : 'Pendente ⏳',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                    color: isCompleted
                                                        ? Colors.green.shade700
                                                        : Colors.orange.shade700,
                                                  ),
                                                ),
                                              ),
                                              
                                              const SizedBox(width: 8),
                                              
                                              // Sequência (streak)
                                              if (currentStreak > 0) ...[
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isDarkMode
                                                        ? Colors.blue.withOpacity(0.2)
                                                        : Colors.blue.shade100,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '🔥 $currentStreak ${currentStreak == 1 ? 'dia' : 'dias'}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.blue.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          
                                          // Lembrete ativo
                                          if (habit.reminderEnabled && habit.reminderTime != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.notifications_active,
                                                  size: 14,
                                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Lembrete: ${habit.reminderTime!.hour.toString().padLeft(2, '0')}:${habit.reminderTime!.minute.toString().padLeft(2, '0')}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                  ),
                                                ),
                                              ],
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
