import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:rk_enterprises/firebase_options.dart';
import 'package:rk_enterprises/database/hive_database.dart';
import 'package:rk_enterprises/services/background_worker.dart';
import 'package:rk_enterprises/sync/sync_manager.dart';
import 'package:rk_enterprises/services/notification_service.dart';
import 'package:rk_enterprises/services/remote_config_service.dart';
import 'package:rk_enterprises/core/widgets/skeleton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rk_enterprises/features/authentication/repositories/auth_repository.dart';
import 'package:rk_enterprises/features/authentication/models/user_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rk_enterprises/features/dashboard/screens/dashboard_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Run animations alongside initialization
      await Future.wait([
        _animationController.forward(),
        _performInitialization(),
      ]);

      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('loggedInUserId');
        if (userId != null) {
          try {
            final userBox = Hive.box<UserModel>(HiveBoxes.users);
            final user = userBox.get(userId);
            if (user != null) {
              ref.read(authStateProvider.notifier).state = user;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
              return;
            }
          } catch (e) {
             // fallback to login if box fails
          }
        }
        
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _performInitialization() async {
    // We already call Firebase.initializeApp in main before runApp just to be safe with messaging,
    // but we move the rest of the heavy lifting here.
    
    // Initialize Hive
    await HiveDatabase.init();

    // Init Notifications
    await NotificationService().init();

    // Init Remote Config
    final remoteConfig = RemoteConfigService(FirebaseRemoteConfig.instance);
    await remoteConfig.init();

    if (!kIsWeb) {
      // Initialize Background Sync
      await BackgroundWorker.init();
      BackgroundWorker.schedulePeriodicSync();
    }

    // Initialize SyncManager listener
    SyncManager().init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isError 
            ? _buildErrorView() 
            : _buildSplashContent(),
      ),
    );
  }

  Widget _buildSplashContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/images/app_logo.jpg',
              width: 250,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 50),
        // Loading Skeleton
        FadeTransition(
          opacity: _fadeAnimation,
          child: const Skeleton(width: 150, height: 10, borderRadius: 10),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text(
            'Initialization Failed',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isError = false;
                _errorMessage = '';
              });
              _initializeApp();
            },
            child: const Text('Retry'),
          )
        ],
      ),
    );
  }
}
