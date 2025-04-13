import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth_provider.dart';
import './screens/login_screen.dart';
import './screens/home_screen.dart';
import './screens/splash_screen.dart'; // A simple loading screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider creates and provides the AuthProvider instance
    return ChangeNotifierProvider(
      create: (ctx) => AuthProvider(),
      child: MaterialApp(
        title: 'Field Inspection App',
        theme: ThemeData(
          primarySwatch: Colors.blue, // Or your preferred color scheme
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo), // Modern color scheme
          useMaterial3: true, // Enable Material 3 features
           inputDecorationTheme: InputDecorationTheme( // Consistent input styling
             border: OutlineInputBorder(
               borderRadius: BorderRadius.circular(8),
             ),
             focusedBorder: OutlineInputBorder(
               borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
               borderRadius: BorderRadius.circular(8),
             ),
           ),
            elevatedButtonTheme: ElevatedButtonThemeData( // Consistent button styling
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(8),
                 ),
              ),
            )
        ),
        home: const AuthWrapper(), // Use a wrapper to handle auth state
         // Define routes for navigation later if needed
         // routes: {
         //   '/home': (ctx) => HomeScreen(),
         //   // other routes
         // },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  // Use late initialization for the future
  late Future<void> _authFuture;

  @override
  void initState() {
    super.initState();
    // Start the auto-login process ONCE when this widget is first created
    // Use listen: false here as it's called outside the build method
    _authFuture = Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the AuthProvider for changes
    final authProvider = context.watch<AuthProvider>();

    return FutureBuilder(
      // Use the future initialized in initState
      future: _authFuture,
      builder: (ctx, authResultSnapshot) {
        // Show splash screen while waiting for auto-login to complete
        if (authResultSnapshot.connectionState == ConnectionState.waiting || !authProvider.isInitialized) {
          return const SplashScreen(); // Simple screen with a loading indicator
        } else {
          // Auto-login attempt finished, check login status
          if (authProvider.isLoggedIn) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        }
      },
    );
  }
}