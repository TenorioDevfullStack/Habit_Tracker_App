// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/providers/theme_provider.dart';
import 'package:habit_tracker_app/providers/gamification_provider.dart';
import 'package:habit_tracker_app/screens/main_screen.dart';
import 'package:habit_tracker_app/services/notification_service.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar timezone
  initializeTimeZones();
  
  // Inicializar formatação de data em português
  await initializeDateFormatting('pt_BR', null);
  
  // Usar timezone padrão do sistema
  tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

  // Inicializar serviço de notificações
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GamificationProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProxyProvider<GamificationProvider, HabitProvider>(
          create: (context) => HabitProvider(),
          update: (context, gamificationProvider, habitProvider) {
            habitProvider!.setGamificationProvider(gamificationProvider);
            return habitProvider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Habit Tracker',
            debugShowCheckedModeBanner: false,
            
            // Configuração de temas
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Configuração de localização
            locale: const Locale('pt', 'BR'),
            
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
