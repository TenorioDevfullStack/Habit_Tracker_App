// lib/models/habit.dart

enum HabitFrequency { daily, specificDays, xTimesPerWeek }

class Habit {
  String id;
  String name;
  HabitFrequency frequency;
  List<int> specificDays; // 1 = Monday, 7 = Sunday
  int xTimesCount;
  DateTime? reminderTime;
  bool reminderEnabled;
  List<String> completionDates; // Armazena strings de data: 'yyyy-mm-dd'

  Habit({
    required this.id,
    required this.name,
    this.frequency = HabitFrequency.daily,
    List<int>? specificDays,
    this.xTimesCount = 0,
    this.reminderTime,
    this.reminderEnabled = false,
    List<String>? completionDates,
  })  : specificDays = specificDays ?? [],
        completionDates = completionDates ?? [];

  // Método para marcar o hábito como concluído para uma data específica
  void markAsCompleted(DateTime date) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    if (!completionDates.contains(dateKey)) {
      completionDates.add(dateKey);
      completionDates.sort();
    }
  }

  // Método para verificar se o hábito foi concluído em uma data específica
  bool isCompletedOn(DateTime date) {
    final dateKey = '${date.year}-${date.month}-${date.day}';
    return completionDates.contains(dateKey);
  }

  // Método para calcular a sequência (streak) atual
  int calculateCurrentStreak([DateTime? testCurrentDate]) {
    if (completionDates.isEmpty) {
      return 0;
    }

    DateTime currentDate = testCurrentDate ?? DateTime.now();
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day);

    int streak = 0;

    // Verifica se foi concluído hoje
    if (isCompletedOn(currentDate)) {
      streak = 1;
      currentDate = currentDate.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    // Continua verificando os dias anteriores
    while (isCompletedOn(currentDate)) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  // Converte um Hábito para um mapa
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'frequency': frequency.index,
        'specificDays': specificDays,
        'xTimesCount': xTimesCount,
        'reminderTime': reminderTime?.toIso8601String(),
        'reminderEnabled': reminderEnabled,
        'completionDates': completionDates,
      };

  // Cria um Hábito a partir de um mapa
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      name: map['name'],
      frequency: HabitFrequency.values[map['frequency']],
      specificDays: List<int>.from(map['specificDays'] ?? []),
      xTimesCount: map['xTimesCount'] ?? 0,
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'])
          : null,
      reminderEnabled: map['reminderEnabled'] ?? false,
      completionDates: List<String>.from(map['completionDates'] ?? []),
    );
  }

  // Mantém compatibilidade com versões antigas
  Map<String, dynamic> toJson() => toMap();
  factory Habit.fromJson(Map<String, dynamic> json) => Habit.fromMap(json);
}
