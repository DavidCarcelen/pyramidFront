import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class PlayerSignupPage extends StatefulWidget {
  static const String routeName = '/pyramid/auth/signup/player';
  const PlayerSignupPage({super.key});

  @override
  State<PlayerSignupPage> createState() => _PlayerSignupPageState();
}

class _PlayerSignupPageState extends State<PlayerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = AuthService();
    try {
      await auth.signupPlayer(_nicknameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Player account created')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign-up failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.35;
    return Scaffold(
      appBar: AppBar(title: const Text('Player Sign Up'), backgroundColor: AppColors.darkBlue),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width,
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Sign Up (Player)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                      obscureText: true,
                      validator: (v) => (v == null || v.trim().length < 6) ? 'Min 6 chars' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nicknameCtrl,
                      decoration: const InputDecoration(labelText: 'Nickname', prefixIcon: Icon(Icons.person)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter nickname' : null,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.petrol),
                        child: _loading ? const CircularProgressIndicator.adaptive() : const Text('Sign Up'),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}