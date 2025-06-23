import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/models/habit.dart';
import 'package:intl/intl.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedDay = DateTime.now();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = Provider.of<HabitProvider>(context);
    final allHabits = habitProvider.habits;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (allHabits.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Theme.of(context).appBarTheme.foregroundColor,
          unselectedLabelColor: Theme.of(context).appBarTheme.foregroundColor?.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Visão Geral'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Calendário'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Estatísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(habitProvider, isDarkMode),
          _buildCalendarTab(habitProvider, isDarkMode),
          _buildStatsTab(habitProvider, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 64,
                color: isDarkMode ? Colors.blue[300] : Colors.blue.shade300,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum progresso ainda!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione hábitos para ver\nseu progresso aqui',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(HabitProvider habitProvider, bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cards de estatísticas rápidas
          _buildQuickStatsGrid(habitProvider, isDarkMode),
          
          const SizedBox(height: 24),
          
          // Gráfico de progresso semanal
          _buildWeeklyProgressChart(habitProvider, isDarkMode),
          
          const SizedBox(height: 24),
          
          // Seção de conquistas
          _buildAchievementsSection(habitProvider, isDarkMode),
          
          const SizedBox(height: 24),
          
          // Hábitos em destaque
          _buildTopHabitsSection(habitProvider, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(HabitProvider habitProvider, bool isDarkMode) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Calendar com heatmap
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendário de Atividades',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                TableCalendar<String>(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, habitProvider, isDarkMode);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, habitProvider, isDarkMode, isToday: true);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(day, habitProvider, isDarkMode, isSelected: true);
                    },
                  ),
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonDecoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    formatButtonTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(
                      color: Colors.red[400],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Detalhes do dia selecionado
        if (_selectedDay != null)
          _buildSelectedDayDetails(habitProvider, _selectedDay!, isDarkMode),
      ],
    );
  }

  Widget _buildStatsTab(HabitProvider habitProvider, bool isDarkMode) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Gráfico circular de conclusão
        _buildCompletionPieChart(habitProvider, isDarkMode),
        
        const SizedBox(height: 24),
        
        // Gráfico de barras por hábito
        _buildHabitsBarChart(habitProvider, isDarkMode),
        
        const SizedBox(height: 24),
        
        // Estatísticas detalhadas
        _buildDetailedStats(habitProvider, isDarkMode),
      ],
    );
  }

  Widget _buildQuickStatsGrid(HabitProvider habitProvider, bool isDarkMode) {
    final today = DateTime.now();
    final todayHabits = habitProvider.getTodayHabits(today);
    final completedToday = todayHabits.where((h) => h.isCompletedOn(today)).length;
    final totalHabits = habitProvider.habits.length;
    
    // Calcular sequência mais longa
    int longestStreak = 0;
    for (var habit in habitProvider.habits) {
      final streak = habit.calculateCurrentStreak();
      if (streak > longestStreak) longestStreak = streak;
    }

    // Calcular taxa de sucesso geral (últimos 7 dias)
    int totalPossible = 0;
    int totalCompleted = 0;
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final dayHabits = habitProvider.getTodayHabits(date);
      totalPossible += dayHabits.length;
      totalCompleted += dayHabits.where((h) => h.isCompletedOn(date)).length;
    }
    final successRate = totalPossible > 0 ? (totalCompleted / totalPossible * 100) : 0.0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildQuickStatCard(
          icon: Icons.today,
          title: 'Hoje',
          value: '$completedToday/${todayHabits.length}',
          subtitle: 'Concluídos',
          color: Colors.green,
          isDarkMode: isDarkMode,
        ),
        _buildQuickStatCard(
          icon: Icons.local_fire_department,
          title: 'Melhor Sequência',
          value: '$longestStreak',
          subtitle: 'dias',
          color: Colors.orange,
          isDarkMode: isDarkMode,
        ),
        _buildQuickStatCard(
          icon: Icons.timeline,
          title: 'Taxa de Sucesso',
          value: '${successRate.toStringAsFixed(0)}%',
          subtitle: '7 dias',
          color: Colors.blue,
          isDarkMode: isDarkMode,
        ),
        _buildQuickStatCard(
          icon: Icons.star,
          title: 'Total Hábitos',
          value: '$totalHabits',
          subtitle: 'ativos',
          color: Colors.purple,
          isDarkMode: isDarkMode,
        ),
      ],
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required bool isDarkMode,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart(HabitProvider habitProvider, bool isDarkMode) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progresso dos Últimos 7 Dias',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.transparent,
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                          return Text(
                            DateFormat('E').format(date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getWeeklyProgressSpots(habitProvider),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                  maxY: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getWeeklyProgressSpots(HabitProvider habitProvider) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dayHabits = habitProvider.getTodayHabits(date);
      final completed = dayHabits.where((h) => h.isCompletedOn(date)).length;
      final percentage = dayHabits.isNotEmpty ? (completed / dayHabits.length * 100) : 0.0;
      spots.add(FlSpot(i.toDouble(), percentage));
    }
    return spots;
  }

  Widget _buildAchievementsSection(HabitProvider habitProvider, bool isDarkMode) {
    final achievements = _getAchievements(habitProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Conquistas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      color: achievement['earned'] 
                          ? (isDarkMode ? Colors.amber.withOpacity(0.2) : Colors.amber.shade50)
                          : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              achievement['icon'],
                              color: achievement['earned'] 
                                  ? Colors.amber 
                                  : Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              achievement['title'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: achievement['earned']
                                    ? (isDarkMode ? Colors.amber[300] : Colors.amber[700])
                                    : Colors.grey,
                              ),
                            ),
                            Text(
                              achievement['description'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                color: achievement['earned']
                                    ? (isDarkMode ? Colors.amber[400] : Colors.amber[600])
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getAchievements(HabitProvider habitProvider) {
    final habits = habitProvider.habits;
    int longestStreak = 0;
    int totalCompletions = 0;
    
    for (var habit in habits) {
      final streak = habit.calculateCurrentStreak();
      if (streak > longestStreak) longestStreak = streak;
      totalCompletions += habit.completionDates.length;
    }

    return [
      {
        'title': 'Primeira Semana',
        'description': '7 dias seguidos',
        'icon': Icons.looks_one,
        'earned': longestStreak >= 7,
      },
      {
        'title': 'Guerreiro',
        'description': '30 dias seguidos',
        'icon': Icons.shield,
        'earned': longestStreak >= 30,
      },
      {
        'title': 'Centurião',
        'description': '100 conclusões',
        'icon': Icons.military_tech,
        'earned': totalCompletions >= 100,
      },
      {
        'title': 'Multitarefas',
        'description': '5+ hábitos',
        'icon': Icons.category,
        'earned': habits.length >= 5,
      },
    ];
  }

  Widget _buildTopHabitsSection(HabitProvider habitProvider, bool isDarkMode) {
    final sortedHabits = List<Habit>.from(habitProvider.habits);
    sortedHabits.sort((a, b) => b.calculateCurrentStreak().compareTo(a.calculateCurrentStreak()));
    final topHabits = sortedHabits.take(3).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hábitos em Destaque',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            ...topHabits.asMap().entries.map((entry) {
              final index = entry.key;
              final habit = entry.value;
              final streak = habit.calculateCurrentStreak();
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? Colors.grey[800]?.withOpacity(0.3)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: index == 0 
                        ? Colors.amber 
                        : (isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                    width: index == 0 ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: index == 0 
                            ? Colors.amber 
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            '$streak dias seguidos',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, HabitProvider habitProvider, bool isDarkMode, {bool isToday = false, bool isSelected = false}) {
    final dayHabits = habitProvider.getTodayHabits(day);
    final completedHabits = dayHabits.where((h) => h.isCompletedOn(day)).length;
    final totalHabits = dayHabits.length;
    
    Color? backgroundColor;
    if (totalHabits > 0) {
      final ratio = completedHabits / totalHabits;
      if (ratio == 1.0) {
        backgroundColor = Colors.green.withOpacity(0.8);
      } else if (ratio >= 0.5) {
        backgroundColor = Colors.orange.withOpacity(0.6);
      } else {
        backgroundColor = Colors.red.withOpacity(0.4);
      }
    }

    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected 
            ? Colors.blue.withOpacity(0.8)
            : backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: isToday 
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: (backgroundColor != null || isSelected) 
                ? Colors.white 
                : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayDetails(HabitProvider habitProvider, DateTime selectedDay, bool isDarkMode) {
    final dayHabits = habitProvider.getTodayHabits(selectedDay);
    final completedHabits = dayHabits.where((h) => h.isCompletedOn(selectedDay)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalhes - ${DateFormat('dd/MM/yyyy').format(selectedDay)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            if (dayHabits.isEmpty)
              Text(
                'Nenhum hábito programado para este dia.',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              )
            else ...[
              Text(
                'Progresso: ${completedHabits.length}/${dayHabits.length} hábitos concluídos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: dayHabits.isNotEmpty ? completedHabits.length / dayHabits.length : 0,
                backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  completedHabits.length == dayHabits.length 
                      ? Colors.green 
                      : Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              ...dayHabits.map((habit) {
                final isCompleted = habit.isCompletedOn(selectedDay);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? (isDarkMode ? Colors.green.withOpacity(0.2) : Colors.green.shade50)
                        : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted 
                          ? Colors.green 
                          : (isDarkMode ? Colors.grey[600]! : Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isCompleted ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          habit.name,
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionPieChart(HabitProvider habitProvider, bool isDarkMode) {
    final today = DateTime.now();
    final todayHabits = habitProvider.getTodayHabits(today);
    final completed = todayHabits.where((h) => h.isCompletedOn(today)).length;
    final pending = todayHabits.length - completed;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conclusão de Hoje',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: todayHabits.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum hábito para hoje',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.green,
                            value: completed.toDouble(),
                            title: '$completed\nConcluídos',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.orange,
                            value: pending.toDouble(),
                            title: '$pending\nPendentes',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitsBarChart(HabitProvider habitProvider, bool isDarkMode) {
    final habits = habitProvider.habits;
    if (habits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sequências por Hábito',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  backgroundColor: Colors.transparent,
                  alignment: BarChartAlignment.spaceAround,
                  maxY: habits.map((h) => h.calculateCurrentStreak().toDouble()).reduce((a, b) => a > b ? a : b) + 5,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < habits.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                habits[value.toInt()].name.length > 8
                                    ? '${habits[value.toInt()].name.substring(0, 8)}...'
                                    : habits[value.toInt()].name,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: habits.asMap().entries.map((entry) {
                    final index = entry.key;
                    final habit = entry.value;
                    final streak = habit.calculateCurrentStreak();
                    
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: streak.toDouble(),
                          color: streak >= 30 
                              ? Colors.green 
                              : streak >= 7 
                                  ? Colors.orange 
                                  : Colors.blue,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedStats(HabitProvider habitProvider, bool isDarkMode) {
    final habits = habitProvider.habits;
    
    // Calcular estatísticas detalhadas
    int totalCompletions = 0;
    int totalPossibleDays = 0;
    Map<String, int> frequencyCount = {};
    
    for (var habit in habits) {
      totalCompletions += habit.completionDates.length;
      
      // Contar dias possíveis baseado na frequência
      switch (habit.frequency) {
        case HabitFrequency.daily:
          totalPossibleDays += 30; // Aproximação para último mês
          break;
        case HabitFrequency.specificDays:
          totalPossibleDays += habit.specificDays.length * 4; // 4 semanas
          break;
        case HabitFrequency.xTimesPerWeek:
          totalPossibleDays += habit.xTimesCount * 4; // 4 semanas
          break;
      }
      
      // Contar tipos de frequência
      final freqKey = habit.frequency.toString().split('.').last;
      frequencyCount[freqKey] = (frequencyCount[freqKey] ?? 0) + 1;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatísticas Detalhadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.headlineLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total de Conclusões:', '$totalCompletions', Icons.check_circle),
            _buildStatRow('Taxa de Conclusão:', '${totalPossibleDays > 0 ? (totalCompletions / totalPossibleDays * 100).toStringAsFixed(1) : 0}%', Icons.timeline),
            _buildStatRow('Hábitos Diários:', '${frequencyCount['daily'] ?? 0}', Icons.today),
            _buildStatRow('Hábitos Semanais:', '${frequencyCount['specificDays'] ?? 0}', Icons.date_range),
            _buildStatRow('Média por Dia:', '${habits.isNotEmpty ? (totalCompletions / habits.length / 30).toStringAsFixed(1) : 0}', Icons.analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
} 