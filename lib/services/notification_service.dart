import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('app_icon_notification');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permissões específicas para Android 13+
    await _requestAndroidPermissions();
  }

  static Future<void> _requestAndroidPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin != null) {
      try {
        // Solicitar permissão para notificações
        await androidPlugin.requestNotificationsPermission();
        
        // Solicitar permissão para alarmes exatos
        await androidPlugin.requestExactAlarmsPermission();
        
        debugPrint('✅ Permissões de notificação solicitadas');
      } catch (e) {
        debugPrint('⚠️ Erro ao solicitar permissões: $e');
      }
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notificação tocada: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        debugPrint('Dados da notificação: $data');
        // Aqui você pode navegar para uma tela específica ou realizar uma ação
      } catch (e) {
        debugPrint('Erro ao decodificar payload: $e');
      }
    }
  }

  // Agendar notificação diária para um hábito
  static Future<void> scheduleHabitReminder(Habit habit) async {
    if (!habit.reminderEnabled || habit.reminderTime == null) return;

    try {
      final int notificationId = habit.id.hashCode.abs();
      
      debugPrint('📅 Agendando notificação para ${habit.name}');

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'habit_reminders',
        'Lembretes de Hábitos',
        channelDescription: 'Notificações para lembrar dos seus hábitos diários',
        importance: Importance.high,
        priority: Priority.high,
        icon: 'app_icon_notification',
        enableVibration: true,
        playSound: true,
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
        showWhen: true,
        styleInformation: BigTextStyleInformation(
          'É hora de praticar seu hábito! Mantenha sua sequência e continue evoluindo. 🎯',
        ),
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'mark_done',
            'Marcar como Feito',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'snooze',
            'Lembrar em 1h',
            showsUserInterface: false,
          ),
        ],
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'habit_reminder',
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Calcular próximo horário de notificação com logs detalhados
      final now = DateTime.now();
      debugPrint('🕐 Hora atual: $now');
      debugPrint('⏰ Lembrete configurado para: ${habit.reminderTime}');
      debugPrint('📝 Extraindo: ${habit.reminderTime!.hour}:${habit.reminderTime!.minute}');
      
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        habit.reminderTime!.hour,
        habit.reminderTime!.minute,
        0, // segundos = 0
        0, // milissegundos = 0
      );
      
      debugPrint('📅 Data calculada inicialmente: $scheduledDate');

      // Se o horário já passou hoje, agendar para amanhã
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        debugPrint('⏭️ Horário passou, movendo para amanhã: $scheduledDate');
      } else {
        debugPrint('✅ Horário ainda não passou, mantendo para hoje: $scheduledDate');
      }

      // Criar TZDateTime corretamente
      final tz.TZDateTime scheduledTZDate = tz.TZDateTime(
        tz.local,
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
        scheduledDate.hour,
        scheduledDate.minute,
        0, // segundos
        0, // milissegundos
      );
      
      debugPrint('🌍 Data com timezone: $scheduledTZDate');
      debugPrint('📍 Timezone local: ${tz.local}');
      
      // Verificar se pode usar alarmes exatos
      final androidPlugin = _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      final bool canScheduleExact = await androidPlugin?.canScheduleExactNotifications() ?? false;

      debugPrint('⏰ Pode agendar alarmes exatos: $canScheduleExact');

      await _notifications.zonedSchedule(
        notificationId,
        '🎯 ${habit.name}',
        'É hora de ${habit.name}! Continue sua sequência de sucesso! 🌟',
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: canScheduleExact 
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repetir diariamente
        payload: json.encode({
          'habitId': habit.id,
          'habitName': habit.name,
          'type': 'habit_reminder',
        }),
      );

      debugPrint('✅ Notificação agendada para: $scheduledTZDate');
      
    } catch (e) {
      debugPrint('❌ Erro ao agendar notificação: $e');
      rethrow;
    }
  }

  // Cancelar notificação de um hábito específico
  static Future<void> cancelHabitReminder(Habit habit) async {
    try {
      final int notificationId = habit.id.hashCode.abs();
      await _notifications.cancel(notificationId);
      debugPrint('🗑️ Notificação cancelada para ${habit.name}');
    } catch (e) {
      debugPrint('❌ Erro ao cancelar notificação: $e');
    }
  }

  // Cancelar todas as notificações
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      debugPrint('🗑️ Todas as notificações canceladas');
    } catch (e) {
      debugPrint('❌ Erro ao cancelar todas as notificações: $e');
    }
  }

  // Enviar notificação de teste agendada (para debug)
  static Future<void> sendTestScheduledNotification(String habitName, int secondsFromNow) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'habit_test_scheduled',
        'Teste Agendado',
        channelDescription: 'Canal para testar notificações agendadas',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'app_icon_notification',
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          'Esta é uma notificação de teste agendada! Se chegou, o sistema está funcionando! 🎯',
        ),
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      final now = DateTime.now();
      final scheduledDate = now.add(Duration(seconds: secondsFromNow));
      final tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);
      
      debugPrint('🧪 Teste agendado para: $scheduledTZDate (em $secondsFromNow segundos)');

      await _notifications.zonedSchedule(
        88888, // ID especial para teste agendado
        '⏰ TESTE AGENDADO: $habitName',
        'Esta notificação foi agendada e chegou na hora certa! ✅',
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: json.encode({
          'test_scheduled': true,
          'habitName': habitName,
          'scheduledFor': scheduledTZDate.toIso8601String(),
        }),
      );

      debugPrint('🧪 Notificação de teste agendada com sucesso!');
    } catch (e) {
      debugPrint('❌ Erro no teste de notificação agendada: $e');
      rethrow;
    }
  }

  // Enviar notificação de teste
  static Future<void> sendTestNotification(String habitName) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'habit_test',
        'Teste de Notificações',
        channelDescription: 'Canal para testar notificações',
        importance: Importance.max,
        priority: Priority.high,
        icon: 'app_icon_notification',
        enableVibration: true,
        playSound: true,
        styleInformation: BigTextStyleInformation(
          'Esta é uma notificação de teste para verificar se o sistema está funcionando corretamente! 🧪',
        ),
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.show(
        99999, // ID especial para testes
        '🧪 Teste: $habitName',
        'Se você está vendo isso, as notificações estão funcionando perfeitamente! ✅',
        notificationDetails,
        payload: json.encode({
          'test': true,
          'habitName': habitName,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      debugPrint('🧪 Notificação de teste enviada!');
    } catch (e) {
      debugPrint('❌ Erro no teste de notificação: $e');
      rethrow;
    }
  }

  // Verificar notificações pendentes
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('❌ Erro ao obter notificações pendentes: $e');
      return [];
    }
  }

  // Verificar status das permissões
  static Future<Map<String, bool>> checkPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidPlugin == null) return {};

    try {
      final bool canScheduleExact = await androidPlugin.canScheduleExactNotifications() ?? false;
      final bool areNotificationsEnabled = await androidPlugin.areNotificationsEnabled() ?? false;
      
      return {
        'canScheduleExact': canScheduleExact,
        'areNotificationsEnabled': areNotificationsEnabled,
      };
    } catch (e) {
      debugPrint('❌ Erro ao verificar permissões: $e');
      return {};
    }
  }

  // Obter estatísticas de notificações
  static Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final pendingNotifications = await getPendingNotifications();
      final permissions = await checkPermissions();
      
      return {
        'totalPending': pendingNotifications.length,
        'permissions': permissions,
        'pendingDetails': pendingNotifications.map((n) => {
          'id': n.id,
          'title': n.title,
          'body': n.body,
        }).toList(),
      };
    } catch (e) {
      debugPrint('❌ Erro ao obter estatísticas: $e');
      return {};
    }
  }
} 