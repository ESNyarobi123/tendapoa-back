import '../models/models.dart' as models;
import 'api_service.dart';

/// Job Service
class JobService {
  static JobService? _instance;
  final ApiService _api = ApiService();

  JobService._internal();

  factory JobService() {
    _instance ??= JobService._internal();
    return _instance!;
  }

  Future<List<models.Category>> getCategories() async {
    final response = await _api.get('/categories', requiresAuth: false);
    // API may return 'categories' or 'data' key, or direct list
    final dynamic rawData = response.data!['categories'] ?? response.data!['data'] ?? response.data!;
    List dataList = [];
    if (rawData is List) {
      dataList = rawData;
    } else if (rawData is Map) {
      dataList = rawData.values.toList();
    }
    return dataList.map((c) => models.Category.fromJson(c)).toList();
  }

  Future<Map<String, dynamic>> getHome() async {
    final response = await _api.get('/home', requiresAuth: false);
    return response.data!['data'];
  }

  Future<models.NearbyWorkersResponse> getNearbyWorkers({
    required double lat,
    required double lng,
    double radius = 5,
  }) async {
    final response = await _api.get(
      '/workers/nearby',
      queryParams: {'lat': lat, 'lng': lng, 'radius': radius},
      requiresAuth: false,
    );
    final data = response.data!['data'] ?? response.data!;
    return models.NearbyWorkersResponse.fromJson(data);
  }

  Future<Map<String, dynamic>> getFeed({
    String? category,
    double? distance,
    int page = 1,
  }) async {
    final response = await _api.get(
      '/feed',
      queryParams: {
        if (category != null) 'category': category,
        if (distance != null) 'distance': distance,
        'page': page,
      },
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> getMapFeed() async {
    final response = await _api.get('/feed/map');
    return response.data!;
  }

  Future<Map<String, dynamic>> postJob({
    required String title,
    required int categoryId,
    required int price,
    required String description,
    required double lat,
    required double lng,
    required String phone,
    String? addressText,
    dynamic image,
  }) async {
    final Map<String, String> fields = {
      'title': title,
      'category_id': categoryId.toString(),
      'price': price.toString(),
      'description': description,
      'lat': lat.toString(),
      'lng': lng.toString(),
      'phone': phone,
      if (addressText != null) 'address_text': addressText,
    };

    if (image != null) {
      final response = await _api.postMultipart(
        '/jobs',
        fields: fields,
        files: {'image': image},
      );
      return response.data!;
    } else {
      final response = await _api.post(
        '/jobs',
        body: fields,
      );
      return response.data!;
    }
  }

  Future<List<models.Job>> getMyJobs() async {
    final response = await _api.get('/jobs/my');
    // API returns 'jobs' key, not 'data'
    final dynamic rawData = response.data!['jobs'] ?? response.data!['data'] ?? [];
    List dataList = [];
    if (rawData is Map) {
      dataList = rawData.values.toList();
    } else if (rawData is List) {
      dataList = rawData;
    }
    return dataList.map((j) => models.Job.fromJson(j)).toList();
  }

  Future<models.Job> getJobDetails(int jobId) async {
    final response = await _api.get('/jobs/$jobId');
    final data = response.data!['data'] ?? response.data!;
    return models.Job.fromJson(data);
  }

  Future<models.Job> selectWorker(int jobId, int commentId) async {
    final response = await _api.post('/jobs/$jobId/accept/$commentId');
    final data = response.data!['data'] ?? response.data!;
    return models.Job.fromJson(data);
  }

  Future<void> cancelJob(int jobId) async {
    await _api.post('/jobs/$jobId/cancel');
  }

  Future<Map<String, dynamic>> retryPayment(int jobId, {String? phone}) async {
    final response = await _api.post('/jobs/$jobId/retry-payment', body: {
      if (phone != null) 'phone': phone,
    });
    return response.data!;
  }

  /// Poll payment status for a job
  /// Returns: {done: bool, status: String}
  Future<Map<String, dynamic>> pollPayment(int jobId) async {
    final response = await _api.get('/jobs/$jobId/poll');
    return {
      'done': response.data!['done'] ?? false,
      'status': response.data!['status'] ?? 'PENDING',
    };
  }

  /// Check nearby workers before posting
  /// Returns: {worker_count, status, message, by_distance}
  Future<Map<String, dynamic>> checkNearbyWorkers({
    required double lat,
    required double lng,
    double radius = 15,
  }) async {
    final response = await _api.get(
      '/workers/nearby',
      queryParams: {'lat': lat, 'lng': lng, 'radius': radius},
      requiresAuth: false,
    );
    return response.data!['data'] ?? response.data!;
  }

  Future<List<models.Job>> getAssignedJobs() async {
    final response = await _api.get('/worker/assigned');
    final dynamic rawData =
        response.data!['data']?['data'] ?? response.data!['data'] ?? [];
    List dataList = [];
    if (rawData is Map) {
      dataList = rawData.values.toList();
    } else if (rawData is List) {
      dataList = rawData;
    }
    return dataList.map((j) => models.Job.fromJson(j)).toList();
  }

  /// Post a comment on a job
  /// type: 'comment' (maoni), 'application' (ombi la kazi), 'offer' (bei)
  Future<void> postComment(int jobId, String message, {
    String type = 'comment',
    int? bidAmount,
  }) async {
    await _api.post(
      '/jobs/$jobId/comment',
      body: {
        'message': message,
        'type': type,
        if (type == 'application' || type == 'offer') 'is_application': true,
        if (bidAmount != null) 'bid_amount': bidAmount,
      },
    );
  }

  Future<void> applyForJob(int jobId, String message, {int? bidAmount}) async {
    await postComment(jobId, message, 
      type: bidAmount != null ? 'offer' : 'application', 
      bidAmount: bidAmount);
  }

  /// Accept an assigned job (Worker)
  Future<Map<String, dynamic>> acceptAssignedJob(int jobId) async {
    final response = await _api.post('/worker/jobs/$jobId/accept');
    return response.data!;
  }

  /// Decline an assigned job (Worker)
  Future<Map<String, dynamic>> declineAssignedJob(int jobId) async {
    final response = await _api.post('/worker/jobs/$jobId/decline');
    return response.data!;
  }

  Future<Map<String, dynamic>> completeJob(int jobId, String code) async {
    final response = await _api.post(
      '/worker/jobs/$jobId/complete',
      body: {'code': code},
    );
    return response.data!;
  }

  Future<models.WorkerDashboard> getWorkerDashboard() async {
    final response = await _api.get('/dashboard');
    return models.WorkerDashboard.fromJson(response.data!['data']);
  }

  Future<models.ClientDashboard> getClientDashboard() async {
    final response = await _api.get('/dashboard');
    return models.ClientDashboard.fromJson(response.data!['data']);
  }

  /// Get job data for editing
  /// Returns: {job, categories, can_edit, status}
  Future<Map<String, dynamic>> getJobForEdit(int jobId) async {
    final response = await _api.get('/jobs/$jobId/edit');
    return response.data!;
  }

  /// Update job details
  /// Returns updated job data and payment info if price increased
  Future<Map<String, dynamic>> updateJob({
    required int jobId,
    required String title,
    required int categoryId,
    required int price,
    required String description,
    required double lat,
    required double lng,
    String? addressText,
    dynamic image,
  }) async {
    final Map<String, String> fields = {
      'title': title,
      'category_id': categoryId.toString(),
      'price': price.toString(),
      'description': description,
      'lat': lat.toString(),
      'lng': lng.toString(),
      if (addressText != null) 'address_text': addressText,
    };

    if (image != null) {
      final response = await _api.putMultipart(
        '/jobs/$jobId',
        fields: fields,
        files: {'image': image},
      );
      return response.data!;
    } else {
      final response = await _api.put(
        '/jobs/$jobId',
        body: fields,
      );
      return response.data!;
    }
  }

  /// Cancel/Delete a job
  /// Returns success message and refund info
  Future<Map<String, dynamic>> deleteJob(int jobId) async {
    final response = await _api.post('/jobs/$jobId/cancel');
    return response.data!;
  }
}
