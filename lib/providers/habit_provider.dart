// lib/providers/habit_provider.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as fln; // Use prefixo
import 'package:timezone/timezone.dart' as tz; // Importa timezone
import '../main.dart'; // Importa a instância global de flutterLocalNotificationsPlugin

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
      _habits = habitMaps.map((map) => Habit.fromJson(map)).toList();
      // Re-agenda notificações para hábitos carregados
      // Importante para que as notificações persistam após o app ser fechado e reaberto
      for (var habit in _habits) {
        _scheduleNotification(habit);
      }
      notifyListeners();
    }
  }

  Future<void> _saveHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final String habitsString = json.encode(
      _habits.map((habit) => habit.toJson()).toList(),
    );
    await prefs.setString('habits', habitsString);
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    _saveHabits();
    _scheduleNotification(habit); // Agenda notificação para o novo hábito
    notifyListeners();
  }

  void updateHabit(Habit updatedHabit) {
    final index = _habits.indexWhere((habit) => habit.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      _cancelNotification(updatedHabit.id); // Cancela a notificação antiga
      _scheduleNotification(updatedHabit); // Agenda a notificação atualizada
      _saveHabits(); // Salva após atualizar
      notifyListeners();
    }
  }

  void deleteHabit(String id) {
    _habits.removeWhere((habit) => habit.id == id);
    _cancelNotification(id); // Cancela a notificação ao deletar o hábito
    _saveHabits(); // Salva após deletar
    notifyListeners();
  }

  void toggleHabitCompletion(Habit habit, DateTime date) {
    final normalizedDate = DateTime(
      date.year,
      date.year,
      date.day,
    ); // Correção aqui: era date.year duas vezes

    // Normaliza a data para remover informações de hora, minuto, segundo
    final targetDate = DateTime(date.year, date.month, date.day);

    if (habit.isCompletedOn(targetDate)) {
      // Se já estava completo, desmarca
      habit.completedDates.removeWhere(
        (d) =>
            d.year == targetDate.year &&
            d.month == targetDate.month &&
            d.day == targetDate.day,
      );
    } else {
      // Se não estava completo, marca
      habit.markAsCompleted(targetDate);
    }
    _saveHabits(); // Salva após alterar o status
    notifyListeners();
  }

  List<Habit> getTodayHabits(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dayOfWeek = normalizedDate.weekday; // 1 = Monday, 7 = Sunday

    return _habits.where((habit) {
      switch (habit.frequency) {
        case HabitFrequency.daily:
          return true; // Hábitos diários sempre aparecem
        case HabitFrequency.specificDays:
          return habit.specificDays.contains(
            dayOfWeek,
          ); // Aparece se o dia da semana estiver na lista
        case HabitFrequency.xTimesPerWeek:
          // Para o MVP, considera todos os hábitos X vezes por semana como diários para exibição aqui.
          return true;
      }
    }).toList();
  }

  // MÉTODOS PARA AGENDAMENTO E CANCELAMENTO DE NOTIFICAÇÕES
  Future<void> _scheduleNotification(Habit habit) async {
    // Se notificações não estiverem ativadas ou não houver hora de lembrete, cancela qualquer notificação existente
    if (!habit.notificationsEnabled || habit.reminderTime == null) {
      _cancelNotification(habit.id);
      return;
    }

    // Converte o ID do hábito para um inteiro único para a notificação
    final int notificationId = habit.id.hashCode;

    // Crie TZDateTime no fuso horário local
    // Agendamos para o fuso horário atual do dispositivo.
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      tz.TZDateTime.now(tz.local).year,
      tz.TZDateTime.now(tz.local).month,
      tz.TZDateTime.now(tz.local).day,
      habit.reminderTime!.hour,
      habit.reminderTime!.minute,
    );

    // Se a hora do lembrete já passou hoje, agenda para o dia seguinte
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Detalhes da notificação para Android
    final fln.AndroidNotificationDetails
    androidPlatformChannelSpecifics = fln.AndroidNotificationDetails(
      'habit_tracker_channel', // ID do canal (pode ser qualquer string única)
      'Lembretes de Hábitos', // Nome do canal (aparecerá nas configurações do Android)
      channelDescription: 'Canal para lembretes diários de hábitos',
      importance: fln
          .Importance
          .max, // Nível de importância (afeta como a notificação aparece)
      priority: fln.Priority.high, // Prioridade da notificação
      ticker: 'ticker', // Texto que aparece brevemente na barra de status
      icon:
          'app_icon_notification', // Nome do ícone que você adicionou no Android
    );

    // Agrupa os detalhes específicos da plataforma
    final fln.NotificationDetails platformChannelSpecifics =
        fln.NotificationDetails(android: androidPlatformChannelSpecifics);

    // Agenda a notificação
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId, // ID único para esta notificação
      'Lembrete: ${habit.name}', // Título da notificação
      'É hora de ${habit.name}!', // Corpo da notificação
      scheduledDate, // Data e hora para agendar
      platformChannelSpecifics,
      androidScheduleMode: fln
          .AndroidScheduleMode
          .exactAllowWhileIdle, // Agenda mesmo em modo de economia de bateria
      matchDateTimeComponents: fln
          .DateTimeComponents
          .time, // Faz a notificação repetir diariamente na mesma hora
      payload: habit
          .id, // Opcional: pode passar dados extras que você pode recuperar quando o usuário clicar na notificação
    );

    debugPrint(
      'Notificação agendada para: ${habit.name} em $scheduledDate (ID: $notificationId)',
    );
  }

  Future<void> _cancelNotification(String habitId) async {
    final int notificationId = habitId.hashCode;
    await flutterLocalNotificationsPlugin.cancel(notificationId);
    debugPrint('Notificação cancelada para: $habitId (ID: $notificationId)');
  }
}
