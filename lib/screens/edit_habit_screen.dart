// lib/screens/edit_habit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/models/habit.dart';

class EditHabitScreen extends StatefulWidget {
  final Habit habit; // O hábito a ser editado

  const EditHabitScreen({super.key, required this.habit});

  @override
  State<EditHabitScreen> createState() => _EditHabitScreenState();
}

class _EditHabitScreenState extends State<EditHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController
  _nameController; // Usamos 'late' porque será inicializado no initState

  late HabitFrequency _selectedFrequency;
  DateTime? _selectedReminderTime;
  late bool _notificationsEnabled;

  int _xTimesCount = 1;
  List<int> _selectedSpecificDays = [];

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores e variáveis de estado com os dados do hábito
    _nameController = TextEditingController(text: widget.habit.name);
    _selectedFrequency = widget.habit.frequency;
    _selectedReminderTime = widget.habit.reminderTime;
    _notificationsEnabled = widget.habit.notificationsEnabled;
    _xTimesCount = widget.habit.xTimesCount;
    _selectedSpecificDays = List.from(
      widget.habit.specificDays,
    ); // Cria uma cópia mutável
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      // Cria um novo objeto Habit com os dados atualizados
      final updatedHabit = Habit(
        id: widget.habit.id, // Mantém o ID original do hábito
        name: _nameController.text,
        frequency: _selectedFrequency,
        specificDays: _selectedSpecificDays,
        xTimesCount: _xTimesCount,
        reminderTime: _selectedReminderTime,
        notificationsEnabled: _notificationsEnabled,
        completedDates: widget
            .habit
            .completedDates, // Mantém as datas de conclusão existentes
      );

      // Chama o updateHabit do provider
      Provider.of<HabitProvider>(
        context,
        listen: false,
      ).updateHabit(updatedHabit);

      Navigator.of(context).pop(); // Volta para a tela anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Hábito'), // Título para edição
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveHabit),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Hábito',
                  hintText: 'Ex: Beber água',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do hábito';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Frequência',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              RadioListTile<HabitFrequency>(
                title: const Text('Todos os dias'),
                value: HabitFrequency.daily,
                groupValue: _selectedFrequency,
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                    _selectedSpecificDays = [];
                    _xTimesCount = 1;
                  });
                },
              ),
              RadioListTile<HabitFrequency>(
                title: const Text('Dias específicos'),
                value: HabitFrequency.specificDays,
                groupValue: _selectedFrequency,
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                    _xTimesCount = 1;
                  });
                },
              ),
              RadioListTile<HabitFrequency>(
                title: const Text('X vezes por semana'),
                value: HabitFrequency.xTimesPerWeek,
                groupValue: _selectedFrequency,
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                    _selectedSpecificDays = [];
                  });
                },
              ),

              const SizedBox(height: 20),

              if (_selectedFrequency == HabitFrequency.specificDays)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Escolha os dias da semana:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: List.generate(7, (index) {
                        final dayIndex = index + 1; // 1 = Segunda, 7 = Domingo
                        final dayName = [
                          'Seg',
                          'Ter',
                          'Qua',
                          'Qui',
                          'Sex',
                          'Sáb',
                          'Dom',
                        ][index];
                        final isSelected = _selectedSpecificDays.contains(
                          dayIndex,
                        );

                        return FilterChip(
                          label: Text(dayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSpecificDays.add(dayIndex);
                              } else {
                                _selectedSpecificDays.remove(dayIndex);
                              }
                              _selectedSpecificDays.sort();
                            });
                          },
                          selectedColor: Colors.blue[100],
                          checkmarkColor: Colors.blue,
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                  ],
                )
              else if (_selectedFrequency == HabitFrequency.xTimesPerWeek)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantas vezes por semana?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: _xTimesCount.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de vezes',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _xTimesCount = int.tryParse(value) ?? 1;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira um número';
                        }
                        if (int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Insira um número válido (maior que 0)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Seção de Lembrete
              Text('Lembrete', style: Theme.of(context).textTheme.titleMedium),
              ListTile(
                title: Text(
                  _selectedReminderTime == null
                      ? 'Selecionar Hora'
                      : '${_selectedReminderTime!.hour.toString().padLeft(2, '0')}:${_selectedReminderTime!.minute.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: _selectedReminderTime != null
                        ? TimeOfDay.fromDateTime(_selectedReminderTime!)
                        : TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedReminderTime = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ativar Notificações',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
