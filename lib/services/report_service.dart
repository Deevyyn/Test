import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/flood_report.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  Future<String?> uploadImage(File file) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final Reference storageRef = _storage.ref().child('flood_images/$fileName');
      
      final UploadTask uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  Future<String?> submitReport(FloodReport report, File? imageFile) async {
    try {
      // Upload image if available
      if (imageFile != null) {
        final String? downloadUrl = await uploadImage(imageFile);
        if (downloadUrl != null) {
          report.photo.downloadUrl = downloadUrl;
        }
      }
      
      // Generate report ID
      final String reportId = _uuid.v4();
      report.reportId = reportId;
      
      // Save to Firestore
      await _firestore.collection('flood_reports').doc(reportId).set(report.toJson());
      
      return reportId;
    } catch (e) {
      return null;
    }
  }
}

