import 'dart:async';
import 'package:ama_legal_solutions/models/image_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RealtimeImageProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;
  String _imgType = "home";
  String get imgType => _imgType;

  List<ImageModel> _images = [];
  bool _isLoading = true;
  String? _error;
  Map<String, List<ImageModel>> imagesByType = {};
  List<ImageModel> get images => _images;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenImages(String type) {
    // 🔥 If already listening to same type → DO NOTHING
    if (_imgType == type && _subscription != null) return;

    _imgType = type;

    // 🔥 ONLY show loading if no cached data
    if (!(imagesByType[type]?.isNotEmpty ?? false)) {
      _isLoading = true;
      notifyListeners();
    }

    _subscription?.cancel();

    _subscription = _firestore
        .collection("images")
        .doc(type)
        .snapshots()
        .listen(
          (snapshot) {
            if (!snapshot.exists) {
              _images = [];
              imagesByType[type] = [];
              _isLoading = false;
              notifyListeners();
              return;
            }

            final data = snapshot.data();
            final List list = data?['urls'] ?? [];

            final newImages = list.map((e) => ImageModel.fromJson(e)).toList()
              ..sort((a, b) => a.priority.compareTo(b.priority));

            _images = newImages;
            imagesByType[type] = newImages;

            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
