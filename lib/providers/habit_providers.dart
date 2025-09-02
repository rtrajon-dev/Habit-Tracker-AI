import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit/models/habit_model.dart';
import 'package:habit/providers/auth_providers.dart';
import 'package:habit/services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

final habitsProvider = StreamProvider<List<HabitModel>>((ref) {
  final user = ref.watch(userProvider).value;
  if (user != null) {
    return ref.watch(firestoreServiceProvider).getHabits(user.uid);
  }
  return const Stream.empty();
});
