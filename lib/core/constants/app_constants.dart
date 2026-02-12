/// App-wide constants
class AppConstants {
  AppConstants._();

  // ===== API CONFIGURATION =====
  static const String baseUrl = 'https://tendapoa.com/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);

  // ===== STORAGE KEYS =====
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';
  static const String fcmTokenKey = 'fcm_token';
  static const String categoriesKey = 'categories_cache';
  static const String settingsKey = 'settings_cache';
  /// Language for API Accept-Language header (same key as SettingsProvider)
  static const String languageKey = 'app_language';

  // ===== USER ROLES =====
  static const String roleMuhitaji = 'muhitaji';
  static const String roleMfanyakazi = 'mfanyakazi';

  // ===== JOB STATUS =====
  // API returns these status values
  static const String statusOpen = 'open';
  static const String statusPosted = 'posted';
  static const String statusPending = 'pending';
  static const String statusPendingPayment = 'pending_payment';
  static const String statusPaid = 'paid';
  static const String statusAccepted = 'accepted';
  static const String statusInProgress = 'in_progress';
  static const String statusAssigned = 'assigned';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';

  // ===== POLLING =====
  static const Duration paymentPollingInterval = Duration(seconds: 5);
  static const Duration chatPollingInterval = Duration(seconds: 3);
  static const int maxPollingAttempts = 60;

  // ===== CACHE =====
  static const Duration categoriesCacheDuration = Duration(hours: 24);
  static const Duration settingsCacheDuration = Duration(hours: 12);

  // ===== MAP =====
  static const double defaultLat = -6.7924;
  static const double defaultLng = 39.2083;
  static const double defaultZoom = 14.0;
  static const double maxRadius = 50.0;

  // ===== IMAGE =====
  static const int maxImageSize = 2048;
  static const int imageQuality = 85;

  // ===== ANIMATIONS =====
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 2);

  // ===== VALIDATION =====
  static const int minPasswordLength = 6;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int minPrice = 1000;
  static const int maxPrice = 10000000;

  // ===== CURRENCY =====
  static const String currency = 'TSh';
  static const String currencyCode = 'TZS';
}
