import 'package:kalasetu_app/core/models/product_listing.dart';
import 'package:kalasetu_app/core/models/craft_passport.dart';
import 'package:kalasetu_app/core/models/pricing_suggestion.dart';
import 'package:kalasetu_app/core/models/order.dart';

/// Default Artisan Data from C:\kalasetu\src\services\mockData.js
class ArtisanProfileData {
  static const String id = 'art_001';
  static const String name = 'Lakshmi Devi';
  static const String craftType = 'Master Artisan · Handloom';
  static const String location = 'Pochampally, Yadadri Bhuvanagiri, Telangana';
  static const String preferredLanguage = 'hi';
  static const String contact = '+91 98765 43210';
  static const int experienceYears = 18;
  static const bool giRegistered = true;
  static const String giTagNumber = 'GI-IN-0043-POCHAMPALLY';
  static const String avatarUrl = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80';
  static const double totalSales = 45800.0;
  static const int productsListed = 12;
  static const int activeOrders = 5;
}

const Map<String, Map<String, String>> mockDescriptions = {
  'Pochampally Saree': {
    'en': 'Authentic hand-woven Pochampally Ikat cotton saree featuring intricate traditional geometric patterns. Woven on traditional pit looms by GI-certified master weavers using natural plant dyes.',
    'hi': 'प्रामाणिक हाथ से बुनी गई पोचमपल्ली इकत सूती साड़ी। पारंपरिक प्राकृतिक रंगों और ज्यामितीय डिज़ाइन के साथ तैयार। जीआई टैग प्रमाणित कारीगरों द्वारा निर्मित।',
  },
  'Jaipur Blue Pottery': {
    'en': 'Traditional Jaipur Blue Pottery vase hand-painted with intricate botanical arabesque motifs. Made without clay using quartz powder stone technology.',
    'hi': 'पारंपरिक जयपुर ब्लू पॉटरी फूलदान। हाथ से पेंट की गई नीली और फ़िरोज़ी पुष्प डिजाइन। प्राकृतिक क्वार्ट्ज़ और काँच सामग्री से निर्मित।',
  },
  'Channapatna Toy': {
    'en': 'Eco-friendly non-toxic wooden ring stacker crafted in the toy town of Channapatna. Colored using natural vegetable dyes and turmeric, 100% child-safe.',
    'hi': 'चन्नापटना शैली में निर्मित इको-फ्रेंडली लकड़ी का खिलौना। 100% बाल-सुरक्षित प्राकृतिक वनस्पति रंगों और हल्दी से रंगा गया।',
  },
  'Dhokra Metalcraft': {
    'en': 'Rare 4,000-year-old lost-wax tribal casting craft. Intricately detailed peacock diya oil lamp handcrafted by Bastar metal artisans.',
    'hi': '4000 साल पुरानी लॉस्ट-वैक्स धातु ढलाई कला से बना बस्तर डोकरा पीतल का दीया। पारंपरिक बस्तर जनजातीय शैली।',
  },
  'Madhubani Painting': {
    'en': 'Exquisite hand-painted Madhubani artwork depicting the sacred fish motif (Matsya), created using natural dyes extracted from flowers, leaves, and berries on handmade Nepali paper.',
    'hi': 'मिथिला क्षेत्र, बिहार की पारंपरिक मधुबनी चित्रकला। यह कलाकृति पवित्र मछली (मत्स्य) की आकृति को दर्शाती है, जिसे फूलों, पत्तियों और जामुन से निकाले गए प्राकृतिक रंगों से चित्रित किया गया है।',
  },
};

final Map<String, PricingSuggestion> mockPricingData = {
  'Pochampally Saree': const PricingSuggestion(
    suggestedPrice: 2799.0,
    materialCost: 1200.0,
    laborCost: 800.0,
    laborHours: 42,
    fairMargin: 799.0,
  ),
  'Jaipur Blue Pottery': const PricingSuggestion(
    suggestedPrice: 1850.0,
    materialCost: 600.0,
    laborCost: 650.0,
    laborHours: 12,
    fairMargin: 600.0,
  ),
  'Channapatna Toy': const PricingSuggestion(
    suggestedPrice: 950.0,
    materialCost: 350.0,
    laborCost: 350.0,
    laborHours: 6,
    fairMargin: 250.0,
  ),
  'Dhokra Metalcraft': const PricingSuggestion(
    suggestedPrice: 3200.0,
    materialCost: 1400.0,
    laborCost: 1100.0,
    laborHours: 24,
    fairMargin: 700.0,
  ),
  'Madhubani Painting': const PricingSuggestion(
    suggestedPrice: 2500.0,
    materialCost: 500.0,
    laborCost: 1500.0,
    laborHours: 15,
    fairMargin: 500.0,
  ),
};

final List<ProductListing> mockProductListings = [
  ProductListing(
    id: 'prod_001',
    title: 'Handwoven Pochampally Ikat Pure Cotton Saree',
    craftCategory: 'Textiles & Handloom',
    price: 2799.0,
    imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
    description: mockDescriptions['Pochampally Saree']!['en']!,
    isGiCertified: true,
    artisanName: 'Lakshmi Devi',
  ),
  ProductListing(
    id: 'prod_002',
    title: 'Handcrafted Jaipur Blue Pottery Floral Vase',
    craftCategory: 'Pottery & Terracotta',
    price: 1850.0,
    imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600&auto=format&fit=crop&q=80',
    description: mockDescriptions['Jaipur Blue Pottery']!['en']!,
    isGiCertified: true,
    artisanName: 'Lakshmi Devi',
  ),
  ProductListing(
    id: 'prod_003',
    title: 'Channapatna Wooden Stacking Toy',
    craftCategory: 'Woodcraft & Carving',
    price: 950.0,
    imageUrl: 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=600&auto=format&fit=crop&q=80',
    description: mockDescriptions['Channapatna Toy']!['en']!,
    isGiCertified: true,
    artisanName: 'Lakshmi Devi',
  ),
  ProductListing(
    id: 'prod_004',
    title: 'Bell Metal Dhokra Peacock Oil Lamp',
    craftCategory: 'Metalcraft & Dhokra',
    price: 3200.0,
    imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600&auto=format&fit=crop&q=80',
    description: mockDescriptions['Dhokra Metalcraft']!['en']!,
    artisanName: 'Lakshmi Devi',
  ),
  ProductListing(
    id: 'prod_005',
    title: 'Madhubani Sacred Fish Painting',
    craftCategory: 'Paintings',
    price: 2500.0,
    imageUrl: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b675?w=600&auto=format&fit=crop&q=80',
    description: mockDescriptions['Madhubani Painting']!['en']!,
    artisanName: 'Lakshmi Devi',
  ),
];

final Map<String, CraftPassport> mockCraftPassports = {
  'prod_001': CraftPassport(
    listingId: 'prod_001',
    productName: 'Handwoven Pochampally Ikat Pure Cotton Saree',
    artisanName: 'Lakshmi Devi',
    location: 'Pochampally, Yadadri Bhuvanagiri, Telangana',
    giTag: 'GI-IN-0043-POCHAMPALLY',
    materials: ['100% Pure Mulberry Cotton', 'Organic Plant Dyes'],
    techniques: ['Traditional Geometric Ikat Weave', 'Pit Loom Hand Weaving'],
    verificationUrl: 'https://karigarsetu.gov.in/verify?id=PASSPORT-KS-PROD_001',
    imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
    createdAt: DateTime.now(),
  ),
  'prod_002': CraftPassport(
    listingId: 'prod_002',
    productName: 'Handcrafted Jaipur Blue Pottery Floral Vase',
    artisanName: 'Lakshmi Devi',
    location: 'Jaipur, Rajasthan',
    giTag: 'GI-IN-0002-JAIPUR-POTTERY',
    materials: ['Quartz Powder', 'Egyptian Paste', 'Natural Cobalt Oxide'],
    techniques: ['Clayless Molding', 'Hand-painted Arabesque Motifs'],
    verificationUrl: 'https://karigarsetu.gov.in/verify?id=PASSPORT-KS-PROD_002',
    imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600&auto=format&fit=crop&q=80',
    createdAt: DateTime.now(),
  ),
  'l-001': CraftPassport(
    listingId: 'l-001',
    productName: 'Handwoven Pochampally Ikat Pure Cotton Saree',
    artisanName: 'Lakshmi Devi',
    location: 'Pochampally, Telangana',
    giTag: 'GI-IN-0043-POCHAMPALLY',
    materials: ['Organic Cotton', 'Vegetable Dyes'],
    techniques: ['Ikat Weaving'],
    verificationUrl: 'https://karigarsetu.gov.in/verify?id=PASSPORT-KS-L001',
    imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
    createdAt: DateTime.now(),
  ),
};

/// INITIAL_ORDERS from C:\kalasetu\src\services\mockData.js
final List<OrderItem> mockOrders = [
  OrderItem(
    id: 'ORD-9843',
    orderNumber: '#ORD-9843',
    sourceNetwork: 'Via ONDC Network · Taj Heritage Hotels',
    productTitle: 'Handmade Bell Metal Dhokra Peacock Oil Lamp',
    quantity: 5,
    price: 16000.0,
    status: OrderStatus.newOrder,
    imageUrl: 'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=600&auto=format&fit=crop&q=80',
    createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
  ),
  OrderItem(
    id: 'ORD-9844',
    orderNumber: '#ORD-9844',
    sourceNetwork: 'Via ONDC Network · Sanya Malhotra',
    productTitle: 'Handcrafted Jaipur Blue Pottery Floral Vase',
    quantity: 1,
    price: 1850.0,
    status: OrderStatus.newOrder,
    imageUrl: 'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?w=600&auto=format&fit=crop&q=80',
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  OrderItem(
    id: 'ORD-9842',
    orderNumber: '#ORD-9842',
    sourceNetwork: 'Via Craftsvilla Boutique',
    productTitle: 'Handwoven Pochampally Ikat Pure Cotton Saree',
    quantity: 3,
    price: 8397.0,
    status: OrderStatus.inTransit,
    imageUrl: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=600&auto=format&fit=crop&q=80',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  OrderItem(
    id: 'ORD-9841',
    orderNumber: '#ORD-9841',
    sourceNetwork: 'Via Hastkala Export Traders',
    productTitle: 'Channapatna Wooden Toys Stacking Set',
    quantity: 20,
    price: 19000.0,
    status: OrderStatus.completed,
    imageUrl: 'https://images.unsplash.com/photo-1596461404969-9ae70f2830c1?w=600&auto=format&fit=crop&q=80',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
