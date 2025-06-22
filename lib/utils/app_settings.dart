import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AppSettings {
  static const MethodChannel _channel = MethodChannel('app_settings');

  // Abrir configurações de notificação do app
  static Future<void> openAppNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      debugPrint('Erro ao abrir configurações: ${e.message}');
      // Fallback: mostrar instruções manuais
      showManualInstructions();
    }
  }

  // Abrir configurações gerais do app
  static Future<void> openAppSettings() async {
    try {
      await _channel.invokeMethod('openAppSettings');
    } on PlatformException catch (e) {
      debugPrint('Erro ao abrir configurações do app: ${e.message}');
    }
  }

  // Mostrar instruções manuais
  static void showManualInstructions() {
    debugPrint('''
    📱 INSTRUÇÕES PARA HABILITAR NOTIFICAÇÕES:
    
    1. Vá para Configurações do Android
    2. Procure por "Apps" ou "Aplicativos"  
    3. Encontre "Habit Tracker" na lista
    4. Toque em "Notificações"
    5. Ative todas as opções de notificação
    6. Se disponível, ative "Alarmes e lembretes"
    
    ⚠️ Para Android 12+:
    - Vá em Configurações > Apps > Acesso especial
    - Procure por "Alarmes e lembretes" 
    - Ative para o Habit Tracker
    ''');
  }

  // Verificar se as notificações estão habilitadas
  static Future<bool> areNotificationsEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('areNotificationsEnabled');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Erro ao verificar status das notificações: ${e.message}');
      return false;
    }
  }

  // Guia de solução de problemas
  static String getTroubleshootingGuide() {
    return '''
🔧 GUIA DE SOLUÇÃO DE PROBLEMAS - NOTIFICAÇÕES

❌ PROBLEMA: Notificações não aparecem
✅ SOLUÇÕES:
1. Verificar se as notificações estão ativas nas configurações do app
2. Verificar se o "Não Perturbe" não está ativo
3. Verificar se o app não está em modo de economia de bateria
4. Reiniciar o app após alterar configurações

❌ PROBLEMA: Notificações atrasam
✅ SOLUÇÕES:
1. Ativar "Alarmes e Lembretes" nas configurações especiais
2. Adicionar o app à lista de apps não otimizados
3. Verificar se o timezone está correto

❌ PROBLEMA: Notificações param após reiniciar
✅ SOLUÇÕES:
1. Verificar se o app tem permissão de inicialização automática
2. Reagendar notificações através das configurações do app
3. Não forçar parada do app

📞 CONFIGURAÇÕES IMPORTANTES:
• Configurações > Apps > Habit Tracker > Notificações > ATIVAR TUDO
• Configurações > Apps > Acesso Especial > Alarmes e Lembretes > Habit Tracker
• Configurações > Bateria > Otimização > Habit Tracker > Não Otimizar
• Configurações > Apps > Habit Tracker > Inicialização Automática > ATIVAR
    ''';
  }
} 