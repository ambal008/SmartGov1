import 'package:flutter/material.dart';
import 'package:myapp/screens/new_report_screen.dart';
import 'package:myapp/screens/report_list_screen.dart';
import 'package:provider/provider.dart';

import './providers/auth_provider.dart';
import './providers/report_provider.dart'; // Import ReportProvider
import './screens/login_screen.dart';
import './screens/home_screen.dart';
import './screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MultiProvider to provide both AuthProvider and ReportProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        // ReportProvider depends on AuthProvider, so use ChangeNotifierProxyProvider
        ChangeNotifierProxyProvider<AuthProvider, ReportProvider>(
          create:
              (ctx) =>
                  ReportProvider(Provider.of<AuthProvider>(ctx, listen: false)),
          update: (ctx, auth, previousReportProvider) => ReportProvider(auth),
        ),
      ],
      child: MaterialApp(
        title: 'Field Inspection App',
        theme: ThemeData(
          // Keep your theme settings
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const AuthWrapper(), // AuthWrapper remains the entry point
        // Define routes for easier navigation (optional but good practice)
        routes: {
          '/home': (ctx) => const HomeScreen(),
          '/report-list': (ctx) => const ReportListScreen(),
          '/new-report': (ctx) => const NewReportScreen(),
        },
      ),
    );
  }
}

// AuthWrapper remains the same
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<void> _authFuture;
  @override
  void initState() {
    super.initState();
    _authFuture =
        Provider.of<AuthProvider>(context, listen: false).tryAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return FutureBuilder(
      future: _authFuture,
      builder: (ctx, authResultSnapshot) {
        if (authResultSnapshot.connectionState == ConnectionState.waiting ||
            !authProvider.isInitialized) {
          return const SplashScreen();
        } else {
          if (authProvider.isLoggedIn) {
            return const HomeScreen(); // Go to HomeScreen after login
          } else {
            return const LoginScreen();
          }
        }
      },
    );
  }
}
