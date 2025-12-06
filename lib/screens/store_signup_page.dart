import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';

class StoreSignupPage extends StatefulWidget {
  static const String routeName = '/pyramid/auth/signup/store';
  const StoreSignupPage({super.key});

  @override
  State<StoreSignupPage> createState() => _StoreSignupPageState();
}

class _StoreSignupPageState extends State<StoreSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _googleMapsLinkCtrl = TextEditingController();
  final _storeCapacityCtrl = TextEditingController();
  final _cardMarketLinkCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final auth = AuthService();
try {
  final capacityText = _storeCapacityCtrl.text.trim();
  final int? capacity = int.tryParse(capacityText);

  if (capacity == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Store capacity must be a valid number')),
    );
    setState(() => _loading = false);
    return;
  }

  await auth.signupStore(
    _emailCtrl.text.trim(),
    _passwordCtrl.text.trim(),
    _nicknameCtrl.text.trim(),
    _countryCtrl.text.trim(),
    _cityCtrl.text.trim(),
    _googleMapsLinkCtrl.text.trim(),
    capacity, // ahora es int
    _cardMarketLinkCtrl.text.trim(),
  );

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store account created')));
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
    _countryCtrl.dispose();
    _cityCtrl.dispose();
    _googleMapsLinkCtrl.dispose();
    _storeCapacityCtrl.dispose();
    _cardMarketLinkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.35;
    return Scaffold(
      appBar: AppBar(title: const Text('Store Sign Up'), backgroundColor: AppColors.darkBlue),
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
                    const Text('Sign Up (Store)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nicknameCtrl,
                      decoration: const InputDecoration(labelText: 'Store Name', prefixIcon: Icon(Icons.store)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter store name' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _countryCtrl,
                      decoration: const InputDecoration(labelText: 'Country', prefixIcon: Icon(Icons.flag)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter country' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cityCtrl,
                      decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter city' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _googleMapsLinkCtrl,
                      decoration: const InputDecoration(labelText: 'Google Maps Link', prefixIcon: Icon(Icons.map)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter Google Maps link' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _storeCapacityCtrl,
                      decoration: const InputDecoration(labelText: 'Store Capacity', prefixIcon: Icon(Icons.people)),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || v.trim().isEmpty || int.tryParse(v.trim()) == null) ? 'Enter valid capacity' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cardMarketLinkCtrl,
                      decoration: const InputDecoration(labelText: 'CardMarket Link', prefixIcon: Icon(Icons.link)),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter CardMarket link' : null,
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