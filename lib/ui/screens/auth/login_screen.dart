import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../ui/widgets/buttons.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.tr('login_accept_terms_error')),
          backgroundColor: AppColors.error));
      return;
    }
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
        _emailController.text.trim(), _passwordController.text);
    if (success && mounted) {
      final user = authProvider.user;
      if (user != null) {
        Navigator.pushReplacementNamed(context,
            user.isMuhitaji ? AppRouter.clientHome : AppRouter.workerHome);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(authProvider.error ?? context.tr('login_failed_error')),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPaddingLarge,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.verticalMd,
                // Language switcher (SW | EN) – same as welcome screen
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildLangChip(
                      'SW',
                      settingsProvider.locale.languageCode == 'sw',
                      () => settingsProvider.setLocale(const Locale('sw')),
                    ),
                    AppSpacing.horizontalSm,
                    _buildLangChip(
                      'EN',
                      settingsProvider.locale.languageCode == 'en',
                      () => settingsProvider.setLocale(const Locale('en')),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle),
                    child: Image.asset('assets/images/tendalogo.jpg',
                        width: 60,
                        height: 60,
                        errorBuilder: (c, e, s) => const Icon(
                            Icons.flash_on_rounded,
                            size: 40,
                            color: AppColors.primary)),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 30),
                Center(
                    child: Text(context.tr('login_welcome_title'),
                        style: AppTextStyles.h1)),
                const SizedBox(height: 10),
                Center(
                    child: Text(context.tr('login_subtitle'),
                        style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary))),
                const SizedBox(height: 50),

                // Inputs
                _buildLabel(context.tr('login_email_label')),
                _buildInput(
                  controller: _emailController,
                  hint: context.tr('login_email_hint'),
                  icon: Icons.email_outlined,
                  validator: (v) =>
                      v!.isEmpty ? context.tr('login_enter_email') : null,
                ),
                const SizedBox(height: 20),
                _buildLabel(context.tr('login_password_label')),
                _buildInput(
                  controller: _passwordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppColors.textLight),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? context.tr('login_enter_password') : null,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {},
                      child: Text(context.tr('login_forgot_password'),
                          style: AppTextStyles.link)),
                ),

                const SizedBox(height: 15),

                // Terms
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: (v) =>
                            setState(() => _acceptedTerms = v ?? false),
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          children: [
                            TextSpan(text: context.tr('login_terms_agree')),
                            TextSpan(
                              text: context.tr('login_terms_link'),
                              style: AppTextStyles.link,
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse(
                                      'https://tendapoa.com/terms-and-conditions');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url,
                                        mode: LaunchMode.externalApplication);
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                Consumer<AuthProvider>(
                  builder: (_, auth, __) => PrimaryButton(
                    text: context.tr('login_btn'),
                    onPressed: _login,
                    isLoading: auth.isLoading,
                    isFullWidth: true,
                  ),
                ),

                const SizedBox(height: 30),
                Center(
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouter.roleSelect),
                    child: RichText(
                      text: TextSpan(
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                        children: [
                          TextSpan(text: context.tr('login_no_account')),
                          TextSpan(
                              text: context.tr('login_register_here'),
style: AppTextStyles.link.copyWith(decoration: TextDecoration.none)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceLight,
          borderRadius: AppSpacing.borderRadiusRound,
          border: active ? Border.all(color: AppColors.primary, width: 1.5) : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: active ? AppColors.primary : AppColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text, style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary)));
  }

  Widget _buildInput(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool obscureText = false,
      Widget? suffix,
      String? Function(String?)? validator}) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: AppSpacing.borderRadiusLg,
          border: Border.all(color: AppColors.surfaceLight)),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: AppSpacing.iconSizeSm, color: AppColors.textLight),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textLight),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
