// lib/providers/habit_provider.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';

class HabitProvider with ChangeNotifier {
  List<Habit> _habits = [];
  final Uuid uuid = Uuid();

  List<Habit> get habits => _habits;

  HabitProvider() {
    _loadHabits();
    _requestNotificationPermissions();
  }

  // Solicitar permissões de notificação
  Future<void> _requestNotificationPermissions() async {
    try {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              fln.AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              fln.AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();
      
      print('✅ Permissões de notificação solicitadas');
    } catch (e) {
      print('⚠️ Erro ao solicitar permissões: $e');
    }
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
      _scheduleNotification(habit);
    }
    
    notifyListeners();
  }

  void updateHabit(Habit updatedHabit) {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      _saveHabits();
      
      // Cancelar notificação anterior e reagendar se necessário
      _cancelNotification(updatedHabit);
      if (updatedHabit.reminderEnabled && updatedHabit.reminderTime != null) {
        _scheduleNotification(updatedHabit);
      }
      
      notifyListeners();
    }
  }

  void removeHabit(String habitId) {
    final habitToRemove = _habits.firstWhere((h) => h.id == habitId);
    _cancelNotification(habitToRemove);
    
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

  // Melhorar o sistema de notificações
  Future<void> _scheduleNotification(Habit habit) async {
    try {
      if (habit.reminderTime == null) return;

      // ID único baseado no hash do hábito
      final int notificationId = habit.id.hashCode.abs();

      print('📅 Agendando notificação para ${habit.name} às ${habit.reminderTime}');

      // Configurações da notificação
      const fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
          fln.AndroidNotificationDetails(
        'habit_reminders',
        'Lembretes de Hábitos',
        channelDescription: 'Notificações para lembrar dos seus hábitos',
        importance: fln.Importance.high,
        priority: fln.Priority.high,
        icon: 'app_icon_notification',
        enableVibration: true,
        playSound: true,
        styleInformation: fln.BigTextStyleInformation(''),
        category: fln.AndroidNotificationCategory.reminder,
      );

      const fln.NotificationDetails platformChannelSpecifics =
          fln.NotificationDetails(android: androidPlatformChannelSpecifics);

      // Calcular próxima ocorrência
      final now = DateTime.now();
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        habit.reminderTime!.hour,
        habit.reminderTime!.minute,
      );

      // Se o horário já passou hoje, agendar para amanhã
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);
      
      print('🕐 Notificação agendada para: $scheduledTZDate');

      // Verificar se pode agendar alarmes exatos
      final bool? canScheduleExactAlarms = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              fln.AndroidFlutterLocalNotificationsPlugin>()
          ?.canScheduleExactNotifications();

      print('⏰ Pode agendar alarmes exatos: $canScheduleExactAlarms');

      if (canScheduleExactAlarms == true) {
        // Usar alarme exato se permitido
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'Lembrete: ${habit.name}',
          '🎯 É hora de ${habit.name}! Mantenha sua sequência!',
          scheduledTZDate,
          platformChannelSpecifics,
          androidScheduleMode: fln.AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: 
              fln.UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: fln.DateTimeComponents.time,
          payload: json.encode({
            'habitId': habit.id,
            'habitName': habit.name,
          }),
        );
        print('✅ Notificação exata agendada com sucesso!');
      } else {
        // Usar notificação inexata como fallback
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
          'Lembrete: ${habit.name}',
          '🎯 É hora de ${habit.name}! Mantenha sua sequência!',
          scheduledTZDate,
          platformChannelSpecifics,
          androidScheduleMode: fln.AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: 
              fln.UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: fln.DateTimeComponents.time,
          payload: json.encode({
            'habitId': habit.id,
            'habitName': habit.name,
          }),
        );
        print('⚠️ Notificação inexata agendada (permissão exata não concedida)');
      }

      // Verificar notificações pendentes
      final List<fln.PendingNotificationRequest> pendingNotifications = 
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      
      print('📋 Total de notificações pendentes: ${pendingNotifications.length}');
      for (var notification in pendingNotifications) {
        if (notification.id == notificationId) {
          print('✅ Notificação confirmada na fila: ID $notificationId');
          break;
        }
      }

    } catch (e) {
      print('❌ Erro ao agendar notificação: $e');
    }
  }

  Future<void> _cancelNotification(Habit habit) async {
    try {
      final int notificationId = habit.id.hashCode.abs();
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      print('🗑️ Notificação cancelada para ${habit.name}');
    } catch (e) {
      print('❌ Erro ao cancelar notificação: $e');
    }
  }

  // Método para testar notificações imediatamente
  Future<void> testNotification(Habit habit) async {
    try {
      final int testNotificationId = 99999; // ID especial para teste
      
      const fln.AndroidNotificationDetails androidPlatformChannelSpecifics =
          fln.AndroidNotificationDetails(
        'habit_test',
        'Teste de Notificações',
        channelDescription: 'Notificações de teste',
        importance: fln.Importance.max,
        priority: fln.Priority.high,
        icon: 'app_icon_notification',
        enableVibration: true,
        playSound: true,
        styleInformation: fln.BigTextStyleInformation('Esta é uma notificação de teste!'),
      );

      const fln.NotificationDetails platformChannelSpecifics =
          fln.NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        testNotificationId,
        '🧪 Teste: ${habit.name}',
        'Se você está vendo isso, as notificações estão funcionando!',
        platformChannelSpecifics,
        payload: json.encode({
          'test': true,
          'habitId': habit.id,
          'habitName': habit.name,
        }),
      );
      
      print('🧪 Notificação de teste enviada!');
    } catch (e) {
      print('❌ Erro no teste de notificação: $e');
    }
  }

  // Método para reagendar todas as notificações
  Future<void> rescheduleAllNotifications() async {
    print('🔄 Reagendando todas as notificações...');
    
    for (Habit habit in _habits) {
      if (habit.reminderEnabled && habit.reminderTime != null) {
        await _cancelNotification(habit);
        await _scheduleNotification(habit);
      }
    }
    
    print('✅ Todas as notificações foram reagendadas!');
  }

  // Método para verificar status das notificações
  Future<void> checkNotificationStatus() async {
    try {
      final List<fln.PendingNotificationRequest> pendingNotifications = 
          await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      
      print('📊 STATUS DAS NOTIFICAÇÕES:');
      print('📋 Total pendentes: ${pendingNotifications.length}');
      
      for (var notification in pendingNotifications) {
        print('   ID: ${notification.id} | Título: ${notification.title}');
      }
      
      // Verificar permissões
      final bool? canScheduleExactAlarms = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              fln.AndroidFlutterLocalNotificationsPlugin>()
          ?.canScheduleExactNotifications();
      
      print('⏰ Permissão para alarmes exatos: $canScheduleExactAlarms');
      
    } catch (e) {
      print('❌ Erro ao verificar status: $e');
    }
  }
}
