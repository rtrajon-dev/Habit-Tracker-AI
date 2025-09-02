import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit/models/habit_model.dart';
import 'package:habit/providers/habit_providers.dart';
import 'package:habit/providers/auth_providers.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  final HabitModel? habit;
  const HabitEditScreen({super.key, this.habit});

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _descriptionController;

  String category = 'Health';
  String frequency = 'Daily';
  DateTime? startDate;

  final List<String> categories = [
    'Health',
    'Study',
    'Fitness',
    'Productivity',
    'Mental Health',
    'Others'
  ];

  final List<String> frequencies = ['Daily', 'Weekly'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit?.title ?? '');
    _notesController = TextEditingController(text: widget.habit?.notes ?? '');
    _descriptionController = TextEditingController(text: widget.habit?.description ?? '');
    category = widget.habit?.category ?? 'Health';
    frequency = widget.habit?.frequency ?? 'Daily';
    startDate = widget.habit?.startDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final user = ref.watch(userProvider).value;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not loaded')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit == null ? 'Add Habit' : 'Edit Habit'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                ),
                validator: (v) => v!.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                ),
                items: categories
                    .map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c),
                ))
                    .toList(),
                onChanged: (v) => setState(() => category = v!),
              ),
              const SizedBox(height: 16),

              // Frequency
              DropdownButtonFormField<String>(
                value: frequency,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                ),
                items: frequencies
                    .map((f) => DropdownMenuItem(
                  value: f,
                  child: Text(f),
                ))
                    .toList(),
                onChanged: (v) => setState(() => frequency = v!),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Short description of this habit',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                ),
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'Save Habit',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final habit = HabitModel(
                      id: widget.habit?.id ?? '',
                      title: _titleController.text,
                      category: category,
                      frequency: frequency,
                      startDate: startDate,
                      description: _descriptionController.text.isEmpty
                          ? null
                          : _descriptionController.text,
                      notes: _notesController.text.isEmpty
                          ? null
                          : _notesController.text,
                    );

                    if (widget.habit == null) {
                      await ref
                          .read(firestoreServiceProvider)
                          .addHabit(user.uid, habit);
                    } else {
                      await ref
                          .read(firestoreServiceProvider)
                          .updateHabit(user.uid, habit);
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
