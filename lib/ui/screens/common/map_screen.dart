import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/constants.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/models.dart';
import '../../../providers/providers.dart';

class MapScreen extends StatefulWidget {
  final List<Job>? jobs;
  final LatLng? initialLocation;
  final bool fetchFromApi;

  const MapScreen({
    super.key,
    this.jobs,
    this.initialLocation,
    this.fetchFromApi = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Job? _selectedJob;
  LatLng? _currentLocation;
  List<Job> _jobs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.initialLocation ??
        const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
    
    if (widget.jobs != null) {
      _jobs = widget.jobs!;
    }
    
    if (widget.fetchFromApi || widget.jobs == null) {
      _loadJobsFromApi();
    }
  }

  Future<void> _loadJobsFromApi() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await context.read<WorkerProvider>().loadMapJobs();
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Marker> _buildJobMarkers() {
    if (_jobs.isEmpty) return [];

    return _jobs.where((job) => job.lat != null && job.lng != null).map((job) {
      final isSelected = _selectedJob?.id == job.id;
      final distanceInfo = job.distanceInfo;
      final isNearby = distanceInfo?.isNear ?? (job.distance != null && job.distance! <= 5);
      
      // Marker color based on distance
      Color markerColor;
      if (isNearby) {
        markerColor = const Color(0xFF22C55E); // Green for nearby
      } else if (distanceInfo?.isModerate ?? false) {
        markerColor = const Color(0xFFF59E0B); // Orange for moderate
      } else if (distanceInfo?.isFar ?? false) {
        markerColor = const Color(0xFFEF4444); // Red for far
      } else {
        markerColor = AppColors.primary; // Default blue
      }

      return Marker(
        point: LatLng(job.lat!, job.lng!),
        width: isSelected ? 120 : 100,
        height: isSelected ? 75 : 65,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedJob = job;
            });
            _mapController.move(LatLng(job.lat!, job.lng!), 15);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price & Category bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFF97316) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF97316) : markerColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category icon
                    Text(
                      job.categoryIcon ?? '💼',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    // Price
                    Text(
                      'TZS ${NumberFormat.compact().format(job.price)}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF1E293B),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Pin pointer
              CustomPaint(
                size: const Size(16, 10),
                painter: _TrianglePainter(
                  color: isSelected ? const Color(0xFFF97316) : Colors.white,
                  borderColor: isSelected ? const Color(0xFFF97316) : markerColor,
                ),
              ),
              // Distance indicator dot
              Container(
                width: isSelected ? 14 : 10,
                height: isSelected ? 14 : 10,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: markerColor.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildJobMarkers();

    return Scaffold(
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: AppConstants.defaultZoom,
              onTap: (_, __) {
                setState(() {
                  _selectedJob = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tendapoa.app',
              ),
              if (markers.isNotEmpty)
                MarkerLayer(
                  markers: markers,
                ),
              // User location marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 20,
                    height: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Color(0xFF1E293B),
                  size: 20,
                ),
              ),
            ),
          ),

          // Jobs Count Badge
          Positioned(
            top: 50,
            right: 20,
            child: _isLoading
                ? Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.work_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_jobs.length} Kazi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Selected Job Card (Bottom)
          if (_selectedJob != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: _buildJobDetailCard(_selectedJob!),
            ),
        ],
      ),
    );
  }

  Widget _buildJobDetailCard(Job job) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRouter.jobDetails,
          arguments: {'job': job},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: job.imageUrl != null && job.imageUrl!.isNotEmpty
                      ? Image.network(
                          job.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
                const SizedBox(width: 16),
                // Job Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      if (job.categoryName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            job.categoryName!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'TZS ${NumberFormat('#,###').format(job.price)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ),
                // Distance
                if (job.distance != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: job.distance! > 5
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: job.distance! > 5
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF22C55E),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${job.distance!.toStringAsFixed(1)}km',
                          style: TextStyle(
                            color: job.distance! > 5
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF22C55E),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Client Info Row
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFDBEAFE),
                  backgroundImage: job.userPhotoUrl != null
                      ? NetworkImage(job.userPhotoUrl!)
                      : null,
                  child: job.userPhotoUrl == null
                      ? Text(
                          job.userName?.isNotEmpty == true
                              ? job.userName![0].toUpperCase()
                              : 'M',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    job.userName ?? 'Mteja',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ),
                // View Button
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ona Kazi',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF1F5F9),
      child: const Icon(
        Icons.work_outline,
        color: Color(0xFFCBD5E1),
        size: 32,
      ),
    );
  }
}

/// Custom painter for triangle pointer below marker bubble
class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color borderColor;

  _TrianglePainter({required this.color, required this.borderColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = ui.Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
