import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
// Import ReportListScreen later when created
// import './report_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example of accessing token if needed, though often not displayed directly
    // final token = Provider.of<AuthProvider>(context, listen: false).token;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              // Show confirmation dialog before logging out
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
              label: const Text('View My Reports'),
              onPressed: () {
                // TODO: Navigate to ReportListScreen
                // Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReportListScreen()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Report List Screen not implemented yet.'),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Start New Inspection'),
              onPressed: () {
                // TODO: Navigate to NewReportScreen
                // Navigator.of(context).push(MaterialPageRoute(builder: (_) => NewReportScreen()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New Inspection Screen not implemented yet.'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // Add FloatingActionButton for new report later if desired
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to NewReportScreen
        },
        child: const Icon(Icons.add),
        tooltip: 'Start New Inspection',
      ),
      */
    );
  }
}
