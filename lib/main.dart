// Copyright (c) 2025 ANUBHAV KUMAR. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.
// Verified Author Code: 11508

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..loadUserData(),
      child: MaterialApp(
        title: 'Suvichar',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const AppInitializer(),
      ),
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        // Show loading while checking authentication
        if (userProvider.user.phone.isEmpty) {
          return FutureBuilder(
            future: Future.delayed(const Duration(milliseconds: 500)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // Check if user is authenticated AND has completed onboarding
                if (userProvider.isAuthenticated && userProvider.user.isOnboardingComplete) {
                  return const MainScreen();
                } else {
                  return const WelcomeScreen();
                }
              }
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6A1B9A),
                  ),
                ),
              );
            },
          );
        }

        // Check if user is authenticated AND has completed onboarding
        if (userProvider.isAuthenticated && userProvider.user.isOnboardingComplete) {
          return const MainScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
