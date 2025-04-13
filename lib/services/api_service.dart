// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // Import XFile
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p; // For getting filename
import '../models/report.dart'; // Import Report model
import 'package:geolocator/geolocator.dart'; // Import Position

class ApiService {
  final String _baseUrl = "YOUR_BACKEND_API_URL"; // Replace later

  // --- Login/Logout remain the same ---
  Future<String> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    if (username == 'test@gov.in' && password == 'password123') {
      return 'dummy_auth_token_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      throw Exception('Invalid username or password');
    }
  }

  Future<void> logout(String token) async {
    await Future.delayed(const Duration(milliseconds: 500));
    print("Logged out with token: $token");
    return;
  }

  // --- Mock Get Reports ---
  Future<List<Report>> getReports(String token) async {
    print("Fetching reports with token: $token");
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // TODO: Replace with actual API call
    // For now, return a static list of mock reports
    return [
      Report(
        id: 'RPT001',
        schoolName: 'Govt. High School, Sample Nagar',
        observations: 'Classrooms clean, toilets need maintenance.',
        inspectionDate: DateTime.now().subtract(const Duration(days: 2)),
        location: Position(
          latitude: 10.7905,
          longitude: 79.1322,
          timestamp: DateTime.now(),
          accuracy: 50.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ), // Approx Thanjavur
        imageUrls: ['https://via.placeholder.com/150/1'],
        status: ReportStatus.Approved,
        officerId: 'Officer1',
      ),
      Report(
        id: 'RPT002',
        schoolName: 'Panchayat Union Middle School, Test Village',
        observations:
            'Teacher attendance good. Mid-day meal quality satisfactory.',
        inspectionDate: DateTime.now().subtract(const Duration(days: 1)),
        location: Position(
          latitude: 10.8000,
          longitude: 79.1400,
          timestamp: DateTime.now(),
          accuracy: 30.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        ),
        imageUrls: [
          'https://via.placeholder.com/150/2',
          'https://via.placeholder.com/150/3',
        ],
        status: ReportStatus.Submitted,
        officerId: 'Officer1',
      ),
      Report(
        id: 'RPT003',
        schoolName: 'Primary School, Anytown',
        observations: 'Awaiting inspection.',
        inspectionDate: DateTime.now(),
        status: ReportStatus.Pending,
        officerId: 'Officer1',
      ),
    ];

    // --- Real Implementation Placeholder ---
    /*
     final url = Uri.parse('$_baseUrl/reports'); // Example endpoint
     try {
       final response = await http.get(
         url,
         headers: {
           'Content-Type': 'application/json',
           'Authorization': 'Bearer $token', // Send auth token
         },
       );

       if (response.statusCode == 200) {
         final List<dynamic> responseData = jsonDecode(response.body);
         return responseData.map((data) => Report.fromJson(data)).toList();
       } else {
         // Handle errors based on status code
         throw Exception('Failed to load reports. Status: ${response.statusCode}');
       }
     } on SocketException {
        throw Exception('No Internet connection');
     } catch (e) {
       throw Exception('Failed to load reports: ${e.toString()}');
     }
     */
  }

  // --- Mock Submit Report ---
  Future<Report> submitReport(
    Report reportData,
    List<XFile> images,
    String token,
  ) async {
    print("Submitting report with token: $token");
    print("Report Data: ${reportData.toJson()}"); // Print JSON data
    print("Number of images: ${images.length}");
    // Simulate network delay and upload process
    await Future.delayed(const Duration(seconds: 3));

    // TODO: Replace with actual multipart API request
    // In a real scenario, you would upload the images and the report data.
    // The backend would save it and return the final saved report object (with an ID).

    // Return a mock response resembling a saved report
    return Report(
      id: 'RPT${DateTime.now().millisecondsSinceEpoch}', // Generate a mock ID
      schoolName: reportData.schoolName,
      observations: reportData.observations,
      inspectionDate: reportData.inspectionDate,
      location: reportData.location,
      imageUrls:
          images
              .map(
                (img) =>
                    'https://via.placeholder.com/150/${DateTime.now().microsecondsSinceEpoch}',
              )
              .toList(), // Mock URLs
      status: ReportStatus.Submitted, // Status after submission
      officerId: reportData.officerId,
    );

    // --- Real Implementation Placeholder (using http multipart request) ---
    /*
    final url = Uri.parse('$_baseUrl/reports'); // Example endpoint
    var request = http.MultipartRequest('POST', url);

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    // Add text fields (report data)
    request.fields['schoolName'] = reportData.schoolName;
    request.fields['observations'] = reportData.observations;
    request.fields['inspectionDate'] = reportData.inspectionDate.toIso8601String();
    request.fields['officerId'] = reportData.officerId;
     if (reportData.location != null) {
       request.fields['latitude'] = reportData.location!.latitude.toString();
       request.fields['longitude'] = reportData.location!.longitude.toString();
       if (reportData.location!.altitude != 0.0) { // Only send if available
         request.fields['altitude'] = reportData.location!.altitude.toString();
       }
     }


    // Add image files
    for (var imageFile in images) {
      var stream = http.ByteStream(imageFile.openRead());
      stream.cast(); // Required for some versions
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'images', // Must match the field name expected by the backend
        stream,
        length,
        filename: p.basename(imageFile.path), // Use path package for filename
      );
      request.files.add(multipartFile);
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
         final responseData = jsonDecode(response.body);
         return Report.fromJson(responseData); // Assuming backend returns the created report
      } else {
         // Handle errors
          print("Error Body: ${response.body}");
         throw Exception('Failed to submit report. Status: ${response.statusCode}');
      }
     } on SocketException {
        throw Exception('No Internet connection');
     } catch (e) {
       throw Exception('Failed to submit report: ${e.toString()}');
     }
     */
  }
}
