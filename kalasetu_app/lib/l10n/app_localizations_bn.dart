// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'কলা সেতু';

  @override
  String get homeGreeting => 'স্বাগতম, কারিগর!';

  @override
  String get namasteRamesh => 'নমস্তে, রমেশ';

  @override
  String get ondcSyncLive => 'ONDC সিঙ্ক লাইভ';

  @override
  String get tapToCreateListing =>
      'ভয়েস এবং ক্যামেরা দিয়ে পণ্য তালিকা তৈরি করতে ট্যাপ করুন';

  @override
  String get startNow => 'এখনই শুরু করুন';

  @override
  String get liveOnOndc => 'ONDC তে লাইভ';

  @override
  String get newOrdersCount => 'নতুন অর্ডার';

  @override
  String get recentActivity => 'সাম্প্রতিক কাজ';

  @override
  String get active => 'সক্রিয়';

  @override
  String get aiProcessing => 'AI প্রসেসিং...';

  @override
  String get newListing => 'নতুন ভয়েস ও ফটো তালিকা';

  @override
  String get newListingSubtitle => 'ছবি তুলুন এবং আপনার শিল্পের বর্ণনা দিন';

  @override
  String get myProducts => 'আমার পণ্য';

  @override
  String myProductsCount(int published, int drafts) {
    return '$published প্রকাশিত · $drafts ড্রাফ্ট';
  }

  @override
  String get online => 'অনলাইন';

  @override
  String get offline => 'অফলাইন';

  @override
  String get lowBandwidth => 'নিম্ন ব্যান্ডউইথ';

  @override
  String cameraStepTitle(int current, int total) {
    return 'ধাপ $current / $total';
  }

  @override
  String get angleFront => 'সামনের দৃশ্য';

  @override
  String get angleDetail => 'বিস্তারিত / টেক্সচার';

  @override
  String get angleProgress => 'কাজ চলছে';

  @override
  String get capture => 'ক্যাপচার';

  @override
  String get retake => 'আবার নিন';

  @override
  String get delete => 'মুছুন';

  @override
  String get next => 'পরবর্তী';

  @override
  String get back => 'পিছনে';

  @override
  String get voiceTitle => 'আপনার পণ্য সম্পর্কে আমাদের বলুন';

  @override
  String get voicePrompt =>
      'মাইক্রোফোনে ট্যাপ করুন এবং আপনার ভাষায় আপনার শিল্পের বর্ণনা দিন';

  @override
  String get recording => 'রেকর্ডিং...';

  @override
  String get tapToRecord => 'রেকর্ড করতে ট্যাপ করুন';

  @override
  String get play => 'চালান';

  @override
  String get pause => 'থামান';

  @override
  String get reRecord => 'আবার রেকর্ড করুন';

  @override
  String get suggestedTopics => 'প্রস্তাবিত বিষয়:';

  @override
  String get topicMaterial => 'ব্যবহৃত উপকরণ';

  @override
  String get topicTime => 'তৈরি করতে সময়';

  @override
  String get topicStory => 'শিল্পের পেছনের গল্প';

  @override
  String get generateListing => 'তালিকা তৈরি করুন';

  @override
  String get previewTitle => 'তালিকা পূর্বরূপ';

  @override
  String get beforeImage => 'আগে';

  @override
  String get afterImage => 'পরে';

  @override
  String get description => 'বর্ণনা';

  @override
  String get fairPrice => 'ন্যায্য মূল্য';

  @override
  String get priceBreakdown => 'মূল্য ভাঙ্গন';

  @override
  String get materials => 'উপকরণ';

  @override
  String get labor => 'শ্রম';

  @override
  String get fairMargin => 'ন্যায্য মার্জিন';

  @override
  String get category => 'বিভাগ';

  @override
  String get approveAndPush => 'অনুমোদন করুন এবং ONDC তে পাঠান';

  @override
  String get editDetails => 'বিবরণ সম্পাদনা করুন';

  @override
  String get processing => 'আপনার শিল্প প্রসেস করা হচ্ছে...';

  @override
  String get processingSubtitle => 'আমাদের AI আপনার ছবিগুলিকে উন্নত করছে';

  @override
  String get myListingsTitle => 'আমার পণ্য';

  @override
  String get filterAll => 'সব পণ্য';

  @override
  String get filterDraft => 'ড্রাফ্ট';

  @override
  String get filterPending => 'অপেক্ষমাণ';

  @override
  String get filterPublished => 'ONDC তে লাইভ';

  @override
  String get filterUnderReview => 'পর্যালোচনাধীন';

  @override
  String get statusDraft => 'ড্রাফ্ট';

  @override
  String get statusProcessing => 'প্রসেসিং';

  @override
  String get statusPending => 'অনুমোদনের অপেক্ষায়';

  @override
  String get statusPublished => 'লাইভ';

  @override
  String stockUnits(int count) {
    return 'স্টক: $count ইউনিট';
  }

  @override
  String get ordersHub => 'অর্ডার হাব';

  @override
  String newOrdersTab(int count) {
    return 'নতুন অর্ডার ($count)';
  }

  @override
  String inTransitTab(int count) {
    return 'ট্রানজিটে ($count)';
  }

  @override
  String get completedTab => 'সম্পন্ন';

  @override
  String get acceptOrder => 'অর্ডার গ্রহণ করুন';

  @override
  String get packAndShip => 'প্যাক এবং শিপ';

  @override
  String get craftPassportTitle => 'ডিজিটাল ক্রাফট পাসপোর্ট';

  @override
  String get artisanName => 'কারিগর';

  @override
  String get location => 'স্থান';

  @override
  String get giTag => 'GI ট্যাগ';

  @override
  String get materialsUsed => 'উপকরণ';

  @override
  String get techniques => 'কৌশল';

  @override
  String get scanQr => 'সত্যতা যাচাই করতে স্ক্যান করুন';

  @override
  String get sharePassport => 'পাসপোর্ট শেয়ার করুন';

  @override
  String get uploadSuccess => 'তালিকা সফলভাবে প্রকাশিত হয়েছে!';

  @override
  String get uploadFailed =>
      'আপলোড ব্যর্থ হয়েছে। পুনরায় চেষ্টা করতে ট্যাপ করুন।';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

  @override
  String get noListingsYet => 'এখনও কোনও তালিকা নেই';

  @override
  String get noListingsSubtitle => 'ছবি তুলে আপনার প্রথম তালিকা তৈরি করুন';

  @override
  String get savedAsDraft => 'ড্রাফ্ট হিসেবে সেভ করা হয়েছে';

  @override
  String get connectionRestored => 'সংযোগ পুনরুদ্ধার করা হয়েছে';

  @override
  String hours(int count) {
    return '$count ঘণ্টা';
  }

  @override
  String get navHome => 'হোম';

  @override
  String get navProducts => 'পণ্য';

  @override
  String get navOrders => 'অর্ডার';

  @override
  String get navProfile => 'প্রোফাইল';

  @override
  String get totalSales => 'মোট বিক্রয়';

  @override
  String get productsLive => 'লাইভ পণ্য';

  @override
  String get giAuthenticated => 'GI প্রমাণীকৃত';

  @override
  String get viewCraftPassport => 'ক্রাফট পাসপোর্ট দেখুন';

  @override
  String get languageSettings => 'ভাষা সেটিংস';

  @override
  String get ondcNetworkStatus => 'ONDC নেটওয়ার্ক স্ট্যাটাস';

  @override
  String get helpVoiceSupport => 'সহায়তা এবং ভয়েস সাপোর্ট';

  @override
  String get selectLanguage => 'ভাষা নির্বাচন করুন';

  @override
  String get defaultLanguage => 'ডিফল্ট ভাষা';

  @override
  String get regionalLanguages => 'আঞ্চলিক ভাষা';
}
