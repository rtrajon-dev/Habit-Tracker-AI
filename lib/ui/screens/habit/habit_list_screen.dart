import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit/providers/habit_providers.dart';
import 'package:habit/ui/screens/habit/habit_edit_screen.dart';
import 'package:habit/providers/auth_providers.dart';

import 'habit_suggestions_screen.dart';

class HabitListScreen extends ConsumerStatefulWidget {
  const HabitListScreen({super.key});

  @override
  ConsumerState<HabitListScreen> createState() => _HabitListScreenState();
}

class _HabitListScreenState extends ConsumerState<HabitListScreen> {
  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Health',
    'Study',
    'Fitness',
    'Productivity',
    'Mental Health',
    'Others',
  ];

  @override
  Widget build(BuildContext context) {
    final habitsAsync = ref.watch(habitsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Habits"),
        elevation: 0,
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCategory,
              items: categories.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(
                    c == 'All' ? 'Category: All' : c,
                    style: TextStyle(
                      fontSize: c == 'All' ? 14 : 16, // smaller for default
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: c == selectedCategory ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() => selectedCategory = val!);
              },
              icon: Icon(
                Icons.filter_list,
                color: isDark ? Colors.white : Colors.black87,
              ),
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HabitEditScreen()),
          );
        },
        backgroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: habitsAsync.when(
        data: (habits) {
          final filtered = selectedCategory == 'All'
              ? habits
              : habits.where((h) => h.category == selectedCategory).toList();

          // In your HabitListScreen build method, when habitsAsyncValue.when data callback:

// ... previous code for filtering habits ...

          if (filtered.isEmpty) {
            final bool showingAllCategories = selectedCategory == 'All';
            final String titleText = showingAllCategories
                ? "Your Habit Slate is Clean!"
                : "No habits in '$selectedCategory' yet.";
            final String messageText = showingAllCategories
                ? "Ready to build some amazing habits?\nTap the '+' button below to add your first one, or explore AI suggestions for inspiration!"
                : "Try a different category or add new habits to '$selectedCategory'.";

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0), // Increased padding for more space
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Engaging Illustration ---
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3), // Softer background
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        showingAllCategories ? Icons.auto_awesome_outlined : Icons.search_off_rounded, // Dynamic icon
                        size: 80,
                        color: theme.colorScheme.primary, // Use primary theme color
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Header ---
                    Text(
                      titleText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith( // Slightly larger, more impactful
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color?.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Informative & Action-Oriented Text ---
                    Text(
                      messageText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith( // Clearer for body text here
                        color: theme.hintColor, // Use hintColor for a softer look
                        height: 1.6, // Improved line spacing
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Optional: A Clear Call to Action (if not solely relying on FAB) ---
                    if (showingAllCategories) // Only show this extra button if viewing all categories
                      ElevatedButton.icon(
                        icon: const Icon(Icons.explore_outlined),
                        label: const Text("Explore AI Suggestions"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          // Navigate to your AI Habit Suggestions Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HabitSuggestionsScreen()), // Make sure this is your correct screen
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }

// ... rest of your ListView.builder for when filteredHabits is NOT empty ...




          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (_, index) {
              final habit = filtered[index];
              return Card(
                color: isDark ? Colors.grey[850] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isDark ? 1 : 3,
                child: ListTile(
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  title: Text(
                    habit.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${habit.category} • ${habit.frequency}",
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.black54,
                        ),
                      ),
                      if (habit.description != null &&
                          habit.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            habit.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? Colors.grey[300]
                                  : Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: isDark ? Colors.blue[300] : Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HabitEditScreen(habit: habit),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: isDark ? Colors.red[300] : Colors.red),
                        onPressed: () async {
                          final user = ref.read(userProvider).value;
                          if (user != null) {
                            await ref
                                .read(firestoreServiceProvider)
                                .deleteHabit(user.uid, habit.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () =>
        const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(
          child: Text(
            "Error: $err",
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }
}
