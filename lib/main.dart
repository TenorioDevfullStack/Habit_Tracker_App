// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/screens/main_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart'; // Importação SEM 'as tz' para initializeAll
import 'package:timezone/timezone.dart'
    as tz; // Importação COM 'as tz' para tz.TZDateTime
import 'package:flutter_native_timezone/flutter_native_timezone.dart'; // Para obter o fuso horário local

// Instância global do plugin de notificações
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Garante que os widgets estejam inicializados

  // >>> INICIALIZAÇÃO DO FUSO HORÁRIO <<<
  initializeAll(); // Chamada direta, sem 'tz.'
  final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(
    tz.getLocation(currentTimeZone),
  ); // Define o fuso horário local

  // Configurações de inicialização para Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings(
        'app_icon_notification',
      ); // Certifique-se que o drawable existe

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
          final String? payload = notificationResponse.payload;
          if (payload != null) {
            debugPrint('Notificação recebida (Android): payload: $payload');
          }
        },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HabitProvider(),
      child: MaterialApp(
        title: 'Habit Tracker',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
