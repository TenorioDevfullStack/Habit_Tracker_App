import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum GoalType {
  daily,      // Meta diária
  weekly,     // Meta semanal
  monthly,    // Meta mensal
  challenge,  // Desafio especial
  streak,     // Meta de sequência
  custom,     // Meta personalizada
}

enum GoalStatus {
  active,     // Ativa
  completed,  // Concluída
  failed,     // Falhada
  expired,    // Expirada
}

class Goal {
  final String id;
  String title;
  String description;
  GoalType type;
  GoalStatus status;
  int targetValue;
  int currentValue;
  int xpReward;
  int coinReward;
  String? badgeReward;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAt;
  bool isDefault; // True para metas automáticas do sistema
  List<String> requiredHabitIds; // IDs dos hábitos específicos (opcional)
  Map<String, dynamic> metadata; // Dados extras específicos do tipo

  Goal({
    String? id,
    required this.title,
    required this.description,
    required this.type,
    this.status = GoalStatus.active,
    required this.targetValue,
    this.currentValue = 0,
    required this.xpReward,
    required this.coinReward,
    this.badgeReward,
    required this.startDate,
    required this.endDate,
    DateTime? createdAt,
    this.isDefault = false,
    List<String>? requiredHabitIds,
    Map<String, dynamic>? metadata,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       requiredHabitIds = requiredHabitIds ?? [],
       metadata = metadata ?? {};

  // Getters
  double get progress => targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
  bool get isCompleted => status == GoalStatus.completed;
  bool get isActive => status == GoalStatus.active;
  bool get isExpired => DateTime.now().isAfter(endDate) && status == GoalStatus.active;
  
  String get typeEmoji {
    switch (type) {
      case GoalType.daily:
        return '📅';
      case GoalType.weekly:
        return '📊';
      case GoalType.monthly:
        return '🗓️';
      case GoalType.challenge:
        return '🏆';
      case GoalType.streak:
        return '🔥';
      case GoalType.custom:
        return '🎯';
    }
  }

  String get typeName {
    switch (type) {
      case GoalType.daily:
        return 'Meta Diária';
      case GoalType.weekly:
        return 'Meta Semanal';
      case GoalType.monthly:
        return 'Meta Mensal';
      case GoalType.challenge:
        return 'Desafio';
      case GoalType.streak:
        return 'Sequência';
      case GoalType.custom:
        return 'Personalizada';
    }
  }

  String get statusName {
    switch (status) {
      case GoalStatus.active:
        return 'Ativa';
      case GoalStatus.completed:
        return 'Concluída';
      case GoalStatus.failed:
        return 'Falhada';
      case GoalStatus.expired:
        return 'Expirada';
    }
  }

  Color get statusColor {
    switch (status) {
      case GoalStatus.active:
        return Colors.blue;
      case GoalStatus.completed:
        return Colors.green;
      case GoalStatus.failed:
        return Colors.red;
      case GoalStatus.expired:
        return Colors.orange;
    }
  }

  // Atualizar progresso
  bool updateProgress(int value) {
    if (status != GoalStatus.active) return false;
    
    currentValue = (currentValue + value).clamp(0, targetValue);
    
    if (currentValue >= targetValue) {
      status = GoalStatus.completed;
      return true; // Meta concluída
    }
    
    return false;
  }

  // Marcar como falha
  void markAsFailed() {
    if (status == GoalStatus.active) {
      status = GoalStatus.failed;
    }
  }

  // Resetar progresso (para metas recorrentes)
  void reset() {
    currentValue = 0;
    status = GoalStatus.active;
  }

  // Verificar se a meta expirou
  void checkExpiration() {
    if (status == GoalStatus.active && DateTime.now().isAfter(endDate)) {
      status = GoalStatus.expired;
    }
  }

  // Dias restantes
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // Serialização
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.index,
      'status': status.index,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'xpReward': xpReward,
      'coinReward': coinReward,
      'badgeReward': badgeReward,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isDefault': isDefault,
      'requiredHabitIds': requiredHabitIds,
      'metadata': metadata,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: GoalType.values[json['type']],
      status: GoalStatus.values[json['status'] ?? 0],
      targetValue: json['targetValue'],
      currentValue: json['currentValue'] ?? 0,
      xpReward: json['xpReward'],
      coinReward: json['coinReward'],
      badgeReward: json['badgeReward'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isDefault: json['isDefault'] ?? false,
      requiredHabitIds: List<String>.from(json['requiredHabitIds'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  // Factory methods para diferentes tipos de metas
  static Goal dailyCompletion({required int targetHabits}) {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return Goal(
      title: 'Conclusão Diária',
      description: 'Complete $targetHabits hábitos hoje',
      type: GoalType.daily,
      targetValue: targetHabits,
      xpReward: targetHabits * 10,
      coinReward: targetHabits * 5,
      startDate: DateTime(now.year, now.month, now.day),
      endDate: endOfDay,
      isDefault: true,
    );
  }

  static Goal weeklyStreak({required int targetDays}) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    return Goal(
      title: 'Sequência Semanal',
      description: 'Mantenha hábitos por $targetDays dias esta semana',
      type: GoalType.weekly,
      targetValue: targetDays,
      xpReward: targetDays * 20,
      coinReward: targetDays * 10,
      badgeReward: targetDays >= 7 ? 'perfect_week' : null,
      startDate: startOfWeek,
      endDate: endOfWeek,
      isDefault: true,
    );
  }

  static Goal monthlyChallenge({required int targetCompletions}) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return Goal(
      title: 'Desafio Mensal',
      description: 'Complete $targetCompletions hábitos este mês',
      type: GoalType.monthly,
      targetValue: targetCompletions,
      xpReward: targetCompletions * 5,
      coinReward: targetCompletions * 3,
      badgeReward: 'monthly_champion',
      startDate: startOfMonth,
      endDate: endOfMonth,
      isDefault: true,
    );
  }

  static Goal perfectWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    return Goal(
      title: 'Semana Perfeita',
      description: 'Complete TODOS os hábitos por 7 dias consecutivos',
      type: GoalType.challenge,
      targetValue: 7,
      xpReward: 200,
      coinReward: 100,
      badgeReward: 'perfect_week_master',
      startDate: startOfWeek,
      endDate: endOfWeek,
      isDefault: true,
    );
  }
} 