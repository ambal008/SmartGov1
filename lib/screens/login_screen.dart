import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return; // Invalid inputs
    }
    _formKey.currentState!.save(); // Triggers onSaved

    // Use listen: false inside callbacks/functions
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.login(
      _usernameController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success && mounted) { // Check if the widget is still in the tree
        final errorMessage = authProvider.errorMessage ?? 'An unknown error occurred.';
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text(errorMessage),
             backgroundColor: Theme.of(context).colorScheme.error,
           ),
         );
    }
    // No need for navigation here, main.dart's Consumer will handle it
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer here if you need to react to loading state for the button
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Field Inspection Login'),
      ),
      body: Center(
        child: SingleChildScrollView( // Prevents overflow on small screens
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                 const Icon(Icons.security_update_good, size: 80, color: Colors.blueAccent), // App Icon
                 const SizedBox(height: 30),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username (Email)',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your username';
                    }
                    // Basic email format check (can be improved)
                    if (!value.contains('@') || !value.contains('.')) {
                       return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                   decoration: InputDecoration(
                     labelText: 'Password',
                     prefixIcon: const Icon(Icons.lock_outline),
                     border: const OutlineInputBorder(),
                     suffixIcon: IconButton(
                       icon: Icon(
                         _obscurePassword ? Icons.visibility_off : Icons.visibility,
                       ),
                       onPressed: () {
                         setState(() {
                           _obscurePassword = !_obscurePassword;
                         });
                       },
                     ),
                   ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                     if (value.length < 6) { // Example length check
                       return 'Password must be at least 6 characters';
                     }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _submit,
                         style: ElevatedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(vertical: 15),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(8),
                           ),
                         ),
                        child: const Text('Login', style: TextStyle(fontSize: 16)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}