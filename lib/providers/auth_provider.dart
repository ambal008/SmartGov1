import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart'; // Import the ApiService

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService(); // Use your ApiService

  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false; // To track if auto-login attempt finished

  // Getters
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  // --- Login Method ---
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify UI about loading start

    try {
      final fetchedToken = await _apiService.login(username, password);
      _token = fetchedToken;
      await _saveTokenToPrefs(fetchedToken); // Save token locally
      _isLoading = false;
      notifyListeners(); // Notify UI about success
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst(
        'Exception: ',
        '',
      ); // Clean up message
      _isLoading = false;
      notifyListeners(); // Notify UI about error
      return false;
    }
  }

  // --- Logout Method ---
  Future<void> logout() async {
    if (_token != null) {
      try {
        await _apiService.logout(_token!); // Call API logout if needed
      } catch (error) {
        // Handle potential API logout errors if necessary, but proceed locally
        print("API Logout Error (ignoring for local logout): $error");
      }
    }
    _token = null;
    await _clearTokenFromPrefs(); // Clear token locally
    notifyListeners(); // Notify UI
  }

  // --- Auto Login Attempt ---
  Future<void> tryAutoLogin() async {
    _token = await _getTokenFromPrefs();
    if (_token != null) {
      // Optional: Add a check here to verify the token with the backend
      // If verification fails, clear the token and set _token = null
      print("Auto-login successful with stored token.");
    } else {
      print("No stored token found for auto-login.");
    }
    _isInitialized = true; // Mark initialization complete
    notifyListeners(); // Update UI based on whether token was found
  }

  // --- Helper Methods for SharedPreferences ---
  Future<void> _saveTokenToPrefs(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    print("Token saved to prefs.");
  }

  Future<String?> _getTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    print("Token retrieved from prefs: ${token != null}");
    return token;
  }

  Future<void> _clearTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    print("Token cleared from prefs.");
  }
}
