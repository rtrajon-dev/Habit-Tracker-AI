import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit/models/habit_model.dart';
import 'package:habit/models/user_model.dart';
import 'package:habit/services/firestore_service.dart';
import 'package:habit/services/cohere_service.dart';

class HabitSuggestionsScreen extends StatefulWidget {
  const HabitSuggestionsScreen({Key? key}) : super(key: key);

  @override
  State<HabitSuggestionsScreen> createState() => _HabitSuggestionsScreenState();
}

class _HabitSuggestionsScreenState extends State<HabitSuggestionsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  List<HabitModel> suggestedHabits = [];
  String? error;

  UserModel? _userProfile;

  @override
  void initState() {
    super.initState();
    loadUserProfileAndSuggestions();
  }

  Future<void> loadUserProfileAndSuggestions() async {
    setState(() {
      isLoading = true;
      error = null;
      suggestedHabits = [];
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      // Fetch user profile from Firestore
      final userProfile = await _firestoreService.getUserProfile(userId);
      if (userProfile == null) {
        throw Exception("User profile not found");
      }
      setState(() => _userProfile = userProfile);

      // Prepare data for AI suggestions
      final Map<String, dynamic> userProfileMap = {
        "age": DateTime.now().year - userProfile.dob.year,
        "gender": userProfile.gender,
        "goals": userProfile.goals,
      };

      // Fetch suggested habits from Cohere API
      final habits = await CohereService.fetchSuggestedHabits(userProfileMap);

      setState(() {
        suggestedHabits = habits;
        isLoading = false;
        if (habits.isEmpty) error = "No suggestions available";
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        error = "Failed to load suggestions. Try again.\n$e";
      });
    }
  }

  Future<void> addHabitToFirestore(HabitModel habit) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestoreService.addHabit(userId, habit);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${habit.title} added!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Habit Suggestions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload Suggestions',
            onPressed: loadUserProfileAndSuggestions,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : suggestedHabits.isEmpty
          ? Center(
        child: Text(
          error ?? "No suggestions available",
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: suggestedHabits.length,
        itemBuilder: (context, index) {
          final habit = suggestedHabits[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            color: isDark ? Colors.grey[850] : Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                habit.title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: habit.description != null
                  ? Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  "${habit.category} | ${habit.frequency}\n${habit.description}",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                  ),
                ),
              )
                  : Text(
                "${habit.category} | ${habit.frequency}",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Colors.grey[300]
                      : Colors.grey[700],
                ),
              ),
              isThreeLine: habit.description != null,
              trailing: IconButton(
                icon: const Icon(
                  Icons.add_circle,
                  color: Colors.green,
                  size: 28,
                ),
                tooltip: 'Add to My Habits',
                onPressed: () => addHabitToFirestore(habit),
              ),
            ),
          );
        },
      ),
    );
  }
}
