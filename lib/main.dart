import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'theme/app_colors.dart';
import 'screens/signup_choice_page.dart';
import 'screens/player_signup_page.dart';
import 'screens/store_signup_page.dart';


void main() {
  runApp(const PyramidApp());
}

class PyramidApp extends StatelessWidget {
  const PyramidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pyramid App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.petrol),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/pyramid/auth/signup': (context) => const SignupChoicePage(),
        '/pyramid/auth/signup/player': (context) => const PlayerSignupPage(),
        '/pyramid/auth/signup/store': (context) => const StoreSignupPage(),
      },
    );
  }
}
