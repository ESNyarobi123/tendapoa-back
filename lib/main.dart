import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/tendapoa_material_themes.dart';
import 'data/services/storage_service.dart';
import 'data/services/firebase_messaging_service.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service FIRST before anything else
  await StorageService().init();

  // Firebase + FCM. Gracefully handles missing google-services.json
  // during development so the app keeps working.
  try {
    await Firebase.initializeApp();
    await FirebaseMessagingService.instance.init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Firebase] init skipped: $e');
    }
  }

  // Load saved language so app shows correct locale from first frame
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString(AppConstants.languageKey);
  final initialLocale =
      (savedLang != null && (savedLang == 'en' || savedLang == 'sw'))
          ? Locale(savedLang)
          : const Locale('sw');

  // Register Swahili locale for timeago
  timeago.setLocaleMessages(
      'sw', timeago.EnMessages()); // Using English as Swahili not available
  timeago.setDefaultLocale(initialLocale.languageCode);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(TendapoaApp(initialLocale: initialLocale));
}

class TendapoaApp extends StatelessWidget {
  final Locale? initialLocale;

  const TendapoaApp({super.key, this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(
            create: (_) => SettingsProvider(initialLocale: initialLocale)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Tendapoa',
            debugShowCheckedModeBanner: false,
            themeMode: settings.themeMode,
            theme: TendapoaMaterialThemes.light(),
            darkTheme: TendapoaMaterialThemes.dark(),
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (deviceLocale, supported) {
              if (deviceLocale != null) {
                for (final loc in supported) {
                  if (loc.languageCode == deviceLocale.languageCode) {
                    return loc;
                  }
                }
              }
              return supported.isNotEmpty
                  ? supported.first
                  : const Locale('sw');
            },
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              final theme = Theme.of(context);
              final cs = theme.colorScheme;
              final brightness = theme.brightness;
              SystemChrome.setSystemUIOverlayStyle(
                SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: brightness == Brightness.dark
                      ? Brightness.light
                      : Brightness.dark,
                  systemNavigationBarColor: cs.surface,
                  systemNavigationBarIconBrightness:
                      brightness == Brightness.dark
                          ? Brightness.light
                          : Brightness.dark,
                ),
              );

              final mediaQueryData = MediaQuery.of(context);
              final constrainedTextScaleFactor =
                  mediaQueryData.textScaler.clamp(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.2,
              );

              return MediaQuery(
                data: mediaQueryData.copyWith(
                  textScaler: constrainedTextScaleFactor,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}
