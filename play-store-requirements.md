# 📱 REQUISITOS COMPLETOS - GOOGLE PLAY STORE

## 🎯 **1. INFORMAÇÕES DO APP**

### **Título e Descrição:**

- **Título:** Máximo 50 caracteres
- **Descrição curta:** Máximo 80 caracteres
- **Descrição completa:** Máximo 4.000 caracteres

### **Exemplo para Habit Tracker:**

```
Título: "Habit Tracker - Rastreador de Hábitos"

Descrição curta: "Crie e acompanhe hábitos saudáveis com notificações inteligentes"

Descrição completa:
🎯 Transforme sua vida criando e mantendo hábitos saudáveis!

✨ FUNCIONALIDADES:
• Criar hábitos personalizados
• Lembretes inteligentes com notificações pontuais
• Acompanhar progresso diário
• Frequência flexível (diário, específicos dias, X vezes por semana)
• Interface moderna e intuitiva

🔔 NOTIFICAÇÕES INTELIGENTES:
• Alarmes precisos no horário configurado
• Funciona mesmo com app fechado
• Compatível com todos os dispositivos Android

📊 ACOMPANHAMENTO:
• Visualize seu progresso
• Mantenha sequências de sucesso
• Estatísticas detalhadas

🎨 DESIGN MODERNO:
• Interface limpa e responsiva
• Fácil de usar
• Material Design 3

Comece hoje a construir a melhor versão de si mesmo!
```

## 🖼️ **2. ASSETS VISUAIS OBRIGATÓRIOS**

### **Ícone do App:**

- **Tamanho:** 512x512 pixels
- **Formato:** PNG
- **Sem transparência**
- **Design limpo e profissional**

### **Screenshots (OBRIGATÓRIO):**

- **Mínimo:** 2 screenshots
- **Máximo:** 8 screenshots
- **Tamanho:** 320px a 3840px
- **Proporção:** 16:9 ou 9:16
- **Formato:** PNG ou JPEG

### **Feature Graphic (Banner):**

- **Tamanho:** 1024x500 pixels
- **Formato:** PNG ou JPEG
- **Sem texto promocional**

### **Opcional mas Recomendado:**

- **Vídeo promocional:** YouTube (máximo 2 minutos)
- **TV Banner:** 1280x720 pixels (se suportar Android TV)

## 📄 **3. POLÍTICAS E CONTEÚDO**

### **Política de Privacidade (OBRIGATÓRIO):**

- Link público válido
- Deve explicar como dados são coletados/usados
- Em português

### **Exemplo de Política Simples:**

```
POLÍTICA DE PRIVACIDADE - HABIT TRACKER

1. DADOS COLETADOS:
Este aplicativo armazena apenas dados localmente no seu dispositivo:
- Nomes dos hábitos criados
- Horários de lembretes
- Histórico de conclusões

2. COMPARTILHAMENTO:
Nenhum dado é enviado para servidores externos ou terceiros.

3. SEGURANÇA:
Todos os dados ficam apenas no seu dispositivo.

4. CONTATO:
[seu-email@exemplo.com]

Última atualização: [data]
```

### **Classificação de Conteúdo:**

- Classificação etária apropriada
- Para Habit Tracker: "Livre para todos"

### **Categoria:**

- "Saúde e fitness" ou "Produtividade"

## 🔧 **4. CONFIGURAÇÕES TÉCNICAS**

### **Versioning (android/app/build.gradle):**

```gradle
android {
    defaultConfig {
        applicationId "com.seudominio.habittracker"  // ÚNICO
        versionCode 1                                 // Número incremental
        versionName "1.0.0"                          // Versão para usuários

        minSdkVersion 21    // Android 5.0+
        targetSdkVersion 34 // Android 14
        compileSdkVersion 34
    }
}
```

### **Permissões (AndroidManifest.xml):**

```xml
<!-- Apenas permissões necessárias -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

## 🛡️ **5. REQUISITOS DE SEGURANÇA**

### **Target API Level:**

- **Mínimo:** API 33 (Android 13) para apps novos em 2024
- **Seu app:** Já está configurado corretamente

### **App Bundle (AAB):**

- **Obrigatório** para uploads na Play Store
- Substitui APK
- Melhor otimização de tamanho

### **Proguard/R8 (Opcional):**

- Seu app já está configurado sem obfuscação
- Funciona perfeitamente

## 💰 **6. CONTA DE DESENVOLVEDOR**

### **Taxa única:** US$ 25

### **Documentos necessários:**

- Conta Google válida
- Cartão de crédito/débito
- Documento de identidade (para alguns países)

## 📝 **7. PROCESSO DE SUBMISSÃO**

### **1. Preparar Assets:**

- Ícone 512x512
- Screenshots do app
- Feature graphic 1024x500
- Descrições em português

### **2. Criar Conta Desenvolvedor:**

- Google Play Console
- Pagar taxa de US$ 25
- Verificar identidade

### **3. Upload do App:**

- App Bundle (.aab)
- Preencher informações
- Política de privacidade
- Screenshots

### **4. Revisão:**

- Google analisa o app (1-3 dias)
- Pode pedir correções
- Aprovação final

## ⚠️ **8. CHECKLIST FINAL**

- [ ] Keystore criado e guardado com segurança
- [ ] App Bundle (.aab) gerado
- [ ] Ícone 512x512 criado
- [ ] Screenshots capturados
- [ ] Descrição escrita
- [ ] Política de privacidade publicada
- [ ] Conta de desenvolvedor criada
- [ ] Taxa de US$ 25 paga

## 🎯 **PRÓXIMOS PASSOS:**

1. **Primeiro:** Criar keystore e assinar app
2. **Segundo:** Preparar assets visuais
3. **Terceiro:** Escrever descrições
4. **Quarto:** Criar conta de desenvolvedor
5. **Quinto:** Fazer upload e submeter
