// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => 'கலாசேது';

  @override
  String get homeGreeting => 'வரவேற்கிறோம், கலைஞரே!';

  @override
  String get namasteRamesh => 'நமஸ்தே, ரமேஷ்';

  @override
  String get ondcSyncLive => 'ONDC ஒத்திசைவு நேரலை';

  @override
  String get tapToCreateListing =>
      'குரல் & கேமரா மூலம் பொருளை பட்டியலிட தட்டவும்';

  @override
  String get startNow => 'இப்போது தொடங்கு';

  @override
  String get liveOnOndc => 'ONDC இல் நேரலை';

  @override
  String get newOrdersCount => 'புதிய ஆர்டர்கள்';

  @override
  String get recentActivity => 'சமீபத்திய செயல்பாடு';

  @override
  String get active => 'செயலில்';

  @override
  String get aiProcessing => 'AI செயலாக்கப்படுகிறது...';

  @override
  String get newListing => 'புதிய குரல் & புகைப்பட பட்டியல்';

  @override
  String get newListingSubtitle =>
      'புகைப்படங்கள் எடுத்து உங்கள் கலையை விவரிக்கவும்';

  @override
  String get myProducts => 'எனது பொருட்கள்';

  @override
  String myProductsCount(int published, int drafts) {
    return '$published வெளியிட்டவை · $drafts வரைவுகள்';
  }

  @override
  String get online => 'ஆன்லைன்';

  @override
  String get offline => 'ஆஃப்லைன்';

  @override
  String get lowBandwidth => 'குறைந்த அலைவரிசை';

  @override
  String cameraStepTitle(int current, int total) {
    return 'படி $current / $total';
  }

  @override
  String get angleFront => 'முன்புற தோற்றம்';

  @override
  String get angleDetail => 'விவரம் / அமைப்பு';

  @override
  String get angleProgress => 'கலை உருவாக்கத்தில்';

  @override
  String get capture => 'பிடி';

  @override
  String get retake => 'மீண்டும் எடு';

  @override
  String get delete => 'நீக்கு';

  @override
  String get next => 'அடுத்து';

  @override
  String get back => 'பின்னே';

  @override
  String get voiceTitle => 'உங்கள் பொருளைப் பற்றி சொல்லுங்கள்';

  @override
  String get voicePrompt =>
      'மைக்ரோஃபோனைத் தட்டி உங்கள் கலையை உங்கள் மொழியில் விவரிக்கவும்';

  @override
  String get recording => 'பதிவாகிறது...';

  @override
  String get tapToRecord => 'பதிவு செய்ய தட்டவும்';

  @override
  String get play => 'இயக்கு';

  @override
  String get pause => 'இடைநிறுத்து';

  @override
  String get reRecord => 'மீண்டும் பதிவு செய்';

  @override
  String get suggestedTopics => 'பரிந்துரைக்கப்பட்ட தலைப்புகள்:';

  @override
  String get topicMaterial => 'பயன்படுத்தப்பட்ட பொருள்';

  @override
  String get topicTime => 'செய்யும் நேரம்';

  @override
  String get topicStory => 'கலைக்குப் பின்னால் உள்ள கதை';

  @override
  String get generateListing => 'பட்டியலை உருவாக்கு';

  @override
  String get previewTitle => 'பட்டியல் முன்னோட்டம்';

  @override
  String get beforeImage => 'முன்';

  @override
  String get afterImage => 'பின்';

  @override
  String get description => 'விளக்கம்';

  @override
  String get fairPrice => 'நியாயமான விலை';

  @override
  String get priceBreakdown => 'விலை விவரம்';

  @override
  String get materials => 'பொருட்கள்';

  @override
  String get labor => 'உழைப்பு';

  @override
  String get fairMargin => 'நியாயமான லாபம்';

  @override
  String get category => 'வகை';

  @override
  String get approveAndPush => 'ஒப்புதல் அளித்து ONDCக்கு அனுப்பு';

  @override
  String get editDetails => 'விவரங்களை திருத்து';

  @override
  String get processing => 'உங்கள் கலை செயலாக்கப்படுகிறது...';

  @override
  String get processingSubtitle => 'எங்கள் AI உங்கள் படங்களை மேம்படுத்துகிறது';

  @override
  String get myListingsTitle => 'எனது பொருட்கள்';

  @override
  String get filterAll => 'அனைத்து பொருட்கள்';

  @override
  String get filterDraft => 'வரைவுகள்';

  @override
  String get filterPending => 'நிலுவையில் உள்ளது';

  @override
  String get filterPublished => 'ONDC இல் நேரலை';

  @override
  String get filterUnderReview => 'மதிப்பாய்வில்';

  @override
  String get statusDraft => 'வரைவு';

  @override
  String get statusProcessing => 'செயலாக்கப்படுகிறது';

  @override
  String get statusPending => 'ஒப்புதலுக்கு நிலுவையில் உள்ளது';

  @override
  String get statusPublished => 'நேரலை';

  @override
  String stockUnits(int count) {
    return 'கையிருப்பு: $count அலகுகள்';
  }

  @override
  String get ordersHub => 'ஆர்டர்கள் மையம்';

  @override
  String newOrdersTab(int count) {
    return 'புதிய ஆர்டர்கள் ($count)';
  }

  @override
  String inTransitTab(int count) {
    return 'பயணத்தில் ($count)';
  }

  @override
  String get completedTab => 'முடிந்தது';

  @override
  String get acceptOrder => 'ஆர்டரை ஏற்றுக்கொள்';

  @override
  String get packAndShip => 'பேக் செய்து அனுப்பு';

  @override
  String get craftPassportTitle => 'டிஜிட்டல் கிராஃப்ட் பாஸ்போர்ட்';

  @override
  String get artisanName => 'கலைஞர்';

  @override
  String get location => 'இடம்';

  @override
  String get giTag => 'GI டேக்';

  @override
  String get materialsUsed => 'பொருட்கள்';

  @override
  String get techniques => 'நுட்பங்கள்';

  @override
  String get scanQr => 'உண்மையா என சரிபார்க்க ஸ்கேன் செய்யவும்';

  @override
  String get sharePassport => 'பாஸ்போர்ட்டை பகிர்';

  @override
  String get uploadSuccess => 'பட்டியல் வெற்றிகரமாக வெளியிடப்பட்டது!';

  @override
  String get uploadFailed =>
      'பதிவேற்றம் தோல்வியடைந்தது. மீண்டும் முயற்சிக்க தட்டவும்.';

  @override
  String get retry => 'மீண்டும் முயற்சி செய்';

  @override
  String get noListingsYet => 'இன்னும் பட்டியல்கள் இல்லை';

  @override
  String get noListingsSubtitle =>
      'புகைப்படங்கள் எடுத்து முதல் பட்டியலை உருவாக்கவும்';

  @override
  String get savedAsDraft => 'வரைவாக சேமிக்கப்பட்டது';

  @override
  String get connectionRestored => 'இணைப்பு மீட்கப்பட்டது';

  @override
  String hours(int count) {
    return '$count மணிநேரம்';
  }

  @override
  String get navHome => 'முகப்பு';

  @override
  String get navProducts => 'பொருட்கள்';

  @override
  String get navOrders => 'ஆர்டர்கள்';

  @override
  String get navProfile => 'சுயவிவரம்';

  @override
  String get totalSales => 'மொத்த விற்பனை';

  @override
  String get productsLive => 'நேரலை பொருட்கள்';

  @override
  String get giAuthenticated => 'GI சான்றளிக்கப்பட்டது';

  @override
  String get viewCraftPassport => 'கிராஃப்ட் பாஸ்போர்ட்டைக் காண்';

  @override
  String get languageSettings => 'மொழி அமைப்புகள்';

  @override
  String get ondcNetworkStatus => 'ONDC நெட்வொர்க் நிலை';

  @override
  String get helpVoiceSupport => 'உதவி & குரல் ஆதரவு';

  @override
  String get selectLanguage => 'மொழியைத் தேர்ந்தெடு';

  @override
  String get defaultLanguage => 'இயல்பு மொழி';

  @override
  String get regionalLanguages => 'பிராந்திய மொழிகள்';
}
