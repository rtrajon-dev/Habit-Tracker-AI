import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class HabitChartScreen extends StatelessWidget {
  const HabitChartScreen({super.key});

  Stream<Map<String, int>> _getWeeklyCompletionData() {
    final user = FirebaseAuth.instance.currentUser!;
    final today = DateTime.now();

    // Prepare keys for last 7 days including today
    final List<String> last7DaysKeys = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return DateFormat('EEE').format(day);
    });

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("habits")
        .snapshots()
        .map((snapshot) {
      // Initialize counts with 0
      final Map<String, int> completionCounts =
      {for (var key in last7DaysKeys) key: 0};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data["completionDates"] != null) {
          for (var ts in List.from(data["completionDates"])) {
            final date = (ts as Timestamp).toDate();
            final dayKey = DateFormat('EEE').format(date);

            // Count only if within last 7 days including today
            if (last7DaysKeys.contains(dayKey)) {
              completionCounts[dayKey] = (completionCounts[dayKey] ?? 0) + 1;
            }
          }
        }
      }

      return completionCounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Habit Completion Chart")),
      body: StreamBuilder<Map<String, int>>(
        stream: _getWeeklyCompletionData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final keys = data.keys.toList();
          final values = data.values.toList();
          final maxY = (values.isNotEmpty ? values.reduce((a, b) => a > b ? a : b) : 1).toDouble() + 1;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < keys.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              keys[value.toInt()],
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  keys.length,
                      (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i].toDouble(),
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(6),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
