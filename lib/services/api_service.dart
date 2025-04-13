// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:io'; // For HttpStatus
import 'package:http/http.dart' as http; // If making real calls

class ApiService {
  // --- Mock Implementation ---
  Future<String> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simple mock check (Replace with actual API call later)
    if (username == 'test@gov.in' && password == 'password123') {
      // Simulate a successful login returning a token
      return 'dummy_auth_token_${DateTime.now().millisecondsSinceEpoch}';
    } else {
      // Simulate a login failure
      throw Exception('Invalid username or password');
    }
  }

  // --- Real Implementation Placeholder (Commented out) ---
  /*
  final String _baseUrl = "YOUR_BACKEND_API_URL"; // Replace with your actual URL

  Future<String> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login'); // Example endpoint
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'email': username, // Assuming backend expects email
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Assuming backend returns JSON like {"token": "your_jwt_token"}
        final responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        if (token != null && token is String) {
          return token;
        } else {
          throw Exception('Token not found in response');
        }
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        // Handle specific errors based on backend response body if available
         final responseBody = jsonDecode(response.body);
         final message = responseBody['message'] ?? 'Invalid credentials';
        throw Exception(message);
      }
       else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } on SocketException {
       throw Exception('No Internet connection');
    } catch (e) {
      // Rethrow other exceptions or handle them
      throw Exception('Login failed: ${e.toString()}');
    }
  }
  */

  // Mock logout (doesn't need to do much for mock)
  Future<void> logout(String token) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    print("Logged out with token: $token");
    // In a real scenario, you might call a backend endpoint to invalidate the token
    return;
  }
}