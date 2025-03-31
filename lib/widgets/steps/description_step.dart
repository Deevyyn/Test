import 'package:flutter/material.dart';
import '../../models/flood_report.dart';
import '../../theme/app_theme.dart';

class DescriptionStep extends StatefulWidget {
  final Description description;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const DescriptionStep({
    Key? key,
    required this.description,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  State<DescriptionStep> createState() => _DescriptionStepState();
}

class _DescriptionStepState extends State<DescriptionStep> {
  final TextEditingController _detailsController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _detailsController.text = widget.description.details;
  }

  bool _canProceed() {
    return widget.description.isValid();
  }

  Widget _buildSeverityOption(SeverityLevel level, String title, String description, Color color, IconData icon) {
    final isSelected = widget.description.severity == level;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.description.severity = level;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Describe the Flooding',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Please select the severity and provide details about the flood.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text(
            'Severity Level',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          _buildSeverityOption(
            SeverityLevel.low,
            'Low',
            'Minor flooding with shallow water',
            AppTheme.lowSeverityColor,
            Icons.water_drop,
          ),
          const SizedBox(height: 12),
          _buildSeverityOption(
            SeverityLevel.medium,
            'Medium',
            'Significant flooding affecting roads and properties',
            AppTheme.mediumSeverityColor,
            Icons.warning,
          ),
          const SizedBox(height: 12),
          _buildSeverityOption(
            SeverityLevel.high,
            'High',
            'Severe flooding with deep water and potential danger',
            AppTheme.highSeverityColor,
            Icons.dangerous,
          ),
          const SizedBox(height: 24),
          Text(
            'Additional Details',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _detailsController,
            decoration: InputDecoration(
              hintText: 'Describe the flooding situation in detail...',
              errorText: _errorMessage,
            ),
            maxLines: 5,
            onChanged: (value) {
              setState(() {
                widget.description.details = value;
                if (value.trim().isEmpty) {
                  _errorMessage = 'Please provide details about the flooding';
                } else {
                  _errorMessage = null;
                }
              });
            },
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
}

