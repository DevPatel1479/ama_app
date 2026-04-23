import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String title;
  final String preview;
  final String description;
  final int order;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.title,
    required this.preview,
    required this.description,
    required this.order,
    required this.isActive,
  });

  factory ServiceModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceModel(
      id: doc.id,
      title: data['title'] ?? '',
      preview: data['preview'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }
}
