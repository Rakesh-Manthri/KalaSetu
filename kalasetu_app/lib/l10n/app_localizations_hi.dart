// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'कला सेतु';

  @override
  String get homeGreeting => 'स्वागत है, कारीगर!';

  @override
  String get namasteRamesh => 'नमस्ते, रमेश';

  @override
  String get ondcSyncLive => 'ONDC सिंक लाइव';

  @override
  String get tapToCreateListing => 'आवाज़ और कैमरे से उत्पाद लिस्टिंग बनाएं';

  @override
  String get startNow => 'अभी शुरू करें';

  @override
  String get liveOnOndc => 'ONDC पर लाइव';

  @override
  String get newOrdersCount => 'नए ऑर्डर';

  @override
  String get recentActivity => 'हाल की गतिविधि';

  @override
  String get active => 'सक्रिय';

  @override
  String get aiProcessing => 'AI प्रोसेसिंग...';

  @override
  String get newListing => 'नई आवाज़ और फोटो लिस्टिंग';

  @override
  String get newListingSubtitle => 'फोटो लें और अपनी कला का वर्णन करें';

  @override
  String get myProducts => 'मेरे उत्पाद';

  @override
  String myProductsCount(int published, int drafts) {
    return '$published प्रकाशित · $drafts ड्राफ्ट';
  }

  @override
  String get online => 'ऑनलाइन';

  @override
  String get offline => 'ऑफलाइन';

  @override
  String get lowBandwidth => 'कम बैंडविड्थ';

  @override
  String cameraStepTitle(int current, int total) {
    return 'चरण $current / $total';
  }

  @override
  String get angleFront => 'सामने का दृश्य';

  @override
  String get angleDetail => 'बारीक / बनावट';

  @override
  String get angleProgress => 'कला प्रगति में';

  @override
  String get capture => 'कैप्चर';

  @override
  String get retake => 'फिर से लें';

  @override
  String get delete => 'हटाएं';

  @override
  String get next => 'आगे';

  @override
  String get back => 'पीछे';

  @override
  String get voiceTitle => 'अपने उत्पाद के बारे में बताएं';

  @override
  String get voicePrompt =>
      'माइक्रोफोन दबाएं और अपनी भाषा में अपनी कला का वर्णन करें';

  @override
  String get recording => 'रिकॉर्डिंग...';

  @override
  String get tapToRecord => 'रिकॉर्ड करने के लिए दबाएं';

  @override
  String get play => 'चलाएं';

  @override
  String get pause => 'रुकें';

  @override
  String get reRecord => 'फिर से रिकॉर्ड';

  @override
  String get suggestedTopics => 'सुझाए गए विषय:';

  @override
  String get topicMaterial => 'उपयोग की गई सामग्री';

  @override
  String get topicTime => 'बनाने में लगा समय';

  @override
  String get topicStory => 'कला के पीछे की कहानी';

  @override
  String get generateListing => 'लिस्टिंग बनाएं';

  @override
  String get previewTitle => 'लिस्टिंग पूर्वावलोकन';

  @override
  String get beforeImage => 'पहले';

  @override
  String get afterImage => 'बाद';

  @override
  String get description => 'विवरण';

  @override
  String get fairPrice => 'उचित मूल्य';

  @override
  String get priceBreakdown => 'मूल्य विवरण';

  @override
  String get materials => 'सामग्री';

  @override
  String get labor => 'श्रम';

  @override
  String get fairMargin => 'उचित मार्जिन';

  @override
  String get category => 'श्रेणी';

  @override
  String get approveAndPush => 'स्वीकृत करें और ONDC पर भेजें';

  @override
  String get editDetails => 'विवरण संपादित करें';

  @override
  String get processing => 'आपकी कला प्रोसेस हो रही है...';

  @override
  String get processingSubtitle => 'हमारी AI आपकी तस्वीरें बेहतर बना रही है';

  @override
  String get myListingsTitle => 'मेरे उत्पाद';

  @override
  String get filterAll => 'सभी उत्पाद';

  @override
  String get filterDraft => 'ड्राफ्ट';

  @override
  String get filterPending => 'लंबित';

  @override
  String get filterPublished => 'ONDC पर लाइव';

  @override
  String get filterUnderReview => 'समीक्षाधीन';

  @override
  String get statusDraft => 'ड्राफ्ट';

  @override
  String get statusProcessing => 'प्रोसेसिंग';

  @override
  String get statusPending => 'स्वीकृति लंबित';

  @override
  String get statusPublished => 'लाइव';

  @override
  String stockUnits(int count) {
    return 'स्टॉक: $count इकाइयां';
  }

  @override
  String get ordersHub => 'ऑर्डर हब';

  @override
  String newOrdersTab(int count) {
    return 'नए ऑर्डर ($count)';
  }

  @override
  String inTransitTab(int count) {
    return 'ट्रांजिट में ($count)';
  }

  @override
  String get completedTab => 'पूरा हुआ';

  @override
  String get acceptOrder => 'ऑर्डर स्वीकार करें';

  @override
  String get packAndShip => 'पैक और शिप';

  @override
  String get craftPassportTitle => 'डिजिटल कला पासपोर्ट';

  @override
  String get artisanName => 'कारीगर';

  @override
  String get location => 'स्थान';

  @override
  String get giTag => 'GI टैग';

  @override
  String get materialsUsed => 'सामग्री';

  @override
  String get techniques => 'तकनीक';

  @override
  String get scanQr => 'प्रमाणिकता सत्यापित करने के लिए स्कैन करें';

  @override
  String get sharePassport => 'पासपोर्ट साझा करें';

  @override
  String get uploadSuccess => 'लिस्टिंग सफलतापूर्वक प्रकाशित!';

  @override
  String get uploadFailed => 'अपलोड विफल। पुन: प्रयास के लिए दबाएं।';

  @override
  String get retry => 'पुन: प्रयास';

  @override
  String get noListingsYet => 'अभी कोई लिस्टिंग नहीं';

  @override
  String get noListingsSubtitle => 'फोटो लेकर अपनी पहली लिस्टिंग बनाएं';

  @override
  String get savedAsDraft => 'ड्राफ्ट के रूप में सहेजा गया';

  @override
  String get connectionRestored => 'कनेक्शन बहाल';

  @override
  String hours(int count) {
    return '$count घंटे';
  }

  @override
  String get navHome => 'मुख्य';

  @override
  String get navProducts => 'उत्पाद';

  @override
  String get navOrders => 'आर्डर';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get totalSales => 'कुल बिक्री';

  @override
  String get productsLive => 'लाइव उत्पाद';

  @override
  String get giAuthenticated => 'GI प्रमाणित';

  @override
  String get viewCraftPassport => 'क्राफ्ट पासपोर्ट देखें';

  @override
  String get languageSettings => 'भाषा सेटिंग्स';

  @override
  String get ondcNetworkStatus => 'ONDC नेटवर्क स्थिति';

  @override
  String get helpVoiceSupport => 'सहायता और वॉइस सपोर्ट';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get defaultLanguage => 'डिफ़ॉल्ट भाषा';

  @override
  String get regionalLanguages => 'क्षेत्रीय भाषाएं';
}
