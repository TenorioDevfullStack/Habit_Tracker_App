// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';
import '../providers/theme_provider.dart';
import '../models/habit.dart';
import '../utils/app_settings.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isTestingNotification = false;

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Seção de Notificações
          _buildSectionCard(
            title: 'Notificações',
            icon: Icons.notifications,
            children: [
              ListTile(
                leading: const Icon(Icons.alarm, color: Colors.orange),
                title: const Text('Reagendar Notificações'),
                subtitle: const Text('Atualizar todos os lembretes'),
                trailing: const Icon(Icons.refresh),
                onTap: () async {
                  await _showLoadingDialog('Reagendando notificações...');
                  await habitProvider.rescheduleAllNotifications();
                  Navigator.of(context).pop();
                  _showSuccessSnackBar('Notificações reagendadas com sucesso!');
                },
              ),
              
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('Diagnóstico de Notificações'),
                subtitle: const Text('Verificar status das notificações'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await _showLoadingDialog('Verificando status...');
                  await habitProvider.checkNotificationStatus();
                  Navigator.of(context).pop();
                  _showNotificationStatusDialog();
                },
              ),
              
              ListTile(
                leading: Icon(
                  _isTestingNotification ? Icons.hourglass_empty : Icons.notifications_active,
                  color: _isTestingNotification ? Colors.amber : Colors.green,
                ),
                title: const Text('Teste de Notificação'),
                subtitle: const Text('Enviar notificação imediata'),
                trailing: _isTestingNotification 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                onTap: _isTestingNotification ? null : () => _testNotification(),
              ),

              ListTile(
                leading: const Icon(Icons.schedule, color: Colors.purple),
                title: const Text('Teste Agendado (10s)'),
                subtitle: const Text('Notificação em 10 segundos'),
                trailing: const Icon(Icons.schedule_send),
                onTap: () => _testScheduledNotification(),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Seção de Dados
          _buildSectionCard(
            title: 'Dados',
            icon: Icons.storage,
            children: [
              ListTile(
                leading: const Icon(Icons.analytics, color: Colors.purple),
                title: const Text('Estatísticas'),
                subtitle: Text('${habitProvider.habits.length} hábitos criados'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showStatsDialog(habitProvider),
              ),
              
              ListTile(
                leading: const Icon(Icons.backup, color: Colors.teal),
                title: const Text('Backup Local'),
                subtitle: const Text('Dados salvos automaticamente'),
                trailing: Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Seção de Aparência
          _buildSectionCard(
            title: 'Aparência',
            icon: Icons.palette,
            children: [
              // Toggle Modo Escuro
              ListTile(
                leading: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: themeProvider.isDarkMode ? Colors.orange : Colors.yellow,
                ),
                title: const Text('Modo Escuro'),
                subtitle: Text('Tema: ${themeProvider.currentThemeName}'),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeColor: Colors.blue,
                ),
              ),
              
              // Opções de Tema
              ListTile(
                leading: const Icon(Icons.color_lens, color: Colors.pink),
                title: const Text('Opções de Tema'),
                subtitle: const Text('Escolher modo do tema'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showThemeOptionsDialog(themeProvider),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Seção de Ajuda
          _buildSectionCard(
            title: 'Ajuda e Suporte',
            icon: Icons.help,
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.amber),
                title: const Text('Tutorial'),
                subtitle: const Text('Como usar o aplicativo'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTutorialDialog(),
              ),
              
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('Sobre o App'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Botão de Emergência
          _buildEmergencyResetButton(habitProvider),
          
          const SizedBox(height: 16),
          
          // Informações adicionais
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Future<void> _testNotification() async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    if (habitProvider.habits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crie um hábito primeiro para testar as notificações!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    setState(() {
      _isTestingNotification = true;
    });

    try {
      // Usar o primeiro hábito para teste
      final firstHabit = habitProvider.habits.first;
      await habitProvider.testNotification(firstHabit);
      
      _showSuccessSnackBar('Notificação de teste enviada! Verifique a área de notificações.');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar notificação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isTestingNotification = false;
      });
    }
  }

  Future<void> _testScheduledNotification() async {
    try {
      await NotificationService.sendTestScheduledNotification('Teste Debug', 30);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notificação agendada para 30 segundos! Aguarde...'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro no teste agendado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showLoadingDialog(String message) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
    
    // Pequeno delay para mostrar o loading
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showNotificationStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Status das Notificações'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informações detalhadas foram enviadas para o console de debug.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Verifique:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('• Permissões de notificação'),
            Text('• Notificações agendadas'),
            Text('• Status dos alarmes exatos'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(HabitProvider habitProvider) {
    int totalHabits = habitProvider.habits.length;
    int habitsWithReminders = habitProvider.habits
        .where((h) => h.reminderEnabled)
        .length;
    
    DateTime now = DateTime.now();
    int todayHabits = habitProvider.getTodayHabits(now).length;
    int completedToday = habitProvider
        .getTodayHabits(now)
        .where((h) => h.isCompletedOn(now))
        .length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics, color: Colors.purple),
            SizedBox(width: 8),
            Text('Estatísticas'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Total de hábitos', '$totalHabits'),
            _buildStatRow('Hábitos com lembretes', '$habitsWithReminders'),
            _buildStatRow('Hábitos para hoje', '$todayHabits'),
            _buildStatRow('Concluídos hoje', '$completedToday'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.school, color: Colors.amber),
            SizedBox(width: 8),
            Text('Como usar'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎯 Criando Hábitos:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('• Toque no botão verde "Novo Hábito"'),
              Text('• Defina nome, frequência e lembretes'),
              SizedBox(height: 12),
              
              Text(
                '✅ Marcando como Concluído:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('• Toque no hábito na tela inicial'),
              Text('• O círculo ficará verde quando concluído'),
              SizedBox(height: 12),
              
              Text(
                '📊 Acompanhando Progresso:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('• Vá para a aba "Progresso"'),
              Text('• Veja estatísticas e sequências'),
              SizedBox(height: 12),
              
              Text(
                '🔔 Notificações:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('• Ative lembretes ao criar hábitos'),
              Text('• Teste nas configurações'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi!'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Habit Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.track_changes, size: 50, color: Colors.blue),
      applicationLegalese: '© 2025 Habit Tracker App',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Desenvolvido para te ajudar a criar e manter hábitos saudáveis.',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 12),
        const Text('✨ Funcionalidades:'),
        const Text('• Hábitos personalizáveis'),
        const Text('• Lembretes inteligentes'),
        const Text('• Acompanhamento de progresso'),
        const Text('• Interface responsiva'),
      ],
    );
  }

  void _openAppSettings() {
    AppSettings.showManualInstructions();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Instruções detalhadas foram exibidas no console. Vá para: Configurações > Apps > Habit Tracker > Notificações',
        ),
        duration: Duration(seconds: 4),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showTroubleshootingGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help, color: Colors.amber),
            SizedBox(width: 8),
            Text('Guia de Solução'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Problemas comuns e soluções:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 16),
              
              _buildTroubleshootItem(
                '❌ Notificações não aparecem',
                [
                  'Verificar permissões do app',
                  'Desativar modo "Não Perturbe"',
                  'Verificar otimização de bateria',
                  'Reiniciar o app',
                ],
              ),
              
              const SizedBox(height: 12),
              
              _buildTroubleshootItem(
                '❌ Notificações atrasam',
                [
                  'Ativar "Alarmes e Lembretes"',
                  'Desativar otimização de bateria',
                  'Verificar timezone do sistema',
                ],
              ),
              
              const SizedBox(height: 12),
              
              _buildTroubleshootItem(
                '❌ Param após reinicializar',
                [
                  'Permitir inicialização automática',
                  'Reagendar nas configurações',
                  'Não forçar parada do app',
                ],
              ),
              
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🔧 Configurações Importantes:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Configurações > Apps > Habit Tracker > Notificações\n'
                      '• Configurações > Apps > Acesso Especial > Alarmes\n'
                      '• Configurações > Bateria > Otimização (Desativar)\n'
                      '• Configurações > Apps > Inicialização Automática',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootItem(String problem, List<String> solutions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          problem,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        ...solutions.map((solution) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 2),
          child: Text(
            '• $solution',
            style: const TextStyle(fontSize: 13),
          ),
        )),
      ],
    );
  }

  // Diálogo para escolher opções de tema
  void _showThemeOptionsDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.palette, color: Colors.pink),
            SizedBox(width: 8),
            Text('Escolher Tema'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('🌞 Claro'),
              subtitle: const Text('Sempre usar tema claro'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setLightMode();
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('🌙 Escuro'),
              subtitle: const Text('Sempre usar tema escuro'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setDarkMode();
                Navigator.of(context).pop();
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('🔄 Sistema'),
              subtitle: const Text('Seguir configuração do sistema'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.setSystemMode();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyResetButton(HabitProvider habitProvider) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.red[700],
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Notificações não funcionando?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vá para Configurações do Android > Apps > Habit Tracker > Notificações e ative todas as permissões.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _openAppSettings(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.settings),
              label: const Text('Abrir Configurações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔧 Informações Adicionais:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Este aplicativo é um projeto de aprendizado. Use-o com responsabilidade.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Contribua com o código no GitHub: https://github.com/seu-usuario/habit-tracker',
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
