import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habit/ui/screens/habit/habit_chart_screen.dart';
import 'package:habit/ui/screens/habit/habit_list_screen.dart';
import 'package:habit/ui/screens/habit/habit_suggestions_screen.dart';
import 'package:habit/ui/screens/profile_screen.dart';
import 'package:habit/ui/screens/habit/today_habits_screen.dart';
import 'package:habit/ui/screens/quotes_screen.dart';
import 'package:habit/ui/tile/theme_toggle_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final _user = FirebaseAuth.instance.currentUser!;
  String displayName = "Loading...";
  String email = "";

  // Bottom navigation pages
  final List<Widget> _pages = [
    const TodayHabitsScreen(),
    const HabitListScreen(),
    const QuotesScreen(),
    const HabitSuggestionsScreen(),
    const ProfileScreen(),
  ];

  final List<String> _titles = [
    "Today's Habits",
    "Habits",
    "Quotes",
    "AI Habit Suggestions",
    "Profile",
  ];

  @override
  void initState() {
    super.initState();
    email = _user.email ?? "";
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(_user.uid)
          .get();
      final data = doc.data();
      setState(() {
        displayName = data?["name"] ?? "Unknown User";
        email = data?["email"] ?? email;
      });
    } catch (e) {
      setState(() {
        displayName = "Unknown User";
      });
      debugPrint("Error fetching user data: $e");
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(displayName),
              accountEmail: Text(email),
              currentAccountPicture: CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(Icons.person,
                    size: 40, color: theme.colorScheme.onSecondaryContainer),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.deepPurple.shade700, Colors.purple.shade900]
                      : [Colors.deepPurple, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            _drawerItem(
              icon: Icons.today,
              text: "Today's Habits",
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            _drawerItem(
              icon: Icons.task_alt,
              text: "Habits",
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            _drawerItem(
              icon: Icons.favorite,
              text: "Quotes",
              onTap: () {
                _onItemTapped(2);
                Navigator.pop(context);
              },
            ),
            _drawerItem(
              icon: Icons.auto_awesome,
              text: "AI Habit Suggestions",
              onTap: () {
                _onItemTapped(3);
                Navigator.pop(context);
              },
            ),
            _drawerItem(
              icon: Icons.person,
              text: "Profile",
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
            _drawerItem(
              icon: Icons.bar_chart,
              text: "Progress Chart",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HabitChartScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            const ThemeToggleTile(),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout",
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.disabledColor,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: "Habits"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Quotes"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: "AI"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(text, style: TextStyle(color: theme.colorScheme.onSurface)),
      onTap: onTap,
    );
  }
}
