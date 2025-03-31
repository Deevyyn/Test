class FloodReport {
  Location location;
  Description description;
  Photo photo;
  String? reportId;
  DateTime timestamp;

  FloodReport({
    required this.location,
    required this.description,
    required this.photo,
    this.reportId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'description': description.toJson(),
      'photo': photo.toJson(),
      'reportId': reportId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory FloodReport.fromJson(Map<String, dynamic> json) {
    return FloodReport(
      location: Location.fromJson(json['location']),
      description: Description.fromJson(json['description']),
      photo: Photo.fromJson(json['photo']),
      reportId: json['reportId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Location {
  double? latitude;
  double? longitude;
  String? address;
  bool useGPS;

  Location({
    this.latitude,
    this.longitude,
    this.address,
    required this.useGPS,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'useGPS': useGPS,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      useGPS: json['useGPS'],
    );
  }

  bool isValid() {
    if (useGPS) {
      return latitude != null && longitude != null;
    } else {
      return address != null && address!.trim().isNotEmpty;
    }
  }
}

enum SeverityLevel { low, medium, high }

class Description {
  SeverityLevel severity;
  String details;

  Description({
    required this.severity,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'severity': severity.toString().split('.').last,
      'details': details,
    };
  }

  factory Description.fromJson(Map<String, dynamic> json) {
    return Description(
      severity: SeverityLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['severity'],
        orElse: () => SeverityLevel.medium,
      ),
      details: json['details'],
    );
  }

  bool isValid() {
    return details.trim().isNotEmpty;
  }
}

class PhotoMetadata {
  String? timestamp;
  bool? hasGeotag;
  String? resolution;
  bool? isWaterDetected;

  PhotoMetadata({
    this.timestamp,
    this.hasGeotag,
    this.resolution,
    this.isWaterDetected,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'hasGeotag': hasGeotag,
      'resolution': resolution,
      'isWaterDetected': isWaterDetected,
    };
  }

  factory PhotoMetadata.fromJson(Map<String, dynamic> json) {
    return PhotoMetadata(
      timestamp: json['timestamp'],
      hasGeotag: json['hasGeotag'],
      resolution: json['resolution'],
      isWaterDetected: json['isWaterDetected'],
    );
  }
}

class Photo {
  String? filePath;
  String? downloadUrl;
  String? preview;
  PhotoMetadata? metadata;

  Photo({
    this.filePath,
    this.downloadUrl,
    this.preview,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'filePath': filePath,
      'downloadUrl': downloadUrl,
      'preview': preview,
      'metadata': metadata?.toJson(),
    };
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      filePath: json['filePath'],
      downloadUrl: json['downloadUrl'],
      preview: json['preview'],
      metadata: json['metadata'] != null
          ? PhotoMetadata.fromJson(json['metadata'])
          : null,
    );
  }

  bool isValid() {
    return filePath != null && filePath!.isNotEmpty;
  }
}

