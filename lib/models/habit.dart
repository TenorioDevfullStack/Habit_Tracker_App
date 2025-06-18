// lib/models/habit.dart

enum HabitFrequency { daily, specificDays, xTimesPerWeek }

class Habit {
  String id;
  String name;
  HabitFrequency frequency;
  List<int> specificDays; // 1 = Monday, 7 = Sunday
  int xTimesCount;
  DateTime? reminderTime;
  bool notificationsEnabled;
  List<DateTime> completedDates; // Armazena apenas a data (ano, mês, dia)

  Habit({
    required this.id,
    required this.name,
    this.frequency = HabitFrequency.daily,
    List<int>? specificDays, // Parâmetro opcional e anulável
    this.xTimesCount = 0,
    this.reminderTime,
    this.notificationsEnabled = false,
    List<DateTime>? completedDates, // Parâmetro opcional e anulável
  }) : this.specificDays =
           specificDays ?? const [], // Garante lista mutável se nula
       this.completedDates =
           completedDates ?? []; // Garante lista mutável se nula

  // Método para marcar o hábito como concluído para uma data específica
  void markAsCompleted(DateTime date) {
    // Normaliza a data para remover informações de hora, minuto, segundo
    final normalizedDate = DateTime(date.year, date.month, date.day);
    if (!completedDates.contains(normalizedDate)) {
      completedDates.add(normalizedDate);
      completedDates.sort(); // Mantém as datas ordenadas
    }
  }

  // Método para verificar se o hábito foi concluído em uma data específica
  bool isCompletedOn(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return completedDates.contains(normalizedDate);
  }

  // Método para calcular a sequência (streak) atual
  // [testCurrentDate] parâmetro opcional para facilitar testes unitários determinísticos
  int calculateCurrentStreak([DateTime? testCurrentDate]) {
    if (completedDates.isEmpty) {
      return 0;
    }

    DateTime currentDate =
        testCurrentDate ?? DateTime.now(); // Usa a data do teste se fornecida
    // Normaliza a data atual para comparação
    currentDate = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day,
    );

    int streak = 0;

    // Primeiro, verifica se o hábito foi concluído HOJE (ou na data testCurrentDate)
    if (isCompletedOn(currentDate)) {
      streak = 1;
      currentDate = currentDate.subtract(
        const Duration(days: 1),
      ); // Retrocede para o dia anterior
    } else {
      // Se não foi concluído hoje, a sequência de hoje é 0, mas precisamos verificar
      // se foi concluído ontem para iniciar uma contagem a partir de lá.
      // Neste cenário, se não for feito hoje, a streak atual é 0.
      return 0;
    }

    // Continua verificando os dias anteriores na lista de completedDates
    // A lista completedDates já deve estar ordenada
    // Itera do final para o começo para encontrar a sequência mais recente
    for (int i = completedDates.length - 1; i >= 0; i--) {
      final completedDate = completedDates[i];
      final normalizedCompletedDate = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );

      // Se a data concluída é o dia anterior ao 'currentDate'
      if (normalizedCompletedDate.isAtSameMomentAs(currentDate)) {
        streak++;
        currentDate = currentDate.subtract(
          const Duration(days: 1),
        ); // Retrocede mais um dia
      } else if (normalizedCompletedDate.isBefore(currentDate)) {
        // Se a data concluída é anterior ao dia esperado, a sequência foi quebrada
        break;
      }
      // Se normalizedCompletedDate for depois de currentDate, ignoramos (não deveria acontecer se estiverem ordenadas)
    }

    return streak;
  }

  // Converte um Hábito para um mapa (útil para persistência de dados)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'frequency': frequency.index,
    'specificDays': specificDays,
    'xTimesCount': xTimesCount,
    'reminderTime': reminderTime?.toIso8601String(),
    'notificationsEnabled': notificationsEnabled,
    'completedDates': completedDates.map((d) => d.toIso8601String()).toList(),
  };

  // Cria um Hábito a partir de um mapa
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      frequency: HabitFrequency.values[json['frequency']],
      specificDays: List<int>.from(
        json['specificDays'] ?? [],
      ), // Garante que a lista não é nula
      xTimesCount: json['xTimesCount'],
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'])
          : null,
      notificationsEnabled: json['notificationsEnabled'],
      completedDates:
          (json['completedDates'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d))
              .toList() ??
          [], // Garante que a lista não é nula
    );
  }
}
