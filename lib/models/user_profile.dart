import 'package:uuid/uuid.dart';

enum UserLevel {
  beginner,    // 0-100 XP
  dedicated,   // 101-500 XP  
  veteran,     // 501-1500 XP
  master,      // 1501+ XP
}

class UserProfile {
  final String id;
  String username;
  int totalXP;
  int coins;
  UserLevel level;
  List<String> unlockedBadges;
  List<String> unlockedThemes;
  String currentTheme;
  List<String> unlockedAvatars;
  String currentAvatarFrame;
  String currentAvatarEffect;
  DateTime createdAt;
  DateTime lastActiveDate;
  Map<String, int> statistics;

  UserProfile({
    String? id,
    this.username = 'Usuário',
    this.totalXP = 0,
    this.coins = 0,
    this.level = UserLevel.beginner,
    List<String>? unlockedBadges,
    List<String>? unlockedThemes,
    this.currentTheme = 'default',
    List<String>? unlockedAvatars,
    this.currentAvatarFrame = 'default',
    this.currentAvatarEffect = 'default',
    DateTime? createdAt,
    DateTime? lastActiveDate,
    Map<String, int>? statistics,
  }) : id = id ?? const Uuid().v4(),
       unlockedBadges = unlockedBadges ?? [],
       unlockedThemes = unlockedThemes ?? ['default'],
       unlockedAvatars = unlockedAvatars ?? ['default'],
       createdAt = createdAt ?? DateTime.now(),
       lastActiveDate = lastActiveDate ?? DateTime.now(),
       statistics = statistics ?? {};

  // Getters para informações do nível
  String get levelName {
    switch (level) {
      case UserLevel.beginner:
        return 'Iniciante';
      case UserLevel.dedicated:
        return 'Dedicado';
      case UserLevel.veteran:
        return 'Veterano';
      case UserLevel.master:
        return 'Mestre';
    }
  }

  String get levelEmoji {
    switch (level) {
      case UserLevel.beginner:
        return '🥉';
      case UserLevel.dedicated:
        return '🥈';
      case UserLevel.veteran:
        return '🥇';
      case UserLevel.master:
        return '💎';
    }
  }

  int get xpForCurrentLevel {
    switch (level) {
      case UserLevel.beginner:
        return totalXP;
      case UserLevel.dedicated:
        return totalXP - 101;
      case UserLevel.veteran:
        return totalXP - 501;
      case UserLevel.master:
        return totalXP - 1501;
    }
  }

  int get xpRequiredForNextLevel {
    switch (level) {
      case UserLevel.beginner:
        return 100 - totalXP;
      case UserLevel.dedicated:
        return 500 - totalXP;
      case UserLevel.veteran:
        return 1500 - totalXP;
      case UserLevel.master:
        return 0; // Nível máximo
    }
  }

  int get xpPerCompletion {
    switch (level) {
      case UserLevel.beginner:
        return 5;
      case UserLevel.dedicated:
        return 7;
      case UserLevel.veteran:
        return 10;
      case UserLevel.master:
        return 15;
    }
  }

  double get levelProgress {
    switch (level) {
      case UserLevel.beginner:
        return totalXP / 100;
      case UserLevel.dedicated:
        return (totalXP - 101) / 399; // 500 - 101
      case UserLevel.veteran:
        return (totalXP - 501) / 999; // 1500 - 501
      case UserLevel.master:
        return 1.0;
    }
  }

  // Adicionar XP e verificar level up
  bool addXP(int xp) {
    final oldLevel = level;
    totalXP += xp;
    coins += (xp * 0.5).round(); // 0.5 moedas por XP
    
    updateLevel();
    return oldLevel != level; // Retorna true se houve level up
  }

  // Atualizar nível baseado no XP
  void updateLevel() {
    if (totalXP >= 1501) {
      level = UserLevel.master;
    } else if (totalXP >= 501) {
      level = UserLevel.veteran;
    } else if (totalXP >= 101) {
      level = UserLevel.dedicated;
    } else {
      level = UserLevel.beginner;
    }
  }

  // Desbloquear badge
  void unlockBadge(String badgeId) {
    if (!unlockedBadges.contains(badgeId)) {
      unlockedBadges.add(badgeId);
    }
  }

  // Desbloquear tema
  void unlockTheme(String themeId) {
    if (!unlockedThemes.contains(themeId)) {
      unlockedThemes.add(themeId);
    }
  }

  // Desbloquear avatar
  void unlockAvatar(String avatarId) {
    if (!unlockedAvatars.contains(avatarId)) {
      unlockedAvatars.add(avatarId);
    }
  }

  // Comprar item com moedas
  bool spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      return true;
    }
    return false;
  }

  // Atualizar estatística
  void updateStatistic(String key, int value) {
    statistics[key] = (statistics[key] ?? 0) + value;
  }

  // Serialização
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'totalXP': totalXP,
      'coins': coins,
      'level': level.index,
      'unlockedBadges': unlockedBadges,
      'unlockedThemes': unlockedThemes,
      'currentTheme': currentTheme,
      'unlockedAvatars': unlockedAvatars,
      'currentAvatarFrame': currentAvatarFrame,
      'currentAvatarEffect': currentAvatarEffect,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveDate': lastActiveDate.toIso8601String(),
      'statistics': statistics,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      username: json['username'] ?? 'Usuário',
      totalXP: json['totalXP'] ?? 0,
      coins: json['coins'] ?? 0,
      level: UserLevel.values[json['level'] ?? 0],
      unlockedBadges: List<String>.from(json['unlockedBadges'] ?? []),
      unlockedThemes: List<String>.from(json['unlockedThemes'] ?? ['default']),
      currentTheme: json['currentTheme'] ?? 'default',
      unlockedAvatars: List<String>.from(json['unlockedAvatars'] ?? ['default']),
      currentAvatarFrame: json['currentAvatarFrame'] ?? 'default',
      currentAvatarEffect: json['currentAvatarEffect'] ?? 'default',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActiveDate: DateTime.parse(json['lastActiveDate'] ?? DateTime.now().toIso8601String()),
      statistics: Map<String, int>.from(json['statistics'] ?? {}),
    );
  }
} 