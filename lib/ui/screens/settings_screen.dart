import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/router/app_router.dart';
import '../../providers/providers.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _packageInfo = info);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    final currentLang = settingsProvider.locale.languageCode;
    final langSubtitle =
        currentLang == 'sw' ? context.tr('swahili') : context.tr('english');

    final isClient = user?.isMuhitaji ?? true;
    final roleSubtitle =
        isClient ? loc.settings_role_client : loc.settings_role_worker;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: const CircleBorder(),
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
                      Expanded(
                        child: Text(
                          context.tr('settings'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      roleSubtitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                                    ? user!.name[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  color: cs.primary,
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
                              user?.name.isNotEmpty == true
                                  ? user!.name
                                  : context.tr('profile'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user != null && user.email.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader(context, context.tr('account').toUpperCase()),
                  _settingsCard(context, [
                    _tile(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: context.tr('edit_profile'),
                      subtitle: loc.settings_edit_profile_subtitle,
                      onTap: () async {
                        final refreshed = await Navigator.pushNamed(
                          context,
                          AppRouter.editProfile,
                        );
                        if (refreshed == true && mounted) setState(() {});
                      },
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    _tile(
                      context,
                      icon: Icons.lock_outline_rounded,
                      title: context.tr('change_password'),
                      subtitle: context.tr('strengthen_security_subtitle'),
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  ]),
                  const SizedBox(height: 25),
                  _sectionHeader(context, context.tr('settings_quick_access')),
                  _settingsCard(context, [
                    if (isClient) ...[
                      _tile(
                        context,
                        icon: Icons.inbox_outlined,
                        title: loc.settings_worker_inbox_client,
                        subtitle: context.tr('applications_tab'),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.clientApplications,
                        ),
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _tile(
                        context,
                        icon: Icons.add_circle_outline_rounded,
                        title: context.tr('post_job_title'),
                        subtitle: context.tr('what_help_today'),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.postJob),
                      ),
                    ] else ...[
                      _tile(
                        context,
                        icon: Icons.outbox_outlined,
                        title: loc.settings_my_applications_worker,
                        subtitle: context.tr('view_all'),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.workerMyApplications,
                        ),
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _tile(
                        context,
                        icon: Icons.account_balance_wallet_outlined,
                        title: context.tr('wallet_balance'),
                        subtitle: loc.settings_wallet_open_subtitle,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRouter.wallet),
                      ),
                      Divider(height: 1, color: theme.dividerColor),
                      _tile(
                        context,
                        icon: Icons.post_add_outlined,
                        title: context.tr('post_job_title'),
                        subtitle: context.tr('tips_description'),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRouter.workerPostJob,
                        ),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 25),
                  _sectionHeader(context, context.tr('general').toUpperCase()),
                  _settingsCard(context, [
                    _toggleTile(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: context.tr('notifications'),
                      subtitle: loc.settings_notifications_subtitle,
                      value: settingsProvider.notificationsEnabled,
                      onChanged: (v) =>
                          settingsProvider.setNotificationsEnabled(v),
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    _tile(
                      context,
                      icon: Icons.language_rounded,
                      title: context.tr('language'),
                      subtitle: langSubtitle,
                      onTap: () => _showLanguageSheet(
                        context,
                        settingsProvider,
                        authProvider,
                      ),
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer
                                      .withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.palette_outlined,
                                  color: cs.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.appearance,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    Text(
                                      _themeLabel(
                                        loc,
                                        settingsProvider.themeMode,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<ThemeMode>(
                              multiSelectionEnabled: false,
                              emptySelectionAllowed: false,
                              showSelectedIcon: false,
                              segments: [
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: const Icon(Icons.brightness_auto,
                                      size: 18),
                                  label: Text(loc.systemTheme),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: const Icon(Icons.light_mode, size: 18),
                                  label: Text(loc.lightTheme),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: const Icon(Icons.dark_mode, size: 18),
                                  label: Text(loc.darkTheme),
                                ),
                              ],
                              selected: {settingsProvider.themeMode},
                              onSelectionChanged: (next) {
                                if (next.isEmpty) return;
                                settingsProvider.setThemeMode(next.first);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 25),
                  _sectionHeader(context, context.tr('help_section_header')),
                  _settingsCard(context, [
                    _tile(
                      context,
                      icon: Icons.settings_suggest_outlined,
                      title: loc.settings_app_permissions,
                      subtitle: loc.settings_permissions_subtitle,
                      iconColor: const Color(0xFF6366F1),
                      onTap: () => AppSettings.openAppSettings(),
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    _tile(
                      context,
                      icon: Icons.support_agent_rounded,
                      title: context.tr('contact_us_whatsapp'),
                      subtitle: context.tr('get_help_fast'),
                      iconColor: const Color(0xFF25D366),
                      onTap: _openWhatsApp,
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    _tile(
                      context,
                      icon: Icons.payments_outlined,
                      title: context.tr('fees_payments_policy'),
                      subtitle: loc.fees_policy_subtitle,
                      onTap: () => _openUrl(
                        'https://tendapoa.com/fees-payments-policy',
                      ),
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    _tile(
                      context,
                      icon: Icons.shield_outlined,
                      title: context.tr('privacyPolicy'),
                      subtitle: loc.privacy_policy_subtitle,
                      onTap: () =>
                          _openUrl('https://tendapoa.com/privacy-policy'),
                    ),
                    Divider(height: 1, color: theme.dividerColor),
                    _tile(
                      context,
                      icon: Icons.description_outlined,
                      title: context.tr('termsOfService'),
                      subtitle: loc.terms_subtitle,
                      onTap: () => _openUrl(
                        'https://tendapoa.com/terms-and-conditions',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () async {
                        await authProvider.logout();
                        if (!context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.splash,
                          (route) => false,
                        );
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
                        backgroundColor: Colors.red.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _showDeleteAccountDialog(context),
                      icon: Icon(Icons.delete_forever_rounded,
                          color: Colors.red.shade800),
                      label: Text(
                        context.tr('delete_account'),
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Colors.red.shade800.withValues(alpha: 0.08),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          loc.appTitle,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_packageInfo != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            loc.app_version_line(
                              _packageInfo!.version,
                              _packageInfo!.buildNumber,
                            ),
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
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

  String _themeLabel(AppLocalizations loc, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return loc.systemTheme;
      case ThemeMode.light:
        return loc.lightTheme;
      case ThemeMode.dark:
        return loc.darkTheme;
    }
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: cs.onSurfaceVariant,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _settingsCard(BuildContext context, List<Widget> children) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final color = iconColor ?? cs.primary;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: cs.onSurface,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontSize: 12,
              ),
            )
          : null,
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: cs.outline,
      ),
      onTap: onTap,
    );
  }

  Widget _toggleTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cs.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: cs.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: cs.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: cs.primary.withValues(alpha: 0.55),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final currentPass = TextEditingController();
    final newPass = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => Container(
            padding: EdgeInsets.fromLTRB(25, 30, 25, bottomInset + 30),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('change_password'),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 25),
                _field(
                  ctx,
                  context.tr('current_password'),
                  currentPass,
                  Icons.lock_open_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                _field(
                  ctx,
                  context.tr('new_password'),
                  newPass,
                  Icons.lock_outline_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (newPass.text.length < 6) {
                              _showSnackbar(
                                context,
                                context.tr('register_password_min'),
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
                              if (context.mounted) {
                                _showSnackbar(
                                  context,
                                  context.tr('password_changed_success'),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                _showSnackbar(
                                  context,
                                  e.toString(),
                                  isError: true,
                                );
                              }
                            } finally {
                              setDialogState(() => isLoading = false);
                            }
                          },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            loc.change_password_now.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _field(
    BuildContext sheetContext,
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
  }) {
    final cs = Theme.of(sheetContext).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: cs.primary, size: 20),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
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

  void _showLanguageSheet(
    BuildContext context,
    SettingsProvider settingsProvider,
    AuthProvider authProvider,
  ) {
    final isMuhitaji = authProvider.user?.isMuhitaji ?? true;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  context.tr('chooseLanguage'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                  if (!context.mounted) return;
                  await _refetchDataAfterLanguageChange(context, isMuhitaji);
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
                  if (!context.mounted) return;
                  await _refetchDataAfterLanguageChange(context, isMuhitaji);
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

  Future<void> _refetchDataAfterLanguageChange(
    BuildContext context,
    bool isMuhitaji,
  ) async {
    try {
      if (isMuhitaji) {
        await context.read<ClientProvider>().loadMyJobs(silent: true);
        if (!context.mounted) return;
        await context.read<ClientProvider>().loadDashboard();
      } else {
        await context.read<WorkerProvider>().refreshAll();
      }
      if (!context.mounted) return;
      _showSnackbar(context, context.tr('language_updated_msg'));
    } catch (_) {
      if (!context.mounted) return;
      _showSnackbar(context, context.tr('language_updated_msg'));
    }
  }

  void _showSnackbar(BuildContext context, String msg, {bool isError = false}) {
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
    final messengerContext = context;
    try {
      final ok = await canLaunchUrl(uri);
      if (!messengerContext.mounted) return;
      if (ok) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackbar(
          messengerContext,
          messengerContext.tr('failed_open_link'),
          isError: true,
        );
      }
    } catch (e) {
      if (!messengerContext.mounted) return;
      _showSnackbar(
        messengerContext,
        '${messengerContext.tr('error_prefix')}: $e',
        isError: true,
      );
    }
  }

  Future<void> _openWhatsApp() async {
    const whatsappUrl =
        'https://api.whatsapp.com/send/?phone=255626957138&text&type=phone_number&app_absent=0';
    await _openUrl(whatsappUrl);
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final passwordCtrl = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => Container(
            padding: EdgeInsets.fromLTRB(25, 30, 25, bottomInset + 30),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.warning_amber_rounded,
                          color: Colors.red.shade700, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.tr('delete_account'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr('delete_account_warning'),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 25),
                _field(
                  ctx,
                  context.tr('current_password'),
                  passwordCtrl,
                  Icons.lock_open_rounded,
                  isPassword: true,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (passwordCtrl.text.isEmpty) {
                              _showSnackbar(
                                context,
                                context.tr('enter_password_prompt'),
                                isError: true,
                              );
                              return;
                            }
                            setDialogState(() => isLoading = true);
                            try {
                              await context
                                  .read<AuthProvider>()
                                  .deleteAccount(password: passwordCtrl.text);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  AppRouter.splash,
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              String msg = e.toString();
                              if (msg.contains('current_password') ||
                                  msg.contains('password')) {
                                if (context.mounted) {
                                  msg = context.tr('wrong_password');
                                }
                              }
                              if (context.mounted) {
                                _showSnackbar(context, msg, isError: true);
                              }
                            } finally {
                              setDialogState(() => isLoading = false);
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
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
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            context.tr('delete_account_confirm').toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(context.tr('cancel')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
