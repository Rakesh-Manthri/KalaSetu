// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appName => 'कला सेतू';

  @override
  String get homeGreeting => 'स्वागत आहे, कारागीर!';

  @override
  String get namasteRamesh => 'नमस्ते, रमेश';

  @override
  String get ondcSyncLive => 'ONDC सिंक लाईव्ह';

  @override
  String get tapToCreateListing =>
      'व्हॉइस आणि कॅमेरासह उत्पादन सूची तयार करण्यासाठी टॅप करा';

  @override
  String get startNow => 'आता सुरू करा';

  @override
  String get liveOnOndc => 'ONDC वर लाईव्ह';

  @override
  String get newOrdersCount => 'नवीन ऑर्डर्स';

  @override
  String get recentActivity => 'अलीकडील क्रियाकलाप';

  @override
  String get active => 'सक्रिय';

  @override
  String get aiProcessing => 'AI प्रक्रिया करत आहे...';

  @override
  String get newListing => 'नवीन व्हॉइस आणि फोटो सूची';

  @override
  String get newListingSubtitle => 'फोटो घ्या आणि आपल्या कलेचे वर्णन करा';

  @override
  String get myProducts => 'माझी उत्पादने';

  @override
  String myProductsCount(int published, int drafts) {
    return '$published प्रकाशित · $drafts ड्राफ्ट';
  }

  @override
  String get online => 'ऑनलाइन';

  @override
  String get offline => 'ऑफलाइन';

  @override
  String get lowBandwidth => 'कमी बँडविड्थ';

  @override
  String cameraStepTitle(int current, int total) {
    return 'पायरी $current / $total';
  }

  @override
  String get angleFront => 'समोरून दृश्य';

  @override
  String get angleDetail => 'तपशील / पोत';

  @override
  String get angleProgress => 'काम प्रगतीपथावर';

  @override
  String get capture => 'कॅप्चर करा';

  @override
  String get retake => 'पुन्हा घ्या';

  @override
  String get delete => 'हटवा';

  @override
  String get next => 'पुढे';

  @override
  String get back => 'मागे';

  @override
  String get voiceTitle => 'आपल्या उत्पादनाविषयी आम्हाला सांगा';

  @override
  String get voicePrompt =>
      'मायक्रोफोन टॅप करा आणि आपल्या भाषेत आपल्या कलेचे वर्णन करा';

  @override
  String get recording => 'रेकॉर्डिंग...';

  @override
  String get tapToRecord => 'रेकॉर्ड करण्यासाठी टॅप करा';

  @override
  String get play => 'प्ले';

  @override
  String get pause => 'थांबवा';

  @override
  String get reRecord => 'पुन्हा रेकॉर्ड करा';

  @override
  String get suggestedTopics => 'सुचविलेले विषय:';

  @override
  String get topicMaterial => 'वापरलेले साहित्य';

  @override
  String get topicTime => 'लागणारा वेळ';

  @override
  String get topicStory => 'कलेमागील कथा';

  @override
  String get generateListing => 'सूची तयार करा';

  @override
  String get previewTitle => 'सूची पूर्वावलोकन';

  @override
  String get beforeImage => 'पूर्वी';

  @override
  String get afterImage => 'नंतर';

  @override
  String get description => 'वर्णन';

  @override
  String get fairPrice => 'योग्य किंमत';

  @override
  String get priceBreakdown => 'किंमत तपशील';

  @override
  String get materials => 'साहित्य';

  @override
  String get labor => 'श्रम';

  @override
  String get fairMargin => 'योग्य नफा';

  @override
  String get category => 'श्रेणी';

  @override
  String get approveAndPush => 'मंजूर करा आणि ONDC वर पाठवा';

  @override
  String get editDetails => 'तपशील संपादित करा';

  @override
  String get processing => 'आपल्या कलेवर प्रक्रिया होत आहे...';

  @override
  String get processingSubtitle => 'आमचे AI आपले फोटो अधिक चांगले करत आहे';

  @override
  String get myListingsTitle => 'माझी उत्पादने';

  @override
  String get filterAll => 'सर्व उत्पादने';

  @override
  String get filterDraft => 'ड्राफ्ट';

  @override
  String get filterPending => 'प्रलंबित';

  @override
  String get filterPublished => 'ONDC वर लाईव्ह';

  @override
  String get filterUnderReview => 'पुनरावलोकनाधीन';

  @override
  String get statusDraft => 'ड्राफ्ट';

  @override
  String get statusProcessing => 'प्रक्रिया करत आहे';

  @override
  String get statusPending => 'मंजुरी प्रलंबित';

  @override
  String get statusPublished => 'लाईव्ह';

  @override
  String stockUnits(int count) {
    return 'स्टॉक: $count युनिट्स';
  }

  @override
  String get ordersHub => 'ऑर्डर हब';

  @override
  String newOrdersTab(int count) {
    return 'नवीन ऑर्डर्स ($count)';
  }

  @override
  String inTransitTab(int count) {
    return 'प्रवासात ($count)';
  }

  @override
  String get completedTab => 'पूर्ण';

  @override
  String get acceptOrder => 'ऑर्डर स्वीकारा';

  @override
  String get packAndShip => 'पॅक आणि शिप';

  @override
  String get craftPassportTitle => 'डिजिटल क्राफ्ट पासपोर्ट';

  @override
  String get artisanName => 'कारागीर';

  @override
  String get location => 'ठिकाण';

  @override
  String get giTag => 'GI टॅग';

  @override
  String get materialsUsed => 'साहित्य';

  @override
  String get techniques => 'तंत्र';

  @override
  String get scanQr => 'सत्यता पडताळण्यासाठी स्कॅन करा';

  @override
  String get sharePassport => 'पासपोर्ट शेअर करा';

  @override
  String get uploadSuccess => 'सूची यशस्वीरित्या प्रकाशित झाली!';

  @override
  String get uploadFailed =>
      'अपलोड अयशस्वी. पुन्हा प्रयत्न करण्यासाठी टॅप करा.';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get noListingsYet => 'अद्याप कोणतीही सूची नाही';

  @override
  String get noListingsSubtitle => 'फोटो घेऊन आपली पहिली सूची तयार करा';

  @override
  String get savedAsDraft => 'ड्राफ्ट म्हणून सेव्ह केले';

  @override
  String get connectionRestored => 'कनेक्शन पूर्ववत झाले';

  @override
  String hours(int count) {
    return '$count तास';
  }

  @override
  String get navHome => 'मुख्य';

  @override
  String get navProducts => 'उत्पादने';

  @override
  String get navOrders => 'ऑर्डर्स';

  @override
  String get navProfile => 'प्रोफाइल';

  @override
  String get totalSales => 'एकूण विक्री';

  @override
  String get productsLive => 'लाईव्ह उत्पादने';

  @override
  String get giAuthenticated => 'GI प्रमाणित';

  @override
  String get viewCraftPassport => 'क्राफ्ट पासपोर्ट पहा';

  @override
  String get languageSettings => 'भाषा सेटिंग्ज';

  @override
  String get ondcNetworkStatus => 'ONDC नेटवर्क स्थिती';

  @override
  String get helpVoiceSupport => 'मदत आणि व्हॉइस सपोर्ट';

  @override
  String get selectLanguage => 'भाषा निवडा';

  @override
  String get defaultLanguage => 'डीफॉल्ट भाषा';

  @override
  String get regionalLanguages => 'प्रादेशिक भाषा';
}
