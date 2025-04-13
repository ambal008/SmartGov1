import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          // Logout Button remains the same
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(ctx).pop(); // Close the dialog
                          },
                        ),
                        TextButton(
                          child: const Text('Logout'),
                          onPressed: () {
                            Navigator.of(ctx).pop(); // Close the dialog
                            Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            ).logout();
                          },
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome, Field Officer!',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.list_alt),
              label: const Text('View My Inspections'),
              onPressed: () {
                // Navigate using named route
                Navigator.of(context).pushNamed('/report-list');
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Start New Inspection'),
              onPressed: () {
                // Navigate using named route
                Navigator.of(context).pushNamed('/new-report');
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- The Logout Dialog Code (keep as before) ---
// showDialog(
//   context: context,
//   builder: (ctx) => AlertDialog(
//     title: const Text('Logout'),
//     content: const Text('Are you sure you want to logout?'),
//     actions: <Widget>[
//       TextButton(
//         child: const Text('Cancel'),
//         onPressed: () {
//           Navigator.of(ctx).pop(); // Close the dialog
//         },
//       ),
//       TextButton(
//         child: const Text('Logout'),
//         onPressed: () {
//           Navigator.of(ctx).pop(); // Close the dialog
//           Provider.of<AuthProvider>(context, listen: false).logout();
//         },
//       ),
//     ],
//   ),
// );
