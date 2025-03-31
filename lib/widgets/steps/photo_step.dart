import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/flood_report.dart';

class PhotoStep extends StatefulWidget {
  final Photo photo;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final Function(File) setImageFile;

  const PhotoStep({
    Key? key,
    required this.photo,
    required this.onNext,
    required this.onBack,
    required this.setImageFile,
  }) : super(key: key);

  @override
  State<PhotoStep> createState() => _PhotoStepState();
}

class _PhotoStepState extends State<PhotoStep> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _errorMessage;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // If we already have a photo path, try to load it
    if (widget.photo.filePath != null) {
      _imageFile = File(widget.photo.filePath!);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _isProcessing = true;
          _errorMessage = null;
        });

        final File file = File(pickedFile.path);
        
        // Simulate processing the image
        await Future.delayed(const Duration(seconds: 2));
        
        // Create metadata
        final PhotoMetadata metadata = PhotoMetadata(
          timestamp: DateTime.now().toIso8601String(),
          hasGeotag: true,
          resolution: '1800x1800',
          isWaterDetected: true,
        );

        setState(() {
          _imageFile = file;
          widget.photo.filePath = file.path;
          widget.photo.preview = file.path;
          widget.photo.metadata = metadata;
          _isProcessing = false;
        });

        widget.setImageFile(file);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: ${e.toString()}';
        _isProcessing = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      widget.photo.filePath = null;
      widget.photo.preview = null;
      widget.photo.metadata = null;
    });
  }

  bool _canProceed() {
    return widget.photo.isValid() && !_isProcessing;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Photo Evidence',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide a photo of the flooding to help authorities assess the situation.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (_imageFile == null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.photo_camera,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No photo selected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please take a photo or select one from your gallery',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.file(
                          _imageFile!,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.7),
                          child: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            onPressed: _removeImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Processing image...'),
                        ],
                      ),
                    )
                  else if (widget.photo.metadata != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Image Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildMetadataItem(
                            'Timestamp',
                            DateTime.parse(widget.photo.metadata!.timestamp!).toString(),
                            Icons.access_time,
                            true,
                          ),
                          _buildMetadataItem(
                            'Geolocation',
                            widget.photo.metadata!.hasGeotag! ? 'Available' : 'Not available',
                            Icons.location_on,
                            widget.photo.metadata!.hasGeotag!,
                          ),
                          _buildMetadataItem(
                            'Resolution',
                            widget.photo.metadata!.resolution!,
                            Icons.high_quality,
                            true,
                          ),
                          _buildMetadataItem(
                            'Water Detection',
                            widget.photo.metadata!.isWaterDetected! ? 'Detected' : 'Not detected',
                            Icons.water_drop,
                            widget.photo.metadata!.isWaterDetected!,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Back'),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _canProceed() ? widget.onNext : null,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Next'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(String title, String value, IconData icon, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}

