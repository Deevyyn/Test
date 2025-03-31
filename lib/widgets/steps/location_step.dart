import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart'; // Fixed geolocator import
import '../../models/flood_report.dart';
import '../../services/location_service.dart';

class LocationStep extends StatefulWidget {
  final Location location;
  final VoidCallback onNext;

  // Fixed constructor syntax
  const LocationStep({
    super.key, // Correct super.key usage
    required this.location,
    required this.onNext,
  }); // Added missing semicolon

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  final LocationService _locationService = LocationService();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // ... rest of the code remains the same ...
  @override
  void initState() {
    super.initState();
    _addressController.text = widget.location.address ?? '';
    
    if (widget.location.useGPS) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Position? position = await _locationService.getCurrentLocation();
      
      if (position != null) {
        setState(() {
          widget.location.latitude = position.latitude;
          widget.location.longitude = position.longitude;
          
          // Get address from coordinates
          _getAddressFromCoordinates(position.latitude, position.longitude);
        });
      } else {
        setState(() {
          _errorMessage = 'Unable to get location. Please check your permissions or enter address manually.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final String? address = await _locationService.getAddressFromCoordinates(
        latitude,
        longitude,
      );
      
      setState(() {
        widget.location.address = address;
        _addressController.text = address ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleLocationMethod() {
    setState(() {
      widget.location.useGPS = !widget.location.useGPS;
      
      if (widget.location.useGPS) {
        _getCurrentLocation();
      }
    });
  }

  bool _canProceed() {
    return widget.location.isValid() && !_isLoading;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where is the flooding?',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide the location of the flood you are reporting.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Location Method',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                      ),
                      Switch(
                        value: widget.location.useGPS,
                        onChanged: (_) => _toggleLocationMethod(),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                      Text(
                        widget.location.useGPS ? 'GPS' : 'Manual',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.location.useGPS) ...[
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (widget.location.latitude != null && widget.location.longitude != null) ...[
                      ListTile(
                        leading: const Icon(Icons.location_on),
                        title: const Text('GPS Coordinates'),
                        subtitle: Text(
                          'Lat: ${widget.location.latitude!.toStringAsFixed(6)}, Lng: ${widget.location.longitude!.toStringAsFixed(6)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _getCurrentLocation,
                        ),
                      ),
                      if (widget.location.address != null)
                        ListTile(
                          leading: const Icon(Icons.home),
                          title: const Text('Address'),
                          subtitle: Text(widget.location.address!),
                        ),
                    ] else if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.my_location),
                        label: const Text('Get Current Location'),
                      ),
                  ] else ...[
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter the location address',
                        prefixIcon: Icon(Icons.home),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        setState(() {
                          widget.location.address = value;
                        });
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
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
    );
  }
}

