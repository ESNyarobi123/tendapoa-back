import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/constants/constants.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/localization/app_localizations.dart';
import 'data/services/storage_service.dart';
import 'providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service FIRST before anything else
  await StorageService().init();

  // Load saved language so app shows correct locale from first frame
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString(AppConstants.languageKey);
  final initialLocale = (savedLang != null && (savedLang == 'en' || savedLang == 'sw'))
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

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

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
        ChangeNotifierProvider(create: (_) => SettingsProvider(initialLocale: initialLocale)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Tendapoa',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppRouter.splash,
            onGenerateRoute: AppRouter.generateRoute,
            builder: (context, child) {
              final mediaQueryData = MediaQuery.of(context);
              final constrainedTextScaleFactor =
                  mediaQueryData.textScaler.clamp(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.2,
              );

              return MediaQuery(
                data: mediaQueryData.copyWith(
                    textScaler: constrainedTextScaleFactor),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
