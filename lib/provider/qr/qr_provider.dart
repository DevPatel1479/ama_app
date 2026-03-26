import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QrProvider extends ChangeNotifier {
  String? qrUrl;
  bool isLoading = true;
  String? error;

  Future<void> fetchQr() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final doc = await FirebaseFirestore.instance
          .doc('qr_collection/main_qr') // O(1) direct document fetch
          .get();

      if (doc.exists) {
        qrUrl = doc.data()?['qr_url'];
      } else {
        error = "QR not found";
      }
    } catch (e) {
      error = "Failed to load QR";
    }

    isLoading = false;
    notifyListeners();
  }
}
