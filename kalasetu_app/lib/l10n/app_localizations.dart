import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('mr'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'KalaSetu'**
  String get appName;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Artisan!'**
  String get homeGreeting;

  /// No description provided for @namasteRamesh.
  ///
  /// In en, this message translates to:
  /// **'Namaste, Ramesh'**
  String get namasteRamesh;

  /// No description provided for @ondcSyncLive.
  ///
  /// In en, this message translates to:
  /// **'ONDC Sync Live'**
  String get ondcSyncLive;

  /// No description provided for @tapToCreateListing.
  ///
  /// In en, this message translates to:
  /// **'Tap to Create Product Listing with Voice & Camera'**
  String get tapToCreateListing;

  /// No description provided for @startNow.
  ///
  /// In en, this message translates to:
  /// **'Start Now'**
  String get startNow;

  /// No description provided for @liveOnOndc.
  ///
  /// In en, this message translates to:
  /// **'Live on ONDC'**
  String get liveOnOndc;

  /// No description provided for @newOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'New Orders'**
  String get newOrdersCount;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @aiProcessing.
  ///
  /// In en, this message translates to:
  /// **'AI Processing...'**
  String get aiProcessing;

  /// No description provided for @newListing.
  ///
  /// In en, this message translates to:
  /// **'New Voice & Photo Listing'**
  String get newListing;

  /// No description provided for @newListingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take photos & describe your craft'**
  String get newListingSubtitle;

  /// No description provided for @myProducts.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myProducts;

  /// No description provided for @myProductsCount.
  ///
  /// In en, this message translates to:
  /// **'{published} Published · {drafts} Drafts'**
  String myProductsCount(int published, int drafts);

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @lowBandwidth.
  ///
  /// In en, this message translates to:
  /// **'Low Bandwidth'**
  String get lowBandwidth;

  /// No description provided for @cameraStepTitle.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String cameraStepTitle(int current, int total);

  /// No description provided for @angleFront.
  ///
  /// In en, this message translates to:
  /// **'Front View'**
  String get angleFront;

  /// No description provided for @angleDetail.
  ///
  /// In en, this message translates to:
  /// **'Detail / Texture'**
  String get angleDetail;

  /// No description provided for @angleProgress.
  ///
  /// In en, this message translates to:
  /// **'Craft in Progress'**
  String get angleProgress;

  /// No description provided for @capture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get capture;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @voiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your product'**
  String get voiceTitle;

  /// No description provided for @voicePrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone and describe your craft in your language'**
  String get voicePrompt;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get recording;

  /// No description provided for @tapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap to Record'**
  String get tapToRecord;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @reRecord.
  ///
  /// In en, this message translates to:
  /// **'Re-record'**
  String get reRecord;

  /// No description provided for @suggestedTopics.
  ///
  /// In en, this message translates to:
  /// **'Suggested topics:'**
  String get suggestedTopics;

  /// No description provided for @topicMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material used'**
  String get topicMaterial;

  /// No description provided for @topicTime.
  ///
  /// In en, this message translates to:
  /// **'Time to make'**
  String get topicTime;

  /// No description provided for @topicStory.
  ///
  /// In en, this message translates to:
  /// **'Story behind the craft'**
  String get topicStory;

  /// No description provided for @generateListing.
  ///
  /// In en, this message translates to:
  /// **'Generate Listing'**
  String get generateListing;

  /// No description provided for @previewTitle.
  ///
  /// In en, this message translates to:
  /// **'Listing Preview'**
  String get previewTitle;

  /// No description provided for @beforeImage.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get beforeImage;

  /// No description provided for @afterImage.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get afterImage;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @fairPrice.
  ///
  /// In en, this message translates to:
  /// **'Fair Price'**
  String get fairPrice;

  /// No description provided for @priceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Price Breakdown'**
  String get priceBreakdown;

  /// No description provided for @materials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// No description provided for @labor.
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get labor;

  /// No description provided for @fairMargin.
  ///
  /// In en, this message translates to:
  /// **'Fair Margin'**
  String get fairMargin;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @approveAndPush.
  ///
  /// In en, this message translates to:
  /// **'Approve & Push to ONDC'**
  String get approveAndPush;

  /// No description provided for @editDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Details'**
  String get editDetails;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing your craft...'**
  String get processing;

  /// No description provided for @processingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Our AI is enhancing your images and generating descriptions'**
  String get processingSubtitle;

  /// No description provided for @myListingsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Products'**
  String get myListingsTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get filterAll;

  /// No description provided for @filterDraft.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get filterDraft;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterPublished.
  ///
  /// In en, this message translates to:
  /// **'Live on ONDC'**
  String get filterPublished;

  /// No description provided for @filterUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get filterUnderReview;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending Approval'**
  String get statusPending;

  /// No description provided for @statusPublished.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get statusPublished;

  /// No description provided for @stockUnits.
  ///
  /// In en, this message translates to:
  /// **'Stock: {count} units'**
  String stockUnits(int count);

  /// No description provided for @ordersHub.
  ///
  /// In en, this message translates to:
  /// **'Orders Hub'**
  String get ordersHub;

  /// No description provided for @newOrdersTab.
  ///
  /// In en, this message translates to:
  /// **'New Orders ({count})'**
  String newOrdersTab(int count);

  /// No description provided for @inTransitTab.
  ///
  /// In en, this message translates to:
  /// **'In Transit ({count})'**
  String inTransitTab(int count);

  /// No description provided for @completedTab.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completedTab;

  /// No description provided for @acceptOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept Order'**
  String get acceptOrder;

  /// No description provided for @packAndShip.
  ///
  /// In en, this message translates to:
  /// **'Pack & Ship'**
  String get packAndShip;

  /// No description provided for @craftPassportTitle.
  ///
  /// In en, this message translates to:
  /// **'Digital Craft Passport'**
  String get craftPassportTitle;

  /// No description provided for @artisanName.
  ///
  /// In en, this message translates to:
  /// **'Artisan'**
  String get artisanName;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @giTag.
  ///
  /// In en, this message translates to:
  /// **'GI Tag'**
  String get giTag;

  /// No description provided for @materialsUsed.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materialsUsed;

  /// No description provided for @techniques.
  ///
  /// In en, this message translates to:
  /// **'Techniques'**
  String get techniques;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan to verify authenticity'**
  String get scanQr;

  /// No description provided for @sharePassport.
  ///
  /// In en, this message translates to:
  /// **'Share Passport'**
  String get sharePassport;

  /// No description provided for @uploadSuccess.
  ///
  /// In en, this message translates to:
  /// **'Listing published successfully!'**
  String get uploadSuccess;

  /// No description provided for @uploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Tap to retry.'**
  String get uploadFailed;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noListingsYet.
  ///
  /// In en, this message translates to:
  /// **'No listings yet'**
  String get noListingsYet;

  /// No description provided for @noListingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first listing by taking photos and recording a voice note'**
  String get noListingsSubtitle;

  /// No description provided for @savedAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Saved as draft'**
  String get savedAsDraft;

  /// No description provided for @connectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connection restored'**
  String get connectionRestored;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'{count} hours'**
  String hours(int count);

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @productsLive.
  ///
  /// In en, this message translates to:
  /// **'Products Live'**
  String get productsLive;

  /// No description provided for @giAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'GI Authenticated'**
  String get giAuthenticated;

  /// No description provided for @viewCraftPassport.
  ///
  /// In en, this message translates to:
  /// **'View Craft Passport'**
  String get viewCraftPassport;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @ondcNetworkStatus.
  ///
  /// In en, this message translates to:
  /// **'ONDC Network Status'**
  String get ondcNetworkStatus;

  /// No description provided for @helpVoiceSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Voice Support'**
  String get helpVoiceSupport;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @defaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'Default Language'**
  String get defaultLanguage;

  /// No description provided for @regionalLanguages.
  ///
  /// In en, this message translates to:
  /// **'Regional Languages'**
  String get regionalLanguages;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'bn',
    'en',
    'hi',
    'kn',
    'mr',
    'ta',
    'te',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
