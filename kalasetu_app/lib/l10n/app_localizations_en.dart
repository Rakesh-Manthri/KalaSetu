// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'KalaSetu';

  @override
  String get homeGreeting => 'Welcome, Artisan!';

  @override
  String get namasteRamesh => 'Namaste, Ramesh';

  @override
  String get ondcSyncLive => 'ONDC Sync Live';

  @override
  String get tapToCreateListing =>
      'Tap to Create Product Listing with Voice & Camera';

  @override
  String get startNow => 'Start Now';

  @override
  String get liveOnOndc => 'Live on ONDC';

  @override
  String get newOrdersCount => 'New Orders';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get active => 'Active';

  @override
  String get aiProcessing => 'AI Processing...';

  @override
  String get newListing => 'New Voice & Photo Listing';

  @override
  String get newListingSubtitle => 'Take photos & describe your craft';

  @override
  String get myProducts => 'My Products';

  @override
  String myProductsCount(int published, int drafts) {
    return '$published Published · $drafts Drafts';
  }

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get lowBandwidth => 'Low Bandwidth';

  @override
  String cameraStepTitle(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get angleFront => 'Front View';

  @override
  String get angleDetail => 'Detail / Texture';

  @override
  String get angleProgress => 'Craft in Progress';

  @override
  String get capture => 'Capture';

  @override
  String get retake => 'Retake';

  @override
  String get delete => 'Delete';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get voiceTitle => 'Tell us about your product';

  @override
  String get voicePrompt =>
      'Tap the microphone and describe your craft in your language';

  @override
  String get recording => 'Recording...';

  @override
  String get tapToRecord => 'Tap to Record';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get reRecord => 'Re-record';

  @override
  String get suggestedTopics => 'Suggested topics:';

  @override
  String get topicMaterial => 'Material used';

  @override
  String get topicTime => 'Time to make';

  @override
  String get topicStory => 'Story behind the craft';

  @override
  String get generateListing => 'Generate Listing';

  @override
  String get previewTitle => 'Listing Preview';

  @override
  String get beforeImage => 'Before';

  @override
  String get afterImage => 'After';

  @override
  String get description => 'Description';

  @override
  String get fairPrice => 'Fair Price';

  @override
  String get priceBreakdown => 'Price Breakdown';

  @override
  String get materials => 'Materials';

  @override
  String get labor => 'Labor';

  @override
  String get fairMargin => 'Fair Margin';

  @override
  String get category => 'Category';

  @override
  String get approveAndPush => 'Approve & Push to ONDC';

  @override
  String get editDetails => 'Edit Details';

  @override
  String get processing => 'Processing your craft...';

  @override
  String get processingSubtitle =>
      'Our AI is enhancing your images and generating descriptions';

  @override
  String get myListingsTitle => 'My Products';

  @override
  String get filterAll => 'All Products';

  @override
  String get filterDraft => 'Drafts';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterPublished => 'Live on ONDC';

  @override
  String get filterUnderReview => 'Under Review';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusPending => 'Pending Approval';

  @override
  String get statusPublished => 'Live';

  @override
  String stockUnits(int count) {
    return 'Stock: $count units';
  }

  @override
  String get ordersHub => 'Orders Hub';

  @override
  String newOrdersTab(int count) {
    return 'New Orders ($count)';
  }

  @override
  String inTransitTab(int count) {
    return 'In Transit ($count)';
  }

  @override
  String get completedTab => 'Completed';

  @override
  String get acceptOrder => 'Accept Order';

  @override
  String get packAndShip => 'Pack & Ship';

  @override
  String get craftPassportTitle => 'Digital Craft Passport';

  @override
  String get artisanName => 'Artisan';

  @override
  String get location => 'Location';

  @override
  String get giTag => 'GI Tag';

  @override
  String get materialsUsed => 'Materials';

  @override
  String get techniques => 'Techniques';

  @override
  String get scanQr => 'Scan to verify authenticity';

  @override
  String get sharePassport => 'Share Passport';

  @override
  String get uploadSuccess => 'Listing published successfully!';

  @override
  String get uploadFailed => 'Upload failed. Tap to retry.';

  @override
  String get retry => 'Retry';

  @override
  String get noListingsYet => 'No listings yet';

  @override
  String get noListingsSubtitle =>
      'Create your first listing by taking photos and recording a voice note';

  @override
  String get savedAsDraft => 'Saved as draft';

  @override
  String get connectionRestored => 'Connection restored';

  @override
  String hours(int count) {
    return '$count hours';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navProducts => 'Products';

  @override
  String get navOrders => 'Orders';

  @override
  String get navProfile => 'Profile';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get productsLive => 'Products Live';

  @override
  String get giAuthenticated => 'GI Authenticated';

  @override
  String get viewCraftPassport => 'View Craft Passport';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get ondcNetworkStatus => 'ONDC Network Status';

  @override
  String get helpVoiceSupport => 'Help & Voice Support';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get defaultLanguage => 'Default Language';

  @override
  String get regionalLanguages => 'Regional Languages';
}
