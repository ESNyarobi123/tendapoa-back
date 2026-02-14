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
  /// **'Tunatafuta maMfanyakazi karibu...'**
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
  /// **'Kazi yako imepostiwa kwa mafanikio. MaMfanyakazi wataanza kuomba hivi punde.'**
  String get job_posted_message;

  /// No description provided for @workers_found_title.
  ///
  /// In sw, this message translates to:
  /// **'MaMfanyakazi Wamepatikana'**
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
  /// **'Hakuna MaMfanyakazi?'**
  String get no_workers_title;

  /// No description provided for @no_workers_message.
  ///
  /// In sw, this message translates to:
  /// **'Hatujapata maMfanyakazi karibu kwa sasa lakini tutaendelea kutafuta.'**
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
  /// **'Jinsi ya kupata Mfanyakazi'**
  String get how_to_find_worker;

  /// No description provided for @client_tagline.
  ///
  /// In sw, this message translates to:
  /// **'Pata Mfanyakazi Karibu Nawe'**
  String get client_tagline;

  /// No description provided for @what_help_today.
  ///
  /// In sw, this message translates to:
  /// **'Je, unahitaji msaada gani leo?'**
  String get what_help_today;

  /// No description provided for @view_map.
  ///
  /// In sw, this message translates to:
  /// **'Ona Ramani'**
  String get view_map;

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

  /// No description provided for @view_all_categories.
  ///
  /// In sw, this message translates to:
  /// **'Ona Kategoria Zote'**
  String get view_all_categories;

  /// No description provided for @all_paid_msg.
  ///
  /// In sw, this message translates to:
  /// **'Kazi zote zimelipwa vizuri!'**
  String get all_paid_msg;

  /// No description provided for @amount_to_pay_label.
  ///
  /// In sw, this message translates to:
  /// **'Kiasi cha kulipa:'**
  String get amount_to_pay_label;

  /// No description provided for @initiating_payment.
  ///
  /// In sw, this message translates to:
  /// **'Inaanzisha malipo...'**
  String get initiating_payment;

  /// No description provided for @confirm_payment_phone.
  ///
  /// In sw, this message translates to:
  /// **'Thibitisha malipo kwenye simu yako!'**
  String get confirm_payment_phone;

  /// No description provided for @refund_from_cancelled.
  ///
  /// In sw, this message translates to:
  /// **'Pesa hii ni refund kutoka kazi zilizofutwa'**
  String get refund_from_cancelled;

  /// No description provided for @posted_jobs_label.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Zilizoposti'**
  String get posted_jobs_label;

  /// No description provided for @balance_label.
  ///
  /// In sw, this message translates to:
  /// **'Salio lako:'**
  String get balance_label;

  /// No description provided for @mpesa_name_label.
  ///
  /// In sw, this message translates to:
  /// **'Jina la M-Pesa'**
  String get mpesa_name_label;

  /// No description provided for @mpesa_name_hint.
  ///
  /// In sw, this message translates to:
  /// **'Jina lililosajiliwa kwenye simu'**
  String get mpesa_name_hint;

  /// No description provided for @no_jobs_here.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna kazi hapa'**
  String get no_jobs_here;

  /// No description provided for @change_password.
  ///
  /// In sw, this message translates to:
  /// **'Badili Password'**
  String get change_password;

  /// No description provided for @strengthen_security_subtitle.
  ///
  /// In sw, this message translates to:
  /// **'Imarisha usalama wa akaunti'**
  String get strengthen_security_subtitle;

  /// No description provided for @notifications_subtitle.
  ///
  /// In sw, this message translates to:
  /// **'Pata arifa za kazi na meseji'**
  String get notifications_subtitle;

  /// No description provided for @help_section_header.
  ///
  /// In sw, this message translates to:
  /// **'MSAADA NA TAARIFA'**
  String get help_section_header;

  /// No description provided for @contact_us_whatsapp.
  ///
  /// In sw, this message translates to:
  /// **'Wasiliana Nasi (WhatsApp)'**
  String get contact_us_whatsapp;

  /// No description provided for @get_help_fast.
  ///
  /// In sw, this message translates to:
  /// **'Pata msaada haraka'**
  String get get_help_fast;

  /// No description provided for @fees_payments_policy.
  ///
  /// In sw, this message translates to:
  /// **'Sera ya Malipo na Ada'**
  String get fees_payments_policy;

  /// No description provided for @current_password.
  ///
  /// In sw, this message translates to:
  /// **'Password ya Sasa'**
  String get current_password;

  /// No description provided for @new_password.
  ///
  /// In sw, this message translates to:
  /// **'Password Mpya'**
  String get new_password;

  /// No description provided for @password_changed_success.
  ///
  /// In sw, this message translates to:
  /// **'Password imebadilishwa!'**
  String get password_changed_success;

  /// No description provided for @language_updated_msg.
  ///
  /// In sw, this message translates to:
  /// **'Lugha imesasishwa.'**
  String get language_updated_msg;

  /// No description provided for @failed_open_link.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindikana kufungua link'**
  String get failed_open_link;

  /// No description provided for @please_fill_here.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali jaza hapa'**
  String get please_fill_here;

  /// No description provided for @update_failed.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindikana kusasisha'**
  String get update_failed;

  /// No description provided for @location_service_disabled.
  ///
  /// In sw, this message translates to:
  /// **'Huduma ya eneo haijawashwa'**
  String get location_service_disabled;

  /// No description provided for @location_permission_denied.
  ///
  /// In sw, this message translates to:
  /// **'Ruhusa ya eneo imekataliwa'**
  String get location_permission_denied;

  /// No description provided for @location_permission_denied_forever.
  ///
  /// In sw, this message translates to:
  /// **'Ruhusa ya eneo imekataliwa kabisa'**
  String get location_permission_denied_forever;

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
  /// **'Anza kuongea na maMfanyakazi hapa.'**
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
  /// **'Imepewa Mfanyakazi'**
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
  /// **'Inasubiri Mfanyakazi'**
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
  /// **'Maombi ya MaMfanyakazi'**
  String get worker_applications;

  /// No description provided for @no_applications_yet.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna maombi bado'**
  String get no_applications_yet;

  /// No description provided for @wait_for_workers.
  ///
  /// In sw, this message translates to:
  /// **'Subiri maMfanyakazi waone kazi yako.'**
  String get wait_for_workers;

  /// No description provided for @assigned_worker.
  ///
  /// In sw, this message translates to:
  /// **'Mfanyakazi Aliyechaguliwa'**
  String get assigned_worker;

  /// No description provided for @completion_code_title.
  ///
  /// In sw, this message translates to:
  /// **'Code ya Kumaliza Kazi'**
  String get completion_code_title;

  /// No description provided for @give_code_instruction.
  ///
  /// In sw, this message translates to:
  /// **'Mpe Mfanyakazi code hii akimaliza kazi.'**
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
  /// **'Chat na Mfanyakazi'**
  String get chat_with_worker;

  /// No description provided for @select_worker.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Mfanyakazi'**
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
  /// **'Mfanyakazi'**
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

  /// No description provided for @now.
  ///
  /// In sw, this message translates to:
  /// **'Sasa hivi'**
  String get now;

  /// No description provided for @time_minutes.
  ///
  /// In sw, this message translates to:
  /// **'Dakika'**
  String get time_minutes;

  /// No description provided for @time_hours.
  ///
  /// In sw, this message translates to:
  /// **'Saa'**
  String get time_hours;

  /// No description provided for @time_days.
  ///
  /// In sw, this message translates to:
  /// **'Siku'**
  String get time_days;

  /// No description provided for @time_weeks.
  ///
  /// In sw, this message translates to:
  /// **'wiki'**
  String get time_weeks;

  /// No description provided for @time_ago_suffix.
  ///
  /// In sw, this message translates to:
  /// **'zilizopita'**
  String get time_ago_suffix;

  /// No description provided for @time_month.
  ///
  /// In sw, this message translates to:
  /// **'mwezi'**
  String get time_month;

  /// No description provided for @time_months.
  ///
  /// In sw, this message translates to:
  /// **'miezi'**
  String get time_months;

  /// No description provided for @distance_radius.
  ///
  /// In sw, this message translates to:
  /// **'Umbali (Radius)'**
  String get distance_radius;

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

  /// No description provided for @welcome_have_account.
  ///
  /// In sw, this message translates to:
  /// **'Tayari una akaunti? '**
  String get welcome_have_account;

  /// No description provided for @welcome_login_link.
  ///
  /// In sw, this message translates to:
  /// **'Ingia hapa'**
  String get welcome_login_link;

  /// No description provided for @login_welcome_title.
  ///
  /// In sw, this message translates to:
  /// **'Karibu Tena!'**
  String get login_welcome_title;

  /// No description provided for @login_subtitle.
  ///
  /// In sw, this message translates to:
  /// **'Ingia kwenye akaunti yako ili uendelee.'**
  String get login_subtitle;

  /// No description provided for @login_email_label.
  ///
  /// In sw, this message translates to:
  /// **'Barua Pepe'**
  String get login_email_label;

  /// No description provided for @login_email_hint.
  ///
  /// In sw, this message translates to:
  /// **'mfano@email.com'**
  String get login_email_hint;

  /// No description provided for @login_password_label.
  ///
  /// In sw, this message translates to:
  /// **'Nenosiri'**
  String get login_password_label;

  /// No description provided for @login_forgot_password.
  ///
  /// In sw, this message translates to:
  /// **'Umesahau Nenosiri?'**
  String get login_forgot_password;

  /// No description provided for @login_terms_agree.
  ///
  /// In sw, this message translates to:
  /// **'Nimekubali '**
  String get login_terms_agree;

  /// No description provided for @login_terms_link.
  ///
  /// In sw, this message translates to:
  /// **'Vigezo na Masharti'**
  String get login_terms_link;

  /// No description provided for @login_btn.
  ///
  /// In sw, this message translates to:
  /// **'Ingia Sasa'**
  String get login_btn;

  /// No description provided for @login_no_account.
  ///
  /// In sw, this message translates to:
  /// **'Huna akaunti? '**
  String get login_no_account;

  /// No description provided for @login_register_here.
  ///
  /// In sw, this message translates to:
  /// **'Jiunge hapa'**
  String get login_register_here;

  /// No description provided for @login_accept_terms_error.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali kubali vigezo na masharti'**
  String get login_accept_terms_error;

  /// No description provided for @login_failed_error.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindwa kuingia'**
  String get login_failed_error;

  /// No description provided for @login_enter_email.
  ///
  /// In sw, this message translates to:
  /// **'Weka barua pepe'**
  String get login_enter_email;

  /// No description provided for @login_enter_password.
  ///
  /// In sw, this message translates to:
  /// **'Weka nenosiri'**
  String get login_enter_password;

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
  /// **'Unatafuta Mfanyakazi gani leo?'**
  String get ask_worker_query;

  /// No description provided for @search_hint.
  ///
  /// In sw, this message translates to:
  /// **'Tafuta Mfanyakazi, huduma...'**
  String get search_hint;

  /// No description provided for @services_label.
  ///
  /// In sw, this message translates to:
  /// **'Huduma'**
  String get services_label;

  /// No description provided for @nearby_workers_label.
  ///
  /// In sw, this message translates to:
  /// **'MaMfanyakazi Karibu'**
  String get nearby_workers_label;

  /// No description provided for @no_workers_nearby.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna maMfanyakazi karibu kwa sasa.'**
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

  /// No description provided for @selected_jobs_title.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Zilizokuchagua'**
  String get selected_jobs_title;

  /// No description provided for @selected_jobs_subtitle.
  ///
  /// In sw, this message translates to:
  /// **'Wateja wamekuchagua - kubali au kataa'**
  String get selected_jobs_subtitle;

  /// No description provided for @assigned_jobs_appear_here.
  ///
  /// In sw, this message translates to:
  /// **'Kazi ulizopewa zitaonekana hapa'**
  String get assigned_jobs_appear_here;

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
  /// **'Mfanyakazi amechaguliwa!'**
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

  /// No description provided for @tap_to_expand.
  ///
  /// In sw, this message translates to:
  /// **'Bonyeza kukubwa'**
  String get tap_to_expand;

  /// No description provided for @verified_client.
  ///
  /// In sw, this message translates to:
  /// **'Mteja Aliyethibitishwa'**
  String get verified_client;

  /// No description provided for @your_application.
  ///
  /// In sw, this message translates to:
  /// **'Ombi Lako'**
  String get your_application;

  /// No description provided for @you_applied.
  ///
  /// In sw, this message translates to:
  /// **'Umeomba kazi hii'**
  String get you_applied;

  /// No description provided for @other_applications.
  ///
  /// In sw, this message translates to:
  /// **'Maombi Mengine'**
  String get other_applications;

  /// No description provided for @be_first_to_apply.
  ///
  /// In sw, this message translates to:
  /// **'Kuwa wa kwanza kuomba kazi hii!'**
  String get be_first_to_apply;

  /// No description provided for @your_proposed_price.
  ///
  /// In sw, this message translates to:
  /// **'Bei uliyopendekeza'**
  String get your_proposed_price;

  /// No description provided for @current_price_min_prefix.
  ///
  /// In sw, this message translates to:
  /// **'Bei ya sasa: TZS'**
  String get current_price_min_prefix;

  /// No description provided for @current_price_min_suffix.
  ///
  /// In sw, this message translates to:
  /// **'Min: TZS 1,000'**
  String get current_price_min_suffix;

  /// No description provided for @price_label_short.
  ///
  /// In sw, this message translates to:
  /// **'Bei: TZS'**
  String get price_label_short;

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

  /// No description provided for @role_select_title.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Aina ya Akaunti'**
  String get role_select_title;

  /// No description provided for @role_select_subtitle.
  ///
  /// In sw, this message translates to:
  /// **'Niambie namna ungependa kutumia Tendapoa ili tusaidie vizuri.'**
  String get role_select_subtitle;

  /// No description provided for @role_muhitaji_title.
  ///
  /// In sw, this message translates to:
  /// **'Muhitaji'**
  String get role_muhitaji_title;

  /// No description provided for @role_muhitaji_desc.
  ///
  /// In sw, this message translates to:
  /// **'Ninatafuta mfanyakazi/Mfanyakazi'**
  String get role_muhitaji_desc;

  /// No description provided for @role_mfanyakazi_title.
  ///
  /// In sw, this message translates to:
  /// **'Mfanyakazi'**
  String get role_mfanyakazi_title;

  /// No description provided for @role_mfanyakazi_desc.
  ///
  /// In sw, this message translates to:
  /// **'Mimi ni Mfanyakazi, ninatafuta kazi'**
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

  /// No description provided for @withdrawal_request_title.
  ///
  /// In sw, this message translates to:
  /// **'Ombi la Uchukuliaji'**
  String get withdrawal_request_title;

  /// No description provided for @amount_to_withdraw_label.
  ///
  /// In sw, this message translates to:
  /// **'Kiasi unachotaka kutoa'**
  String get amount_to_withdraw_label;

  /// No description provided for @enter_amount_required.
  ///
  /// In sw, this message translates to:
  /// **'Weka kiasi'**
  String get enter_amount_required;

  /// No description provided for @invalid_number_error.
  ///
  /// In sw, this message translates to:
  /// **'Namba si sahihi'**
  String get invalid_number_error;

  /// No description provided for @min_2000_error.
  ///
  /// In sw, this message translates to:
  /// **'Kiwango cha chini ni 2,000'**
  String get min_2000_error;

  /// No description provided for @payment_phone_label.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya Simu ya Malipo'**
  String get payment_phone_label;

  /// No description provided for @enter_phone_required.
  ///
  /// In sw, this message translates to:
  /// **'Weka namba'**
  String get enter_phone_required;

  /// No description provided for @error_occurred.
  ///
  /// In sw, this message translates to:
  /// **'Hitilafu ilitokea'**
  String get error_occurred;

  /// No description provided for @try_again_btn.
  ///
  /// In sw, this message translates to:
  /// **'Jaribu Tena'**
  String get try_again_btn;

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

  /// No description provided for @register_password_mismatch.
  ///
  /// In sw, this message translates to:
  /// **'Nenosiri halifanani!'**
  String get register_password_mismatch;

  /// No description provided for @register_failed.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindwa kusajili'**
  String get register_failed;

  /// No description provided for @register_location_required_title.
  ///
  /// In sw, this message translates to:
  /// **'Eneo Linahitajika!'**
  String get register_location_required_title;

  /// No description provided for @register_location_required_subtitle.
  ///
  /// In sw, this message translates to:
  /// **'Kama mfanyakazi, eneo lako ni lazima ili:'**
  String get register_location_required_subtitle;

  /// No description provided for @register_location_reason_1.
  ///
  /// In sw, this message translates to:
  /// **'Wateja waone umbali wako'**
  String get register_location_reason_1;

  /// No description provided for @register_location_reason_2.
  ///
  /// In sw, this message translates to:
  /// **'Upate kazi zilizo karibu nawe'**
  String get register_location_reason_2;

  /// No description provided for @register_location_reason_3.
  ///
  /// In sw, this message translates to:
  /// **'Mfumo uhesabu umbali kwa usahihi'**
  String get register_location_reason_3;

  /// No description provided for @register_location_ok_btn.
  ///
  /// In sw, this message translates to:
  /// **'SAWA, NITAWEKA ENEO'**
  String get register_location_ok_btn;

  /// No description provided for @register_badge_muhitaji.
  ///
  /// In sw, this message translates to:
  /// **'Muhitaji / Mteja'**
  String get register_badge_muhitaji;

  /// No description provided for @register_badge_mfanyakazi.
  ///
  /// In sw, this message translates to:
  /// **'Mfanyakazi / Mfanyakazi'**
  String get register_badge_mfanyakazi;

  /// No description provided for @register_title_muhitaji.
  ///
  /// In sw, this message translates to:
  /// **'Karibu TendaPoa!'**
  String get register_title_muhitaji;

  /// No description provided for @register_title_mfanyakazi.
  ///
  /// In sw, this message translates to:
  /// **'Jiunge na TendaPoa!'**
  String get register_title_mfanyakazi;

  /// No description provided for @register_subtitle_muhitaji.
  ///
  /// In sw, this message translates to:
  /// **'Pata wafanyakazi wazuri karibu nawe'**
  String get register_subtitle_muhitaji;

  /// No description provided for @register_subtitle_mfanyakazi.
  ///
  /// In sw, this message translates to:
  /// **'Anza kupata kazi karibu nawe leo'**
  String get register_subtitle_mfanyakazi;

  /// No description provided for @register_section_personal.
  ///
  /// In sw, this message translates to:
  /// **'Taarifa Binafsi'**
  String get register_section_personal;

  /// No description provided for @register_full_name.
  ///
  /// In sw, this message translates to:
  /// **'Jina Kamili'**
  String get register_full_name;

  /// No description provided for @register_full_name_hint.
  ///
  /// In sw, this message translates to:
  /// **'Mfano: Juma Ramadhani'**
  String get register_full_name_hint;

  /// No description provided for @register_full_name_error.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali weka jina lako'**
  String get register_full_name_error;

  /// No description provided for @register_email_error.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali weka email'**
  String get register_email_error;

  /// No description provided for @register_email_invalid.
  ///
  /// In sw, this message translates to:
  /// **'Email si sahihi'**
  String get register_email_invalid;

  /// No description provided for @register_phone_error.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali weka namba ya simu'**
  String get register_phone_error;

  /// No description provided for @register_phone_invalid.
  ///
  /// In sw, this message translates to:
  /// **'Namba ya simu si sahihi'**
  String get register_phone_invalid;

  /// No description provided for @register_section_security.
  ///
  /// In sw, this message translates to:
  /// **'Usalama'**
  String get register_section_security;

  /// No description provided for @register_confirm_password.
  ///
  /// In sw, this message translates to:
  /// **'Thibitisha Nenosiri'**
  String get register_confirm_password;

  /// No description provided for @register_confirm_password_error.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali thibitisha nenosiri'**
  String get register_confirm_password_error;

  /// No description provided for @register_password_min.
  ///
  /// In sw, this message translates to:
  /// **'Nenosiri liwe na herufi 6 au zaidi'**
  String get register_password_min;

  /// No description provided for @register_terms_notice.
  ///
  /// In sw, this message translates to:
  /// **'Kwa kusajili, unakubali Masharti na Sera ya Faragha yetu.'**
  String get register_terms_notice;

  /// No description provided for @register_btn_muhitaji.
  ///
  /// In sw, this message translates to:
  /// **'TENGENEZA AKAUNTI'**
  String get register_btn_muhitaji;

  /// No description provided for @register_btn_mfanyakazi.
  ///
  /// In sw, this message translates to:
  /// **'JIUNGE KAMA Mfanyakazi'**
  String get register_btn_mfanyakazi;

  /// No description provided for @register_location_title.
  ///
  /// In sw, this message translates to:
  /// **'Eneo Lako'**
  String get register_location_title;

  /// No description provided for @register_required_badge.
  ///
  /// In sw, this message translates to:
  /// **'LAZIMA'**
  String get register_required_badge;

  /// No description provided for @register_location_found.
  ///
  /// In sw, this message translates to:
  /// **'Eneo limepatikana!'**
  String get register_location_found;

  /// No description provided for @register_location_tap.
  ///
  /// In sw, this message translates to:
  /// **'Bonyeza kupata eneo lako'**
  String get register_location_tap;

  /// No description provided for @register_location_help.
  ///
  /// In sw, this message translates to:
  /// **'Eneo lako linasaidia wateja kukupata kwa urahisi na kupata kazi zilizo karibu nawe.'**
  String get register_location_help;

  /// No description provided for @register_location_searching.
  ///
  /// In sw, this message translates to:
  /// **'Inatafuta eneo...'**
  String get register_location_searching;

  /// No description provided for @register_location_refresh.
  ///
  /// In sw, this message translates to:
  /// **'Sasisha Eneo'**
  String get register_location_refresh;

  /// No description provided for @register_location_get_btn.
  ///
  /// In sw, this message translates to:
  /// **'PATA ENEO LANGU'**
  String get register_location_get_btn;

  /// No description provided for @register_location_success.
  ///
  /// In sw, this message translates to:
  /// **'Eneo lako limepatikana!'**
  String get register_location_success;

  /// No description provided for @register_location_disabled.
  ///
  /// In sw, this message translates to:
  /// **'Huduma ya eneo haijawashwa. Tafadhali washa GPS.'**
  String get register_location_disabled;

  /// No description provided for @register_location_denied.
  ///
  /// In sw, this message translates to:
  /// **'Ruhusa ya eneo imekataliwa'**
  String get register_location_denied;

  /// No description provided for @register_location_denied_forever.
  ///
  /// In sw, this message translates to:
  /// **'Ruhusa ya eneo imekataliwa kabisa. Nenda Settings kubadilisha.'**
  String get register_location_denied_forever;

  /// No description provided for @register_location_failed.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindikana kupata eneo'**
  String get register_location_failed;

  /// No description provided for @splash_tagline.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Imeisha!'**
  String get splash_tagline;

  /// No description provided for @confirm_delete_title.
  ///
  /// In sw, this message translates to:
  /// **'Futa Kazi?'**
  String get confirm_delete_title;

  /// No description provided for @min_amount_error.
  ///
  /// In sw, this message translates to:
  /// **'Kiasi cha chini ni TZS 5,000'**
  String get min_amount_error;

  /// No description provided for @fill_all_fields.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali jaza taarifa zote'**
  String get fill_all_fields;

  /// No description provided for @withdrawal_submitted.
  ///
  /// In sw, this message translates to:
  /// **'Ombi lako limewasilishwa! Subiri uthibitisho.'**
  String get withdrawal_submitted;

  /// No description provided for @error_prefix.
  ///
  /// In sw, this message translates to:
  /// **'Hitilafu'**
  String get error_prefix;

  /// No description provided for @post_job_new.
  ///
  /// In sw, this message translates to:
  /// **'Post Kazi Mpya'**
  String get post_job_new;

  /// No description provided for @gps_enable_first.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali washa GPS yako kwanza'**
  String get gps_enable_first;

  /// No description provided for @location_detected.
  ///
  /// In sw, this message translates to:
  /// **'Eneo limetambuliwa'**
  String get location_detected;

  /// No description provided for @job_location_placeholder.
  ///
  /// In sw, this message translates to:
  /// **'Eneo la Kazi'**
  String get job_location_placeholder;

  /// No description provided for @step_details.
  ///
  /// In sw, this message translates to:
  /// **'Maelezo'**
  String get step_details;

  /// No description provided for @step_location_post.
  ///
  /// In sw, this message translates to:
  /// **'Eneo & Post'**
  String get step_location_post;

  /// No description provided for @post_need_help.
  ///
  /// In sw, this message translates to:
  /// **'Unahitaji msaidizi gani?'**
  String get post_need_help;

  /// No description provided for @post_fill_details.
  ///
  /// In sw, this message translates to:
  /// **'Jaza taarifa hizi ili maMfanyakazi wa karibu waanze kuomba.'**
  String get post_fill_details;

  /// No description provided for @post_title_hint.
  ///
  /// In sw, this message translates to:
  /// **'Mfano: Napata Mfanyakazi bomba wa kurekebisha sinki'**
  String get post_title_hint;

  /// No description provided for @post_budget_hint.
  ///
  /// In sw, this message translates to:
  /// **'Mfano: 20,000'**
  String get post_budget_hint;

  /// No description provided for @post_description_hint.
  ///
  /// In sw, this message translates to:
  /// **'Elezea kazi kwa undani zaidi hapa...'**
  String get post_description_hint;

  /// No description provided for @post_description_error.
  ///
  /// In sw, this message translates to:
  /// **'Elezea kazi yako'**
  String get post_description_error;

  /// No description provided for @post_location_help.
  ///
  /// In sw, this message translates to:
  /// **'Tunatumia GPS yako kutambua eneo ili maMfanyakazi wa karibu zaidi waone kazi yako.'**
  String get post_location_help;

  /// No description provided for @post_location_searching.
  ///
  /// In sw, this message translates to:
  /// **'Inatafuta eneo...'**
  String get post_location_searching;

  /// No description provided for @post_allow_gps.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali ruhusu GPS kwanza'**
  String get post_allow_gps;

  /// No description provided for @post_retry_location.
  ///
  /// In sw, this message translates to:
  /// **'RUDIA KUTAFUTA'**
  String get post_retry_location;

  /// No description provided for @post_searching_workers.
  ///
  /// In sw, this message translates to:
  /// **'Inatafuta wafanyakazi karibu nawe...'**
  String get post_searching_workers;

  /// No description provided for @post_no_workers_nearby.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna Wafanyakazi Karibu'**
  String get post_no_workers_nearby;

  /// No description provided for @post_continue_anyway.
  ///
  /// In sw, this message translates to:
  /// **'Unaweza kuendelea lakini muda wa kupata mfanyakazi unaweza kuwa mrefu.'**
  String get post_continue_anyway;

  /// No description provided for @post_workers_found.
  ///
  /// In sw, this message translates to:
  /// **'Wafanyakazi Wamepatikana!'**
  String get post_workers_found;

  /// No description provided for @post_job_visible_soon.
  ///
  /// In sw, this message translates to:
  /// **'Kazi yako itaonekana haraka!'**
  String get post_job_visible_soon;

  /// No description provided for @post_within_km.
  ///
  /// In sw, this message translates to:
  /// **'ndani'**
  String get post_within_km;

  /// No description provided for @post_continue_btn.
  ///
  /// In sw, this message translates to:
  /// **'Endelea'**
  String get post_continue_btn;

  /// No description provided for @choose_photo.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Picha'**
  String get choose_photo;

  /// No description provided for @camera.
  ///
  /// In sw, this message translates to:
  /// **'Kamera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In sw, this message translates to:
  /// **'Galeri'**
  String get gallery;

  /// No description provided for @profile_updated.
  ///
  /// In sw, this message translates to:
  /// **'Wasifu umesasishwa!'**
  String get profile_updated;

  /// No description provided for @today.
  ///
  /// In sw, this message translates to:
  /// **'Leo'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In sw, this message translates to:
  /// **'Jana'**
  String get yesterday;

  /// No description provided for @mark_all_read.
  ///
  /// In sw, this message translates to:
  /// **'Soma Zote'**
  String get mark_all_read;

  /// No description provided for @no_notifications.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna Taarifa'**
  String get no_notifications;

  /// No description provided for @notifications_empty_sub.
  ///
  /// In sw, this message translates to:
  /// **'Taarifa zako zitaonekana hapa'**
  String get notifications_empty_sub;

  /// No description provided for @edit_job_title.
  ///
  /// In sw, this message translates to:
  /// **'Hariri Kazi'**
  String get edit_job_title;

  /// No description provided for @select_job_location.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali chagua eneo la kazi kwenye ramani'**
  String get select_job_location;

  /// No description provided for @price_cannot_decrease.
  ///
  /// In sw, this message translates to:
  /// **'Huwezi kupunguza bei. Bei ya sasa ni TZS'**
  String get price_cannot_decrease;

  /// No description provided for @extra_payment_required.
  ///
  /// In sw, this message translates to:
  /// **'Malipo ya ziada yanahitajika'**
  String get extra_payment_required;

  /// No description provided for @job_updated.
  ///
  /// In sw, this message translates to:
  /// **'Kazi imebadilishwa!'**
  String get job_updated;

  /// No description provided for @refund_note.
  ///
  /// In sw, this message translates to:
  /// **'Kama kazi ililipiwa, pesa itarudishwa kwenye wallet yako.'**
  String get refund_note;

  /// No description provided for @job_deleted.
  ///
  /// In sw, this message translates to:
  /// **'Kazi imefutwa!'**
  String get job_deleted;

  /// No description provided for @cannot_edit.
  ///
  /// In sw, this message translates to:
  /// **'Huwezi Kuhariri'**
  String get cannot_edit;

  /// No description provided for @cannot_edit_reason.
  ///
  /// In sw, this message translates to:
  /// **'Kazi hii haiwezi kuhaririwa kwa sababu imeanza au imekamilika.'**
  String get cannot_edit_reason;

  /// No description provided for @edit_section_title.
  ///
  /// In sw, this message translates to:
  /// **'Kichwa cha Kazi'**
  String get edit_section_title;

  /// No description provided for @edit_section_category.
  ///
  /// In sw, this message translates to:
  /// **'Kategoria'**
  String get edit_section_category;

  /// No description provided for @edit_section_price.
  ///
  /// In sw, this message translates to:
  /// **'Bei (TZS)'**
  String get edit_section_price;

  /// No description provided for @edit_section_description.
  ///
  /// In sw, this message translates to:
  /// **'Maelezo'**
  String get edit_section_description;

  /// No description provided for @edit_price_hint.
  ///
  /// In sw, this message translates to:
  /// **'Mfano: 25000'**
  String get edit_price_hint;

  /// No description provided for @edit_price_required.
  ///
  /// In sw, this message translates to:
  /// **'Weka bei'**
  String get edit_price_required;

  /// No description provided for @edit_price_min.
  ///
  /// In sw, this message translates to:
  /// **'Bei lazima iwe TZS 500+'**
  String get edit_price_min;

  /// No description provided for @edit_current_price_prefix.
  ///
  /// In sw, this message translates to:
  /// **'Bei ya sasa: TZS '**
  String get edit_current_price_prefix;

  /// No description provided for @edit_current_price_suffix.
  ///
  /// In sw, this message translates to:
  /// **'. Unaweza kuongeza tu, si kupunguza.'**
  String get edit_current_price_suffix;

  /// No description provided for @edit_my_location.
  ///
  /// In sw, this message translates to:
  /// **'Eneo Langu'**
  String get edit_my_location;

  /// No description provided for @edit_address.
  ///
  /// In sw, this message translates to:
  /// **'Anwani'**
  String get edit_address;

  /// No description provided for @edit_title_hint.
  ///
  /// In sw, this message translates to:
  /// **'Mfano: Mfanyakazi Bomba Anahitajika'**
  String get edit_title_hint;

  /// No description provided for @edit_title_required.
  ///
  /// In sw, this message translates to:
  /// **'Weka kichwa'**
  String get edit_title_required;

  /// No description provided for @edit_description_hint.
  ///
  /// In sw, this message translates to:
  /// **'Eleza kazi kwa undani...'**
  String get edit_description_hint;

  /// No description provided for @edit_select_category.
  ///
  /// In sw, this message translates to:
  /// **'Chagua kategoria'**
  String get edit_select_category;

  /// No description provided for @edit_section_image.
  ///
  /// In sw, this message translates to:
  /// **'Picha ya Kazi'**
  String get edit_section_image;

  /// No description provided for @edit_tap_add_photo.
  ///
  /// In sw, this message translates to:
  /// **'Bonyeza kuongeza picha'**
  String get edit_tap_add_photo;

  /// No description provided for @edit_change_photo.
  ///
  /// In sw, this message translates to:
  /// **'Badilisha'**
  String get edit_change_photo;

  /// No description provided for @edit_address_placeholder.
  ///
  /// In sw, this message translates to:
  /// **'Bonyeza ramani kuchagua eneo'**
  String get edit_address_placeholder;

  /// No description provided for @payment_check_phone.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali kagua simu yako na uingize PIN ya M-Pesa...'**
  String get payment_check_phone;

  /// No description provided for @payment_timeout.
  ///
  /// In sw, this message translates to:
  /// **'Muda umeisha. Malipo hayajakamilika.'**
  String get payment_timeout;

  /// No description provided for @payment_success_msg.
  ///
  /// In sw, this message translates to:
  /// **'Malipo Yamefanikiwa! Kazi yako sasa ipo hewani.'**
  String get payment_success_msg;

  /// No description provided for @payment_retrying.
  ///
  /// In sw, this message translates to:
  /// **'Inaanzisha malipo tena...'**
  String get payment_retrying;

  /// No description provided for @payment_retry_failed.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindikana kuanzisha malipo. Jaribu tena.'**
  String get payment_retry_failed;

  /// No description provided for @payment_retry_btn.
  ///
  /// In sw, this message translates to:
  /// **'JARIBU TENA'**
  String get payment_retry_btn;

  /// No description provided for @cancel_and_go_back.
  ///
  /// In sw, this message translates to:
  /// **'Futa na Rudi Nyuma'**
  String get cancel_and_go_back;

  /// No description provided for @payment_dont_close.
  ///
  /// In sw, this message translates to:
  /// **'Usifunge ukurasa huu mpaka utakapopata uthibitisho.'**
  String get payment_dont_close;

  /// No description provided for @payment_check_phone_label.
  ///
  /// In sw, this message translates to:
  /// **'Angalia simu'**
  String get payment_check_phone_label;

  /// No description provided for @payment_enter_pin.
  ///
  /// In sw, this message translates to:
  /// **'Ingiza PIN'**
  String get payment_enter_pin;

  /// No description provided for @payment_confirm.
  ///
  /// In sw, this message translates to:
  /// **'Thibitisha'**
  String get payment_confirm;

  /// No description provided for @payment_status_completed.
  ///
  /// In sw, this message translates to:
  /// **'MALIPO YAMEKAMILIKA'**
  String get payment_status_completed;

  /// No description provided for @payment_status_failed.
  ///
  /// In sw, this message translates to:
  /// **'MALIPO YAMESHINDIKANA'**
  String get payment_status_failed;

  /// No description provided for @payment_status_waiting.
  ///
  /// In sw, this message translates to:
  /// **'INASUBIRI MALIPO'**
  String get payment_status_waiting;

  /// No description provided for @payment_exit_title.
  ///
  /// In sw, this message translates to:
  /// **'Unataka Kutoka?'**
  String get payment_exit_title;

  /// No description provided for @payment_exit_message.
  ///
  /// In sw, this message translates to:
  /// **'Ikiwa malipo bado yanaendelea, kazi yako itachapishwa baada ya malipo kukamilika.'**
  String get payment_exit_message;

  /// No description provided for @continue_waiting.
  ///
  /// In sw, this message translates to:
  /// **'Endelea Kusubiri'**
  String get continue_waiting;

  /// No description provided for @leave_btn.
  ///
  /// In sw, this message translates to:
  /// **'Toka'**
  String get leave_btn;

  /// No description provided for @dash_balance_label.
  ///
  /// In sw, this message translates to:
  /// **'SALIO LAKO'**
  String get dash_balance_label;

  /// No description provided for @dash_withdraw_btn.
  ///
  /// In sw, this message translates to:
  /// **'TOA PESA (Withdraw)'**
  String get dash_withdraw_btn;

  /// No description provided for @dash_total_earnings.
  ///
  /// In sw, this message translates to:
  /// **'Mapato Jumla'**
  String get dash_total_earnings;

  /// No description provided for @dash_withdrawn.
  ///
  /// In sw, this message translates to:
  /// **'Imechukuliwa'**
  String get dash_withdrawn;

  /// No description provided for @dash_jobs_completed.
  ///
  /// In sw, this message translates to:
  /// **'Kazi Zilizomalizika'**
  String get dash_jobs_completed;

  /// No description provided for @dash_monthly_jobs.
  ///
  /// In sw, this message translates to:
  /// **'Kazi za Mwezi'**
  String get dash_monthly_jobs;

  /// No description provided for @dash_earnings_history.
  ///
  /// In sw, this message translates to:
  /// **'Historia ya Mapato'**
  String get dash_earnings_history;

  /// No description provided for @dash_withdrawal_history.
  ///
  /// In sw, this message translates to:
  /// **'Historia ya Uchukuliaji'**
  String get dash_withdrawal_history;

  /// No description provided for @view_all_btn.
  ///
  /// In sw, this message translates to:
  /// **'Ona Zote'**
  String get view_all_btn;

  /// No description provided for @wallet_my_wallet.
  ///
  /// In sw, this message translates to:
  /// **'Mkoba Wangu'**
  String get wallet_my_wallet;

  /// No description provided for @wallet_balance_now.
  ///
  /// In sw, this message translates to:
  /// **'SALIO LAKO LA SASA'**
  String get wallet_balance_now;

  /// No description provided for @wallet_add_balance.
  ///
  /// In sw, this message translates to:
  /// **'Ongeza Salio'**
  String get wallet_add_balance;

  /// No description provided for @wallet_withdraw.
  ///
  /// In sw, this message translates to:
  /// **'Toa Fedha'**
  String get wallet_withdraw;

  /// No description provided for @wallet_payment_history.
  ///
  /// In sw, this message translates to:
  /// **'Historia ya Malipo'**
  String get wallet_payment_history;

  /// No description provided for @wallet_view_all.
  ///
  /// In sw, this message translates to:
  /// **'Ona Zote'**
  String get wallet_view_all;

  /// No description provided for @wallet_no_history.
  ///
  /// In sw, this message translates to:
  /// **'Bado hujaanza kutumia mkoba'**
  String get wallet_no_history;

  /// No description provided for @wallet_credit.
  ///
  /// In sw, this message translates to:
  /// **'Pesa Ingia'**
  String get wallet_credit;

  /// No description provided for @wallet_debit.
  ///
  /// In sw, this message translates to:
  /// **'Pesa Toka'**
  String get wallet_debit;

  /// No description provided for @withdrawal_insufficient.
  ///
  /// In sw, this message translates to:
  /// **'Salio lako halitoshi. Unahitaji TZS'**
  String get withdrawal_insufficient;

  /// No description provided for @withdrawal_failed_submit.
  ///
  /// In sw, this message translates to:
  /// **'Imeshindikana kutuma ombi'**
  String get withdrawal_failed_submit;

  /// No description provided for @withdrawal_title.
  ///
  /// In sw, this message translates to:
  /// **'Toa Pesa'**
  String get withdrawal_title;

  /// No description provided for @withdrawal_subtitle.
  ///
  /// In sw, this message translates to:
  /// **'Jaza fomu hii kutoa pesa kwenye simu yako'**
  String get withdrawal_subtitle;

  /// No description provided for @withdrawal_amount_section.
  ///
  /// In sw, this message translates to:
  /// **'Kiasi cha Kutoa'**
  String get withdrawal_amount_section;

  /// No description provided for @withdrawal_amount_hint.
  ///
  /// In sw, this message translates to:
  /// **'Weka kiasi (mf. 10000)'**
  String get withdrawal_amount_hint;

  /// No description provided for @withdrawal_amount_required.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali weka kiasi'**
  String get withdrawal_amount_required;

  /// No description provided for @withdrawal_min_label.
  ///
  /// In sw, this message translates to:
  /// **'Kiasi cha chini:'**
  String get withdrawal_min_label;

  /// No description provided for @withdrawal_fee_label.
  ///
  /// In sw, this message translates to:
  /// **'Makato ya huduma:'**
  String get withdrawal_fee_label;

  /// No description provided for @withdrawal_you_receive.
  ///
  /// In sw, this message translates to:
  /// **'Utapokea:'**
  String get withdrawal_you_receive;

  /// No description provided for @withdrawal_network_section.
  ///
  /// In sw, this message translates to:
  /// **'Chagua Mtandao'**
  String get withdrawal_network_section;

  /// No description provided for @withdrawal_phone_section.
  ///
  /// In sw, this message translates to:
  /// **'Nambari ya Simu'**
  String get withdrawal_phone_section;

  /// No description provided for @withdrawal_phone_hint.
  ///
  /// In sw, this message translates to:
  /// **'07XXXXXXXX'**
  String get withdrawal_phone_hint;

  /// No description provided for @withdrawal_phone_required.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali weka nambari ya simu'**
  String get withdrawal_phone_required;

  /// No description provided for @withdrawal_phone_invalid.
  ///
  /// In sw, this message translates to:
  /// **'Nambari ya simu si sahihi'**
  String get withdrawal_phone_invalid;

  /// No description provided for @withdrawal_name_section.
  ///
  /// In sw, this message translates to:
  /// **'Jina Lililosajiliwa'**
  String get withdrawal_name_section;

  /// No description provided for @withdrawal_name_hint.
  ///
  /// In sw, this message translates to:
  /// **'Jina linaloonekana kwenye M-Pesa/Tigo Pesa'**
  String get withdrawal_name_hint;

  /// No description provided for @withdrawal_name_required.
  ///
  /// In sw, this message translates to:
  /// **'Tafadhali weka jina lililosajiliwa'**
  String get withdrawal_name_required;

  /// No description provided for @withdrawal_name_short.
  ///
  /// In sw, this message translates to:
  /// **'Jina ni fupi sana'**
  String get withdrawal_name_short;

  /// No description provided for @withdrawal_submit_btn.
  ///
  /// In sw, this message translates to:
  /// **'TUMA OMBI LA KUTOA PESA'**
  String get withdrawal_submit_btn;

  /// No description provided for @withdrawal_success_title.
  ///
  /// In sw, this message translates to:
  /// **'Ombi Limetumwa!'**
  String get withdrawal_success_title;

  /// No description provided for @withdrawal_success_body.
  ///
  /// In sw, this message translates to:
  /// **'Ombi lako la kutoa TZS'**
  String get withdrawal_success_body;

  /// No description provided for @withdrawal_success_footer.
  ///
  /// In sw, this message translates to:
  /// **'Subiri uthibitisho wa Admin. Pesa itatumwa ndani ya masaa 24.'**
  String get withdrawal_success_footer;

  /// No description provided for @withdrawal_ok_btn.
  ///
  /// In sw, this message translates to:
  /// **'SAWA'**
  String get withdrawal_ok_btn;

  /// No description provided for @withdrawal_history_title.
  ///
  /// In sw, this message translates to:
  /// **'Historia ya Kutoa Pesa'**
  String get withdrawal_history_title;

  /// No description provided for @withdrawal_no_history.
  ///
  /// In sw, this message translates to:
  /// **'Hakuna historia ya kutoa pesa'**
  String get withdrawal_no_history;

  /// No description provided for @withdrawal_important_note.
  ///
  /// In sw, this message translates to:
  /// **'Muhimu!'**
  String get withdrawal_important_note;

  /// No description provided for @withdrawal_note_body.
  ///
  /// In sw, this message translates to:
  /// **'Hakikisha nambari ya simu na jina ni sahihi. Pesa itatumwa ndani ya masaa 24 baada ya uthibitisho wa Admin.'**
  String get withdrawal_note_body;

  /// No description provided for @withdrawal_status_paid.
  ///
  /// In sw, this message translates to:
  /// **'Imelipwa'**
  String get withdrawal_status_paid;

  /// No description provided for @withdrawal_status_rejected.
  ///
  /// In sw, this message translates to:
  /// **'Imekataliwa'**
  String get withdrawal_status_rejected;

  /// No description provided for @withdrawal_status_pending.
  ///
  /// In sw, this message translates to:
  /// **'Inasubiri'**
  String get withdrawal_status_pending;
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
