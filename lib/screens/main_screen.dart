// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:habit_tracker_app/screens/home_screen.dart';
import 'package:habit_tracker_app/screens/habits_screen.dart';
import 'package:habit_tracker_app/screens/progress_screen.dart';
import 'package:habit_tracker_app/screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Controla o índice da aba selecionada

  // Lista de telas que serão exibidas na BottomNavigationBar
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    HabitsScreen(),
    ProgressScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Atualiza o índice da aba selecionada
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(
          _selectedIndex,
        ), // Exibe a tela correspondente ao índice selecionado
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue, // Fundo azul para a barra de navegação
        selectedItemColor: Colors.white, // Ícone/texto selecionado em branco
        unselectedItemColor:
            Colors.blue[200], // Ícone/texto não selecionado em azul claro
        type: BottomNavigationBarType
            .fixed, // Garante que todos os itens são visíveis e ocupam espaço fixo
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Hoje'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Hábitos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Progresso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
        currentIndex: _selectedIndex, // Define o item selecionado
        onTap: _onItemTapped, // Chama a função quando um item é tocado
      ),
    );
  }
}
