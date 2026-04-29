import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
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
            SnackBar(content: Text(context.tr('category_error'))));
        return;
      }
      setState(() => _currentStep = 1);
    }
  }

  Future<void> _submitJob() async {
    if (_lat == null || _lng == null) {
      await _detectLocation();
      if (!mounted) return;
      if (_lat == null || _lng == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr('gps_enable_first'))));
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
            addressText: _addressText ?? context.tr('job_location_placeholder'),
            image: _selectedImage,
          );

      if (mounted) {
        // Posting is free; pay after worker selection (Job Details → fund escrow). PaymentWait is for USSD after that flow.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('job_posted_message')),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.clientHome,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${context.tr('error_prefix')}: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: scheme.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('post_job_new'),
          style: TextStyle(
            color: scheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
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
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _buildStep(context, 0, context.tr('step_details')),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      height: 3,
                      decoration: BoxDecoration(
                        color: _currentStep >= 1
                            ? scheme.primary
                            : scheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _buildStep(context, 1, context.tr('step_location_post')),
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

  Widget _buildStep(BuildContext context, int step, String label) {
    final scheme = Theme.of(context).colorScheme;
    final isActive = _currentStep == step;
    final isDone = _currentStep > step;
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isDone
                ? scheme.primary
                : scheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: isActive
                ? Border.all(color: scheme.onPrimary, width: 2)
                : Border.all(color: scheme.outlineVariant),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check, color: scheme.onPrimary, size: 16)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive
                          ? scheme.onPrimary
                          : scheme.onSurfaceVariant,
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
            color: isActive ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepOne() {
    final categories = context.watch<AppProvider>().categories;
    final cs = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            context.tr('post_need_help'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            context.tr('post_fill_details'),
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 30),

          // Image Picker
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: cs.outlineVariant, width: 2),
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
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.camera_alt_rounded,
                            size: 30,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('add_image_optional'),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: CircleAvatar(
                          backgroundColor: cs.surfaceContainerHigh,
                          child: IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 20,
                              color: cs.primary,
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ),
            ),
          ).animate().scale(duration: 400.ms),

          const SizedBox(height: 35),

          _buildInputLabel(context.tr('enter_job_title')),
          _buildTextField(
            controller: _titleController,
            hint: context.tr('post_title_hint'),
            icon: Icons.edit_note_rounded,
            validator: (v) =>
                v!.isEmpty ? context.tr('job_title_error') : null,
          ),

          const SizedBox(height: 25),
          _buildInputLabel(context.tr('select_category')),
          Builder(
            builder: (ctx) {
              final cs = Theme.of(ctx).colorScheme;
              return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<models.Category>(
                isExpanded: true,
                value: _selectedCategory,
                dropdownColor: cs.surfaceContainerHigh,
                hint: Text('${context.tr('select_category')}...',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
                items: categories
                    .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface))))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
            ),
          );
            },
          ),

          const SizedBox(height: 25),
          _buildInputLabel(context.tr('your_budget')),
          _buildTextField(
            controller: _priceController,
            hint: context.tr('post_budget_hint'),
            icon: Icons.payments_rounded,
            keyboardType: TextInputType.number,
            validator: (v) => v!.isEmpty ? context.tr('budget_error') : null,
          ),

          const SizedBox(height: 25),
          _buildInputLabel(context.tr('additional_details')),
          Builder(
            builder: (ctx) {
              final cs = Theme.of(ctx).colorScheme;
              return Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: cs.outlineVariant)),
            child: TextFormField(
              controller: _descController,
              maxLines: 5,
              style: TextStyle(color: cs.onSurface, fontSize: 15),
              cursorColor: cs.primary,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: context.tr('post_description_hint'),
                  hintStyle: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
              validator: (v) => v!.isEmpty ? context.tr('post_description_error') : null,
            ),
          );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStepTwo() {
    final cs = Theme.of(context).colorScheme;
    final onCard = cs.onPrimary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          context.tr('location_title'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          context.tr('post_location_help'),
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(height: 30),

        // Location Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: cs.primary,
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
                    color: onCard.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: Icon(Icons.location_on_rounded,
                    size: 50,
                    color: _lat != null
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFF97316)),
              ),
              const SizedBox(height: 20),
              Text(
                  _lat != null
                      ? context.tr('location_detected').toUpperCase()
                      : context.tr('post_location_searching').toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: onCard,
                      fontSize: 14,
                      letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(_addressText ?? context.tr('post_allow_gps'),
                  style: TextStyle(
                      color: onCard.withValues(alpha: 0.75),
                      fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _detectLocation,
                icon: Icon(Icons.refresh_rounded, size: 16, color: onCard),
                label: Text(context.tr('post_retry_location'),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: onCard)),
                style: OutlinedButton.styleFrom(
                    foregroundColor: onCard.withValues(alpha: 0.85),
                    side: BorderSide(color: onCard.withValues(alpha: 0.25)),
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
        _buildInputLabel(context.tr('phone_number')),
        _buildTextField(
          controller: _phoneController,
          hint: '07XXXXXXXX',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          validator: (v) => v!.isEmpty ? context.tr('phone_error') : null,
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildNearbyWorkersCard() {
    final cs = Theme.of(context).colorScheme;
    if (_isCheckingWorkers) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: cs.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                context.tr('post_searching_workers'),
                style: TextStyle(
                  color: cs.onSurfaceVariant,
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
                      Text(
                        context.tr('post_no_workers_nearby'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nearbyWorkersMessage ?? context.tr('post_continue_anyway'),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
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
                        '$_nearbyWorkerCount ${context.tr('post_workers_found')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _nearbyWorkersMessage ?? context.tr('post_job_visible_soon'),
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
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
              '${context.tr('post_within_km')} $label',
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
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: cs.onSurface,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String hint,
      required IconData icon,
      TextInputType? keyboardType,
      String? Function(String?)? validator}) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: cs.onSurface,
        ),
        cursorColor: cs.primary,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: cs.onSurfaceVariant),
          hintText: hint,
          hintStyle: TextStyle(
              color: cs.onSurfaceVariant,
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
      decoration: BoxDecoration(
        color: cs.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: cs.onSurface,
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
                    ? cs.primary
                    : const Color(0xFF22C55E),
                foregroundColor: _currentStep == 0
                    ? cs.onPrimary
                    : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: _currentStep == 0
                            ? cs.onPrimary
                            : Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _currentStep == 0 ? context.tr('post_continue_btn').toUpperCase() : context.tr('post_job_btn').toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _currentStep == 0
                            ? cs.onPrimary
                            : Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
