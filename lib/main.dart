import 'package:flutter/material.dart';
import 'package:habit_builder/common/color_extensions.dart';
import 'package:habit_builder/common/globe.dart';
import 'package:habit_builder/screens/login/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Globe.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "manrope",
        scaffoldBackgroundColor: AppColor.bg,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: AppColor.primary,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColor.primary),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
