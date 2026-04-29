import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../data/services/services.dart';
import '../../../providers/providers.dart';

/// Mfanyakazi posts a job they can do, with optional image upload.
/// Backend: `POST /api/worker/jobs` (multipart when image provided).
class WorkerPostJobScreen extends StatefulWidget {
  const WorkerPostJobScreen({super.key});

  @override
  State<WorkerPostJobScreen> createState() => _WorkerPostJobScreenState();
}

class _WorkerPostJobScreenState extends State<WorkerPostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _phoneController = TextEditingController();

  Category? _selectedCategory;
  double? _lat;
  double? _lng;
  String? _addressText;
  XFile? _pickedImage;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user?.phone != null && user!.phone!.isNotEmpty) {
        _phoneController.text = user.phone!;
      }
      _detectLocation();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
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
              'Eneo (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
        });
      }
    } catch (_) {}
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: AppConstants.maxImageSize.toDouble(),
        imageQuality: AppConstants.imageQuality,
      );
      if (picked != null && mounted) {
        setState(() => _pickedImage = picked);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imeshindwa kuchagua picha: $e')),
        );
      }
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Piga picha'),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Chagua kwenye galari'),
            onTap: () {
              Navigator.pop(ctx);
              _pickImage(ImageSource.gallery);
            },
          ),
          if (_pickedImage != null)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Ondoa picha',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _pickedImage = null);
              },
            ),
        ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('category_error'))),
      );
      return;
    }
    if (_lat == null || _lng == null) {
      await _detectLocation();
      if (!mounted) return;
      if (_lat == null || _lng == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('gps_enable_first'))),
        );
        return;
      }
    }

    final price = int.tryParse(_priceController.text.replaceAll(',', '')) ?? 0;
    if (price < AppConstants.minPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Bei lazima iwe angalau TZS ${AppConstants.minPrice.toString()}.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final res = await JobService().postWorkerJob(
        title: _titleController.text.trim(),
        categoryId: _selectedCategory!.id,
        price: price,
        description: _descController.text.trim(),
        lat: _lat!,
        lng: _lng!,
        phone: _phoneController.text.trim(),
        addressText: _addressText,
        image: _pickedImage,
      );

      if (!mounted) return;

      final paymentMethod = res['payment_method']?.toString();
      final data = res['data'];
      Job? job;
      if (data is Map && data['job'] != null) {
        job = Job.fromJson(Map<String, dynamic>.from(data['job'] as Map));
      }

      await context.read<WorkerProvider>().refreshAll();
      if (!mounted) return;

      if (paymentMethod == 'clickpesa' && job != null) {
        Navigator.pushReplacementNamed(
          context,
          AppRouter.paymentWait,
          arguments: {'job': job},
        );
        return;
      }

      final ok = res['success'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? (res['message']?.toString() ?? 'Imefanikiwa')
                : (res['message']?.toString() ?? 'Imeshindikana'),
          ),
          backgroundColor: ok ? const Color(0xFF22C55E) : AppColors.error,
        ),
      );

      if (ok) {
        if (job != null) {
          Navigator.pushReplacementNamed(
            context,
            AppRouter.jobDetails,
            arguments: {'job': job},
          );
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.tr('error_prefix')}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<AppProvider>().categories;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Chapisha kazi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Onyesha kazi unayoweza kufanya; wateja wataona kwenye soko.',
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Image picker
            _buildImagePicker(cs),
            const SizedBox(height: 20),

            TextFormField(
              controller: _titleController,
              style: TextStyle(color: cs.onSurface),
              cursorColor: cs.primary,
              decoration: InputDecoration(
                labelText: 'Kichwa',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? context.tr('job_title_error')
                  : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              initialValue: _selectedCategory,
              dropdownColor: cs.surfaceContainerHigh,
              style: TextStyle(color: cs.onSurface),
              decoration: InputDecoration(
                labelText: context.tr('select_category'),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
              ),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(value: c, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (c) => setState(() => _selectedCategory = c),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: cs.onSurface),
              cursorColor: cs.primary,
              decoration: InputDecoration(
                labelText: 'Bei (TZS)',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? context.tr('budget_error')
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 5,
              style: TextStyle(color: cs.onSurface),
              cursorColor: cs.primary,
              decoration: InputDecoration(
                labelText: context.tr('additional_details'),
                hintText: context.tr('post_description_hint'),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
              ),
              validator: (v) {
                if (v == null || v.trim().length < 20) {
                  return 'Andika maelezo angalau herufi 20.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: TextStyle(color: cs.onSurface),
              cursorColor: cs.primary,
              decoration: InputDecoration(
                labelText: 'Simu (malipo ya ada)',
                hintText: '07XXXXXXXX',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Lazima uweke namba ya simu';
                }
                final p = v.replaceAll(RegExp(r'\s'), '');
                final ok = RegExp(r'^(0[6-7]\d{8}|255[6-7]\d{8})$').hasMatch(p);
                return ok ? null : 'Namba si sahihi (Tanzania)';
              },
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.place_outlined, color: cs.onSurfaceVariant),
              title: Text(
                _addressText ?? context.tr('job_location_placeholder'),
                style: TextStyle(color: cs.onSurface),
              ),
              subtitle: _lat != null
                  ? Text('GPS imetambuliwa',
                      style: TextStyle(color: cs.onSurfaceVariant))
                  : Text('Gusa kutafuta eneo tena',
                      style: TextStyle(color: cs.onSurfaceVariant)),
              onTap: _detectLocation,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Tuma kazi',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker(ColorScheme cs) {
    return GestureDetector(
      onTap: _showImagePickerSheet,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pickedImage != null
                ? const Color(0xFFF97316)
                : cs.outlineVariant,
            width: _pickedImage != null ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: _pickedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  FutureBuilder(
                    future: _pickedImage!.readAsBytes(),
                    builder: (ctx, snap) {
                      if (snap.hasData) {
                        return Image.memory(snap.data!, fit: BoxFit.cover);
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => setState(() => _pickedImage = null),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child:
                              Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Material(
                      color: const Color(0xFFF97316),
                      shape: const StadiumBorder(),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: _showImagePickerSheet,
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text('Badilisha',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      size: 40, color: cs.onSurfaceVariant),
                  const SizedBox(height: 8),
                  Text(
                    'Ongeza picha (hiari)',
                    style: TextStyle(
                        color: cs.onSurface, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Picha husaidia kuvutia waombaji wengi',
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
