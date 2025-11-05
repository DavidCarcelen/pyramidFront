import 'package:flutter/material.dart';

class SignupChoicePage extends StatelessWidget {
  static const String routeName = '/pyramid/auth/signup';

  const SignupChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sign up as:',
                    style: textStyle ?? const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/pyramid/auth/signup/player');
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                    child: const Text('Player'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/pyramid/auth/signup/store');
                    },
                    style: ElevatedButton.styleFrom(minimumSize: const Size(200, 50)),
                    child: const Text('Store'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
