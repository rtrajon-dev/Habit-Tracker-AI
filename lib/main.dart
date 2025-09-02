import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit/providers/theme_provider.dart';
import 'package:habit/ui/screens/goals_screen.dart';
import 'package:habit/ui/screens/habit/habit_list_screen.dart';
import 'package:habit/ui/screens/habit/habit_suggestions_screen.dart';
import 'package:habit/ui/screens/habit/today_habits_screen.dart';
import 'package:habit/ui/screens/home_screen.dart';
import 'wrappers/auth_wrapper.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  await dotenv.load();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Habit Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeMode, // controlled by ThemeProvider
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => const HomeScreen(),
        '/today-habit' : (context) => const TodayHabitsScreen(),
        '/habit-list': (context) => const HabitListScreen(),
        '/habit-suggestions': (context) => const HabitSuggestionsScreen(),
        '/select-goals' : (context) => const GoalsScreen(),
      },
    );
  }
}
