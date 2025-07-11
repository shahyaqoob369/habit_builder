import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:habit_builder/common/color_extensions.dart';
import 'package:habit_builder/screens/login/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Hide status bar and navigation buttons for full-screen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    load();
  }

  void load() async {
    await Future.delayed(const Duration(seconds: 3));

    loadNextScreen();
  }

  void loadNextScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()),
      (_) => false,
    );
  }

  @override
  void dispose() {
    // Restore system UI when leaving the splash screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/img/splash_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 40), // Adjust padding from top
              Text(
                "WELCOME TO\nMONUMENTAL\nHABITS",
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColor.primaryText,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
