// lib/screens/add_habit_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habit_tracker_app/providers/habit_provider.dart';
import 'package:habit_tracker_app/models/habit.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  List<int> _selectedDays = [];
  int _xTimesCount = 1;
  DateTime? _reminderTime;
  bool _notificationsEnabled = false;

  final List<String> _dayNames = [
    'Segunda-feira',
    'Terça-feira', 
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Hábito'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nome do Hábito
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome do Hábito',
                  hintText: 'Ex: Beber água, Ler livro, Exercitar-se',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, insira um nome para o hábito';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Frequência
              const Text(
                'Frequência',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              
              // Opções de Frequência
              Column(
                children: [
                  RadioListTile<HabitFrequency>(
                    title: const Text('Diariamente'),
                    value: HabitFrequency.daily,
                    groupValue: _selectedFrequency,
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequency = value!;
                        _selectedDays.clear();
                      });
                    },
                  ),
                  RadioListTile<HabitFrequency>(
                    title: const Text('Dias específicos da semana'),
                    value: HabitFrequency.specificDays,
                    groupValue: _selectedFrequency,
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequency = value!;
                        _selectedDays.clear();
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
                        _selectedDays.clear();
                      });
                    },
                  ),
                ],
              ),
              
              // Dias específicos (se selecionado)
              if (_selectedFrequency == HabitFrequency.specificDays) ...[
                const SizedBox(height: 10),
                const Text(
                  'Selecione os dias:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8.0,
                  children: List.generate(7, (index) {
                    final dayIndex = index + 1; // 1 = Monday, 7 = Sunday
                    final isSelected = _selectedDays.contains(dayIndex);
                    return FilterChip(
                      label: Text(_dayNames[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedDays.add(dayIndex);
                          } else {
                            _selectedDays.remove(dayIndex);
                          }
                        });
                      },
                    );
                  }),
                ),
              ],
              
              // X vezes por semana (se selecionado)
              if (_selectedFrequency == HabitFrequency.xTimesPerWeek) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Quantas vezes por semana:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<int>(
                      value: _xTimesCount,
                      items: List.generate(7, (index) {
                        final count = index + 1;
                        return DropdownMenuItem(
                          value: count,
                          child: Text('$count'),
                        );
                      }),
                      onChanged: (value) {
                        setState(() {
                          _xTimesCount = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Lembretes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications, color: Colors.orange),
                          const SizedBox(width: 8),
                          const Text(
                            'Lembretes',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        title: const Text('Ativar notificações'),
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                            if (!value) {
                              _reminderTime = null;
                            }
                          });
                        },
                      ),
                      if (_notificationsEnabled) ...[
                        const SizedBox(height: 10),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            _reminderTime != null
                                ? 'Lembrete às ${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                                : 'Definir horário do lembrete',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: _selectReminderTime,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Botão Salvar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Salvar Hábito',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null 
          ? TimeOfDay.fromDateTime(_reminderTime!)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _reminderTime = DateTime(2023, 1, 1, picked.hour, picked.minute);
      });
    }
  }

  void _saveHabit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validações específicas
    if (_selectedFrequency == HabitFrequency.specificDays && _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecione pelo menos um dia da semana'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_notificationsEnabled && _reminderTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, defina um horário para o lembrete'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Criar o hábito
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    final newHabit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      frequency: _selectedFrequency,
      specificDays: _selectedFrequency == HabitFrequency.specificDays 
          ? List.from(_selectedDays)
          : [],
      xTimesCount: _selectedFrequency == HabitFrequency.xTimesPerWeek 
          ? _xTimesCount 
          : 0,
      reminderTime: _notificationsEnabled ? _reminderTime : null,
      reminderEnabled: _notificationsEnabled,
    );

    habitProvider.addHabit(newHabit);

    // Feedback de sucesso
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hábito "${newHabit.name}" criado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );

    // Voltar para a tela anterior
    Navigator.of(context).pop();
  }
}
