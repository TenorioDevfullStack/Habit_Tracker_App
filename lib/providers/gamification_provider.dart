// lib/providers/gamification_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import '../models/goal.dart';

class GamificationProvider with ChangeNotifier {
  UserProfile _userProfile = UserProfile();
  List<Goal> _goals = [];
  List<Map<String, dynamic>> _availableBadges = [];
  List<Map<String, dynamic>> _availableThemes = [];
  List<Map<String, dynamic>> _availableAvatars = [];
  bool _isLoading = false;

  // Getters
  UserProfile get userProfile => _userProfile;
  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();
  List<Goal> get expiredGoals => _goals.where((g) => g.isExpired).toList();
  List<Map<String, dynamic>> get availableBadges => _availableBadges;
  List<Map<String, dynamic>> get availableThemes => _availableThemes;
  List<Map<String, dynamic>> get availableAvatars => _availableAvatars;
  bool get isLoading => _isLoading;

  // Construtor
  GamificationProvider() {
    _initializeBadges();
    _initializeThemes();
    _initializeAvatars();
    loadData();
  }

  // Inicializar badges disponíveis
  void _initializeBadges() {
    _availableBadges = [
      {
        'id': 'first_week',
        'name': 'Primeira Semana',
        'description': '7 dias consecutivos',
        'icon': '🥇',
        'requirement': 'streak_7',
      },
      {
        'id': 'warrior',
        'name': 'Guerreiro',
        'description': '30 dias consecutivos',
        'icon': '⚔️',
        'requirement': 'streak_30',
      },
      {
        'id': 'centurion',
        'name': 'Centurião',
        'description': '100 conclusões totais',
        'icon': '🛡️',
        'requirement': 'completions_100',
      },
      {
        'id': 'multitasker',
        'name': 'Multitarefas',
        'description': '5+ hábitos ativos',
        'icon': '📚',
        'requirement': 'habits_5',
      },
    ];
  }

  // Inicializar temas disponíveis
  void _initializeThemes() {
    _availableThemes = [
      {
        'id': 'default',
        'name': 'Padrão',
        'description': 'Tema padrão do app',
        'price': 0,
        'category': 'basic',
        'colors': {
          'primary': 0xFF2196F3,
          'accent': 0xFF03DAC6,
        },
        'gradient': [0xFF2196F3, 0xFF21CBF3],
        'unlocked': true,
      },
      {
        'id': 'dark_blue',
        'name': 'Azul Escuro',
        'description': 'Profundezas do oceano',
        'price': 50,
        'category': 'premium',
        'colors': {
          'primary': 0xFF1565C0,
          'accent': 0xFF64B5F6,
        },
        'gradient': [0xFF0D47A1, 0xFF1976D2],
        'unlocked': false,
      },
      {
        'id': 'green_nature',
        'name': 'Verde Natureza',
        'description': 'Inspirado na floresta',
        'price': 75,
        'category': 'premium',
        'colors': {
          'primary': 0xFF388E3C,
          'accent': 0xFF66BB6A,
        },
        'gradient': [0xFF1B5E20, 0xFF4CAF50],
        'unlocked': false,
      },
      {
        'id': 'purple_royal',
        'name': 'Roxo Real',
        'description': 'Elegância majestosa',
        'price': 100,
        'category': 'premium',
        'colors': {
          'primary': 0xFF512DA8,
          'accent': 0xFF7E57C2,
        },
        'gradient': [0xFF4A148C, 0xFF673AB7],
        'unlocked': false,
      },
      {
        'id': 'orange_sunset',
        'name': 'Pôr do Sol',
        'description': 'Cores do entardecer',
        'price': 125,
        'category': 'premium',
        'colors': {
          'primary': 0xFFE65100,
          'accent': 0xFFFF8F00,
        },
        'gradient': [0xFFBF360C, 0xFFFF5722],
        'unlocked': false,
      },
      {
        'id': 'red_passion',
        'name': 'Paixão Vermelha',
        'description': 'Intensidade ardente',
        'price': 150,
        'category': 'premium',
        'colors': {
          'primary': 0xFFC62828,
          'accent': 0xFFE57373,
        },
        'gradient': [0xFFB71C1C, 0xFFF44336],
        'unlocked': false,
      },
      {
        'id': 'cyber_neon',
        'name': 'Cyber Neon',
        'description': 'Futuro tecnológico',
        'price': 175,
        'category': 'epic',
        'colors': {
          'primary': 0xFF00BCD4,
          'accent': 0xFF00E5FF,
        },
        'gradient': [0xFF006064, 0xFF0097A7],
        'unlocked': false,
      },
      {
        'id': 'gold_luxury',
        'name': 'Ouro Luxuoso',
        'description': 'Riqueza e sofisticação',
        'price': 200,
        'category': 'epic',
        'colors': {
          'primary': 0xFFFFB300,
          'accent': 0xFFFFC107,
        },
        'gradient': [0xFFE65100, 0xFFFFB300],
        'unlocked': false,
      },
      {
        'id': 'rainbow_magic',
        'name': 'Arco-íris Mágico',
        'description': 'Cores que inspiram',
        'price': 250,
        'category': 'legendary',
        'colors': {
          'primary': 0xFF9C27B0,
          'accent': 0xFF00BCD4,
        },
        'gradient': [0xFF9C27B0, 0xFF2196F3, 0xFF00BCD4],
        'unlocked': false,
      },
    ];
  }

  // Inicializar avatares e efeitos disponíveis
  void _initializeAvatars() {
    _availableAvatars = [
      {
        'id': 'default',
        'name': 'Avatar Padrão',
        'description': 'Avatar básico do nível',
        'price': 0,
        'category': 'basic',
        'type': 'frame',
        'effect': 'none',
        'unlocked': true,
      },
      {
        'id': 'golden_frame',
        'name': 'Moldura Dourada',
        'description': 'Frame dourado elegante',
        'price': 30,
        'category': 'premium',
        'type': 'frame',
        'effect': 'golden_border',
        'unlocked': false,
      },
      {
        'id': 'silver_frame',
        'name': 'Moldura Prateada',
        'description': 'Frame prateado moderno',
        'price': 25,
        'category': 'premium',
        'type': 'frame',
        'effect': 'silver_border',
        'unlocked': false,
      },
      {
        'id': 'neon_glow',
        'name': 'Brilho Neon',
        'description': 'Efeito de brilho colorido',
        'price': 50,
        'category': 'epic',
        'type': 'effect',
        'effect': 'neon_glow',
        'unlocked': false,
      },
      {
        'id': 'pulse_animation',
        'name': 'Animação Pulse',
        'description': 'Efeito de pulsação suave',
        'price': 40,
        'category': 'epic',
        'type': 'effect',
        'effect': 'pulse',
        'unlocked': false,
      },
      {
        'id': 'rainbow_border',
        'name': 'Borda Arco-íris',
        'description': 'Frame com cores do arco-íris',
        'price': 75,
        'category': 'legendary',
        'type': 'frame',
        'effect': 'rainbow_border',
        'unlocked': false,
      },
      {
        'id': 'fire_effect',
        'name': 'Efeito de Fogo',
        'description': 'Chamas ao redor do avatar',
        'price': 100,
        'category': 'legendary',
        'type': 'effect',
        'effect': 'fire_animation',
        'unlocked': false,
      },
    ];
  }

  // Carregar dados
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Carregar perfil do usuário
      final profileJson = prefs.getString('user_profile');
      if (profileJson != null) {
        _userProfile = UserProfile.fromJson(json.decode(profileJson));
      }

      // Carregar metas
      final goalsJson = prefs.getString('user_goals');
      if (goalsJson != null) {
        final goalsList = json.decode(goalsJson) as List;
        _goals = goalsList.map((g) => Goal.fromJson(g)).toList();
      }

      // Atualizar temas desbloqueados
      _updateUnlockedThemes();

      // Verificar expiração de metas
      _checkGoalExpirations();

      // Gerar metas padrão se necessário
      if (_goals.isEmpty) {
        _generateDefaultGoals();
      }

    } catch (e) {
      debugPrint('Erro ao carregar dados de gamificação: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Salvar dados
  Future<void> saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Salvar perfil
      await prefs.setString('user_profile', json.encode(_userProfile.toJson()));
      
      // Salvar metas
      final goalsJson = _goals.map((g) => g.toJson()).toList();
      await prefs.setString('user_goals', json.encode(goalsJson));
      
    } catch (e) {
      debugPrint('Erro ao salvar dados de gamificação: $e');
    }
  }

  // Adicionar XP e verificar level up
  Future<bool> addXP(int xp, {String? reason}) async {
    final hadLevelUp = _userProfile.addXP(xp);
    
    if (reason != null) {
      _userProfile.updateStatistic('xp_from_$reason', xp);
    }

    // Verificar se desbloqueou novos badges
    await _checkBadgeUnlocks();
    
    await saveData();
    notifyListeners();
    
    return hadLevelUp;
  }

  // Verificar desbloqueio de badges
  Future<void> _checkBadgeUnlocks() async {
    for (final badge in _availableBadges) {
      final badgeId = badge['id'] as String;
      
      if (_userProfile.unlockedBadges.contains(badgeId)) continue;

      bool shouldUnlock = false;

      switch (badge['requirement']) {
        case 'streak_7':
          shouldUnlock = _userProfile.totalXP >= 35; // Aproximação baseada em XP
          break;
        case 'streak_30':
          shouldUnlock = _userProfile.totalXP >= 150;
          break;
        case 'completions_100':
          shouldUnlock = _userProfile.totalXP >= 500;
          break;
        case 'habits_5':
          shouldUnlock = _userProfile.totalXP >= 50; // Aproximação
          break;
      }

      if (shouldUnlock) {
        _userProfile.unlockBadge(badgeId);
      }
    }
  }

  // Atualizar metas baseado na conclusão de hábitos
  Future<List<Goal>> updateGoalsProgress(int habitCompletions) async {
    List<Goal> completedGoals = [];

    for (final goal in _goals.where((g) => g.isActive)) {
      bool wasCompleted = goal.updateProgress(habitCompletions);

      if (wasCompleted) {
        completedGoals.add(goal);
        
        // Dar recompensas
        await addXP(goal.xpReward, reason: 'goal_completion');
        _userProfile.coins += goal.coinReward;
        
        if (goal.badgeReward != null) {
          _userProfile.unlockBadge(goal.badgeReward!);
        }
      }
    }

    if (completedGoals.isNotEmpty) {
      await saveData();
      notifyListeners();
    }

    return completedGoals;
  }

  // Verificar expiração de metas
  void _checkGoalExpirations() {
    bool hasChanges = false;
    
    for (final goal in _goals) {
      if (goal.isActive && goal.isExpired) {
        goal.checkExpiration();
        hasChanges = true;
      }
    }

    if (hasChanges) {
      saveData();
      notifyListeners();
    }
  }

  // Gerar metas padrão
  void _generateDefaultGoals() {
    _goals.addAll([
      Goal.dailyCompletion(targetHabits: 3),
      Goal.weeklyStreak(targetDays: 5),
      Goal.monthlyChallenge(targetCompletions: 50),
    ]);
    
    saveData();
    notifyListeners();
  }

  // Adicionar meta personalizada
  Future<void> addCustomGoal(Goal goal) async {
    _goals.add(goal);
    await saveData();
    notifyListeners();
  }

  // Remover meta
  Future<void> removeGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    await saveData();
    notifyListeners();
  }

  // Comprar tema
  Future<bool> purchaseTheme(String themeId) async {
    final theme = _availableThemes.firstWhere((t) => t['id'] == themeId);
    final price = theme['price'] as int;

    if (_userProfile.spendCoins(price)) {
      _userProfile.unlockTheme(themeId);
      theme['unlocked'] = true;
      await saveData();
      notifyListeners();
      return true;
    }

    return false;
  }

  // Trocar tema atual
  Future<void> changeTheme(String themeId) async {
    if (_userProfile.unlockedThemes.contains(themeId)) {
      _userProfile.currentTheme = themeId;
      await saveData();
      notifyListeners();
    }
  }

  // Comprar avatar/efeito
  Future<bool> purchaseAvatar(String avatarId) async {
    final avatar = _availableAvatars.firstWhere((a) => a['id'] == avatarId);
    final price = avatar['price'] as int;

    if (_userProfile.spendCoins(price)) {
      _userProfile.unlockAvatar(avatarId);
      avatar['unlocked'] = true;
      await saveData();
      notifyListeners();
      return true;
    }

    return false;
  }

  // Equipar avatar/efeito
  Future<void> equipAvatar(String avatarId) async {
    if (_userProfile.unlockedAvatars.contains(avatarId)) {
      final avatar = _availableAvatars.firstWhere((a) => a['id'] == avatarId);
      if (avatar['type'] == 'frame') {
        _userProfile.currentAvatarFrame = avatarId;
      } else {
        _userProfile.currentAvatarEffect = avatarId;
      }
      await saveData();
      notifyListeners();
    }
  }

  // Atualizar temas desbloqueados
  void _updateUnlockedThemes() {
    for (final theme in _availableThemes) {
      final themeId = theme['id'] as String;
      theme['unlocked'] = _userProfile.unlockedThemes.contains(themeId);
    }
  }

  // Obter badge por ID
  Map<String, dynamic>? getBadge(String badgeId) {
    try {
      return _availableBadges.firstWhere((b) => b['id'] == badgeId);
    } catch (e) {
      return null;
    }
  }

  // Obter tema por ID
  Map<String, dynamic>? getTheme(String themeId) {
    try {
      return _availableThemes.firstWhere((t) => t['id'] == themeId);
    } catch (e) {
      return null;
    }
  }

  // Resetar progresso (para testes)
  Future<void> resetProgress() async {
    _userProfile = UserProfile();
    _goals.clear();
    _generateDefaultGoals();
    await saveData();
    notifyListeners();
  }

  // Atualizar username
  Future<void> updateUsername(String username) async {
    _userProfile.username = username;
    await saveData();
    notifyListeners();
  }

  // Obter estatísticas do usuário
  Map<String, dynamic> getUserStats() {
    return {
      'totalXP': _userProfile.totalXP,
      'level': _userProfile.levelName,
      'coins': _userProfile.coins,
      'badges': _userProfile.unlockedBadges.length,
      'completedGoals': completedGoals.length,
      'activeGoals': activeGoals.length,
      'daysSinceStart': DateTime.now().difference(_userProfile.createdAt).inDays,
    };
  }
} 