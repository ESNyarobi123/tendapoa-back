import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

  // Register Swahili locale for timeago
  timeago.setLocaleMessages(
      'sw', timeago.EnMessages()); // Using English as Swahili not available
  timeago.setDefaultLocale('sw');

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

  runApp(const TendapoaApp());
}

class TendapoaApp extends StatelessWidget {
  const TendapoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => WorkerProvider()),
        ChangeNotifierProvider(create: (_) => ClientProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
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
