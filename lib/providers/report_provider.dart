// For File type if needed later

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../models/report.dart';
import '../services/api_service.dart';
import './auth_provider.dart'; // To get the auth token

class ReportProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthProvider _authProvider; // Receive AuthProvider instance

  List<Report> _reports = [];
  bool _isLoadingList = false;
  String? _listError;

  bool _isSubmitting = false;
  String? _submitError;

  // --- Constructor ---
  ReportProvider(this._authProvider); // Constructor expects AuthProvider

  // --- Getters ---
  List<Report> get reports => [..._reports]; // Return a copy
  bool get isLoadingList => _isLoadingList;
  String? get listError => _listError;
  bool get isSubmitting => _isSubmitting;
  String? get submitError => _submitError;

  // --- Fetch Reports Method ---
  Future<void> fetchReports() async {
    if (_authProvider.token == null) {
      _listError = "Not authenticated.";
      notifyListeners();
      return;
    }

    _isLoadingList = true;
    _listError = null;
    notifyListeners();

    try {
      final fetchedReports = await _apiService.getReports(_authProvider.token!);
      _reports = fetchedReports;
      _isLoadingList = false;
      notifyListeners();
    } catch (error) {
      _listError = error.toString().replaceFirst('Exception: ', '');
      _isLoadingList = false;
      notifyListeners();
    }
  }

  // --- Submit New Report Method ---
  Future<bool> submitNewReport({
    required String schoolName,
    required String observations,
    required DateTime inspectionDate,
    required Position? location,
    required List<XFile> images,
    // required String officerId, // Get officerId from AuthProvider if possible
  }) async {
    if (_authProvider.token == null) {
      _submitError = "Not authenticated.";
      notifyListeners();
      return false;
    }
    // Assume officerId can be derived from the logged-in user (e.g., email or a dedicated ID)
    // Replace 'mockOfficerId' with actual logic if available in AuthProvider
    final String officerId = _authProvider.token!.substring(
      0,
      10,
    ); // Example: derive from token

    _isSubmitting = true;
    _submitError = null;
    notifyListeners();

    final newReportData = Report(
      schoolName: schoolName,
      observations: observations,
      inspectionDate: inspectionDate,
      location: location,
      officerId: officerId, // Add officerId
      // imageFiles are handled separately in the API call
      // imageUrls will be populated by the backend response
      status: ReportStatus.Syncing, // Indicate submission in progress
    );

    try {
      final submittedReport = await _apiService.submitReport(
        newReportData,
        images, // Pass the XFile list
        _authProvider.token!,
      );

      // Add the newly submitted report to the beginning of the list
      _reports.insert(0, submittedReport);
      _isSubmitting = false;
      notifyListeners();
      return true; // Indicate success
    } catch (error) {
      _submitError = error.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false; // Indicate failure
    }
  }
}
