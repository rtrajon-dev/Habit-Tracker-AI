import 'dart:convert';
import 'package:habit/models/habit_model.dart';
import 'package:http/http.dart' as http;

class CohereService {
  // 🔑 Replace with your Cohere trial or production API key
  static const String _apiKey = "HtRU41uw5eEduhi2miqx52HCxoQa8atatBVaaiah";
  static const String _endpoint = "https://api.cohere.ai/generate";

  // Offline fallback habits
  static final List<HabitModel> _fallbackHabits = [
    HabitModel(
      id: "f1",
      title: "Morning Meditation",
      category: "Mental Health",
      frequency: "Daily",
      description: "Practice 10 minutes of meditation every morning.",
    ),
    HabitModel(
      id: "f2",
      title: "Study 1 hour",
      category: "Study",
      frequency: "Daily",
      description: "Focus on studying a chosen subject for 1 hour daily.",
    ),
    HabitModel(
      id: "f3",
      title: "Workout",
      category: "Fitness",
      frequency: "Weekly",
      description: "Exercise at least 3 times a week for 30 minutes.",
    ),
  ];

  /// Fetch AI-generated habit suggestions from Cohere
  static Future<List<HabitModel>> fetchSuggestedHabits(Map<String, dynamic> userProfile) async {
    try {
      final prompt = """
Suggest 3-5 healthy habits for the following profile:
${jsonEncode(userProfile)}

Format the output strictly as a JSON array:
[
  {"title": "Habit Title", "category": "Health/Study/etc", "frequency": "Daily/Weekly", "description": "Short description"},
  ...
]
""";

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "command", // Deprecated, but works for trial; future: migrate to Chat API
          "prompt": prompt,
          "max_tokens": 300,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>?;
        print("Cohere API raw response: $data");

        // Use 'text' directly instead of 'generations'
        final text = data?['text'] as String?;
        if (text != null && text.isNotEmpty) {
          try {
            final List parsed = jsonDecode(text);
            return parsed.map((h) {
              return HabitModel(
                id: h['title'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: h['title'] ?? "Untitled",
                category: h['category'] ?? "Others",
                frequency: h['frequency'] ?? "Daily",
                description: h['description'] ?? "",
              );
            }).toList();
          } catch (e) {
            print("Error parsing JSON from AI output: $e");
            return _fallbackHabits;
          }
        } else {
          print("Cohere API returned empty text.");
          return _fallbackHabits;
        }
      } else {
        print("Cohere API error: ${response.statusCode} - ${response.body}");
        return _fallbackHabits;
      }
    } catch (e) {
      print("Error fetching Cohere habits: $e");
      return _fallbackHabits;
    }
  }
}
