import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../providers/settings_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'color': const Color(0xFF1E40AF),
      'icon': Icons.rocket_launch_rounded,
      'title': 'Karibu Tendapoa',
      'subtitle':
          'Suluhisho rahisi la kupata mafundi na wafanyakazi wa ndani kwa haraka na usalama.',
    },
    {
      'color': const Color(0xFFF97316),
      'icon': Icons.search_rounded,
      'title': 'Tafuta kwa Urahisi',
      'subtitle':
          'Pata fundi yeyote unayemhitaji karibu nawe. Kuanzia mafundi bomba hadi walimu wa ziada.',
    },
    {
      'color': const Color(0xFF059669),
      'icon': Icons.verified_user_rounded,
      'title': 'Huduma ya Uhakika',
      'subtitle':
          'Malipo yako ni salama. Tunatoa hakikisho la ubora kwa kila kazi unayoomba.',
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background soft shapes
          Positioned(
            top: -150,
            right: -100,
            child: CircleAvatar(
                radius: 200,
                backgroundColor:
                    _pages[_currentPage]['color'].withValues(alpha: 0.05)),
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
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(30)),
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
                        child: const Text('Ruka',
                            style: TextStyle(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (v) => setState(() => _currentPage = v),
                    itemBuilder: (ctx, i) => _buildPage(i),
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
                            _pages.length,
                            (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  width: _currentPage == index ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentPage == index
                                        ? _pages[index]['color']
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _pages.length - 1) {
                              Navigator.pushReplacementNamed(
                                  context, '/role-select');
                            } else {
                              _pageController.nextPage(
                                  duration: 500.ms, curve: Curves.easeOutQuart);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pages[_currentPage]['color'],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 0,
                          ),
                          child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'Anza Sasa'
                                  : 'Endelea',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.1, end: 0),

                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                color: Color(0xFF64748B), fontSize: 14),
                            children: [
                              const TextSpan(text: 'Tayari una akaunti? '),
                              TextSpan(
                                  text: 'Ingia hapa',
                                  style: TextStyle(
                                      color: _pages[_currentPage]['color'],
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
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
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5)
                ]
              : null,
        ),
        child: Text(label,
            style: TextStyle(
                color: active ? AppColors.primary : const Color(0xFF94A3B8),
                fontWeight: FontWeight.bold,
                fontSize: 12)),
      ),
    );
  }

  Widget _buildPage(int index) {
    final page = _pages[index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: page['color'].withValues(alpha: 0.1),
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
            style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: -1),
          )
              .animate(key: ValueKey('t$index'))
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 15),
          Text(
            page['subtitle']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 14, color: Color(0xFF64748B), height: 1.5),
          )
              .animate(key: ValueKey('s$index'))
              .fadeIn(delay: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}
