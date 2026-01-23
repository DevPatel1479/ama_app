class ImageModel {
  final String url;
  final int priority;

  ImageModel({required this.url, required this.priority});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(url: json['url'] ?? '', priority: json['priority'] ?? 0);
  }
}
