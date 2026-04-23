class LeadingOrganisationModel {
  final String url;
  final int order;
  final bool active;

  LeadingOrganisationModel({
    required this.url,
    required this.order,
    required this.active,
  });

  factory LeadingOrganisationModel.fromDoc(doc) {
    return LeadingOrganisationModel(
      url: doc['url'],
      order: doc['order'],
      active: doc['active'],
    );
  }
}
