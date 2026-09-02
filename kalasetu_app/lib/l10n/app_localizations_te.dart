// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appName => 'కళాసేతు';

  @override
  String get homeGreeting => 'స్వాగతం, కళాకారుడా!';

  @override
  String get namasteRamesh => 'నమస్తే, రమేష్';

  @override
  String get ondcSyncLive => 'ONDC సింక్ లైవ్';

  @override
  String get tapToCreateListing =>
      'వాయిస్ & కెమెరాతో ప్రోడక్ట్ లిస్టింగ్ క్రియేట్ చేయడానికి ట్యాప్ చేయండి';

  @override
  String get startNow => 'ఇప్పుడే ప్రారంభించండి';

  @override
  String get liveOnOndc => 'ONDC లో లైవ్';

  @override
  String get newOrdersCount => 'కొత్త ఆర్డర్‌లు';

  @override
  String get recentActivity => 'ఇటీవలి చర్యలు';

  @override
  String get active => 'యాక్టివ్';

  @override
  String get aiProcessing => 'AI ప్రాసెసింగ్...';

  @override
  String get newListing => 'కొత్త వాయిస్ & ఫోటో లిస్టింగ్';

  @override
  String get newListingSubtitle => 'ఫోటోలు తీసి మీ నైపుణ్యాన్ని వివరించండి';

  @override
  String get myProducts => 'నా ఉత్పత్తులు';

  @override
  String myProductsCount(int published, int drafts) {
    return '$published ప్రచురించబడినవి · $drafts డ్రాఫ్ట్‌లు';
  }

  @override
  String get online => 'ఆన్‌లైన్';

  @override
  String get offline => 'ఆఫ్‌లైన్';

  @override
  String get lowBandwidth => 'తక్కువ బ్యాండ్‌విడ్త్';

  @override
  String cameraStepTitle(int current, int total) {
    return 'దశ $current / $total';
  }

  @override
  String get angleFront => 'ముందు వైపు';

  @override
  String get angleDetail => 'వివరాలు / ఆకృతి';

  @override
  String get angleProgress => 'తయారీలో ఉన్న పని';

  @override
  String get capture => 'క్యాప్చర్';

  @override
  String get retake => 'మళ్ళీ తీయండి';

  @override
  String get delete => 'తొలగించండి';

  @override
  String get next => 'తదుపరి';

  @override
  String get back => 'వెనుకకు';

  @override
  String get voiceTitle => 'మీ ఉత్పత్తి గురించి మాకు చెప్పండి';

  @override
  String get voicePrompt =>
      'మైక్రోఫోన్‌ను ట్యాప్ చేసి, మీ నైపుణ్యాన్ని మీ భాషలో వివరించండి';

  @override
  String get recording => 'రికార్డింగ్...';

  @override
  String get tapToRecord => 'రికార్డ్ చేయడానికి ట్యాప్ చేయండి';

  @override
  String get play => 'ప్లే';

  @override
  String get pause => 'పాజ్';

  @override
  String get reRecord => 'మళ్ళీ రికార్డ్ చేయండి';

  @override
  String get suggestedTopics => 'సూచించిన అంశాలు:';

  @override
  String get topicMaterial => 'ఉపయోగించిన మెటీరియల్';

  @override
  String get topicTime => 'తయారీకి పట్టే సమయం';

  @override
  String get topicStory => 'కళ వెనుక ఉన్న కథ';

  @override
  String get generateListing => 'లిస్టింగ్‌ను రూపొందించండి';

  @override
  String get previewTitle => 'లిస్టింగ్ ప్రివ్యూ';

  @override
  String get beforeImage => 'ముందు';

  @override
  String get afterImage => 'తర్వాత';

  @override
  String get description => 'వివరణ';

  @override
  String get fairPrice => 'న్యాయమైన ధర';

  @override
  String get priceBreakdown => 'ధర వివరాలు';

  @override
  String get materials => 'మెటీరియల్స్';

  @override
  String get labor => 'శ్రమ';

  @override
  String get fairMargin => 'న్యాయమైన మార్జిన్';

  @override
  String get category => 'కేటగిరీ';

  @override
  String get approveAndPush => 'ఆమోదించండి & ONDC కి పంపండి';

  @override
  String get editDetails => 'వివరాలను సవరించండి';

  @override
  String get processing => 'మీ కళ ప్రాసెస్ అవుతోంది...';

  @override
  String get processingSubtitle => 'మా AI మీ చిత్రాలను మెరుగుపరుస్తోంది';

  @override
  String get myListingsTitle => 'నా ఉత్పత్తులు';

  @override
  String get filterAll => 'అన్ని ఉత్పత్తులు';

  @override
  String get filterDraft => 'డ్రాఫ్ట్‌లు';

  @override
  String get filterPending => 'పెండింగ్';

  @override
  String get filterPublished => 'ONDC లో లైవ్';

  @override
  String get filterUnderReview => 'సమీక్షలో ఉంది';

  @override
  String get statusDraft => 'డ్రాఫ్ట్';

  @override
  String get statusProcessing => 'ప్రాసెసింగ్';

  @override
  String get statusPending => 'ఆమోదం కోసం పెండింగ్';

  @override
  String get statusPublished => 'లైవ్';

  @override
  String stockUnits(int count) {
    return 'స్టాక్: $count యూనిట్లు';
  }

  @override
  String get ordersHub => 'ఆర్డర్స్ హబ్';

  @override
  String newOrdersTab(int count) {
    return 'కొత్త ఆర్డర్‌లు ($count)';
  }

  @override
  String inTransitTab(int count) {
    return 'రవాణాలో ఉన్నాయి ($count)';
  }

  @override
  String get completedTab => 'పూర్తయినవి';

  @override
  String get acceptOrder => 'ఆర్డర్ అంగీకరించండి';

  @override
  String get packAndShip => 'ప్యాక్ & షిప్';

  @override
  String get craftPassportTitle => 'డిజిటల్ క్రాఫ్ట్ పాస్‌పోర్ట్';

  @override
  String get artisanName => 'కళాకారుడు';

  @override
  String get location => 'స్థలం';

  @override
  String get giTag => 'GI ట్యాగ్';

  @override
  String get materialsUsed => 'మెటీరియల్స్';

  @override
  String get techniques => 'పద్ధతులు';

  @override
  String get scanQr => 'ప్రామాణికతను ధృవీకరించడానికి స్కాన్ చేయండి';

  @override
  String get sharePassport => 'పాస్‌పోర్ట్ భాగస్వామ్యం చేయండి';

  @override
  String get uploadSuccess => 'లిస్టింగ్ విజయవంతంగా ప్రచురించబడింది!';

  @override
  String get uploadFailed =>
      'అప్‌లోడ్ విఫలమైంది. మళ్ళీ ప్రయత్నించడానికి ట్యాప్ చేయండి.';

  @override
  String get retry => 'మళ్ళీ ప్రయత్నించండి';

  @override
  String get noListingsYet => 'ఇంకా లిస్టింగ్స్ లేవు';

  @override
  String get noListingsSubtitle =>
      'ఫోటోలు తీసి మీ మొదటి లిస్టింగ్‌ను సృష్టించండి';

  @override
  String get savedAsDraft => 'డ్రాఫ్ట్‌గా సేవ్ చేయబడింది';

  @override
  String get connectionRestored => 'కనెక్షన్ పునరుద్ధరించబడింది';

  @override
  String hours(int count) {
    return '$count గంటలు';
  }

  @override
  String get navHome => 'హోమ్';

  @override
  String get navProducts => 'ఉత్పత్తులు';

  @override
  String get navOrders => 'ఆర్డర్‌లు';

  @override
  String get navProfile => 'ప్రొఫైల్';

  @override
  String get totalSales => 'మొత్తం విక్రయాలు';

  @override
  String get productsLive => 'లైవ్ ఉత్పత్తులు';

  @override
  String get giAuthenticated => 'GI ధృవీకరించబడింది';

  @override
  String get viewCraftPassport => 'క్రాఫ్ట్ పాస్‌పోర్ట్ చూడండి';

  @override
  String get languageSettings => 'భాష సెట్టింగ్‌లు';

  @override
  String get ondcNetworkStatus => 'ONDC నెట్‌వర్క్ స్థితి';

  @override
  String get helpVoiceSupport => 'సహాయం & వాయిస్ సపోర్ట్';

  @override
  String get selectLanguage => 'భాషను ఎంచుకోండి';

  @override
  String get defaultLanguage => 'డిఫాల్ట్ భాష';

  @override
  String get regionalLanguages => 'ప్రాంతీయ భాషలు';
}
