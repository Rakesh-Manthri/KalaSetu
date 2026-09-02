/// Product Listing Model for KalaSetu artisan catalog
class ProductListing {
  final String id;
  final String title;
  final String craftCategory;
  final double price;
  final String imageUrl;
  final String? localRawImagePath;
  final String? montageUrl;
  final String description;
  final bool isGiCertified;
  final String artisanName;
  final DateTime createdAt;

  ProductListing({
    required this.id,
    required this.title,
    required this.craftCategory,
    required this.price,
    required this.imageUrl,
    this.localRawImagePath,
    this.montageUrl,
    required this.description,
    this.isGiCertified = false,
    required this.artisanName,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'craftCategory': craftCategory,
        'price': price,
        'imageUrl': imageUrl,
        'localRawImagePath': localRawImagePath,
        'montageUrl': montageUrl,
        'description': description,
        'isGiCertified': isGiCertified,
        'artisanName': artisanName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ProductListing.fromJson(Map<String, dynamic> json) => ProductListing(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        craftCategory: json['craftCategory'] ?? 'Handloom & Handicraft',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: json['imageUrl'] ?? '',
        localRawImagePath: json['localRawImagePath'],
        montageUrl: json['montageUrl'],
        description: json['description'] ?? '',
        isGiCertified: json['isGiCertified'] == true,
        artisanName: json['artisanName'] ?? 'KalaSetu Artisan',
        createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      );
}
