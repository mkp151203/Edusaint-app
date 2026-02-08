import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const EdusaintApp(),
    ),
  );
}

class EdusaintApp extends StatelessWidget {
  const EdusaintApp({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<ThemeProvider>().primaryColor;

    return MaterialApp(
      title: 'Edusaint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: const Color(0xFFF4F6FF),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
