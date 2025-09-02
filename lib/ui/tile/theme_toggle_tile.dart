// lib/ui/widgets/theme_toggle_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit/providers/theme_provider.dart';

class ThemeToggleTile extends ConsumerWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final notifier = ref.read(themeProvider.notifier);

    return SwitchListTile(
      title: const Text("Dark Mode"),
      secondary: const Icon(Icons.brightness_6),
      value: themeMode == ThemeMode.dark,
      onChanged: (val) {
        notifier.toggleTheme();
      },
    );
  }
}
