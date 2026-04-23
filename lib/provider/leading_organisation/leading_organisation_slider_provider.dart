import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LeadingOrganisationSliderProvider extends ChangeNotifier {
  final List<String> _images = [];
  List<String> get images => _images;

  bool _loading = true;
  bool get loading => _loading;

  StreamSubscription? _sub;

  void init() {
    _sub?.cancel();

    _sub = FirebaseFirestore.instance
        .collection('leading_organisation')
        .where('active', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .listen((snapshot) {
          final newImages = snapshot.docs
              .map((d) => d['url'] as String)
              .toList();

          // 🔥 Prevent unnecessary rebuilds (important for smooth UI)
          if (_images.length == newImages.length &&
              _images.every((e) => newImages.contains(e))) {
            _loading = false;
            return;
          }

          _images
            ..clear()
            ..addAll(newImages);

          _loading = false;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _sub?.cancel(); // 🔥 prevent memory leak
    super.dispose();
  }
}
