# ✅ CHECKLIST DE TESTE - SISTEMA DE NOTIFICAÇÕES

## 🧪 **TESTES OBRIGATÓRIOS**

### **1. Teste de Notificação Imediata**

- [ ] Abrir app → Configurações → "Testar Notificação"
- [ ] Aparece notificação com título "🧪 Teste: [Nome do Hábito]"
- [ ] Notificação tem ícone correto
- [ ] Som e vibração funcionando
- [ ] Ao tocar, não dá erro

### **2. Teste de Criação e Agendamento**

- [ ] Criar novo hábito com nome "Teste Lembrete"
- [ ] Ativar toggle "Lembretes"
- [ ] Definir horário para 2 minutos no futuro
- [ ] Salvar hábito sem erros
- [ ] Aguardar horário definido
- [ ] Notificação aparece pontualmente

### **3. Teste de Diagnóstico**

- [ ] Configurações → "Diagnóstico de Notificações"
- [ ] Verificar logs no console (flutter logs)
- [ ] Conferir se há notificações pendentes
- [ ] Verificar permissões no status

### **4. Teste de Persistência**

- [ ] Fechar app completamente
- [ ] Aguardar notificação agendada
- [ ] Verificar se chega mesmo com app fechado
- [ ] Reabrir app e verificar se hábitos estão salvos

## 🔧 **DIAGNÓSTICOS AVANÇADOS**

### **Verificar Permissões no Android:**

1. Configurações do Android → Apps → Habit Tracker
2. Verificar se "Notificações" está ATIVADO
3. Verificar se "Alarmes e Lembretes" está PERMITIDO
4. Conferir se não está em "Otimização de Bateria"

### **Logs de Debug:**

```bash
# No terminal, executar:
flutter logs
# Procurar por mensagens com:
# ✅ Notificação agendada
# 📅 Agendando notificação
# ⏰ Pode agendar alarmes exatos
```

## ❌ **POSSÍVEIS PROBLEMAS E SOLUÇÕES**

### **Problema: Notificação de teste não aparece**

**Solução:**

1. Verificar permissões do app
2. Desativar "Não Perturbe"
3. Configurações → "Guia de Solução"
4. Tentar reiniciar o app

### **Problema: Notificações agendadas não chegam**

**Solução:**

1. Verificar se o horário do sistema está correto
2. Configurações → "Reagendar Notificações"
3. Permitir app em "Inicialização Automática"
4. Desativar otimização de bateria para o app

### **Problema: App trava ao criar hábito**

**Solução:**

1. Verificar logs no terminal
2. Tentar criar sem notificação primeiro
3. Verificar se todas as dependências foram instaladas

## 📊 **RESULTADOS ESPERADOS**

### **✅ SUCESSO COMPLETO:**

- Notificação de teste aparece instantaneamente
- Notificações agendadas chegam pontualmente
- App não trava ou apresenta erros
- Hábitos são salvos corretamente
- Logs mostram "✅ Notificação agendada com sucesso"

### **⚠️ SUCESSO PARCIAL:**

- Notificações funcionam mas atrasam
- Algumas vezes não chegam
- Logs mostram "⚠️ Notificação inexata agendada"

### **❌ FALHA:**

- Nenhuma notificação aparece
- App trava ao criar hábitos
- Logs mostram "❌ Erro ao agendar notificação"

## 🎯 **PRÓXIMOS PASSOS APÓS TESTE**

### **Se tudo funcionar:**

1. Gerar APK atualizado
2. Instalar no celular via arquivo
3. Testar novamente no dispositivo final

### **Se houver problemas:**

1. Anotar exatamente qual erro ocorreu
2. Copiar logs do terminal
3. Reportar para correção adicional

---

**🔔 IMPORTANTE:** Teste em horários diferentes para garantir que as notificações funcionam em qualquer momento do dia!
