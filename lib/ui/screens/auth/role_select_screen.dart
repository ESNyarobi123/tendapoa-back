import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';

class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPaddingLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.verticalXxl,
              Text(context.tr('role_select_title'),
                  style: AppTextStyles.h1.copyWith(fontSize: 34, height: 1.1)),
              AppSpacing.verticalMd,
              Text(
                  context.tr('role_select_subtitle'),
                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary, height: 1.5)),
              AppSpacing.verticalXxl,
              _buildRoleCard(
                context,
                title: context.tr('role_muhitaji_title'),
                subtitle: context.tr('role_muhitaji_desc'),
                icon: Icons.person_search_rounded,
                color: AppColors.primaryDark,
                onTap: () => Navigator.pushNamed(context, '/register',
                    arguments: {'role': 'muhitaji'}),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              _buildRoleCard(
                context,
                title: context.tr('role_mfanyakazi_title'),
                subtitle: context.tr('role_mfanyakazi_desc'),
                icon: Icons.construction_rounded,
                color: AppColors.walletAccent,
                onTap: () => Navigator.pushNamed(context, '/register',
                    arguments: {'role': 'mfanyakazi'}),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                      children: [
                        TextSpan(text: context.tr('welcome_have_account')),
                        TextSpan(
                            text: context.tr('welcome_login_link'),
                            style: AppTextStyles.link.copyWith(decoration: TextDecoration.none)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: AppSpacing.borderRadius2xl,
          border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: color, borderRadius: AppSpacing.borderRadiusLg),
              child: Icon(icon, color: AppColors.textWhite, size: 30),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  AppSpacing.verticalXs,
                  Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
