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
  bool _isLoading = false;

  // Getters
  UserProfile get userProfile => _userProfile;
  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();
  List<Goal> get expiredGoals => _goals.where((g) => g.isExpired).toList();
  List<Map<String, dynamic>> get availableBadges => _availableBadges;
  List<Map<String, dynamic>> get availableThemes => _availableThemes;
  bool get isLoading => _isLoading;

  // Construtor
  GamificationProvider() {
    _initializeBadges();
    _initializeThemes();
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
        'colors': {
          'primary': 0xFF2196F3,
          'accent': 0xFF03DAC6,
        },
        'unlocked': true,
      },
      {
        'id': 'dark_blue',
        'name': 'Azul Escuro',
        'description': 'Tema azul profundo',
        'price': 50,
        'colors': {
          'primary': 0xFF1565C0,
          'accent': 0xFF64B5F6,
        },
        'unlocked': false,
      },
      {
        'id': 'green_nature',
        'name': 'Verde Natureza',
        'description': 'Inspirado na natureza',
        'price': 75,
        'colors': {
          'primary': 0xFF4CAF50,
          'accent': 0xFF8BC34A,
        },
        'unlocked': false,
      },
      {
        'id': 'purple_royal',
        'name': 'Roxo Real',
        'description': 'Elegância roxa',
        'price': 100,
        'colors': {
          'primary': 0xFF673AB7,
          'accent': 0xFF9C27B0,
        },
        'unlocked': false,
      },
      {
        'id': 'orange_sunset',
        'name': 'Pôr do Sol',
        'description': 'Cores do entardecer',
        'price': 125,
        'colors': {
          'primary': 0xFFFF9800,
          'accent': 0xFFFF5722,
        },
        'unlocked': false,
      },
      {
        'id': 'red_passion',
        'name': 'Paixão Vermelha',
        'description': 'Vermelho intenso',
        'price': 150,
        'colors': {
          'primary': 0xFFF44336,
          'accent': 0xFFE91E63,
        },
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