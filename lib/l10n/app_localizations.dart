import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

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
    Locale('en'),
    Locale('sw')
  ];

  /// No description provided for @appTitle.
  ///
  /// In sw, this message translates to:
  /// **'TendaPoa'**
  String get appTitle;

  /// No description provided for @applications_tab.
  ///
  /// In sw, this message translates to:
  /// **'Maombi'**
  String get applications_tab;

  /// No description provided for @settings.
  ///
  /// In sw, this message translates to:
  /// **'Mipangilio'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In sw, this message translates to:
  /// **'Muonekano'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In sw, this message translates to:
  /// **'Mandhari'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In sw, this message translates to:
  /// **'Mwangaza'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In sw, this message translates to:
  /// **'Giza'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In sw, this message translates to:
  /// **'Mfumo'**
  String get systemTheme;

  /// No description provided for @language.
  ///
  /// In sw, this message translates to:
  /// **'Lugha'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Lugha'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In sw, this message translates to:
  /// **'Kiingereza'**
  String get english;

  /// No description provided for @swahili.
  ///
  /// In sw, this message translates to:
  /// **'Kiswahili'**
  String get swahili;

  /// No description provided for @general.
  ///
  /// In sw, this message translates to:
  /// **'Jumla'**
  String get general;

  /// No description provided for @account.
  ///
  /// In sw, this message translates to:
  /// **'Akaunti'**
  String get account;

  /// No description provided for @logout.
  ///
  /// In sw, this message translates to:
  /// **'Ondoka'**
  String get logout;

  /// No description provided for @notifications.
  ///
  /// In sw, this message translates to:
  /// **'Taarifa'**
  String get notifications;

  /// No description provided for @helpHelp.
  ///
  /// In sw, this message translates to:
  /// **'Msaada'**
  String get helpHelp;

  /// No description provided for @privacyPolicy.
  ///
  /// In sw, this message translates to:
  /// **'Sera ya Faragha'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In sw, this message translates to:
  /// **'Vigezo na Masharti'**
  String get termsOfService;

  /// No description provided for @dashboard.
  ///
  /// In sw, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @home.
  ///
  /// In sw, this message translates to:
  /// **'Nyumbani'**
  String get home;

  /// No description provided for @myJobs.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Zangu'**
  String get myJobs;

  /// No description provided for @chat.
  ///
  /// In sw, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In sw, this message translates to:
  /// **'Wasifu'**
  String get profile;

  /// No description provided for @search.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta'**
  String get search;

  /// No description provided for @post_job_title.
  ///
  /// In sw, this message translates to:
  /// **'Posti Kazi'**
  String get post_job_title;

  /// No description provided for @job_details_step.
  ///
  /// In sw, this message translates to:
  /// **'Maelezo ya Kazi'**
  String get job_details_step;

  /// No description provided for @location_payment_step.
  ///
  /// In sw, this message translates to:
  /// **'Mahali na Malipo'**
  String get location_payment_step;

  /// No description provided for @fill_job_details.
  ///
  /// In sw, this message translates to:
  /// **'Jaza maelezo ya kazi'**
  String get fill_job_details;

  /// No description provided for @image_picker_camera.
  ///
  /// In sw, this message translates to:
  /// **'Piga Picha'**
  String get image_picker_camera;

  /// No description provided for @image_picker_gallery.
  ///
  /// In sw, this message translates to:
  /// **'Chagua kutoka Gallery'**
  String get image_picker_gallery;

  /// No description provided for @add_image_optional.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza Picha (Optional)'**
  String get add_image_optional;

  /// No description provided for @enter_job_title.
  ///
  /// In sw, this message translates to:
  /// **'Ingiza kichwa cha kazi'**
  String get enter_job_title;

  /// No description provided for @job_title_error.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali ingiza kichwa cha kazi'**
  String get job_title_error;

  /// No description provided for @select_category.
  ///
  /// In sw, this message translates to:
  /// **'Chagua kundi la kazi'**
  String get select_category;

  /// No description provided for @category_error.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali chagua kundi'**
  String get category_error;

  /// No description provided for @your_budget.
  ///
  /// In sw, this message translates to:
  /// **'Bajeti yako'**
  String get your_budget;

  /// No description provided for @budget_error.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali ingiza bajeti'**
  String get budget_error;

  /// No description provided for @budget_invalid.
  ///
  /// In sw, this message translates to:
  /// **'Bajeti si sahihi'**
  String get budget_invalid;

  /// No description provided for @phone_number.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya Simu'**
  String get phone_number;

  /// No description provided for @phone_error.
  ///
  /// In sw, this message translates to:
  /// **'Ingiza namba ya simu'**
  String get phone_error;

  /// No description provided for @additional_details.
  ///
  /// In sw, this message translates to:
  /// **'Maelezo ya ziada'**
  String get additional_details;

  /// No description provided for @next_step_location.
  ///
  /// In sw, this message translates to:
  /// **'Hatua ya Mahali'**
  String get next_step_location;

  /// No description provided for @choose_location_title.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Mahali'**
  String get choose_location_title;

  /// No description provided for @location_description.
  ///
  /// In sw, this message translates to:
  /// **'Taja sehemu kazi inapofanyika'**
  String get location_description;

  /// No description provided for @use_my_location.
  ///
  /// In sw, this message translates to:
  /// **'Tumia eneo langu'**
  String get use_my_location;

  /// No description provided for @posting_job.
  ///
  /// In sw, this message translates to:
  /// **'Tunaposti kazi yako...'**
  String get posting_job;

  /// No description provided for @searching_workers.
  ///
  /// In sw, this message translates to:
  /// **'Tunatafuta mafundi karibu...'**
  String get searching_workers;

  /// No description provided for @go_back.
  ///
  /// In sw, this message translates to:
  /// **'Rudi nyuma'**
  String get go_back;

  /// No description provided for @search_post.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta na Posti'**
  String get search_post;

  /// No description provided for @job_posted_success.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Imepostiwa!'**
  String get job_posted_success;

  /// No description provided for @job_posted_message.
  ///
  /// In sw, this message translates to:
  /// **'Kazi yako imepostiwa kwa mafanikio. Mafundi wataanza kuomba hivi punde.'**
  String get job_posted_message;

  /// No description provided for @workers_found_title.
  ///
  /// In sw, this message translates to:
  /// **'Mafundi Wamepatikana'**
  String get workers_found_title;

  /// No description provided for @wait.
  ///
  /// In sw, this message translates to:
  /// **'Subiri kidogo'**
  String get wait;

  /// No description provided for @post_job_btn.
  ///
  /// In sw, this message translates to:
  /// **'Posti Kazi Sasa'**
  String get post_job_btn;

  /// No description provided for @no_workers_title.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna Mafundi?'**
  String get no_workers_title;

  /// No description provided for @no_workers_message.
  ///
  /// In sw, this message translates to:
  /// **'Hatujapata mafundi karibu kwa sasa lakini tutaendelea kutafuta.'**
  String get no_workers_message;

  /// No description provided for @network_error_title.
  ///
  /// In sw, this message translates to:
  /// **'Hitilafu ya Mtandao'**
  String get network_error_title;

  /// No description provided for @network_error_message.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindwa kuunganishwa. Angalia intaneti yako.'**
  String get network_error_message;

  /// No description provided for @cancel.
  ///
  /// In sw, this message translates to:
  /// **'Ghairi'**
  String get cancel;

  /// No description provided for @post_anyway.
  ///
  /// In sw, this message translates to:
  /// **'Posti Hivyohivyo'**
  String get post_anyway;

  /// No description provided for @gps_permission_denied.
  ///
  /// In sw, this message translates to:
  /// **'Ruhusa ya GPS imekataliwa'**
  String get gps_permission_denied;

  /// No description provided for @enable_gps.
  ///
  /// In sw, this message translates to:
  /// **'Washa GPS'**
  String get enable_gps;

  /// No description provided for @how_to_find_worker.
  ///
  /// In sw, this message translates to:
  /// **'Jinsi ya kupata fundi'**
  String get how_to_find_worker;

  /// No description provided for @tips_description.
  ///
  /// In sw, this message translates to:
  /// **'Hakikisha unaelezea kazi vizuri na kuweka bajeti sahihi.'**
  String get tips_description;

  /// No description provided for @categories_title.
  ///
  /// In sw, this message translates to:
  /// **'Makundi ya Kazi'**
  String get categories_title;

  /// No description provided for @recent_jobs_title.
  ///
  /// In sw, this message translates to:
  /// **'Kazi za Hivi Karibuni'**
  String get recent_jobs_title;

  /// No description provided for @view_all.
  ///
  /// In sw, this message translates to:
  /// **'Ona Zote'**
  String get view_all;

  /// No description provided for @no_jobs_here.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna kazi hapa'**
  String get no_jobs_here;

  /// No description provided for @jobs_will_appear_here.
  ///
  /// In sw, this message translates to:
  /// **'Kazi zitakazopostiwa zitaonekana hapa.'**
  String get jobs_will_appear_here;

  /// No description provided for @pending_tab.
  ///
  /// In sw, this message translates to:
  /// **'Pending'**
  String get pending_tab;

  /// No description provided for @all_tab.
  ///
  /// In sw, this message translates to:
  /// **'Zote'**
  String get all_tab;

  /// No description provided for @active_tab.
  ///
  /// In sw, this message translates to:
  /// **'Zinazoendelea'**
  String get active_tab;

  /// No description provided for @completed_tab.
  ///
  /// In sw, this message translates to:
  /// **'Zilizokamilika'**
  String get completed_tab;

  /// No description provided for @retry_payment.
  ///
  /// In sw, this message translates to:
  /// **'Jaribu Malipo Tena'**
  String get retry_payment;

  /// No description provided for @delete_job.
  ///
  /// In sw, this message translates to:
  /// **'Futa Kazi'**
  String get delete_job;

  /// No description provided for @confirm_delete_job.
  ///
  /// In sw, this message translates to:
  /// **'Je, una uhakika unataka kufuta kazi hii?'**
  String get confirm_delete_job;

  /// No description provided for @yes_delete.
  ///
  /// In sw, this message translates to:
  /// **'Ndiyo, Futa'**
  String get yes_delete;

  /// No description provided for @no.
  ///
  /// In sw, this message translates to:
  /// **'Hapana'**
  String get no;

  /// No description provided for @job_deleted_success.
  ///
  /// In sw, this message translates to:
  /// **'Kazi imefutwa kwa mafanikio.'**
  String get job_deleted_success;

  /// No description provided for @payment_initiated.
  ///
  /// In sw, this message translates to:
  /// **'Malipo yameanzishwa.'**
  String get payment_initiated;

  /// No description provided for @conversations.
  ///
  /// In sw, this message translates to:
  /// **'Mazungumzo'**
  String get conversations;

  /// No description provided for @no_conversations.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna mazungumzo'**
  String get no_conversations;

  /// No description provided for @conversations_subtitle.
  ///
  /// In sw, this message translates to:
  /// **'Anza kuongea na mafundi hapa.'**
  String get conversations_subtitle;

  /// No description provided for @edit_profile.
  ///
  /// In sw, this message translates to:
  /// **'Badili Wasifu'**
  String get edit_profile;

  /// No description provided for @save_changes.
  ///
  /// In sw, this message translates to:
  /// **'Hifadhi'**
  String get save_changes;

  /// No description provided for @full_name.
  ///
  /// In sw, this message translates to:
  /// **'Majina Kamili'**
  String get full_name;

  /// No description provided for @enter_name.
  ///
  /// In sw, this message translates to:
  /// **'Ingiza majina yako'**
  String get enter_name;

  /// No description provided for @profile_updated_success.
  ///
  /// In sw, this message translates to:
  /// **'Profile imesasishwa.'**
  String get profile_updated_success;

  /// No description provided for @user_info_missing.
  ///
  /// In sw, this message translates to:
  /// **'Taarifa hazitoshi.'**
  String get user_info_missing;

  /// No description provided for @status_completed.
  ///
  /// In sw, this message translates to:
  /// **'Imekamilika'**
  String get status_completed;

  /// No description provided for @status_assigned.
  ///
  /// In sw, this message translates to:
  /// **'Imepewa Fundi'**
  String get status_assigned;

  /// No description provided for @status_in_progress.
  ///
  /// In sw, this message translates to:
  /// **'Inafanyika'**
  String get status_in_progress;

  /// No description provided for @status_active.
  ///
  /// In sw, this message translates to:
  /// **'Ipo Hewani'**
  String get status_active;

  /// No description provided for @status_offered.
  ///
  /// In sw, this message translates to:
  /// **'Inasubiri Fundi'**
  String get status_offered;

  /// No description provided for @status_cancelled.
  ///
  /// In sw, this message translates to:
  /// **'Imefutwa'**
  String get status_cancelled;

  /// No description provided for @status_pending_payment.
  ///
  /// In sw, this message translates to:
  /// **'Inasubiri Malipo'**
  String get status_pending_payment;

  /// No description provided for @status_empty.
  ///
  /// In sw, this message translates to:
  /// **'Haina Hali'**
  String get status_empty;

  /// No description provided for @location_title.
  ///
  /// In sw, this message translates to:
  /// **'Eneo la Kazi'**
  String get location_title;

  /// No description provided for @worker_applications.
  ///
  /// In sw, this message translates to:
  /// **'Maombi ya Mafundi'**
  String get worker_applications;

  /// No description provided for @no_applications_yet.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna maombi bado'**
  String get no_applications_yet;

  /// No description provided for @wait_for_workers.
  ///
  /// In sw, this message translates to:
  /// **'Subiri mafundi waone kazi yako.'**
  String get wait_for_workers;

  /// No description provided for @assigned_worker.
  ///
  /// In sw, this message translates to:
  /// **'Fundi Aliyechaguliwa'**
  String get assigned_worker;

  /// No description provided for @completion_code_title.
  ///
  /// In sw, this message translates to:
  /// **'Code ya Kumaliza Kazi'**
  String get completion_code_title;

  /// No description provided for @give_code_instruction.
  ///
  /// In sw, this message translates to:
  /// **'Mpe fundi code hii akimaliza kazi.'**
  String get give_code_instruction;

  /// No description provided for @delete_job_btn.
  ///
  /// In sw, this message translates to:
  /// **'Futa Kazi'**
  String get delete_job_btn;

  /// No description provided for @deleting.
  ///
  /// In sw, this message translates to:
  /// **'Inafuta...'**
  String get deleting;

  /// No description provided for @call_worker.
  ///
  /// In sw, this message translates to:
  /// **'Piga Simu'**
  String get call_worker;

  /// No description provided for @chat_with_worker.
  ///
  /// In sw, this message translates to:
  /// **'Chat na Fundi'**
  String get chat_with_worker;

  /// No description provided for @select_worker.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Fundi'**
  String get select_worker;

  /// No description provided for @offer_price.
  ///
  /// In sw, this message translates to:
  /// **'Ofa ya Bei'**
  String get offer_price;

  /// No description provided for @reviews.
  ///
  /// In sw, this message translates to:
  /// **'Uhiki'**
  String get reviews;

  /// No description provided for @find_jobs.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta Kazi'**
  String get find_jobs;

  /// No description provided for @wallet_balance.
  ///
  /// In sw, this message translates to:
  /// **'Salio la Wallet'**
  String get wallet_balance;

  /// No description provided for @total_earnings.
  ///
  /// In sw, this message translates to:
  /// **'Jumla ya Mapato'**
  String get total_earnings;

  /// No description provided for @jobs_done.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Zilizofanywa'**
  String get jobs_done;

  /// No description provided for @withdraw_btn.
  ///
  /// In sw, this message translates to:
  /// **'Toa Pesa'**
  String get withdraw_btn;

  /// No description provided for @active_jobs_title.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Zinazoendelea'**
  String get active_jobs_title;

  /// No description provided for @no_active_jobs.
  ///
  /// In sw, this message translates to:
  /// **'Huna kazi inayoendelea'**
  String get no_active_jobs;

  /// No description provided for @no_active_jobs_sub.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta kazi uanze kupata kipato.'**
  String get no_active_jobs_sub;

  /// No description provided for @press_to_complete.
  ///
  /// In sw, this message translates to:
  /// **'Bonyeza kama umemaliza'**
  String get press_to_complete;

  /// No description provided for @complete_existing_job.
  ///
  /// In sw, this message translates to:
  /// **'Maliza kazi iliyopo'**
  String get complete_existing_job;

  /// No description provided for @complete_existing_job_sub.
  ///
  /// In sw, this message translates to:
  /// **'Huwezi kuchukua kazi nyingine mpaka umalize hii.'**
  String get complete_existing_job_sub;

  /// No description provided for @return_to_job.
  ///
  /// In sw, this message translates to:
  /// **'Rudi kwenye Kazi'**
  String get return_to_job;

  /// No description provided for @search_jobs_hint.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta kazi hapa...'**
  String get search_jobs_hint;

  /// No description provided for @no_jobs_found.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna kazi iliyopatikana'**
  String get no_jobs_found;

  /// No description provided for @no_jobs_found_sub.
  ///
  /// In sw, this message translates to:
  /// **'Jaribu kutafuta kwa jina lingine.'**
  String get no_jobs_found_sub;

  /// No description provided for @new_tag.
  ///
  /// In sw, this message translates to:
  /// **'MPYA'**
  String get new_tag;

  /// No description provided for @apply_btn.
  ///
  /// In sw, this message translates to:
  /// **'Omba Kazi'**
  String get apply_btn;

  /// No description provided for @worker_role.
  ///
  /// In sw, this message translates to:
  /// **'Fundi'**
  String get worker_role;

  /// No description provided for @my_profile_menu.
  ///
  /// In sw, this message translates to:
  /// **'Wasifu Wangu'**
  String get my_profile_menu;

  /// No description provided for @settings_menu.
  ///
  /// In sw, this message translates to:
  /// **'Mipangilio'**
  String get settings_menu;

  /// No description provided for @logout_menu.
  ///
  /// In sw, this message translates to:
  /// **'Toka'**
  String get logout_menu;

  /// No description provided for @job_description_title.
  ///
  /// In sw, this message translates to:
  /// **'Maelezo ya Kazi'**
  String get job_description_title;

  /// No description provided for @client_budget.
  ///
  /// In sw, this message translates to:
  /// **'Bajeti ya Mteja'**
  String get client_budget;

  /// No description provided for @client_label.
  ///
  /// In sw, this message translates to:
  /// **'Mteja'**
  String get client_label;

  /// No description provided for @new_client_tag.
  ///
  /// In sw, this message translates to:
  /// **'Mteja Mpya'**
  String get new_client_tag;

  /// No description provided for @bids_title.
  ///
  /// In sw, this message translates to:
  /// **'Maombi yako'**
  String get bids_title;

  /// No description provided for @accept_btn.
  ///
  /// In sw, this message translates to:
  /// **'Kubali'**
  String get accept_btn;

  /// No description provided for @decline_btn.
  ///
  /// In sw, this message translates to:
  /// **'Kataa'**
  String get decline_btn;

  /// No description provided for @complete_job_code_btn.
  ///
  /// In sw, this message translates to:
  /// **'Weka Code ya Kumaliza'**
  String get complete_job_code_btn;

  /// No description provided for @ask_question_btn.
  ///
  /// In sw, this message translates to:
  /// **'Uliza Swali'**
  String get ask_question_btn;

  /// No description provided for @send_offer_btn.
  ///
  /// In sw, this message translates to:
  /// **'Tuma Ofa'**
  String get send_offer_btn;

  /// No description provided for @ask_question_title.
  ///
  /// In sw, this message translates to:
  /// **'Uliza Swali'**
  String get ask_question_title;

  /// No description provided for @enter_message_hint.
  ///
  /// In sw, this message translates to:
  /// **'Andika ujumbe wako...'**
  String get enter_message_hint;

  /// No description provided for @cancel_btn.
  ///
  /// In sw, this message translates to:
  /// **'Futa'**
  String get cancel_btn;

  /// No description provided for @send_message_btn.
  ///
  /// In sw, this message translates to:
  /// **'Tuma Ujumbe'**
  String get send_message_btn;

  /// No description provided for @send_offer_title.
  ///
  /// In sw, this message translates to:
  /// **'Tuma Ofa ya Bei'**
  String get send_offer_title;

  /// No description provided for @your_price_label.
  ///
  /// In sw, this message translates to:
  /// **'Bei yako (TSh)'**
  String get your_price_label;

  /// No description provided for @message_to_client_label.
  ///
  /// In sw, this message translates to:
  /// **'Ujumbe kwa mteja'**
  String get message_to_client_label;

  /// No description provided for @why_choose_you_hint.
  ///
  /// In sw, this message translates to:
  /// **'Kwa nini mteja akuchague?'**
  String get why_choose_you_hint;

  /// No description provided for @submit_application_btn.
  ///
  /// In sw, this message translates to:
  /// **'Tuma Ombi'**
  String get submit_application_btn;

  /// No description provided for @success_application_sent.
  ///
  /// In sw, this message translates to:
  /// **'Ombi lako limetumwa!'**
  String get success_application_sent;

  /// No description provided for @job_accepted_success.
  ///
  /// In sw, this message translates to:
  /// **'Umeikubali kazi hii.'**
  String get job_accepted_success;

  /// No description provided for @enter_completion_code.
  ///
  /// In sw, this message translates to:
  /// **'Ingiza Code'**
  String get enter_completion_code;

  /// No description provided for @verify_btn.
  ///
  /// In sw, this message translates to:
  /// **'Thibitisha'**
  String get verify_btn;

  /// No description provided for @job_completed_success.
  ///
  /// In sw, this message translates to:
  /// **'Hongera! Kazi imekamilika.'**
  String get job_completed_success;

  /// No description provided for @completion_failed.
  ///
  /// In sw, this message translates to:
  /// **'Code si sahihi. Jaribu tena.'**
  String get completion_failed;

  /// No description provided for @hello.
  ///
  /// In sw, this message translates to:
  /// **'Habari'**
  String get hello;

  /// No description provided for @loading.
  ///
  /// In sw, this message translates to:
  /// **'Inapakia...'**
  String get loading;

  /// No description provided for @job_details.
  ///
  /// In sw, this message translates to:
  /// **'Maelezo ya Kazi'**
  String get job_details;

  /// No description provided for @congratulations.
  ///
  /// In sw, this message translates to:
  /// **'Hongera sana!'**
  String get congratulations;

  /// No description provided for @job_completed_content.
  ///
  /// In sw, this message translates to:
  /// **'Kazi imekamilika na malipo yameingia.'**
  String get job_completed_content;

  /// No description provided for @you_earned.
  ///
  /// In sw, this message translates to:
  /// **'Umeingiza'**
  String get you_earned;

  /// No description provided for @ok_btn.
  ///
  /// In sw, this message translates to:
  /// **'Sawa'**
  String get ok_btn;

  /// No description provided for @active_job_title.
  ///
  /// In sw, this message translates to:
  /// **'Kazi ya Sasa'**
  String get active_job_title;

  /// No description provided for @completion_request_hint.
  ///
  /// In sw, this message translates to:
  /// **'Omba code kwa mteja umalize kazi'**
  String get completion_request_hint;

  /// No description provided for @service_label.
  ///
  /// In sw, this message translates to:
  /// **'Huduma'**
  String get service_label;

  /// No description provided for @enter_completion_code_title.
  ///
  /// In sw, this message translates to:
  /// **'Ingiza Code ya Kumaliza'**
  String get enter_completion_code_title;

  /// No description provided for @chat_with_client_btn.
  ///
  /// In sw, this message translates to:
  /// **'Chat na Mteja'**
  String get chat_with_client_btn;

  /// No description provided for @complete_job_button.
  ///
  /// In sw, this message translates to:
  /// **'Maliza Kazi'**
  String get complete_job_button;

  /// No description provided for @success_message_sent.
  ///
  /// In sw, this message translates to:
  /// **'Ujumbe umetumwa!'**
  String get success_message_sent;

  /// No description provided for @job_accept_failed.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindwa kukubali kazi.'**
  String get job_accept_failed;

  /// No description provided for @complete_job_title.
  ///
  /// In sw, this message translates to:
  /// **'Kamilisha Kazi'**
  String get complete_job_title;

  /// No description provided for @searching_messages.
  ///
  /// In sw, this message translates to:
  /// **'Tunasaka ujumbe...'**
  String get searching_messages;

  /// No description provided for @no_messages_found.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna ujumbe hapa'**
  String get no_messages_found;

  /// No description provided for @no_messages_found_sub.
  ///
  /// In sw, this message translates to:
  /// **'Ujumbe wako utaonekana hapa.'**
  String get no_messages_found_sub;

  /// No description provided for @failed_send_message.
  ///
  /// In sw, this message translates to:
  /// **'Ujumbe haujatuma.'**
  String get failed_send_message;

  /// No description provided for @no_messages_yet_start.
  ///
  /// In sw, this message translates to:
  /// **'Anza maongezi sasa hivi.'**
  String get no_messages_yet_start;

  /// No description provided for @rating_label.
  ///
  /// In sw, this message translates to:
  /// **'Rating'**
  String get rating_label;

  /// No description provided for @jobs_label.
  ///
  /// In sw, this message translates to:
  /// **'Kazi'**
  String get jobs_label;

  /// No description provided for @completion_label.
  ///
  /// In sw, this message translates to:
  /// **'Kukamilika'**
  String get completion_label;

  /// No description provided for @filter_active.
  ///
  /// In sw, this message translates to:
  /// **'Zinazoendelea'**
  String get filter_active;

  /// No description provided for @filter_nearby.
  ///
  /// In sw, this message translates to:
  /// **'Zilizokaribu'**
  String get filter_nearby;

  /// No description provided for @filter_high_pay.
  ///
  /// In sw, this message translates to:
  /// **'Bei Nzuri'**
  String get filter_high_pay;

  /// No description provided for @terms_accept_label.
  ///
  /// In sw, this message translates to:
  /// **'Nakubaliana na '**
  String get terms_accept_label;

  /// No description provided for @terms_link_text.
  ///
  /// In sw, this message translates to:
  /// **'VIGEZO NA MASHARTI'**
  String get terms_link_text;

  /// No description provided for @terms_error.
  ///
  /// In sw, this message translates to:
  /// **'Lazima ukubali vigezo na masharti'**
  String get terms_error;

  /// No description provided for @welcome_title_1.
  ///
  /// In sw, this message translates to:
  /// **'Karibu TendaPoa'**
  String get welcome_title_1;

  /// No description provided for @welcome_subtitle_1.
  ///
  /// In sw, this message translates to:
  /// **'Jukwaa la kuunganisha wafanyakazi na wateja kwa urahisi. Pata mfanyakazi, pata kazi.'**
  String get welcome_subtitle_1;

  /// No description provided for @welcome_title_2.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta Mfanyakazi'**
  String get welcome_title_2;

  /// No description provided for @welcome_subtitle_2.
  ///
  /// In sw, this message translates to:
  /// **'Pata mfanyakazi mzuri karibu nawe kwa dakika chache tu. Angalia kazi zake na uhakiki.'**
  String get welcome_subtitle_2;

  /// No description provided for @welcome_title_3.
  ///
  /// In sw, this message translates to:
  /// **'Pata Kazi'**
  String get welcome_title_3;

  /// No description provided for @welcome_subtitle_3.
  ///
  /// In sw, this message translates to:
  /// **'Kama wewe ni mfanyakazi, jisajili na uanze kupata kazi mbalimbali na kuongeza kipato.'**
  String get welcome_subtitle_3;

  /// No description provided for @welcome_title_4.
  ///
  /// In sw, this message translates to:
  /// **'Malipo Salama'**
  String get welcome_title_4;

  /// No description provided for @welcome_subtitle_4.
  ///
  /// In sw, this message translates to:
  /// **'Lipa kwa usalama kabisa. Pesa yako inatunzwa mpaka kazi ikamilike kikamilifu.'**
  String get welcome_subtitle_4;

  /// No description provided for @skip.
  ///
  /// In sw, this message translates to:
  /// **'Ruka'**
  String get skip;

  /// No description provided for @start_now.
  ///
  /// In sw, this message translates to:
  /// **'Anza Sasa'**
  String get start_now;

  /// No description provided for @continue_btn.
  ///
  /// In sw, this message translates to:
  /// **'Endelea'**
  String get continue_btn;

  /// No description provided for @have_account_login.
  ///
  /// In sw, this message translates to:
  /// **'Tayari nina akaunti? Ingia'**
  String get have_account_login;

  /// No description provided for @nyumbani_nav.
  ///
  /// In sw, this message translates to:
  /// **'Nyumbani'**
  String get nyumbani_nav;

  /// No description provided for @kazi_zangu_nav.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Zangu'**
  String get kazi_zangu_nav;

  /// No description provided for @inbox_nav.
  ///
  /// In sw, this message translates to:
  /// **'Inbox'**
  String get inbox_nav;

  /// No description provided for @wasifu_nav.
  ///
  /// In sw, this message translates to:
  /// **'Wasifu'**
  String get wasifu_nav;

  /// No description provided for @ask_worker_query.
  ///
  /// In sw, this message translates to:
  /// **'Unatafuta fundi gani leo?'**
  String get ask_worker_query;

  /// No description provided for @search_hint.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta fundi, huduma...'**
  String get search_hint;

  /// No description provided for @services_label.
  ///
  /// In sw, this message translates to:
  /// **'Huduma'**
  String get services_label;

  /// No description provided for @nearby_workers_label.
  ///
  /// In sw, this message translates to:
  /// **'Mafundi Karibu'**
  String get nearby_workers_label;

  /// No description provided for @no_workers_nearby.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna mafundi karibu kwa sasa.'**
  String get no_workers_nearby;

  /// No description provided for @failed_to_delete.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindwa kufuta'**
  String get failed_to_delete;

  /// No description provided for @payment_retried.
  ///
  /// In sw, this message translates to:
  /// **'Mchakato wa malipo umeanza tena.'**
  String get payment_retried;

  /// No description provided for @no_jobs_posted_yet.
  ///
  /// In sw, this message translates to:
  /// **'Hujaposti kazi bado'**
  String get no_jobs_posted_yet;

  /// No description provided for @dash_nav.
  ///
  /// In sw, this message translates to:
  /// **'Dash'**
  String get dash_nav;

  /// No description provided for @feed_nav.
  ///
  /// In sw, this message translates to:
  /// **'Feed'**
  String get feed_nav;

  /// No description provided for @working_status.
  ///
  /// In sw, this message translates to:
  /// **'Tenda Poa, Lipwa Poa!'**
  String get working_status;

  /// No description provided for @active_job_label.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Inayoendelea'**
  String get active_job_label;

  /// No description provided for @total_completed_jobs.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Zilizokamilika'**
  String get total_completed_jobs;

  /// No description provided for @your_rating.
  ///
  /// In sw, this message translates to:
  /// **'Rating Yako'**
  String get your_rating;

  /// No description provided for @withdraw_money_btn.
  ///
  /// In sw, this message translates to:
  /// **'Toa Pesa'**
  String get withdraw_money_btn;

  /// No description provided for @no_active_job_msg.
  ///
  /// In sw, this message translates to:
  /// **'Huna kazi inayoendelea sasa'**
  String get no_active_job_msg;

  /// No description provided for @complete_current_job_first.
  ///
  /// In sw, this message translates to:
  /// **'Kamilisha Kazi Iliyopo'**
  String get complete_current_job_first;

  /// No description provided for @cannot_see_new_jobs_msg.
  ///
  /// In sw, this message translates to:
  /// **'Huwezi kuona kazi mpya wakati una kazi inayoendelea. Tafadhali kamilisha kazi ya sasa kwanza.'**
  String get cannot_see_new_jobs_msg;

  /// No description provided for @view_your_job_btn.
  ///
  /// In sw, this message translates to:
  /// **'ANGALIA KAZI YAKO'**
  String get view_your_job_btn;

  /// No description provided for @job_market_label.
  ///
  /// In sw, this message translates to:
  /// **'Soko la Kazi'**
  String get job_market_label;

  /// No description provided for @no_jobs_available.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna Kazi Sasa'**
  String get no_jobs_available;

  /// No description provided for @try_again_later_msg.
  ///
  /// In sw, this message translates to:
  /// **'Jaribu tena baadaye au badilisha eneo'**
  String get try_again_later_msg;

  /// No description provided for @edit_profile_menu.
  ///
  /// In sw, this message translates to:
  /// **'Badili Wasifu'**
  String get edit_profile_menu;

  /// No description provided for @job_history_menu.
  ///
  /// In sw, this message translates to:
  /// **'Historia ya Kazi'**
  String get job_history_menu;

  /// No description provided for @help_menu.
  ///
  /// In sw, this message translates to:
  /// **'Msaada'**
  String get help_menu;

  /// No description provided for @worker_selected_success.
  ///
  /// In sw, this message translates to:
  /// **'Fundi amechaguliwa!'**
  String get worker_selected_success;

  /// No description provided for @failed_fetch_job_details.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindwa kupata taarifa za kazi'**
  String get failed_fetch_job_details;

  /// No description provided for @apply_job_dialog_title.
  ///
  /// In sw, this message translates to:
  /// **'Omba Kazi Hii'**
  String get apply_job_dialog_title;

  /// No description provided for @bid_hint.
  ///
  /// In sw, this message translates to:
  /// **'Andika bei yako na maelezo mafupi...'**
  String get bid_hint;

  /// No description provided for @posted_by_label.
  ///
  /// In sw, this message translates to:
  /// **'Ameposti kazi hii'**
  String get posted_by_label;

  /// No description provided for @completion_code_label.
  ///
  /// In sw, this message translates to:
  /// **'Kodi ya Kukamilisha'**
  String get completion_code_label;

  /// No description provided for @no_desc.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna maelezo'**
  String get no_desc;

  /// No description provided for @no_location.
  ///
  /// In sw, this message translates to:
  /// **'Mahali haijatajwa'**
  String get no_location;

  /// No description provided for @wallet_title.
  ///
  /// In sw, this message translates to:
  /// **'Mkoba Wangu'**
  String get wallet_title;

  /// No description provided for @deposit_btn.
  ///
  /// In sw, this message translates to:
  /// **'Weka Pesa'**
  String get deposit_btn;

  /// No description provided for @recent_transactions.
  ///
  /// In sw, this message translates to:
  /// **'Miamala ya Hivi Karibuni'**
  String get recent_transactions;

  /// No description provided for @no_transactions.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna miamala'**
  String get no_transactions;

  /// No description provided for @transaction.
  ///
  /// In sw, this message translates to:
  /// **'Muamala'**
  String get transaction;

  /// No description provided for @verifying_code.
  ///
  /// In sw, this message translates to:
  /// **'Inathibitisha...'**
  String get verifying_code;

  /// No description provided for @enter_code_error.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali weka kodi ya kukamilisha'**
  String get enter_code_error;

  /// No description provided for @status_label.
  ///
  /// In sw, this message translates to:
  /// **'HALI YA KAZI'**
  String get status_label;

  /// No description provided for @who_are_you.
  ///
  /// In sw, this message translates to:
  /// **'Wewe ni nani?'**
  String get who_are_you;

  /// No description provided for @role_muhitaji_title.
  ///
  /// In sw, this message translates to:
  /// **'Muhitaji'**
  String get role_muhitaji_title;

  /// No description provided for @role_muhitaji_desc.
  ///
  /// In sw, this message translates to:
  /// **'Ninatafuta mfanyakazi/fundi'**
  String get role_muhitaji_desc;

  /// No description provided for @role_mfanyakazi_title.
  ///
  /// In sw, this message translates to:
  /// **'Mfanyakazi'**
  String get role_mfanyakazi_title;

  /// No description provided for @role_mfanyakazi_desc.
  ///
  /// In sw, this message translates to:
  /// **'Mimi ni fundi, ninatafuta kazi'**
  String get role_mfanyakazi_desc;

  /// No description provided for @withdraw_request_title.
  ///
  /// In sw, this message translates to:
  /// **'Omba Kutoa Pesa'**
  String get withdraw_request_title;

  /// No description provided for @withdrawal_amount_label.
  ///
  /// In sw, this message translates to:
  /// **'Kiasi unachotoa'**
  String get withdrawal_amount_label;

  /// No description provided for @amount_hint.
  ///
  /// In sw, this message translates to:
  /// **'Mfano: 10000'**
  String get amount_hint;

  /// No description provided for @min_withdrawal_error.
  ///
  /// In sw, this message translates to:
  /// **'Kiwango cha chini ni 2000'**
  String get min_withdrawal_error;

  /// No description provided for @insufficient_balance_error.
  ///
  /// In sw, this message translates to:
  /// **'Salio halitoshi'**
  String get insufficient_balance_error;

  /// No description provided for @phone_networks_label.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya Simu (M-PESA/Tigo Pesa)'**
  String get phone_networks_label;

  /// No description provided for @submit_request_btn.
  ///
  /// In sw, this message translates to:
  /// **'Tuma Maombi'**
  String get submit_request_btn;

  /// No description provided for @withdrawal_success_msg.
  ///
  /// In sw, this message translates to:
  /// **'Maombi yako yametumwa kwa ajili ya uhakiki.'**
  String get withdrawal_success_msg;

  /// No description provided for @status_open.
  ///
  /// In sw, this message translates to:
  /// **'Ipo Wazi'**
  String get status_open;

  /// No description provided for @status_pending_applications.
  ///
  /// In sw, this message translates to:
  /// **'Inasubiri Maombi'**
  String get status_pending_applications;

  /// No description provided for @status_accepted.
  ///
  /// In sw, this message translates to:
  /// **'Inafanyiwa Kazi'**
  String get status_accepted;

  /// No description provided for @retry_payment_btn.
  ///
  /// In sw, this message translates to:
  /// **'Lipia Tena'**
  String get retry_payment_btn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
