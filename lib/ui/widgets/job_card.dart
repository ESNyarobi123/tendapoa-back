import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/models.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final VoidCallback? onRetryPayment;
  final VoidCallback? onCancel;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onRetryPayment,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.surfaceLight),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. IMAGE SECTION
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 1,
                      child: job.imageUrl != null
                          ? Image.network(job.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder())
                          : _buildPlaceholder(),
                    ),
                    // Gradient Overlay for better text readability if needed
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.3)
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Price Tag
                    Positioned(
                      top: 15,
                      right: 15,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: AppColors.walletAccent,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 10)
                            ]),
                        child: Text('TZS ${job.price}',
                            style: const TextStyle(
                                color: AppColors.textWhite,
                                fontWeight: FontWeight.w900,
                                fontSize: 13)),
                      ),
                    ),
                    // Category Tag
                    if (job.categoryName != null)
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(job.categoryName!,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),

                // 2. INFO SECTION
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: AppColors.surfaceLight,
                            child: Text(
                                job.userName?.isNotEmpty == true
                                    ? job.userName![0]
                                    : 'U',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text(job.userName ?? 'Mteja',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                          const Spacer(),
                          const Icon(Icons.access_time_rounded,
                              size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                              job.createdAt != null
                                  ? timeago.format(job.createdAt!, locale: Localizations.localeOf(context).languageCode)
                                  : context.tr('now'),
                              style: const TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),

                // 3. ACTION BAR (Only if needed)
                if (job.status == 'pending_payment')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    color: const Color(0xFFFFF7ED),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.walletAccent, size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                            child: Text('Inasubiri Malipo',
                                style: TextStyle(
                                    color: Color(0xFFEA580C),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold))),
                        if (onRetryPayment != null)
                          TextButton(
                              onPressed: onRetryPayment,
                              child: const Text('LIPA SASA',
                                  style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOut);
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: const Center(
          child: Icon(Icons.architecture_rounded,
              size: 40, color: Color(0xFFE2E8F0))),
    );
  }
}
