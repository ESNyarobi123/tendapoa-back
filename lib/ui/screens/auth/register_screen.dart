import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/providers.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _role;

  // Location for Mfanyakazi
  double? _lat;
  double? _lng;
  String? _addressText;
  bool _isLoadingLocation = false;
  bool _locationDetected = false;

  // Focus nodes
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // Animation
  late AnimationController _headerAnimController;

  @override
  void initState() {
    super.initState();
    _headerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _role = (args != null && args['role'] != null) ? args['role'] : 'muhitaji';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _headerAnimController.dispose();
    super.dispose();
  }

  bool get _isMfanyakazi => _role == 'mfanyakazi';
  
  Color get _themeColor => _isMfanyakazi ? const Color(0xFFF97316) : const Color(0xFF2563EB);
  
  List<Color> get _gradientColors => _isMfanyakazi 
      ? [const Color(0xFFF97316), const Color(0xFFEA580C)]
      : [const Color(0xFF2563EB), const Color(0xFF1D4ED8)];

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Huduma ya eneo haijawashwa. Tafadhali washa GPS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Ruhusa ya eneo imekataliwa');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Ruhusa ya eneo imekataliwa kabisa. Nenda Settings kubadilisha.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _locationDetected = true;
      });

      await _getAddressFromCoordinates();

      if (mounted) {
        _showSuccessSnackBar('Eneo lako limepatikana! 📍');
      }
    } catch (e) {
      _showLocationError('Imeshindikana kupata eneo: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _getAddressFromCoordinates() async {
    if (_lat == null || _lng == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_lat!, _lng!);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _addressText = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).join(', ');
        });
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  void _showLocationError(String message) {
    if (!mounted) return;
    setState(() => _isLoadingLocation = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('Nenosiri halifanani!'),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // For mfanyakazi, location is REQUIRED
    if (_isMfanyakazi && !_locationDetected) {
      _showLocationRequiredDialog();
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      role: _role!,
      lat: _lat,
      lng: _lng,
    );

    if (success && mounted) {
      final user = authProvider.user;
      if (user != null) {
        Navigator.pushReplacementNamed(
          context,
          user.isMuhitaji ? AppRouter.clientHome : AppRouter.workerHome,
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(authProvider.error ?? 'Imeshindwa kusajili')),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showLocationRequiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  color: Color(0xFFEF4444),
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Eneo Linahitajika! 📍',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kama mfanyakazi, eneo lako ni lazima ili:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 16),
              _buildReasonItem('Wateja waone umbali wako'),
              const SizedBox(height: 8),
              _buildReasonItem('Upate kazi zilizo karibu nawe'),
              const SizedBox(height: 8),
              _buildReasonItem('Mfumo uhesabu umbali kwa usahihi'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.my_location),
                  label: const Text('SAWA, NITAWEKA ENEO'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReasonItem(String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Color(0xFF22C55E), size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Animated Header
          SliverAppBar(
            expandedHeight: 220,
            floating: false,
            pinned: true,
            backgroundColor: _themeColor,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Role Badge
                        AnimatedBuilder(
                          animation: _headerAnimController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 20 * (1 - _headerAnimController.value)),
                              child: Opacity(
                                opacity: _headerAnimController.value,
                                child: child,
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isMfanyakazi ? Icons.handyman_rounded : Icons.person_search_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isMfanyakazi ? 'Mfanyakazi / Fundi' : 'Muhitaji / Mteja',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        AnimatedBuilder(
                          animation: _headerAnimController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - _headerAnimController.value)),
                              child: Opacity(
                                opacity: _headerAnimController.value,
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isMfanyakazi ? 'Jiunge na TendaPoa! 🔧' : 'Karibu TendaPoa! 👋',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _isMfanyakazi 
                                    ? 'Anza kupata kazi karibu nawe leo'
                                    : 'Pata wafanyakazi wazuri karibu nawe',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -25),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 35, 24, 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Indicator
                        _buildProgressIndicator(),
                        const SizedBox(height: 30),

                        // Personal Info Section
                        _buildSectionCard(
                          title: 'Taarifa Binafsi',
                          icon: Icons.person_rounded,
                          children: [
                            _buildModernInput(
                              controller: _nameController,
                              label: 'Jina Kamili',
                              hint: 'Mfano: Juma Ramadhani',
                              icon: Icons.badge_outlined,
                              focusNode: _nameFocus,
                              nextFocus: _emailFocus,
                              validator: (v) => v!.isEmpty ? 'Tafadhali weka jina lako' : null,
                            ),
                            const SizedBox(height: 18),
                            _buildModernInput(
                              controller: _emailController,
                              label: 'Barua Pepe',
                              hint: 'mfano@email.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              focusNode: _emailFocus,
                              nextFocus: _phoneFocus,
                              validator: (v) {
                                if (v!.isEmpty) return 'Tafadhali weka email';
                                if (!v.contains('@')) return 'Email si sahihi';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            _buildModernInput(
                              controller: _phoneController,
                              label: 'Namba ya Simu',
                              hint: '07XXXXXXXX',
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                              focusNode: _phoneFocus,
                              nextFocus: _passwordFocus,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (v) {
                                if (v!.isEmpty) return 'Tafadhali weka namba ya simu';
                                if (v.length < 10) return 'Namba ya simu si sahihi';
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Location Section (Only for Mfanyakazi)
                        if (_isMfanyakazi) ...[
                          _buildLocationSection(),
                          const SizedBox(height: 24),
                        ],

                        // Security Section
                        _buildSectionCard(
                          title: 'Usalama',
                          icon: Icons.shield_rounded,
                          children: [
                            _buildModernInput(
                              controller: _passwordController,
                              label: 'Nenosiri',
                              hint: '••••••••',
                              icon: Icons.lock_outline_rounded,
                              obscureText: _obscurePassword,
                              focusNode: _passwordFocus,
                              nextFocus: _confirmPasswordFocus,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: const Color(0xFF94A3B8),
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Tafadhali weka nenosiri';
                                if (v.length < 6) return 'Nenosiri liwe na herufi 6 au zaidi';
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            _buildModernInput(
                              controller: _confirmPasswordController,
                              label: 'Thibitisha Nenosiri',
                              hint: '••••••••',
                              icon: Icons.lock_clock_outlined,
                              obscureText: _obscureConfirmPassword,
                              focusNode: _confirmPasswordFocus,
                              textInputAction: TextInputAction.done,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  size: 20,
                                  color: const Color(0xFF94A3B8),
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              validator: (v) {
                                if (v!.isEmpty) return 'Tafadhali thibitisha nenosiri';
                                if (v != _passwordController.text) return 'Nenosiri halifanani';
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Terms Notice
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _themeColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _themeColor.withOpacity(0.1)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: _themeColor, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Kwa kusajili, unakubali Masharti na Sera ya Faragha yetu.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _themeColor.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Register Button
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) => SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _themeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(_isMfanyakazi ? Icons.handyman : Icons.person_add),
                                        const SizedBox(width: 10),
                                        Text(
                                          _isMfanyakazi ? 'JIUNGE KAMA FUNDI' : 'TENGENEZA AKAUNTI',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Tayari una akaunti? ',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(context, AppRouter.login),
                                child: Text(
                                  'Ingia hapa',
                                  style: TextStyle(
                                    color: _themeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = _isMfanyakazi ? 3 : 2;
    return Row(
      children: List.generate(steps, (index) {
        const isActive = true; // All steps visible at once in this design
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < steps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? _themeColor : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: _themeColor),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _locationDetected ? const Color(0xFF22C55E) : const Color(0xFFE2E8F0),
          width: _locationDetected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _locationDetected 
                ? const Color(0xFF22C55E).withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _locationDetected 
                      ? const Color(0xFF22C55E).withOpacity(0.1)
                      : _themeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _locationDetected ? Icons.location_on : Icons.location_searching,
                  size: 20,
                  color: _locationDetected ? const Color(0xFF22C55E) : _themeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Eneo Lako',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'LAZIMA',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _locationDetected 
                          ? 'Eneo limepatikana!'
                          : 'Bonyeza kupata eneo lako',
                      style: TextStyle(
                        fontSize: 12,
                        color: _locationDetected 
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              if (_locationDetected)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFFF59E0B), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Eneo lako linasaidia wateja kukupata kwa urahisi na kupata kazi zilizo karibu nawe.',
                    style: TextStyle(fontSize: 12, color: Colors.amber[900], height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Location Display (if detected)
          if (_locationDetected && _addressText != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place, color: Color(0xFF22C55E), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _addressText!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF166534),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Coordinates
            Row(
              children: [
                Expanded(
                  child: _buildCoordinateChip('Lat', _lat!.toStringAsFixed(4)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCoordinateChip('Lng', _lng!.toStringAsFixed(4)),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Get Location Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoadingLocation ? null : _getCurrentLocation,
              icon: _isLoadingLocation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Icon(_locationDetected ? Icons.refresh : Icons.my_location),
              label: Text(
                _isLoadingLocation 
                    ? 'Inatafuta eneo...'
                    : _locationDetected 
                        ? 'Sasisha Eneo' 
                        : '📍 PATA ENEO LANGU',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _locationDetected ? const Color(0xFF64748B) : _themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoordinateChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          focusNode: focusNode,
          textInputAction: textInputAction ?? (nextFocus != null ? TextInputAction.next : TextInputAction.done),
          inputFormatters: inputFormatters,
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          },
          validator: validator,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: _themeColor.withOpacity(0.7)),
            suffixIcon: suffix,
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: _themeColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
        ),
      ],
    );
  }
}
