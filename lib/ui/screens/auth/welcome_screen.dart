import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/settings_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, dynamic>> _buildPages(BuildContext context) => [
        {
          'color': AppColors.primaryDark,
          'icon': Icons.rocket_launch_rounded,
          'title': context.tr('welcome_title_1'),
          'subtitle': context.tr('welcome_subtitle_1'),
        },
        {
          'color': AppColors.walletAccent,
          'icon': Icons.search_rounded,
          'title': context.tr('welcome_title_2'),
          'subtitle': context.tr('welcome_subtitle_2'),
        },
        {
          'color': AppColors.success,
          'icon': Icons.verified_user_rounded,
          'title': context.tr('welcome_title_3'),
          'subtitle': context.tr('welcome_subtitle_3'),
        },
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Background soft shapes
          Positioned(
            top: -150,
            right: -100,
            child: CircleAvatar(
                radius: 200,
                backgroundColor:
                    (_buildPages(context)[_currentPage]['color'] as Color).withValues(alpha: 0.05)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top controls
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language Toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: AppSpacing.borderRadiusRound),
                        child: Row(
                          children: [
                            _buildLangBtn(
                                'SW',
                                settings.locale.languageCode == 'sw',
                                () => settings.setLocale(const Locale('sw'))),
                            _buildLangBtn(
                                'EN',
                                settings.locale.languageCode == 'en',
                                () => settings.setLocale(const Locale('en'))),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, '/role-select'),
                        child: Text(context.tr('skip'),
                            style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _buildPages(context).length,
                    onPageChanged: (v) => setState(() => _currentPage = v),
                    itemBuilder: (ctx, i) => _buildPage(context, i),
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
                  child: Column(
                    children: [
                      // Page Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                            _buildPages(context).length,
                            (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentPage == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentPage == index
                                        ? _buildPages(context)[index]['color'] as Color
                                        : AppColors.grey200,
                                    borderRadius: AppSpacing.borderRadiusSm,
                                  ),
                                )),
                      ),
                      const SizedBox(height: 40),

                      Builder(
                        builder: (ctx) {
                          final pages = _buildPages(ctx);
                          return SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentPage == pages.length - 1) {
                                  Navigator.pushReplacementNamed(
                                      context, '/role-select');
                                } else {
                                  _pageController.nextPage(
                                      duration: 500.ms,
                                      curve: Curves.easeOutQuart);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pages[_currentPage]['color'] as Color,
                                foregroundColor: AppColors.textWhite,
                                shape: RoundedRectangleBorder(
                                    borderRadius: AppSpacing.borderRadiusLg),
                                elevation: 0,
                              ),
                              child: Text(
                                  _currentPage == pages.length - 1
                                      ? context.tr('start_now')
                                      : context.tr('continue_btn'),
                                  style: AppTextStyles.buttonLarge.copyWith(color: AppColors.textWhite, fontSize: 16)),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 20),
                      Builder(
                        builder: (ctx) {
                          final pages = _buildPages(ctx);
                          return TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/login'),
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                                children: [
                                  TextSpan(text: context.tr('welcome_have_account')),
                                  TextSpan(
                                      text: context.tr('welcome_login_link'),
                                      style: AppTextStyles.labelLarge.copyWith(color: pages[_currentPage]['color'] as Color)),
                                ],
                              ),
                            ),
                          );
                        },
                      ).animate().fadeIn(delay: 400.ms),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: AppSpacing.borderRadiusRound,
          boxShadow: active
              ? [
                  BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 5)
                ]
              : null,
        ),
        child: Text(label,
            style: AppTextStyles.labelMedium.copyWith(
                color: active ? AppColors.primary : AppColors.textLight)),
      ),
    );
  }

  Widget _buildPage(BuildContext context, int index) {
    final page = _buildPages(context)[index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: (page['color'] as Color).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page['icon'] as IconData,
                size: 80, color: page['color'] as Color),
          )
              .animate(key: ValueKey(index))
              .scale(duration: 600.ms, curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 30),
          Text(
            page['title']!,
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(fontSize: 26, letterSpacing: -1),
          )
              .animate(key: ValueKey('t$index'))
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 15),
          Text(
            page['subtitle']!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.5),
          )
              .animate(key: ValueKey('s$index'))
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
