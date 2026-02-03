import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/providers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  String? _role;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _role = (args != null && args['role'] != null) ? args['role'] : 'muhitaji';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Nenosiri halifanani'),
          backgroundColor: AppColors.error));
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _role!,
    );

    if (success && mounted) {
      final user = authProvider.user;
      if (user != null) {
        Navigator.pushReplacementNamed(context,
            user.isMuhitaji ? AppRouter.clientHome : AppRouter.workerHome);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(authProvider.error ?? 'Imeshindwa kusajili'),
          backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor =
        _role == 'muhitaji' ? const Color(0xFF1E40AF) : const Color(0xFFF97316);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E293B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            _role == 'muhitaji'
                ? 'Akaunti ya Muhitaji'
                : 'Akaunti ya Mfanyakazi',
            style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 17,
                fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Jisajili Sasa',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                const Text('Jaza fomu hii kwa usahihi kujiunga na Tendapoa.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                const SizedBox(height: 35),
                _buildLabel('Jina Kamili'),
                _buildInput(
                    controller: _nameController,
                    hint: 'Mfano: Juma Ramadhani',
                    icon: Icons.person_outline_rounded),
                const SizedBox(height: 20),
                _buildLabel('Barua Pepe'),
                _buildInput(
                    controller: _emailController,
                    hint: 'mfano@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildLabel('Namba ya Simu'),
                _buildInput(
                    controller: _phoneController,
                    hint: '07XXXXXXXX',
                    icon: Icons.phone_android_rounded,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 20),
                _buildLabel('Nenosiri'),
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
                        color: const Color(0xFF94A3B8)),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel('Thibitisha Nenosiri'),
                _buildInput(
                    controller: _confirmPasswordController,
                    hint: '••••••••',
                    icon: Icons.check_circle_outline_rounded,
                    obscureText: _obscurePassword),
                const SizedBox(height: 40),
                Consumer<AuthProvider>(
                  builder: (_, auth, __) => SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        elevation: 0,
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Kamilisha Usajili',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, AppRouter.login),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 14),
                        children: [
                          const TextSpan(text: 'Tayari una akaunti? '),
                          TextSpan(
                              text: 'Ingia hapa',
                              style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold)),
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

  Widget _buildLabel(String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF475569),
                fontSize: 13)));
  }

  Widget _buildInput(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      bool obscureText = false,
      Widget? suffix,
      TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFF1F5F9))),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: (v) => v!.isEmpty ? 'Tafadhali jaza hapa' : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }
}
