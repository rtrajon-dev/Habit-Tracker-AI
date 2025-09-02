// lib/wrappers/auth_wrapper.dart
import 'package:firebase_auth/firebase_auth.dart' show User; // Import User specifically
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit/providers/auth_providers.dart';
import 'package:habit/ui/screens/auth/auth_screen.dart';
import 'package:habit/ui/screens/goals_screen.dart';
import 'package:habit/ui/screens/home_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen to authStateProvider for login/logout events
    // This is the CRUCIAL part for the fix.
    ref.listen<AsyncValue<User?>>(authStateProvider, (previousState, nextState) {
      final firebaseUser = nextState.value; // Get user from the new state
      if (firebaseUser != null) {
        // User logged in, load their profile. This call is now safe.
        ref.read(userProvider.notifier).loadUserProfile(firebaseUser.uid);
      } else {
        // User logged out, reset user profile data. This call is also safe.
        ref.read(userProvider.notifier).resetState();
      }
    });

    // We still watch authStateProvider and userProvider to build the UI
    final authState = ref.watch(authStateProvider);
    final userProfileState = ref.watch(userProvider);

    return authState.when(
      data: (firebaseUser) {
        if (firebaseUser == null) {
          // No Firebase user (logged out), show AuthScreen
          return const AuthScreen();
        }

        // Firebase user exists, now check our application's userProfileState
        return userProfileState.when(
          data: (userModel) {
            // UserModel from your Firestore (could be null if profile doesn't exist yet)
            if (userModel == null) {
              // This can happen if:
              // 1. Profile is still loading (but userProfileState.isLoading should be true then)
              // 2. Profile genuinely doesn't exist for this authenticated user.
              // We assume if userModel is null and not loading, they need to set goals.
              // A more robust check might be `if (userModel == null && !userProfileState.isLoading)`
              // but if loadUserProfile correctly sets state to data(null) when not found,
              // this should be okay.
              return const GoalsScreen();
            }

            final goals = userModel.goals ?? [];
            if (goals.isEmpty) {
              // Profile exists but no goals set
              return const GoalsScreen();
            }

            // Profile exists and has goals
            return const HomeScreen();
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator(key: Key("UserProfileLoadingIndicator"))),
          ),
          error: (err, stack) => Scaffold(
            body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error loading user profile: $err\n\nPlease try restarting the app.'),
                )
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(key: Key("AuthLoadingIndicator"))),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Authentication Error: $err\n\nPlease check your internet connection and try again.'),
            )
        ),
      ),
    );
  }
}
