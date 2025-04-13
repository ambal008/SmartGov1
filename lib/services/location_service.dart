import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      // Consider prompting user to enable services via settings using geolocator's openAppSettings/openLocationSettings
      print('Location services are disabled.'); // Log for debugging
      throw Exception(
        'Location services are disabled. Please enable them in settings.',
      );
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        print('Location permissions are denied.'); // Log
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      print('Location permissions are permanently denied.'); // Log
      throw Exception(
        'Location permissions are permanently denied, we cannot request permissions. Please enable them in app settings.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    print('Fetching current position...'); // Log
    try {
      // Set desired accuracy and timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy.high, // Or medium/low depending on need
        timeLimit: const Duration(seconds: 15), // Add timeout
      );
    } on TimeoutException {
      print('Location request timed out.'); // Log
      throw Exception(
        'Could not get location within the time limit. Please try again.',
      );
    } catch (e) {
      print('Error getting location: $e'); // Log any other errors
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }
}
