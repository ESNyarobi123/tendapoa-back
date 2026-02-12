import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../providers/providers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final user = authProvider.user;
    final isClient = user?.isMuhitaji ?? true;
    final currentLang = settingsProvider.locale.languageCode;
    final langSubtitle = currentLang == 'sw' ? context.tr('swahili') : context.tr('english');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Blue Header
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        context.tr('settings'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Profile Summary
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: user?.profilePhotoUrl != null
                            ? NetworkImage(user!.profilePhotoUrl!)
                            : null,
                        child: user?.profilePhotoUrl == null
                            ? Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name[0]
                                    : 'U',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? context.tr('profile'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Settings Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ACCOUNT SECTION
                  _buildSectionHeader(context.tr('account').toUpperCase()),
                  _buildSettingsCard([
                    _buildSettingItem(
                      icon: Icons.person_outline_rounded,
                      title: context.tr('edit_profile'),
                      subtitle: user?.name ?? context.tr('client_label'),
                      onTap: () => _showEditProfileDialog(context),
                    ),
                    const Divider(height: 1),
                    _buildSettingItem(
                      icon: Icons.lock_outline_rounded,
                      title: currentLang == 'sw' ? 'Badili Password' : 'Change Password',
                      subtitle: currentLang == 'sw' ? 'Imarisha usalama wa akaunti' : 'Strengthen account security',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ]),

                  const SizedBox(height: 25),

                  // PREFERENCES SECTION
                  _buildSectionHeader(context.tr('general').toUpperCase()),
                  _buildSettingsCard([
                    _buildToggleItem(
                      icon: Icons.notifications_none_rounded,
                      title: context.tr('notifications'),
                      subtitle: currentLang == 'sw' ? 'Pata arifa za kazi na meseji' : 'Get job and message notifications',
                      value: _notificationsEnabled,
                      onChanged: (v) => setState(() => _notificationsEnabled = v),
                    ),
                    const Divider(height: 1),
                    _buildSettingItem(
                      icon: Icons.language_rounded,
                      title: context.tr('language'),
                      subtitle: langSubtitle,
                      onTap: () => _showLanguageSheet(context, settingsProvider, authProvider),
                    ),
                  ]),

                  const SizedBox(height: 25),

                  // SUPPORT SECTION
                  _buildSectionHeader(settingsProvider.locale.languageCode == 'sw' ? 'MSAADA NA TAARIFA' : 'HELP & INFO'),
                  _buildSettingsCard([
                    _buildSettingItem(
                      icon: Icons.support_agent_rounded,
                      title: 'Wasiliana Nasi (WhatsApp)',
                      subtitle: 'Pata msaada haraka',
                      iconColor: const Color(0xFF25D366),
                      onTap: () => _openWhatsApp(),
                    ),
                    const Divider(height: 1),
                    _buildSettingItem(
                      icon: Icons.payments_outlined,
                      title: 'Sera ya Malipo na Ada',
                      subtitle: 'Fees & Payments Policy',
                      onTap: () => _openUrl('https://tendapoa.com/fees-payments-policy'),
                    ),
                    const Divider(height: 1),
                    _buildSettingItem(
                      icon: Icons.description_outlined,
                      title: 'Vigezo na Masharti',
                      subtitle: 'Terms & Conditions',
                      onTap: () => _openUrl('https://tendapoa.com/terms-and-conditions'),
                    ),
                  ]),

                  const SizedBox(height: 30),

                  // LOGOUT
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/',
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: Text(
                        context.tr('logout'),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Version 1.0.0 • Tendapoa',
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final color = iconColor ?? AppColors.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Color(0xFFCBD5E1),
      ),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 12,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final nameController = TextEditingController(text: user?.name);
    final phoneController = TextEditingController(text: user?.phone);
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          padding: EdgeInsets.fromLTRB(
            25,
            30,
            25,
            MediaQuery.of(ctx).viewInsets.bottom + 30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hariri Wasifu',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 25),
              _buildField('Jina Kamili', nameController, Icons.person_rounded),
              const SizedBox(height: 20),
              _buildField(
                'Namba ya Simu',
                phoneController,
                Icons.phone_android_rounded,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() => isLoading = true);
                          try {
                            await context.read<AuthProvider>().updateProfile(
                              name: nameController.text.trim(),
                              phone: phoneController.text.trim(),
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSnackbar('Wasifu umesasishwa!');
                          } catch (e) {
                            _showSnackbar(e.toString(), isError: true);
                          } finally {
                            setDialogState(() => isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'HIFADHI MABADILIKO',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPass = TextEditingController();
    final newPass = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          padding: EdgeInsets.fromLTRB(
            25,
            30,
            25,
            MediaQuery.of(ctx).viewInsets.bottom + 30,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Badili Password',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 25),
              _buildField(
                'Password ya Sasa',
                currentPass,
                Icons.lock_open_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 20),
              _buildField(
                'Password Mpya',
                newPass,
                Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (newPass.text.length < 6) {
                            _showSnackbar(
                              'Password lazima iwe na angalau herufi 6',
                              isError: true,
                            );
                            return;
                          }
                          setDialogState(() => isLoading = true);
                          try {
                            await context.read<AuthProvider>().changePassword(
                              currentPassword: currentPass.text,
                              newPassword: newPass.text,
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSnackbar('Password imebadilishwa!');
                          } catch (e) {
                            _showSnackbar(e.toString(), isError: true);
                          } finally {
                            setDialogState(() => isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'BADILI SASA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  /// Language switcher: save locale + refetch so API returns title/description in new language
  void _showLanguageSheet(BuildContext context, SettingsProvider settingsProvider, AuthProvider authProvider) {
    final isMuhitaji = authProvider.user?.isMuhitaji ?? true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  context.tr('chooseLanguage'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(context.tr('english')),
                trailing: settingsProvider.locale.languageCode == 'en'
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  await settingsProvider.setLocale(const Locale('en'));
                  if (!ctx.mounted) return;
                  _refetchDataAfterLanguageChange(ctx, isMuhitaji);
                  if (mounted) setState(() {});
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(context.tr('swahili')),
                trailing: settingsProvider.locale.languageCode == 'sw'
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
                onTap: () async {
                  Navigator.pop(ctx);
                  await settingsProvider.setLocale(const Locale('sw'));
                  if (!ctx.mounted) return;
                  _refetchDataAfterLanguageChange(ctx, isMuhitaji);
                  if (mounted) setState(() {});
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refetchDataAfterLanguageChange(BuildContext context, bool isMuhitaji) async {
    try {
      if (isMuhitaji) {
        await context.read<ClientProvider>().loadMyJobs(silent: true);
        await context.read<ClientProvider>().loadDashboard();
      } else {
        await context.read<WorkerProvider>().refreshAll();
      }
      if (mounted) {
        _showSnackbar(
          context.tr('language') == 'Language'
              ? 'Language changed. Content updated.'
              : 'Lugha imebadilishwa. Maudhui yamesasishwa.',
        );
      }
    } catch (_) {
      if (mounted) _showSnackbar(context.tr('language') == 'Language' ? 'Language updated.' : 'Lugha imesasishwa.');
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackbar('Imeshindikana kufungua link', isError: true);
      }
    } catch (e) {
      _showSnackbar('Hitilafu: $e', isError: true);
    }
  }

  Future<void> _openWhatsApp() async {
    const whatsappUrl = 'https://api.whatsapp.com/send/?phone=255626957138&text&type=phone_number&app_absent=0';
    await _openUrl(whatsappUrl);
  }
}
