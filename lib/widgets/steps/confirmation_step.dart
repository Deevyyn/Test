import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/flood_report.dart';
import '../../theme/app_theme.dart';

class ConfirmationStep extends StatelessWidget {
  final FloodReport report;
  final File? imageFile;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onBack;
  final Function(int) onEditStep;

  const ConfirmationStep({
    Key? key,
    required this.report,
    required this.imageFile,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onBack,
    required this.onEditStep,
  }) : super(key: key);

  String _getSeverityText(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.low:
        return 'Low - Minor flooding with shallow water';
      case SeverityLevel.medium:
        return 'Medium - Significant flooding affecting roads and properties';
      case SeverityLevel.high:
        return 'High - Severe flooding with deep water and potential danger';
    }
  }

  Color _getSeverityColor(SeverityLevel severity) {
    switch (severity) {
      case SeverityLevel.low:
        return AppTheme.lowSeverityColor;
      case SeverityLevel.medium:
        return AppTheme.mediumSeverityColor;
      case SeverityLevel.high:
        return AppTheme.highSeverityColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Your Report',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Please review your flood report details before submitting.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          // Location Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(width: 8),
                          Text(
                            'Location',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditStep(0),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (report.location.useGPS && report.location.latitude != null) ...[
                    Text(
                      'GPS Coordinates:',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Lat: ${report.location.latitude!.toStringAsFixed(6)}, Lng: ${report.location.longitude!.toStringAsFixed(6)}',
                    ),
                  ],
                  if (report.location.address != null && report.location.address!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Address:',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(report.location.address!),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.description),
                          const SizedBox(width: 8),
                          Text(
                            'Description',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditStep(1),
                      ),
                    ],
                  ),
                  const Divider(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(report.description.severity).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getSeverityColor(report.description.severity),
                          ),
                        ),
                        child: Text(
                          _getSeverityText(report.description.severity),
                          style: TextStyle(
                            color: _getSeverityColor(report.description.severity),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Details:',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(report.description.details),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Photo Card
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.photo),
                          const SizedBox(width: 8),
                          Text(
                            'Photo',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditStep(2),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (imageFile != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(12),
                    ),
                    child: Image.file(
                      imageFile!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text('Submit Report'),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Back Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onBack,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Back'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

