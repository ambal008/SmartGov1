import 'dart:io'; // For File type for image preview
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // For formatting date display

import '../providers/report_provider.dart';
import '../services/location_service.dart'; // We'll create this helper service

class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _schoolNameController = TextEditingController();
  final _observationsController = TextEditingController();
  final LocationService _locationService = LocationService(); // Location helper
  final ImagePicker _picker = ImagePicker(); // Image picker instance

  Position? _currentPosition;
  bool _isFetchingLocation = false;
  String? _locationError;

  final List<XFile> _selectedImages = []; // Store selected image files

  @override
  void dispose() {
    _schoolNameController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  // --- Get Location Method ---
  Future<void> _getLocation() async {
    setState(() {
      _isFetchingLocation = true;
      _locationError = null;
    });
    try {
      final position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _isFetchingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString().replaceFirst('Exception: ', '');
        _isFetchingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $_locationError')),
        );
      }
    }
  }

  // --- Pick Image Method ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Reduce quality slightly to save space
        maxWidth: 1024, // Optional: Limit image width
      );

      if (pickedFile != null) {
        setState(() {
          // Limit the number of images if desired (e.g., max 5)
          if (_selectedImages.length < 5) {
            _selectedImages.add(pickedFile);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Maximum 5 images allowed.')),
            );
          }
        });
      }
    } catch (e) {
      print("Image picker error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  // --- Remove Image ---
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // --- Submit Report Method ---
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't submit if form is invalid
    }
    // Optional: Check if location is captured
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture location before submitting.'),
        ),
      );
      return;
    }
    // Optional: Check if at least one image is added
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one photo.')),
      );
      return;
    }

    _formKey.currentState!.save(); // Trigger onSaved if needed

    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    final success = await reportProvider.submitNewReport(
      schoolName: _schoolNameController.text.trim(),
      observations: _observationsController.text.trim(),
      inspectionDate: DateTime.now(), // Use current time for submission
      location: _currentPosition,
      images: _selectedImages,
    );

    if (mounted) {
      // Check if widget is still active
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Optionally clear form fields here if staying on the page
        // setState(() {
        //    _schoolNameController.clear();
        //    _observationsController.clear();
        //    _currentPosition = null;
        //    _selectedImages.clear();
        // });
        Navigator.of(
          context,
        ).pop(); // Go back to the previous screen (Report List)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit report: ${reportProvider.submitError ?? 'Unknown error'}',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider =
        context.watch<ReportProvider>(); // Watch for loading state

    return Scaffold(
      appBar: AppBar(title: const Text('Start New Inspection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- School Name ---
              TextFormField(
                controller: _schoolNameController,
                decoration: const InputDecoration(
                  labelText: 'School/Site Name',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the school/site name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // --- Observations ---
              TextFormField(
                controller: _observationsController,
                decoration: const InputDecoration(
                  labelText: 'Observations / Notes',
                  prefixIcon: Icon(Icons.notes_outlined),
                  alignLabelWithHint: true, // Good for multiline
                ),
                maxLines: 4, // Allow multiple lines
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your observations';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // --- Location Section ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      if (_isFetchingLocation)
                        const Center(
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        ),
                      if (!_isFetchingLocation && _currentPosition == null)
                        Center(
                          child: Text(
                            _locationError ?? 'Location not captured yet.',
                          ),
                        ),
                      if (_currentPosition != null)
                        Text(
                          'Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, Lon: ${_currentPosition!.longitude.toStringAsFixed(5)} (Acc: ${_currentPosition!.accuracy.toStringAsFixed(1)}m)\nCaptured: ${DateFormat.yMd().add_jm().format(_currentPosition!.timestamp)}', // Add timestamp
                          style: TextStyle(color: Colors.green.shade800),
                        ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.my_location),
                          label: const Text('Capture Current Location'),
                          onPressed:
                              _isFetchingLocation
                                  ? null
                                  : _getLocation, // Disable while fetching
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey.shade50,
                            foregroundColor: Colors.blueGrey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Image Section ---
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photos (Max 5)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      // Image Preview Grid
                      if (_selectedImages.isNotEmpty)
                        GridView.builder(
                          shrinkWrap:
                              true, // Important inside SingleChildScrollView
                          physics:
                              const NeverScrollableScrollPhysics(), // Disable grid scrolling
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3, // Adjust number of columns
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.file(
                                    File(_selectedImages[index].path),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                // Remove button
                                InkWell(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    margin: const EdgeInsets.all(2),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      const SizedBox(height: 10),
                      // Add Image Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                            onPressed: () => _pickImage(ImageSource.camera),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade50,
                              foregroundColor: Colors.teal.shade800,
                            ),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Gallery'),
                            onPressed: () => _pickImage(ImageSource.gallery),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade50,
                              foregroundColor: Colors.purple.shade800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- Submit Button ---
              reportProvider.isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: const Text('Submit Inspection Report'),
                    onPressed: _submitReport,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
