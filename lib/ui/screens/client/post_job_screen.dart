import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../providers/providers.dart';
import '../../../data/models/category_model.dart' as models;
import '../../../data/services/services.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();

  int _currentStep = 0; // 0: Maelezo, 1: Eneo & Malipo

  XFile? _selectedImage;
  models.Category? _selectedCategory;
  double? _lat;
  double? _lng;
  String? _addressText;

  // Nearby workers state
  bool _isCheckingWorkers = false;
  int _nearbyWorkerCount = 0;
  String? _nearbyWorkersMessage;
  Map<String, int>? _workersByDistance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user?.phone != null) {
        _phoneController.text = user?.phone ?? '';
      }
      _detectLocation();
    });
  }

  Future<void> _detectLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _lat = position.latitude;
          _lng = position.longitude;
          _addressText =
              "Eneo Limetambuliwa (${position.latitude.toStringAsFixed(4)})";
        });
        // Check nearby workers after getting location
        _checkNearbyWorkers();
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _checkNearbyWorkers() async {
    if (_lat == null || _lng == null) return;

    setState(() => _isCheckingWorkers = true);

    try {
      final result = await JobService().checkNearbyWorkers(
        lat: _lat!,
        lng: _lng!,
        radius: 15,
      );

      if (mounted) {
        setState(() {
          _nearbyWorkerCount = result['worker_count'] ?? 0;
          _nearbyWorkersMessage = result['message'];
          _workersByDistance = {
            'within_1km': result['by_distance']?['within_1km'] ?? 0,
            'within_3km': result['by_distance']?['within_3km'] ?? 0,
            'within_5km': result['by_distance']?['within_5km'] ?? 0,
          };
          _isCheckingWorkers = false;
        });
      }
    } catch (e) {
      debugPrint('Nearby workers error: $e');
      if (mounted) {
        setState(() => _isCheckingWorkers = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = pickedFile);
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tafadhali chagua kategoria')));
        return;
      }
      setState(() => _currentStep = 1);
    }
  }

  Future<void> _submitJob() async {
    if (_lat == null || _lng == null) {
      await _detectLocation();
      if (_lat == null || _lng == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tafadhali washa GPS yako kwanza')));
        }
        return;
      }
    }

    try {
      await context.read<ClientProvider>().postJob(
            title: _titleController.text,
            categoryId: _selectedCategory!.id,
            price: int.tryParse(_priceController.text.replaceAll(',', '')) ?? 0,
            description: _descController.text,
            lat: _lat!,
            lng: _lng!,
            phone: _phoneController.text.isNotEmpty
                ? _phoneController.text
                : 'N/A',
            addressText: _addressText ?? 'Eneo la Kazi',
            image: _selectedImage,
          );

      if (mounted) {
        // Find the job in the updated list or parse from response if available
        // Assuming loadMyJobs was called inside postJob provider method
        final clientProvider = context.read<ClientProvider>();
        final newJob = clientProvider.myJobs.firstWhere(
            (j) => j.title == _titleController.text,
            orElse: () => clientProvider.myJobs.first);

        Navigator.pushReplacementNamed(context, AppRouter.paymentWait,
            arguments: {'job': newJob});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Hitilafu: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Post Kazi Mpya',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildStep(0, 'Maelezo'),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 3,
                      decoration: BoxDecoration(
                        color: _currentStep >= 1
                            ? AppColors.primary
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _buildStep(1, 'Eneo & Post'),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: _currentStep == 0 ? _buildStepOne() : _buildStepTwo(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStep(int step, String label) {
    bool isActive = _currentStep == step;
    bool isDone = _currentStep > step;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isDone
                ? AppColors.primary
                : const Color(0xFFEEF2FF),
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: Colors.white, width: 2)
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: isActive ? AppColors.primary : const Color(0xFF64748B),
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepOne() {
    final categories = context.watch<AppProvider>().categories;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text('Unahitaji msaidizi gani?',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5)),
          const SizedBox(height: 5),
          const Text('Jaza taarifa hizi ili mafundi wa karibu waanze kuomba.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(height: 30),

          // Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                image: _selectedImage != null
                    ? DecorationImage(
                        image: kIsWeb
                            ? NetworkImage(_selectedImage!.path)
                            : FileImage(File(_selectedImage!.path))
                                as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _selectedImage == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded,
                              size: 30, color: AppColors.primary),
                        ),
                        const SizedBox(height: 12),
                        const Text('Ongeza Picha (Optional)',
                            style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: IconButton(
                              icon: const Icon(Icons.edit_rounded,
                                  size: 20, color: AppColors.primary),
                              onPressed: _pickImage),
                        ),
                      ),
                    ),
            ),
          ).animate().scale(duration: 400.ms),

          const SizedBox(height: 35),

          _buildInputLabel('Kichwa cha Kazi'),
          _buildTextField(
            controller: _titleController,
            hint: 'Mfano: Napata fundi bomba wa kurekebisha sinki',
            icon: Icons.edit_note_rounded,
            validator: (v) =>
                v!.isEmpty ? 'Tafadhali weka kichwa cha kazi' : null,
          ),

          const SizedBox(height: 25),
          _buildInputLabel('Kategoria ya Kazi'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9))),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<models.Category>(
                isExpanded: true,
                value: _selectedCategory,
                hint: const Text('Chagua Kategoria...',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                items: categories
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
            ),
          ),

          const SizedBox(height: 25),
          _buildInputLabel('Dau / Bajeti Yako (TZS)'),
          _buildTextField(
            controller: _priceController,
            hint: 'Mfano: 20,000',
            icon: Icons.payments_rounded,
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? 'Weka bajeti' : null,
          ),

          const SizedBox(height: 25),
          _buildInputLabel('Maelezo ya Kazi'),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFF1F5F9))),
            child: TextFormField(
              controller: _descController,
              maxLines: 5,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Elezea kazi kwa undani zaidi hapa...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
              validator: (v) => v!.isEmpty ? 'Elezea kazi yako' : null,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text('Eneo la Kazi',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5)),
        const SizedBox(height: 5),
        const Text(
            'Tunatumia GPS yako kutambua eneo ili mafundi wa karibu zaidi waone kazi yako.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        const SizedBox(height: 30),

        // Location Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10))
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle),
                child: Icon(Icons.location_on_rounded,
                    size: 50,
                    color: _lat != null
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFF97316)),
              ),
              const SizedBox(height: 20),
              Text(_lat != null ? 'ENEO LIMETAMBULIWA' : 'INATAFUTA ENEO...',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 14,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(_addressText ?? 'Tafadhali ruhusu GPS kwanza',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _detectLocation,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('RUDIA KUTAFUTA',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),

        const SizedBox(height: 25),

        // Nearby Workers Card
        _buildNearbyWorkersCard(),

        const SizedBox(height: 30),
        _buildInputLabel('Namba ya Mawasiliano'),
        _buildTextField(
          controller: _phoneController,
          hint: '07XXXXXXXX',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          validator: (v) => v!.isEmpty ? 'Weka namba ya simu' : null,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildNearbyWorkersCard() {
    if (_isCheckingWorkers) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                'Inatafuta wafanyakazi karibu nawe...',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn();
    }

    if (_nearbyWorkerCount == 0 && _lat != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF97316).withValues(alpha: 0.1),
              const Color(0xFFFED7AA).withValues(alpha: 0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFFF97316).withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFF97316), size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hakuna Wafanyakazi Karibu',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nearbyWorkersMessage ?? 'Unaweza kuendelea lakini muda wa kupata mfanyakazi unaweza kuwa mrefu.',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn().shake(delay: 300.ms, duration: 500.ms);
    }

    if (_nearbyWorkerCount > 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.08),
              const Color(0xFF34D399).withValues(alpha: 0.15),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.people_alt_rounded,
                      color: Color(0xFF10B981), size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wafanyakazi $_nearbyWorkerCount Wamepatikana!',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nearbyWorkersMessage ?? 'Kazi yako itaonekana haraka!',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_workersByDistance != null) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildDistanceBadge('1km', _workersByDistance!['within_1km'] ?? 0, const Color(0xFF10B981)),
                  const SizedBox(width: 10),
                  _buildDistanceBadge('3km', _workersByDistance!['within_3km'] ?? 0, const Color(0xFF3B82F6)),
                  const SizedBox(width: 10),
                  _buildDistanceBadge('5km', _workersByDistance!['within_5km'] ?? 0, const Color(0xFF8B5CF6)),
                ],
              ),
            ],
          ],
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
    }

    return const SizedBox.shrink();
  }

  Widget _buildDistanceBadge(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'ndani $label',
              style: TextStyle(
                fontSize: 10,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 10),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF1E293B),
                fontSize: 14)));
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9))),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF94A3B8)),
          hintText: hint,
          hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
              fontWeight: FontWeight.normal),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLoading = context.watch<ClientProvider>().isLoading;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep == 1) ...[
            GestureDetector(
              onTap: () => setState(() => _currentStep = 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const SizedBox(width: 15),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : (_currentStep == 0 ? _nextStep : _submitJob),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentStep == 0
                    ? AppColors.primary
                    : const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == 0 ? 'ENDELEA' : 'POST KAZI SASA',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
