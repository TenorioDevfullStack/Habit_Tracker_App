// test/habit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker_app/models/habit.dart';

void main() {
  group('Habit Model', () {
    test(
      'should correctly calculate current streak when habit is completed daily',
      () {
        // Define uma data de referência para o teste (ex: hoje)
        final testDate = DateTime(2025, 6, 18); // 18 de junho de 2025

        // Cria um hábito com datas de conclusão consecutivas até a data de teste
        final habit = Habit(
          id: '1',
          name: 'Beber água',
          completedDates: [
            DateTime(2025, 6, 16), // 2 dias atrás
            DateTime(2025, 6, 17), // 1 dia atrás
            DateTime(2025, 6, 18), // Hoje
          ],
        );

        // Passa a data do último dia da sequência como a "data atual" para o teste
        expect(habit.calculateCurrentStreak(testDate), 3);
      },
    );

    test(
      'should return correct streak if habit was not completed yesterday but completed today',
      () {
        // Define uma data de referência para o teste (ex: hoje)
        final testDate = DateTime(2025, 6, 18); // 18 de junho de 2025

        // Cria um hábito com uma quebra na sequência
        final habit = Habit(
          id: '2',
          name: 'Exercitar-se',
          completedDates: [
            DateTime(2025, 6, 15), // Pulou o dia 16 e 17
            DateTime(2025, 6, 18), // Hoje
          ],
        );
        // A sequência deve ser 1 (apenas o dia 18 conta, pois houve quebra)
        expect(habit.calculateCurrentStreak(testDate), 1);
      },
    );

    test('should return 0 streak if habit was not completed today', () {
      // Define uma data de referência para o teste (ex: hoje)
      final testDate = DateTime(2025, 6, 18); // 18 de junho de 2025

      // Hábito concluído em dias anteriores, mas NÃO hoje
      final habit = Habit(
        id: 'streak_test_3',
        name: 'Meditar',
        completedDates: [DateTime(2025, 6, 16), DateTime(2025, 6, 17)],
      );
      // Se não foi concluído hoje, a sequência atual é 0
      expect(habit.calculateCurrentStreak(testDate), 0);
    });

    test('should correctly mark habit as completed', () {
      final habit = Habit(id: '3', name: 'Ler');
      final dateToComplete = DateTime(2025, 6, 16);

      habit.markAsCompleted(dateToComplete);

      expect(habit.isCompletedOn(dateToComplete), isTrue);
      expect(habit.completedDates.length, 1);
    });

    test('should not add duplicate completed dates', () {
      final habit = Habit(id: '4', name: 'Meditar');
      final date = DateTime(2025, 6, 16);

      habit.markAsCompleted(date);
      habit.markAsCompleted(date); // Tenta adicionar a mesma data novamente

      expect(habit.completedDates.length, 1);
      expect(habit.isCompletedOn(date), isTrue);
    });

    test('should correctly handle markAsCompleted for different dates', () {
      final habit = Habit(id: '5', name: 'Escrever');
      final date1 = DateTime(2025, 6, 1);
      final date2 = DateTime(2025, 6, 2);

      habit.markAsCompleted(date1);
      habit.markAsCompleted(date2);

      expect(habit.completedDates.length, 2);
      expect(habit.isCompletedOn(date1), isTrue);
      expect(habit.isCompletedOn(date2), isTrue);
    });

    test(
      'toJson and fromJson should correctly serialize and deserialize a Habit',
      () {
        final originalHabit = Habit(
          id: 'test_id_123',
          name: 'Correr',
          frequency: HabitFrequency.specificDays,
          specificDays: [1, 3, 5], // Seg, Qua, Sex
          xTimesCount: 0,
          reminderTime: DateTime(2025, 1, 1, 8, 30),
          notificationsEnabled: true,
          completedDates: [DateTime(2025, 6, 10), DateTime(2025, 6, 11)],
        );

        final habitMap = originalHabit.toJson();
        final decodedHabit = Habit.fromJson(habitMap);

        expect(decodedHabit.id, originalHabit.id);
        expect(decodedHabit.name, originalHabit.name);
        expect(decodedHabit.frequency, originalHabit.frequency);
        expect(decodedHabit.specificDays, originalHabit.specificDays);
        expect(decodedHabit.xTimesCount, originalHabit.xTimesCount);
        expect(
          decodedHabit.reminderTime?.toIso8601String(),
          originalHabit.reminderTime?.toIso8601String(),
        );
        expect(
          decodedHabit.notificationsEnabled,
          originalHabit.notificationsEnabled,
        );
        expect(
          decodedHabit.completedDates.map((d) => d.toIso8601String()).toList(),
          originalHabit.completedDates.map((d) => d.toIso8601String()).toList(),
        );
      },
    );
  });
}
