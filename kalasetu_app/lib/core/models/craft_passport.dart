class CraftPassport {
  final String listingId;
  final String productName;
  final String artisanName;
  final String location;
  final String? giTag;
  final List<String> materials;
  final List<String> techniques;
  final String verificationUrl;
  final String imageUrl;
  final DateTime createdAt;

  const CraftPassport({
    required this.listingId,
    required this.productName,
    required this.artisanName,
    required this.location,
    this.giTag,
    required this.materials,
    required this.techniques,
    required this.verificationUrl,
    required this.imageUrl,
    required this.createdAt,
  });
}
