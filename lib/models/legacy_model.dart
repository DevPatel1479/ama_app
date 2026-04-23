class LegacyModel {
  final String title;
  final String subtitle;
  final String description;
  final String imgUrl;

  LegacyModel({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imgUrl,
  });

  factory LegacyModel.fromDoc(doc) {
    return LegacyModel(
      title: doc['title'],
      subtitle: doc['subtitle'],
      description: doc['description'],
      imgUrl: doc['img_url'],
    );
  }
}
