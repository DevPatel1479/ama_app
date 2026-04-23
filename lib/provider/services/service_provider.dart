import 'package:ama_legal_solutions/models/services_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ServicesProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ServiceModel> _services = [];
  bool _loading = true;

  List<ServiceModel> get services => _services;
  bool get loading => _loading;

  ServicesProvider() {
    _listenServices();
  }

  void _listenServices() {
    _db
        .collection('services')
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .listen((snapshot) {
          _services = snapshot.docs
              .map((doc) => ServiceModel.fromDoc(doc))
              .toList();
          _loading = false;
          notifyListeners();
        });
  }
}
