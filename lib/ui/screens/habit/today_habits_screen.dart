import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodayHabitsScreen extends StatefulWidget {
  final String initialCategory;
  final String initialStatus;

  const TodayHabitsScreen({
    Key? key,
    this.initialCategory = "All",
    this.initialStatus = "All",
  }) : super(key: key);

  @override
  State<TodayHabitsScreen> createState() => _TodayHabitsScreenState();
}

class _TodayHabitsScreenState extends State<TodayHabitsScreen> {
  final _user = FirebaseAuth.instance.currentUser!;
  late String _selectedCategory;
  late String _selectedStatus;

  final List<String> categories = [
    "All",
    "Health",
    "Study",
    "Fitness",
    "Productivity",
    "Mental Health",
    "Others"
  ];

  final List<String> statuses = ["All", "Completed", "Pending"];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedStatus = widget.initialStatus;
  }

  Future<void> _toggleCompletion(String habitId, Map<String, dynamic> habit) async {
    final today = DateTime.now();
    final todayKey = "${today.year}-${today.month}-${today.day}";

    final habitRef = FirebaseFirestore.instance
        .collection("users")
        .doc(_user.uid)
        .collection("habits")
        .doc(habitId);

    final completions = habit['completions'] ?? {};
    final streak = habit['streak'] ?? 0;

    if (completions.containsKey(todayKey)) {
      completions.remove(todayKey);
      await habitRef.update({
        'completions': completions,
        'streak': streak > 0 ? streak - 1 : 0,
      });
    } else {
      completions[todayKey] = true;
      await habitRef.update({
        'completions': completions,
        'streak': streak + 1,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsRef = FirebaseFirestore.instance
        .collection("users")
        .doc(_user.uid)
        .collection("habits");

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Habits"),
        actions: [
          // --- Category Dropdown ---
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCategory,
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(
                    cat == 'All' ? 'Category: All' : cat,
                    style: TextStyle(
                      fontSize: cat == 'All' ? 14 : 16, // smaller for default
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: cat == _selectedCategory ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
              icon: Icon(
                Icons.filter_list,
                color: isDark ? Colors.white : Colors.black87,
              ),
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
            ),
          ),
          const SizedBox(width: 8),

          // --- Status Dropdown ---
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              items: statuses.map((st) {
                return DropdownMenuItem(
                  value: st,
                  child: Text(
                    st == 'All' ? 'Status: All' : st,
                    style: TextStyle(
                      fontSize: st == 'All' ? 14 : 16, // smaller for default
                      color: isDark ? Colors.white : Colors.black87,
                      fontWeight: st == _selectedStatus ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedStatus = val!),
              icon: Icon(
                Icons.check_circle_outline,
                color: isDark ? Colors.white : Colors.black87,
              ),
              dropdownColor: isDark ? Colors.grey[900] : Colors.white,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: habitsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          final docs = snapshot.data!.docs;
          final today = DateTime.now();
          final todayKey = "${today.year}-${today.month}-${today.day}";

          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final category = data['category'] ?? "Others";
            final completions = data['completions'] ?? {};
            final completedToday = completions.containsKey(todayKey);

            final categoryMatch =
                _selectedCategory == "All" || category == _selectedCategory;
            final statusMatch = _selectedStatus == "All" ||
                (_selectedStatus == "Completed" && completedToday) ||
                (_selectedStatus == "Pending" && !completedToday);

            return categoryMatch && statusMatch;
          }).toList();

          // In your TodayHabitsScreen build method, within the StreamBuilder's builder:
// ...
// final filteredDocs = docs.where((doc) { ... }).toList();

          if (filteredDocs.isEmpty) {
            // Determine if it's because of filters or genuinely no habits for today
            final bool isAnyFilterActive = _selectedCategory != "All" || _selectedStatus != "All";

            String titleText;
            String messageText;
            IconData iconData;

            if (isAnyFilterActive) {
              titleText = "No habits match your filters for today! 🧐";
              messageText = "Try adjusting the category or status filters, or check back later if habits are scheduled for a different time.";
              iconData = Icons.filter_alt_off_outlined;
            } else {
              titleText = "Nothing on your plate for today! ափ"; // Coffee cup emoji
              messageText = "Looks like a fresh start! Add habits via the 'Habits' page or get some AI-powered ideas to kickstart your journey.";
              iconData = Icons.coffee_outlined; // Using a coffee cup for a 'fresh start' / 'break' vibe
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0), // More breathing room
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Engaging Illustration ---
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withOpacity(0.4), // Softer, distinct background
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        iconData, // Dynamic icon
                        size: 72, // Slightly smaller than previous iteration, adjust as needed
                        color: theme.colorScheme.onSecondaryContainer.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- Header ---
                    Text(
                      titleText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleLarge?.color?.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Informative Text ---
                    Text(
                      messageText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.hintColor,
                        height: 1.55, // Good line spacing
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Action Buttons ---
                    // Conditionally show buttons or a single primary action if filters are active
                    if (!isAnyFilterActive) ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.list_alt_rounded),
                        label: const Text("Manage My Habits"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "/habit-list");
                        },
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon( // Changed to OutlinedButton for visual hierarchy
                        icon: Icon(Icons.auto_awesome_outlined, color: theme.colorScheme.secondary),
                        label: Text("Get AI Suggestions", style: TextStyle(color: theme.colorScheme.secondary)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.colorScheme.secondary.withOpacity(0.7), width: 1.5),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, "/habit-suggestions");
                        },
                      ),
                    ] else ...[
                      // If filters are active, maybe just a button to clear filters or go to habits
                      ElevatedButton(
                        onPressed: () {
                          setState(() { // Assuming _selectedCategory and _selectedStatus are state variables
                            _selectedCategory = "All";
                            _selectedStatus = "All";
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Clear Filters & Refresh"),
                      ),
                    ]
                  ],
                ),
              ),
            );
          }

// ... rest of your StreamBuilder logic for when filteredDocs is NOT empty




          // Summary
          final total = filteredDocs.length;
          final completed = filteredDocs
              .where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final completions = data['completions'] ?? {};
            return completions.containsKey(todayKey);
          })
              .length;
          final pending = total - completed;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: isDark ? Colors.grey[850] : Colors.deepPurple.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _summaryCard("Total", total, theme.colorScheme.primary),
                    _summaryCard("Completed", completed, Colors.green),
                    _summaryCard("Pending", pending, Colors.red),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final completions = data['completions'] ?? {};
                    final completedToday = completions.containsKey(todayKey);
                    final streak = data['streak'] ?? 0;

                    return Card(
                      color: isDark ? Colors.grey[850] : Colors.white,
                      elevation: isDark ? 1 : 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        title: Text(
                          data['title'] ?? "",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "${data['category']} • Streak: $streak",
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.black54,
                          ),
                        ),
                        trailing: Checkbox(
                          value: completedToday,
                          onChanged: (_) => _toggleCompletion(doc.id, data),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
