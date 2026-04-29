import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../ui/screens/screens.dart';
import '../../data/models/models.dart';

/// App Router - All named routes
class AppRouter {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String roleSelect = '/role-select';
  static const String login = '/login';
  static const String register = '/register';
  static const String clientHome = '/client-home';
  static const String clientDashboard = '/client-dashboard';
  static const String workerHome = '/worker-home';
  static const String postJob = '/post-job';
  static const String chatList = '/chat-list';
  static const String chatRoom = '/chat-room';
  static const String jobDetails = '/job-details';
  static const String wallet = '/wallet';
  static const String map = '/map';
  static const String notifications = '/notifications';
  static const String workerJobs = '/worker-jobs';
  static const String workerActiveJob = '/worker-active-job';
  static const String settingsPage = '/settings';
  static const String paymentWait = '/payment-wait';
  static const String editJob = '/edit-job';
  static const String editProfile = '/edit-profile';
  static const String forgotPassword = '/forgot-password';
  static const String depositWait = '/deposit-wait';
  static const String clientApplications = '/client-applications';
  static const String clientCategoryFeed = '/client-category-feed';
  static const String fundEscrow = '/fund-escrow';
  static const String workerMyApplications = '/worker-my-applications';
  static const String workerPostJob = '/worker-post-job';
  static const String workerDashboard = '/worker-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case welcome:
        return _buildRoute(const WelcomeScreen(), settings);
      case roleSelect:
        return _buildRoute(const RoleSelectScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case register:
        return _buildRoute(const RegisterScreen(), settings);
      case clientHome:
        return _buildRoute(const ClientHomeScreen(), settings);
      case clientDashboard:
        return _buildRoute(const ClientDashboardScreen(), settings);
      case workerHome:
        return _buildRoute(const WorkerHomeScreen(), settings);
      case postJob:
        return _buildRoute(const PostJobScreen(), settings);
      case map:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          MapScreen(
            jobs: args?['jobs'] as List<Job>?,
            initialLocation: args?['initialLocation'] as LatLng?,
            fetchFromApi: args?['fetchFromApi'] as bool? ?? false,
          ),
          settings,
        );
      case jobDetails:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Invalid job details'))),
            settings,
          );
        }
        return _buildRoute(
          JobDetailsScreen(
            job: args['job'] as Job?,
            jobId: args['jobId'] as int?,
          ),
          settings,
        );
      case notifications:
        return _buildRoute(const NotificationScreen(), settings);
      case workerJobs:
        return _buildRoute(const WorkerJobsScreen(), settings);
      case workerActiveJob:
        final waArgs = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          WorkerActiveJobScreen(
            initialJob: waArgs?['job'] as Job?,
          ),
          settings,
        );
      case settingsPage:
        return _buildRoute(const SettingsScreen(), settings);
      case paymentWait:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['job'] == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Invalid payment data'))),
            settings,
          );
        }
        return _buildRoute(
          PaymentWaitScreen(job: args['job'] as Job),
          settings,
        );
      case wallet:
        return _buildRoute(const WalletScreen(), settings);
      case chatList:
        return _buildRoute(const ChatListScreen(), settings);
      case chatRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        if (args == null || args['conversation'] == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Invalid chat room'))),
            settings,
          );
        }
        return _buildRoute(
          ChatRoomScreen(
            conversation: args['conversation'] as ChatConversation,
          ),
          settings,
        );
      case editJob:
        final job = settings.arguments as Job?;
        if (job == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Invalid job data'))),
            settings,
          );
        }
        return _buildRoute(
          EditJobScreen(job: job),
          settings,
        );
      case editProfile:
        return _buildRoute(const EditProfileScreen(), settings);
      case forgotPassword:
        return _buildRoute(const ForgotPasswordScreen(), settings);
      case depositWait:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          DepositWaitScreen(
            transactionId: args?['transactionId'] as int? ?? 0,
            amount: args?['amount'] as int? ?? 0,
          ),
          settings,
        );
      case clientApplications:
        return _buildRoute(const ClientApplicationsScreen(), settings);
      case clientCategoryFeed:
        final catArgs = settings.arguments as Map<String, dynamic>?;
        final category = catArgs?['category'] as Category?;
        if (category == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Invalid category'))),
            settings,
          );
        }
        return _buildRoute(
          ClientCategoryFeedScreen(category: category),
          settings,
        );
      case fundEscrow:
        final fundArgs = settings.arguments as Map<String, dynamic>?;
        final fundJob = fundArgs?['job'] as Job?;
        if (fundJob == null) {
          return _buildRoute(
            const Scaffold(body: Center(child: Text('Invalid job'))),
            settings,
          );
        }
        return _buildRoute(FundEscrowScreen(job: fundJob), settings);
      case workerMyApplications:
        return _buildRoute(const WorkerMyApplicationsScreen(), settings);
      case workerDashboard:
        return _buildRoute(const WorkerDashboardScreen(), settings);
      case workerPostJob:
        return _buildRoute(const WorkerPostJobScreen(), settings);
      default:
        return _buildRoute(
            const Scaffold(body: Center(child: Text('Route not found'))),
            settings);
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
