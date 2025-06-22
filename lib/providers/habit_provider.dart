// lib/providers/habit_provider.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/notification_service.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  final Uuid uuid = Uuid();

  List<Habit> get habits => _habits;

  HabitProvider() {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String? habitsString = prefs.getString('habits');

    if (habitsString != null) {
      final List<dynamic> habitMaps = json.decode(habitsString);
      _habits = habitMaps.map((map) => Habit.fromMap(map)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String habitsString = json.encode(_habits.map((h) => h.toMap()).toList());
    await prefs.setString('habits', habitsString);
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveHabits();
    
    // Agendar notificação se habilitada
    if (habit.reminderEnabled && habit.reminderTime != null) {
      NotificationService.scheduleHabitReminder(habit);
    }
    
    notifyListeners();
  }

  void updateHabit(Habit updatedHabit) {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      _saveHabits();
      
      // Cancelar notificação anterior e reagendar se necessário
      NotificationService.cancelHabitReminder(updatedHabit);
      if (updatedHabit.reminderEnabled && updatedHabit.reminderTime != null) {
        NotificationService.scheduleHabitReminder(updatedHabit);
      }
      
      notifyListeners();
    }
  }

  void removeHabit(String habitId) {
    final habitToRemove = _habits.firstWhere((h) => h.id == habitId);
    NotificationService.cancelHabitReminder(habitToRemove);
    
    _habits.removeWhere((h) => h.id == habitId);
    _saveHabits();
    notifyListeners();
  }

  void toggleHabitCompletion(Habit habit, DateTime date) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    
    if (habit.completionDates.contains(dateKey)) {
      habit.completionDates.remove(dateKey);
    } else {
      habit.completionDates.add(dateKey);
    }
    
    _saveHabits();
    notifyListeners();
  }

  List<Habit> getTodayHabits(DateTime date) {
    final int weekday = date.weekday;
    return _habits.where((habit) {
      switch (habit.frequency) {
        case HabitFrequency.daily:
          return true;
        case HabitFrequency.specificDays:
          return habit.specificDays.contains(weekday);
        case HabitFrequency.xTimesPerWeek:
          return true; // Simplificado - sempre mostra para MVP
      }
    }).toList();
  }

  // Método para testar notificações imediatamente
  Future<void> testNotification(Habit habit) async {
    try {
      await NotificationService.sendTestNotification(habit.name);
      debugPrint('🧪 Notificação de teste enviada!');
    } catch (e) {
      debugPrint('❌ Erro no teste de notificação: $e');
      rethrow;
    }
  }

  // Método para testar notificação agendada
  Future<void> testScheduledNotification(Habit habit, int secondsFromNow) async {
    try {
      await NotificationService.sendTestScheduledNotification(habit.name, secondsFromNow);
      debugPrint('🧪 Notificação de teste agendada para $secondsFromNow segundos!');
    } catch (e) {
      debugPrint('❌ Erro no teste de notificação agendada: $e');
      rethrow;
    }
  }

  // Método para reagendar todas as notificações
  Future<void> rescheduleAllNotifications() async {
    debugPrint('🔄 Reagendando todas as notificações...');
    
    for (Habit habit in _habits) {
      if (habit.reminderEnabled && habit.reminderTime != null) {
        await NotificationService.cancelHabitReminder(habit);
        await NotificationService.scheduleHabitReminder(habit);
      }
    }
    
    debugPrint('✅ Todas as notificações foram reagendadas!');
  }

  // Método para verificar status das notificações
  Future<void> checkNotificationStatus() async {
    try {
      final stats = await NotificationService.getNotificationStats();
      
      debugPrint('📊 STATUS DAS NOTIFICAÇÕES:');
      debugPrint('📋 Total pendentes: ${stats['totalPending']}');
      debugPrint('🔒 Permissões: ${stats['permissions']}');
      
      final List pendingDetails = stats['pendingDetails'] ?? [];
      for (var notification in pendingDetails) {
        debugPrint('   ID: ${notification['id']} | Título: ${notification['title']}');
      }
      
    } catch (e) {
      debugPrint('❌ Erro ao verificar status: $e');
    }
  }
}
