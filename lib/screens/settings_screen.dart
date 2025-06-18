// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
// Futuramente, se tivermos configurações que dependem de estado (ex: tema, notificações gerais)
// poderíamos usar um provider ou outro gerenciador de estado aqui.

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Gerenciar Notificações'),
            subtitle: const Text('Ative ou desative lembretes de hábitos'),
            leading: const Icon(Icons.notifications),
            onTap: () {
              // Por enquanto, apenas um SnackBar.
              // Futuramente, poderíamos navegar para uma tela de detalhes de notificação
              // ou implementar um switch direto aqui para notificações globais.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações de notificações em breve!'),
                ),
              );
            },
          ),
          const Divider(), // Uma linha divisória
          ListTile(
            title: const Text('Sobre o App'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Habit Tracker',
                applicationVersion: '1.0.0 (MVP)',
                applicationLegalese:
                    '© 2025 Seu Nome/Empresa. Todos os direitos reservados.',
                children: [
                  const Text(
                    'Este aplicativo foi desenvolvido para te ajudar a criar e manter hábitos saudáveis e produtivos.',
                  ),
                ],
              );
            },
          ),
          // Podemos adicionar mais opções aqui no futuro, como:
          // ListTile(
          //   title: const Text('Tema (Claro/Escuro)'),
          //   leading: const Icon(Icons.color_lens),
          //   onTap: () { /* Lógica para mudar tema */ },
          // ),
          // ListTile(
          //   title: const Text('Backup de Dados'),
          //   leading: const Icon(Icons.backup),
          //   onTap: () { /* Lógica de backup */ },
          // ),
        ],
      ),
    );
  }
}
