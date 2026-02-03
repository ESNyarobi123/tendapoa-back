import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/constants.dart';
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
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Mipangilio (Settings)',
            style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        children: [
          // ACCOUNT SECTION
          _buildSectionHeader('AKAUNTI YAKO'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.person_outline_rounded,
              title: 'Hariri Wasifu',
              subtitle: user?.name ?? 'Mteja',
              onTap: () => _showEditProfileDialog(context),
            ),
            const Divider(height: 1),
            _buildSettingItem(
              icon: Icons.lock_outline_rounded,
              title: 'Badili Password',
              subtitle: 'Imarisha usalama wa akaunti',
              onTap: () => _showChangePasswordDialog(context),
            ),
          ]),

          const SizedBox(height: 35),

          // PREFERENCES SECTION
          _buildSectionHeader('MAPENDEKEZO (PREFERENCES)'),
          _buildSettingsCard([
            _buildToggleItem(
              icon: Icons.notifications_none_rounded,
              title: 'Taarifa (Notifications)',
              subtitle: 'Pata arifa za kazi na meseji',
              value: _notificationsEnabled,
              onChanged: (v) => setState(() => _notificationsEnabled = v),
            ),
            const Divider(height: 1),
            _buildSettingItem(
              icon: Icons.language_rounded,
              title: 'Lugha (Language)',
              subtitle: 'Kiswahili (Tanzania)',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 35),

          // SUPPORT SECTION
          _buildSectionHeader('MSAADA NA TAARIFA'),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.help_outline_rounded,
              title: 'Kitovu cha Msaada',
              onTap: () {},
            ),
            const Divider(height: 1),
            _buildSettingItem(
              icon: Icons.description_outlined,
              title: 'Vigezo na Masharti',
              onTap: () {},
            ),
            const Divider(height: 1),
            _buildSettingItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Sera ya Faragha',
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 50),

          // LOGOUT
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                await authProvider.logout();
                if (mounted)
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('TOKA KWENYE AKAUNTI',
                  style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1)),
            ),
          ),

          const SizedBox(height: 20),
          const Center(
            child: Text('Version 1.0.4 • Made with ♥ by Tendapoa',
                style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: Color(0xFF94A3B8),
              letterSpacing: 1.2)),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem(
      {required IconData icon,
      required String title,
      String? subtitle,
      required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF475569), size: 22),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B))),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: Color(0xFFCBD5E1)),
      onTap: onTap,
    );
  }

  Widget _buildToggleItem(
      {required IconData icon,
      required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: const Color(0xFF475569), size: 22),
      ),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1E293B))),
      subtitle: Text(subtitle,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
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
              25, 30, 25, MediaQuery.of(ctx).viewInsets.bottom + 30),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Hariri Wasifu',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _buildField('Jina Kamili', nameController, Icons.person_rounded),
              const SizedBox(height: 20),
              _buildField('Namba ya Simu', phoneController,
                  Icons.phone_android_rounded),
              const SizedBox(height: 35),
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
                                phone: phoneController.text.trim());
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
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('HIFADHI MABADILIKO',
                          style: TextStyle(fontWeight: FontWeight.bold)),
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
              25, 30, 25, MediaQuery.of(ctx).viewInsets.bottom + 30),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Badili Password',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 25),
              _buildField(
                  'Password ya Sasa', currentPass, Icons.lock_open_rounded,
                  isPassword: true),
              const SizedBox(height: 20),
              _buildField('Password Mpya', newPass, Icons.lock_outline_rounded,
                  isPassword: true),
              const SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (newPass.text.length < 6) {
                            _showSnackbar(
                                'Password lazima iwe na angalau herufi 6',
                                isError: true);
                            return;
                          }
                          setDialogState(() => isLoading = true);
                          try {
                            await context.read<AuthProvider>().changePassword(
                                currentPassword: currentPass.text,
                                newPassword: newPass.text);
                            if (ctx.mounted) Navigator.pop(ctx);
                            _showSnackbar('Password imebadilishwa kikamilifu!');
                          } catch (e) {
                            _showSnackbar(e.toString(), isError: true);
                          } finally {
                            setDialogState(() => isLoading = false);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('BADILI SASA',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, IconData icon,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF64748B),
                fontSize: 13)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
