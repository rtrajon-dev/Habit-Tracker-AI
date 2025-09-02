// lib/ui/screens/goals_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit/services/firestore_service.dart'; // Assuming you have this
import 'package:firebase_auth/firebase_auth.dart';
// Import your user provider if you need to update it after saving goals
// import 'package:habit/providers/auth_providers.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  // Enhanced default goals with icons for better visual appeal - NOW HABIT FOCUSED
  final List<Map<String, dynamic>> _defaultGoalsData = [
    {"text": "Build Healthy Habits", "icon": Icons.health_and_safety_outlined},
    {"text": "Daily Fitness", "icon": Icons.fitness_center_outlined},
    {"text": "Productive Mornings", "icon": Icons.wb_sunny_outlined},
    {"text": "Mindful Moments", "icon": Icons.self_improvement_outlined},
    {"text": "Learn a New Skill", "icon": Icons.school_outlined},
    {"text": "Consistent Reading", "icon": Icons.menu_book_outlined},
    {"text": "Sleep Hygiene", "icon": Icons.bedtime_outlined},
  ];

  final List<String> _selectedGoals = [];
  final TextEditingController _customGoalController = TextEditingController();
  final FocusNode _customGoalFocusNode = FocusNode();

  bool _saving = false;

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        if (_selectedGoals.length < 5) { // Optional: Limit number of selectable goals
          _selectedGoals.add(goal);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can select up to 5 core habit goals.")),
          );
        }
      }
    });
  }

  Future<void> _saveGoals() async {
    if (_selectedGoals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one goal to personalize your habit journey.")),
      );
      return;
    }

    setState(() => _saving = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirestoreService().saveUserGoals(user.uid, _selectedGoals);
        // Optional: Update local user state if you have a userProvider
        // ref.read(userProvider.notifier).updateUserGoals(_selectedGoals);
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/home");
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save goals: $e")),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _saving = false);
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found. Please try again.")),
        );
        setState(() => _saving = false);
      }
    }
  }

  void _addCustomGoal() {
    final goal = _customGoalController.text.trim();
    if (goal.isNotEmpty) {
      if (!_selectedGoals.contains(goal)) {
        if (_selectedGoals.length < 5) { // Apply same limit
          setState(() {
            _selectedGoals.add(goal);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("You can select up to 5 core habit goals.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("'$goal' is already a selected goal.")),
        );
      }
    }
    _customGoalController.clear();
    _customGoalFocusNode.unfocus(); // Dismiss keyboard
  }

  @override
  void dispose() {
    _customGoalController.dispose();
    _customGoalFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personalize Your Habits"), // Changed
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "What habits are you focusing on?", // Changed
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                "Select a few core goals. This helps us suggest relevant habits and track your progress effectively. (Up to 5)", // Changed
                style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 24),

              // Predefined goals
              Expanded(
                child: ListView(
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _defaultGoalsData.map((goalData) {
                        final String goalText = goalData["text"];
                        final IconData goalIcon = goalData["icon"];
                        final isSelected = _selectedGoals.contains(goalText);

                        return InkWell(
                          onTap: () => _toggleGoal(goalText),
                          borderRadius: BorderRadius.circular(25.0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : theme.cardColor,
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor.withOpacity(0.5),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ] : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  goalIcon,
                                  size: 20,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.iconTheme.color,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  goalText,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer
                                        : theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Add custom goal section
                    Text(
                      "Or, add a specific habit goal:", // Changed
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customGoalController,
                            focusNode: _customGoalFocusNode,
                            decoration: InputDecoration(
                              hintText: "e.g., Drink 8 glasses of water daily", // Changed
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: theme.dividerColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: theme.inputDecorationTheme.fillColor ?? theme.canvasColor,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onSubmitted: (_) => _addCustomGoal(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _addCustomGoal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                          ),
                          child: const Icon(Icons.add_rounded, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Show custom selected goals (if any)
                    if (_selectedGoals.any((g) => !_defaultGoalsData.any((dg) => dg["text"] == g)))
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedGoals
                            .where((g) => !_defaultGoalsData.any((dg) => dg["text"] == g))
                            .map((g) => Chip(
                          label: Text(g, style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          deleteIcon: Icon(Icons.close_rounded, size: 18, color: theme.colorScheme.onSecondaryContainer),
                          onDeleted: () {
                            setState(() {
                              _selectedGoals.remove(g);
                            });
                          },
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ))
                            .toList(),
                      ),
                    const SizedBox(height: 20), // Spacer for FAB
                  ],
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedGoals.isEmpty || _saving ? null : _saveGoals,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      disabledBackgroundColor: theme.disabledColor.withOpacity(0.1),
                      disabledForegroundColor: theme.disabledColor.withOpacity(0.5),
                    ),
                    child: _saving
                        ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                        strokeWidth: 3,
                      ),
                    )
                        : const Text("Start My Habit Journey"), // Changed
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
