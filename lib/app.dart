import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'state/app_controller.dart';
import 'theme.dart';

class ReThinkApp extends StatelessWidget {
  const ReThinkApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Re-think',
      theme: rethinkTheme(),
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (!controller.settings.onboardingComplete) {
            return OnboardingScreen(controller: controller);
          }
          return HomeScreen(controller: controller);
        },
      ),
    );
  }
}
