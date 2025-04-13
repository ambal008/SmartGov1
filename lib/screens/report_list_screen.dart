import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // For date formatting

import '../providers/report_provider.dart';
import '../models/report.dart'; // Import Report model

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  late Future<void> _fetchReportsFuture;

  @override
  void initState() {
    super.initState();
    // Fetch reports when the screen loads - Use listen: false in initState
    _fetchReportsFuture =
        Provider.of<ReportProvider>(context, listen: false).fetchReports();
  }

  // Helper to get status color
  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.Approved:
        return Colors.green.shade100;
      case ReportStatus.Rejected:
        return Colors.red.shade100;
      case ReportStatus.Submitted:
        return Colors.blue.shade100;
      case ReportStatus.Syncing:
        return Colors.orange.shade100;
      case ReportStatus.Pending:
      default:
        return Colors.grey.shade200;
    }
  }

  // Helper to get status icon
  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.Approved:
        return Icons.check_circle_outline;
      case ReportStatus.Rejected:
        return Icons.cancel_outlined;
      case ReportStatus.Submitted:
        return Icons.upload_file_outlined;
      case ReportStatus.Syncing:
        return Icons.sync_outlined;
      case ReportStatus.Pending:
      default:
        return Icons.pending_actions_outlined;
    }
  }

  // Function to refresh reports
  Future<void> _refreshReports(BuildContext context) async {
    await Provider.of<ReportProvider>(context, listen: false).fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Inspections'),
        actions: [
          // Add new report button
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Start New Inspection',
            onPressed: () {
              Navigator.of(context).pushNamed('/new-report');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchReportsFuture,
        builder: (ctx, snapshot) {
          // Check initial loading state based on FutureBuilder
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Use Consumer for subsequent updates and error handling
            return Consumer<ReportProvider>(
              builder: (ctx, reportProvider, child) {
                // Handle errors during fetch
                if (reportProvider.listError != null &&
                    reportProvider.reports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${reportProvider.listError}'),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _refreshReports(context),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Show loading indicator if fetching again via RefreshIndicator
                if (reportProvider.isLoadingList &&
                    reportProvider.reports.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Show message if list is empty
                if (reportProvider.reports.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => _refreshReports(context),
                    child: ListView(
                      // Wrap in ListView to allow refresh even when empty
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ), // Adjust spacing
                        const Center(
                          child: Text('No inspection reports found.'),
                        ),
                        const Center(
                          child: Text('Pull down to refresh or add a new one.'),
                        ),
                      ],
                    ),
                  );
                }

                // Display the list using RefreshIndicator
                return RefreshIndicator(
                  onRefresh: () => _refreshReports(context),
                  child: ListView.builder(
                    itemCount: reportProvider.reports.length,
                    itemBuilder: (ctx, index) {
                      final report = reportProvider.reports[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        elevation: 2,
                        child: ListTile(
                          tileColor: _getStatusColor(report.status),
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).primaryColorLight,
                            child: Icon(
                              _getStatusIcon(report.status),
                              color: Theme.of(context).primaryColorDark,
                            ),
                          ),
                          title: Text(
                            report.schoolName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${report.status.name} on ${DateFormat.yMd().add_jm().format(report.inspectionDate)}', // Format date
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Implement navigation to a Report Detail Screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Tapped on report: ${report.id ?? 'New'}',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      // Floating Action Button (alternative to AppBar action)
      /*
       floatingActionButton: FloatingActionButton(
          onPressed: () {
             Navigator.of(context).pushNamed('/new-report');
          },
          tooltip: 'Start New Inspection',
          child: const Icon(Icons.add),
        ),
        */
    );
  }
}
