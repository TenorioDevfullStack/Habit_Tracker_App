# 🐛 INSTRUÇÕES DE DEBUG - NOTIFICAÇÕES

## ✅ O CÓDIGO ESTÁ FUNCIONANDO!

Pelos logs, vemos que o sistema de notificações está correto:

- ✅ Notificação agendada com sucesso
- ✅ Permissões exatas concedidas
- ✅ Notificação na fila

## 🔧 PROBLEMA: PERMISSÕES DO ANDROID

### 📱 CONFIGURAÇÕES OBRIGATÓRIAS:

#### 1. NOTIFICAÇÕES BÁSICAS:

```
Configurações > Apps > habit_tracker_app > Notificações
┌─────────────────────────────────────┐
│ ✅ Permitir notificações            │
│ ✅ Mostrar na tela de bloqueio       │
│ ✅ Som                              │
│ ✅ Vibração                         │
│ ✅ Aparecer sobre outros apps       │
└─────────────────────────────────────┘
```

#### 2. ALARMES EXATOS (ESSENCIAL):

```
Configurações > Apps > Acesso especial > Alarmes e lembretes
┌─────────────────────────────────────┐
│ 🔍 Procurar: habit_tracker_app      │
│ ✅ ATIVAR esta permissão            │
└─────────────────────────────────────┘
```

#### 3. BATERIA (IMPORTANTE):

```
Configurações > Bateria > Otimização de bateria
┌─────────────────────────────────────┐
│ 🔍 Procurar: habit_tracker_app      │
│ ✅ Escolher "Não otimizar"          │
└─────────────────────────────────────┘
```

#### 4. INICIALIZAÇÃO AUTOMÁTICA:

```
Configurações > Apps > habit_tracker_app
┌─────────────────────────────────────┐
│ ✅ Inicialização automática         │
│ ✅ Executar em segundo plano        │
└─────────────────────────────────────┘
```

## 🧪 TESTES PARA FAZER:

### TESTE 1: Notificação Imediata

1. Abrir o app
2. Configurações → "Testar Notificação"
3. DEVE aparecer notificação instantânea

### TESTE 2: Hábito com Lembrete

1. Criar novo hábito "Teste"
2. Ativar lembretes
3. Horário: 2 minutos no futuro
4. Salvar e aguardar

### TESTE 3: Verificar Configurações Android

1. Após os passos acima
2. Configurações Android → Apps → habit_tracker_app
3. Verificar se todas permissões estão ativas

## ❌ POSSÍVEIS BLOQUEIOS:

### Samsung/Xiaomi/Huawei:

- Pode ter "Gerenciador inteligente" bloqueando
- Verificar "Limpeza automática"
- Desativar "Economia ultra"

### Android 12+:

- Verificar "Não perturbe" não está ativo
- Configurações → Som → Não perturbe → Permitir exceções

### Fabricantes específicos:

- MIUI (Xiaomi): Configurações → Notificações → Controle de notificações
- One UI (Samsung): Configurações → Notificações → Configurações avançadas
- EMUI (Huawei): Configurações → Notificações → Permitir notificações

## 📊 RESULTADO ESPERADO:

✅ **SUCESSO:** Notificação aparece instantaneamente no teste
⚠️ **PARCIAL:** Notificação aparece mas atrasa
❌ **FALHA:** Nenhuma notificação aparece

## 🆘 SE NADA FUNCIONAR:

1. Reiniciar o celular
2. Abrir o app novamente
3. Testar notificação
4. Se ainda não funcionar, reportar modelo do celular e versão Android
