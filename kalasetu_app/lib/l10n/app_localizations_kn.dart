// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Kannada (`kn`).
class AppLocalizationsKn extends AppLocalizations {
  AppLocalizationsKn([String locale = 'kn']) : super(locale);

  @override
  String get appName => 'ಕಲಾ ಸೇತು';

  @override
  String get homeGreeting => 'ಸ್ವಾಗತ, ಕುಶಲಕರ್ಮಿ!';

  @override
  String get namasteRamesh => 'ನಮಸ್ತೆ, ರಮೇಶ್';

  @override
  String get ondcSyncLive => 'ONDC ಸಿಂಕ್ ಲೈವ್';

  @override
  String get tapToCreateListing =>
      'ಧ್ವನಿ ಮತ್ತು ಕ್ಯಾಮೆರಾದೊಂದಿಗೆ ಉತ್ಪನ್ನ ಪಟ್ಟಿಯನ್ನು ರಚಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get startNow => 'ಈಗ ಪ್ರಾರಂಭಿಸಿ';

  @override
  String get liveOnOndc => 'ONDC ನಲ್ಲಿ ಲೈವ್';

  @override
  String get newOrdersCount => 'ಹೊಸ ಆದೇಶಗಳು';

  @override
  String get recentActivity => 'ಇತ್ತೀಚಿನ ಚಟುವಟಿಕೆ';

  @override
  String get active => 'ಸಕ್ರಿಯ';

  @override
  String get aiProcessing => 'AI ಸಂಸ್ಕರಣೆ...';

  @override
  String get newListing => 'ಹೊಸ ಧ್ವನಿ ಮತ್ತು ಫೋಟೋ ಪಟ್ಟಿ';

  @override
  String get newListingSubtitle =>
      'ಫೋಟೋಗಳನ್ನು ತೆಗೆದುಕೊಳ್ಳಿ ಮತ್ತು ನಿಮ್ಮ ಕಲೆಯನ್ನು ವಿವರಿಸಿ';

  @override
  String get myProducts => 'ನನ್ನ ಉತ್ಪನ್ನಗಳು';

  @override
  String myProductsCount(int published, int drafts) {
    return '$published ಪ್ರಕಟಿತ · $drafts ಕರಡುಗಳು';
  }

  @override
  String get online => 'ಆನ್‌ಲೈನ್';

  @override
  String get offline => 'ಆಫ್‌ಲೈನ್';

  @override
  String get lowBandwidth => 'ಕಡಿಮೆ ಬ್ಯಾಂಡ್‌ವಿಡ್ತ್';

  @override
  String cameraStepTitle(int current, int total) {
    return 'ಹಂತ $current / $total';
  }

  @override
  String get angleFront => 'ಮುಂಭಾಗದ ನೋಟ';

  @override
  String get angleDetail => 'ವಿವರ / ವಿನ್ಯಾಸ';

  @override
  String get angleProgress => 'ಪ್ರಗತಿಯಲ್ಲಿರುವ ಕಲೆ';

  @override
  String get capture => 'ಸೆರೆಹಿಡಿಯಿರಿ';

  @override
  String get retake => 'ಮರುತೆಗೆದುಕೊಳ್ಳಿ';

  @override
  String get delete => 'ಅಳಿಸಿ';

  @override
  String get next => 'ಮುಂದೆ';

  @override
  String get back => 'ಹಿಂದೆ';

  @override
  String get voiceTitle => 'ನಿಮ್ಮ ಉತ್ಪನ್ನದ ಬಗ್ಗೆ ನಮಗೆ ತಿಳಿಸಿ';

  @override
  String get voicePrompt =>
      'ಮೈಕ್ರೊಫೋನ್ ಟ್ಯಾಪ್ ಮಾಡಿ ಮತ್ತು ನಿಮ್ಮ ಕಲೆಯನ್ನು ನಿಮ್ಮ ಭಾಷೆಯಲ್ಲಿ ವಿವರಿಸಿ';

  @override
  String get recording => 'ರೆಕಾರ್ಡಿಂಗ್...';

  @override
  String get tapToRecord => 'ರೆಕಾರ್ಡ್ ಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ';

  @override
  String get play => 'ಪ್ಲೇ';

  @override
  String get pause => 'ವಿರಾಮ';

  @override
  String get reRecord => 'ಮರು-ರೆಕಾರ್ಡ್ ಮಾಡಿ';

  @override
  String get suggestedTopics => 'ಸೂಚಿಸಿದ ವಿಷಯಗಳು:';

  @override
  String get topicMaterial => 'ಬಳಸಿದ ವಸ್ತು';

  @override
  String get topicTime => 'ಮಾಡಲು ಬೇಕಾದ ಸಮಯ';

  @override
  String get topicStory => 'ಕಲೆಯ ಹಿಂದಿನ ಕಥೆ';

  @override
  String get generateListing => 'ಪಟ್ಟಿಯನ್ನು ರಚಿಸಿ';

  @override
  String get previewTitle => 'ಪಟ್ಟಿ ಮುನ್ನೋಟ';

  @override
  String get beforeImage => 'ಮೊದಲು';

  @override
  String get afterImage => 'ನಂತರ';

  @override
  String get description => 'ವಿವರಣೆ';

  @override
  String get fairPrice => 'ನ್ಯಾಯಯುತ ಬೆಲೆ';

  @override
  String get priceBreakdown => 'ಬೆಲೆ ವಿಭಜನೆ';

  @override
  String get materials => 'ವಸ್ತುಗಳು';

  @override
  String get labor => 'ಶ್ರಮ';

  @override
  String get fairMargin => 'ನ್ಯಾಯಯುತ ಮಾರ್ಜಿನ್';

  @override
  String get category => 'ವರ್ಗ';

  @override
  String get approveAndPush => 'ಅನುಮೋದಿಸಿ ಮತ್ತು ONDC ಗೆ ಕಳುಹಿಸಿ';

  @override
  String get editDetails => 'ವಿವರಗಳನ್ನು ಸಂಪಾದಿಸಿ';

  @override
  String get processing => 'ನಿಮ್ಮ ಕಲೆಯನ್ನು ಸಂಸ್ಕರಿಸಲಾಗುತ್ತಿದೆ...';

  @override
  String get processingSubtitle => 'ನಮ್ಮ AI ನಿಮ್ಮ ಚಿತ್ರಗಳನ್ನು ಹೆಚ್ಚಿಸುತ್ತಿದೆ';

  @override
  String get myListingsTitle => 'ನನ್ನ ಉತ್ಪನ್ನಗಳು';

  @override
  String get filterAll => 'ಎಲ್ಲಾ ಉತ್ಪನ್ನಗಳು';

  @override
  String get filterDraft => 'ಕರಡುಗಳು';

  @override
  String get filterPending => 'ಬಾಕಿ ಉಳಿದಿದೆ';

  @override
  String get filterPublished => 'ONDC ನಲ್ಲಿ ಲೈವ್';

  @override
  String get filterUnderReview => 'ಪರಿಶೀಲನೆಯಲ್ಲಿದೆ';

  @override
  String get statusDraft => 'ಕರಡು';

  @override
  String get statusProcessing => 'ಸಂಸ್ಕರಿಸಲಾಗುತ್ತಿದೆ';

  @override
  String get statusPending => 'ಅನುಮೋದನೆಗಾಗಿ ಬಾಕಿ ಉಳಿದಿದೆ';

  @override
  String get statusPublished => 'ಲೈವ್';

  @override
  String stockUnits(int count) {
    return 'ಸ್ಟಾಕ್: $count ಘಟಕಗಳು';
  }

  @override
  String get ordersHub => 'ಆದೇಶಗಳ ಹಬ್';

  @override
  String newOrdersTab(int count) {
    return 'ಹೊಸ ಆದೇಶಗಳು ($count)';
  }

  @override
  String inTransitTab(int count) {
    return 'ಸಾಗಣೆಯಲ್ಲಿ ($count)';
  }

  @override
  String get completedTab => 'ಪೂರ್ಣಗೊಂಡಿದೆ';

  @override
  String get acceptOrder => 'ಆದೇಶವನ್ನು ಸ್ವೀಕರಿಸಿ';

  @override
  String get packAndShip => 'ಪ್ಯಾಕ್ ಮತ್ತು ಶಿಪ್';

  @override
  String get craftPassportTitle => 'ಡಿಜಿಟಲ್ ಕ್ರಾಫ್ಟ್ ಪಾಸ್‌ಪೋರ್ಟ್';

  @override
  String get artisanName => 'ಕುಶಲಕರ್ಮಿ';

  @override
  String get location => 'ಸ್ಥಳ';

  @override
  String get giTag => 'GI ಟ್ಯಾಗ್';

  @override
  String get materialsUsed => 'ವಸ್ತುಗಳು';

  @override
  String get techniques => 'ತಂತ್ರಗಳು';

  @override
  String get scanQr => 'ದೃಢೀಕರಣವನ್ನು ಪರಿಶೀಲಿಸಲು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ';

  @override
  String get sharePassport => 'ಪಾಸ್‌ಪೋರ್ಟ್ ಹಂಚಿಕೊಳ್ಳಿ';

  @override
  String get uploadSuccess => 'ಪಟ್ಟಿಯನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಪ್ರಕಟಿಸಲಾಗಿದೆ!';

  @override
  String get uploadFailed => 'ಅಪ್‌ಲೋಡ್ ವಿಫಲವಾಗಿದೆ. ಮರುಪ್ರಯತ್ನಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ.';

  @override
  String get retry => 'ಮರುಪ್ರಯತ್ನಿಸಿ';

  @override
  String get noListingsYet => 'ಇನ್ನೂ ಯಾವುದೇ ಪಟ್ಟಿಗಳಿಲ್ಲ';

  @override
  String get noListingsSubtitle =>
      'ಫೋಟೋಗಳನ್ನು ತೆಗೆದುಕೊಂಡು ಮೊದಲ ಪಟ್ಟಿಯನ್ನು ರಚಿಸಿ';

  @override
  String get savedAsDraft => 'ಕರಡು ಎಂದು ಉಳಿಸಲಾಗಿದೆ';

  @override
  String get connectionRestored => 'ಸಂಪರ್ಕ ಮರುಸ್ಥಾಪಿಸಲಾಗಿದೆ';

  @override
  String hours(int count) {
    return '$count ಗಂಟೆಗಳು';
  }

  @override
  String get navHome => 'ಮನೆ';

  @override
  String get navProducts => 'ಉತ್ಪನ್ನಗಳು';

  @override
  String get navOrders => 'ಆದೇಶಗಳು';

  @override
  String get navProfile => 'ಪ್ರೊಫೈಲ್';

  @override
  String get totalSales => 'ಒಟ್ಟು ಮಾರಾಟ';

  @override
  String get productsLive => 'ಲೈವ್ ಉತ್ಪನ್ನಗಳು';

  @override
  String get giAuthenticated => 'GI ದೃಢೀಕರಿಸಲಾಗಿದೆ';

  @override
  String get viewCraftPassport => 'ಕ್ರಾಫ್ಟ್ ಪಾಸ್‌ಪೋರ್ಟ್ ವೀಕ್ಷಿಸಿ';

  @override
  String get languageSettings => 'ಭಾಷಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳು';

  @override
  String get ondcNetworkStatus => 'ONDC ನೆಟ್‌ವರ್ಕ್ ಸ್ಥಿತಿ';

  @override
  String get helpVoiceSupport => 'ಸಹಾಯ ಮತ್ತು ಧ್ವನಿ ಬೆಂಬಲ';

  @override
  String get selectLanguage => 'ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ';

  @override
  String get defaultLanguage => 'ಡೀಫಾಲ್ಟ್ ಭಾಷೆ';

  @override
  String get regionalLanguages => 'ಪ್ರಾದೇಶಿಕ ಭಾಷೆಗಳು';
}
