import 'dart:async';
import 'package:ama_legal_solutions/models/legacy_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LegacyProvider extends ChangeNotifier {
  final List<LegacyModel> _items = [];
  List<LegacyModel> get items => _items;

  bool _loading = true;
  bool get loading => _loading;

  StreamSubscription? _sub;

  void init() {
    _sub?.cancel();

    _sub = FirebaseFirestore.instance
        .collection('our_legacy')
        .snapshots()
        .listen((snap) {
          final newList = snap.docs.map((d) => LegacyModel.fromDoc(d)).toList();

          // prevent unnecessary rebuild
          if (_items.length == newList.length) {
            bool same = true;
            for (int i = 0; i < _items.length; i++) {
              if (_items[i].title != newList[i].title) {
                same = false;
                break;
              }
            }
            if (same) {
              _loading = false;
              return;
            }
          }

          _items
            ..clear()
            ..addAll(newList);

          _loading = false;
          notifyListeners();
        });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
