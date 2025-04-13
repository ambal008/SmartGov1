import 'package:image_picker/image_picker.dart'; // For image files
import 'package:geolocator/geolocator.dart'; // For Position

enum ReportStatus { Pending, Submitted, Approved, Rejected, Syncing }

class Report {
  final String? id; // Nullable for new reports before submission
  final String schoolName;
  final String observations;
  final DateTime inspectionDate;
  final Position? location; // Captured geo-location
  final List<XFile>? imageFiles; // Temporary storage for images during creation
  final List<String>? imageUrls; // URLs after upload
  final ReportStatus status;
  final String officerId; // ID of the officer submitting

  Report({
    this.id,
    required this.schoolName,
    required this.observations,
    required this.inspectionDate,
    this.location,
    this.imageFiles, // Used during creation
    this.imageUrls, // Used after submission/fetching
    this.status = ReportStatus.Pending, // Default status
    required this.officerId,
  });

  // Example: Factory constructor for creating from JSON (useful for API responses)
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String?,
      schoolName: json['schoolName'] as String? ?? 'N/A',
      observations: json['observations'] as String? ?? '',
      inspectionDate:
          json['inspectionDate'] != null
              ? DateTime.parse(json['inspectionDate'] as String)
              : DateTime.now(), // Provide a default or handle error
      location:
          json['latitude'] != null && json['longitude'] != null
              ? Position(
                latitude: (json['latitude'] as num).toDouble(),
                longitude: (json['longitude'] as num).toDouble(),
                timestamp:
                    json['inspectionDate'] != null
                        ? DateTime.parse(json['inspectionDate'] as String)
                        : DateTime.now(), // Use inspection date or current
                accuracy: 0.0, // Not usually available from simple storage
                altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
                altitudeAccuracy: 0.0,
                heading: 0.0,
                headingAccuracy: 0.0,
                speed: 0.0,
                speedAccuracy: 0.0,
              )
              : null,
      imageUrls:
          (json['imageUrls'] as List<dynamic>?)
              ?.map((item) => item as String)
              .toList(),
      status: _parseStatus(json['status'] as String?),
      officerId: json['officerId'] as String? ?? 'Unknown',
    );
  }

  // Example: Method to convert to JSON (useful for API requests)
  Map<String, dynamic> toJson() {
    // Note: XFile images are not directly serializable to JSON.
    // They need to be handled separately during upload (e.g., multipart request).
    return {
      'id': id,
      'schoolName': schoolName,
      'observations': observations,
      'inspectionDate': inspectionDate.toIso8601String(),
      'latitude': location?.latitude,
      'longitude': location?.longitude,
      'altitude': location?.altitude,
      // 'imageUrls': imageUrls, // Only include if relevant for submission context
      'status': status.name, // Convert enum to string
      'officerId': officerId,
    };
  }

  // Helper to parse status string (add more robust parsing if needed)
  static ReportStatus _parseStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'submitted':
        return ReportStatus.Submitted;
      case 'approved':
        return ReportStatus.Approved;
      case 'rejected':
        return ReportStatus.Rejected;
      case 'syncing':
        return ReportStatus.Syncing;
      case 'pending':
      default:
        return ReportStatus.Pending;
    }
  }
}
