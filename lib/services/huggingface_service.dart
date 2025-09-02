import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/habit_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HuggingFaceService {
  static final String huggingFaceToken = dotenv.env['HUGGINGFACE_API_KEY'] ?? "";
  static final String apiKey = huggingFaceToken;

  static const String apiUrl =
      "https://api-inference.huggingface.co/models/distilgpt2"; // or any model
  // "https://api-inference.huggingface.co/models/distilgpt2";


  // Static fallback AI-style habits
  static final List<HabitModel> staticAiHabits = [
    HabitModel(
      id: "ai1",
      title: "Meditation 10 min",
      category: "Mental Health",
      frequency: "Daily",
      description: "Practice mindfulness for 10 minutes every morning.",
    ),
    HabitModel(
      id: "ai2",
      title: "Journaling",
      category: "Productivity",
      frequency: "Daily",
      description: "Write down thoughts and goals to stay organized.",
    ),
    HabitModel(
      id: "ai3",
      title: "Stretching",
      category: "Fitness",
      frequency: "Daily",
      description: "Do a 5-minute stretch session after waking up.",
    ),
  ];

  static Future<List<HabitModel>> fetchSuggestedHabits(
      Map<String, dynamic> userProfile) async {
    try {
      final prompt =
          "Suggest 3-5 habits for a user with profile: ${jsonEncode(userProfile)}. "
          "Return JSON array with: title, category, frequency, description.";

      // Wrap with AllOrigins proxy
      // final proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(apiUrl)}";
      // final proxyUrl = "https://corsproxy.io/?url=${Uri.encodeComponent(apiUrl)}";
      final proxyUrl = "https://corsproxy.io/?url=${Uri.encodeComponent(apiUrl)}";

      // final proxyUrl = "https://api.allorigins.win/raw?url=${Uri.encodeComponent(apiUrl)}";

      // final proxyUrl = "https://thingproxy.freeboard.io/fetch/${Uri.encodeComponent(apiUrl)}";
      // final proxyUrl = "https://corsproxy.io/?${Uri.encodeComponent(apiUrl)}";

      final response = await http.post(
        Uri.parse(proxyUrl),
        headers: {
          "Authorization": "Bearer $apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"inputs": prompt}),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // HuggingFace can return list or object
        final text = decoded is List
            ? decoded[0]["generated_text"]
            : decoded["generated_text"];

        // Try parsing JSON text
        final List habitsJson = jsonDecode(text);

        return habitsJson.map((h) {
          return HabitModel(
            id: h["title"] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            title: h["title"] ?? "Untitled",
            category: h["category"] ?? "Others",
            frequency: h["frequency"] ?? "Daily",
            description: h["description"] ?? "",
          );
        }).toList();
      } else {
        print("HuggingFace API error: ${response.statusCode}");
        return staticAiHabits; // fallback
      }
    } catch (e) {
      print("Error fetching HuggingFace: $e");
      return staticAiHabits; // fallback
    }
  }
}
