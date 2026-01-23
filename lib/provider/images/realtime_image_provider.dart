import 'dart:async';
import 'package:ama_legal_solutions/models/image_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RealtimeImageProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _subscription;

  List<ImageModel> _images = [];
  bool _isLoading = true;
  String? _error;

  List<ImageModel> get images => _images;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void listenImages(String type) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();

    _subscription = _firestore
        .collection("images")
        .doc(type)
        .snapshots()
        .listen(
          (snapshot) {
            if (!snapshot.exists) {
              _images = [];
              _isLoading = false;
              notifyListeners();
              return;
            }

            final data = snapshot.data();
            final List list = data?['urls'] ?? [];

            _images = list.map((e) => ImageModel.fromJson(e)).toList()
              ..sort((a, b) => a.priority.compareTo(b.priority));

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
