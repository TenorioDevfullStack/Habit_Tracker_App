# 🎯 Habit Tracker App

Um aplicativo moderno e intuitivo para rastreamento de hábitos desenvolvido em Flutter, com interface responsiva e sistema completo de notificações.

## 📱 Screenshots

![Habit Tracker App](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen)
![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue)

## ✨ Funcionalidades

### 🏠 **Tela Principal (Home)**

- Interface moderna com cabeçalho gradiente
- Visualização dos hábitos do dia atual
- Indicadores visuais de progresso circulares
- Animações suaves e feedback háptico
- Design responsivo para diferentes tamanhos de tela

### 📊 **Acompanhamento de Progresso**

- Estatísticas detalhadas de conclusão
- Gráficos de barras de progresso coloridos
- Cálculo automático de sequências (streaks)
- Resumo geral com percentuais de conclusão
- Layout responsivo evitando overflow

### 📝 **Gerenciamento de Hábitos**

- Criação de hábitos personalizados
- Múltiplas opções de frequência:
  - Todos os dias
  - Dias específicos da semana
  - X vezes por semana
- Sistema de edição completo
- Exclusão com confirmação

### 🔔 **Sistema de Notificações**

- Notificações de teste funcionais
- Suporte ao Android 12+ com alarmes exatos
- Permissões automáticas
- Diagnóstico de status de notificações
- Fallback para dispositivos sem permissões especiais

### ⚙️ **Configurações Avançadas**

- Tela de diagnóstico de notificações
- Estatísticas detalhadas de uso
- Tutorial integrado
- Informações sobre o aplicativo
- Ferramentas de teste e depuração

## 🛠️ Tecnologias Utilizadas

- **Flutter** 3.0+ - Framework de desenvolvimento
- **Dart** 3.0+ - Linguagem de programação
- **Provider** - Gerenciamento de estado
- **SharedPreferences** - Persistência local de dados
- **Flutter Local Notifications** - Sistema de notificações
- **Timezone** - Gerenciamento de fusos horários
- **UUID** - Geração de IDs únicos
- **Intl** - Internacionalização (pt_BR)

## 📦 Instalação

### Pré-requisitos

- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Dispositivo Android ou emulador

### Passos para instalação

1. **Clone o repositório**

```bash
git clone https://github.com/TenorioDevfullStack/Habit_Tracker_App.git
cd Habit_Tracker_App
```

2. **Instale as dependências**

```bash
flutter pub get
```

3. **Execute o aplicativo**

```bash
flutter run
```

### 📱 Instalação APK

Para instalar diretamente no dispositivo Android:

1. Baixe o arquivo `HabitTracker_v1.0.apk`
2. Ative "Fontes desconhecidas" nas configurações do Android
3. Execute o APK e toque em "Instalar"

## 🏗️ Arquitetura do Projeto

```
lib/
├── main.dart                 # Ponto de entrada do app
├── models/
│   └── habit.dart           # Modelo de dados dos hábitos
├── providers/
│   └── habit_provider.dart  # Gerenciamento de estado
├── screens/
│   ├── main_screen.dart     # Tela principal com navegação
│   ├── home_screen.dart     # Tela inicial (Hoje)
│   ├── habits_screen.dart   # Gerenciamento de hábitos
│   ├── progress_screen.dart # Tela de progresso
│   ├── settings_screen.dart # Configurações
│   ├── add_habit_screen.dart # Adicionar hábito
│   └── edit_habit_screen.dart # Editar hábito
└── ...
```

## 🎨 Design e UX

### Princípios de Design

- **Material Design 3** - Interface moderna e familiar
- **Responsividade** - Adaptação automática a diferentes telas
- **Acessibilidade** - Suporte a diferentes necessidades
- **Feedback Visual** - Animações e estados visuais claros

### Paleta de Cores

- **Primária**: Azul (`Colors.blue`)
- **Sucesso**: Verde (`Colors.green`)
- **Atenção**: Laranja (`Colors.orange`)
- **Erro**: Vermelho (`Colors.red`)

## 🧪 Testes

O projeto inclui testes unitários para os principais componentes:

```bash
flutter test
```

Testes cobrem:

- Modelos de dados (Habit)
- Cálculos de streak
- Lógica de frequência
- Persistência de dados

## 🔧 Configuração de Notificações

### Android

1. O aplicativo solicita permissões automaticamente
2. Para Android 12+, pode ser necessário ativar "Alarmes exatos"
3. Acesse: Configurações → Apps → Habit Tracker → Notificações

### Problemas Comuns

- **Xiaomi/MIUI**: Ativar "Autostart" e desativar "Battery optimization"
- **Samsung**: Adicionar à lista de "Apps nunca suspensos"
- **Huawei**: Configurar "Launch" como "Manage manually"

## 📈 Roadmap

### Versão 1.1

- [ ] Modo escuro
- [ ] Backup na nuvem
- [ ] Widgets para tela inicial
- [ ] Estatísticas avançadas

### Versão 1.2

- [ ] Metas personalizadas
- [ ] Categorias de hábitos
- [ ] Exportação de dados
- [ ] Integração com Google Fit

### Versão 2.0

- [ ] Versão iOS
- [ ] Sincronização multi-dispositivo
- [ ] Comunidade de hábitos
- [ ] Gamificação avançada

## 🤝 Contribuição

Contribuições são bem-vindas! Para contribuir:

1. Faça um Fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Desenvolvedor

**TenorioDevfullStack**

- GitHub: [@TenorioDevfullStack](https://github.com/TenorioDevfullStack)

## 🙏 Agradecimentos

- Comunidade Flutter pela documentação excepcional
- Material Design pela inspiração visual
- Contribuidores dos packages utilizados

---

⭐ **Não esqueça de dar uma estrela se este projeto te ajudou!**
