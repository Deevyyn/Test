import 'dart:io';
import 'package:flutter/material.dart';
import '../models/flood_report.dart';
import '../widgets/steps/location_step.dart';
import '../widgets/steps/description_step.dart';
import '../widgets/steps/photo_step.dart';
import '../widgets/steps/confirmation_step.dart';
import '../widgets/steps/success_step.dart';
import '../widgets/progress_indicator.dart';
import '../services/report_service.dart';

class WizardScreen extends StatefulWidget {
  const WizardScreen({Key? key}) : super(key: key);

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  final PageController _pageController = PageController();
  final ReportService _reportService = ReportService();
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // Location
    GlobalKey<FormState>(), // Description
    GlobalKey<FormState>(), // Photo
  ];

  int _currentStep = 0;
  bool _isSubmitting = false;
  String? _reportId;
  File? _imageFile;

  final FloodReport _report = FloodReport(
    location: Location(useGPS: true),
    description: Description(severity: SeverityLevel.medium, details: ''),
    photo: Photo(),
  );

  final List<String> _stepTitles = [
    'Location',
    'Description',
    'Photo',
    'Confirmation',
    'Success',
  ];

  void _goToNextStep() {
    if (_currentStep < 4) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    if (step < _currentStep) {
      setState(() => _currentStep = step);
      _pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKeys[0].currentState?.validate() ?? false;
      case 1:
        return _formKeys[1].currentState?.validate() ?? false;
      case 2:
        if (_imageFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please upload a photo')),
          );
          return false;
        }
        return _formKeys[2].currentState?.validate() ?? false;
      default:
        return true;
    }
  }

  Future<void> _submitReport() async {
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final reportId = await _reportService.submitReport(_report, _imageFile!);
      if (!mounted) return;

      setState(() {
        _reportId = reportId;
        _isSubmitting = false;
        _currentStep = 4;
      });
      _pageController.jumpToPage(4);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _setImageFile(File file) => setState(() => _imageFile = file);

  void _resetWizard() {
    setState(() {
      _currentStep = 0;
      _reportId = null;
      _imageFile = null;
      _report.location = Location(useGPS: true);
      _report.description = Description(severity: SeverityLevel.medium, details: '');
      _report.photo = Photo();
    });
    _pageController.jumpToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flood Report'),
        leading: _currentStep > 0 && _currentStep < 4
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goToPreviousStep,
        )
            : null,
      ),
      body: Column(
        children: [
          StepProgressIndicator(
            currentStep: _currentStep,
            stepTitles: _stepTitles,
            onStepTapped: _goToStep,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                LocationStep(
                  key: _formKeys[0],
                  location: _report.location,
                  onNext: _goToNextStep,
                ),
                DescriptionStep(
                  key: _formKeys[1],
                  description: _report.description,
                  onNext: _goToNextStep,
                  onBack: _goToPreviousStep,
                ),
                PhotoStep(
                  key: _formKeys[2],
                  photo: _report.photo,
                  onNext: _goToNextStep,
                  onBack: _goToPreviousStep,
                  setImageFile: _setImageFile,
                ),
                ConfirmationStep(
                  report: _report,
                  imageFile: _imageFile,
                  isSubmitting: _isSubmitting,
                  onSubmit: _submitReport,
                  onBack: _goToPreviousStep,
                  onEditStep: _goToStep,
                ),
                SuccessStep(
                  reportId: _reportId,
                  onSubmitAnother: _resetWizard,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}