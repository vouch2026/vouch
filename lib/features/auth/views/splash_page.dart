import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/route_paths.dart';
import '../../../core/config/supabase_config.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _opacityController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final LocalAuthentication _auth = LocalAuthentication();
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacityController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _opacityController,
        curve: const Interval(0.1, 1.0, curve: Curves.easeInOut),
      ),
    );

    _scaleController.forward().then((_) {
      _checkBiometricsAndNavigate();
    });
  }

  Future<void> _checkBiometricsAndNavigate() async {
    final isLoggedIn = SupabaseConfig.client.auth.currentUser != null;
    
    if (isLoggedIn) {
      final box = Hive.box('settings');
      final rawData = box.get('app_settings_data');
      bool biometricEnabled = false;
      
      if (rawData != null) {
        try {
          final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(rawData as Map);
          biometricEnabled = jsonMap['biometric_lock_enabled'] ?? false;
        } catch (_) {}
      }

      if (biometricEnabled) {
        await _authenticateAndNavigate();
        return;
      }
    }

    // Default flow: play fade out and go to dashboard
    _opacityController.forward().then((_) {
      if (mounted) {
        context.go(RoutePaths.dashboard);
      }
    });
  }

  Future<void> _authenticateAndNavigate() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate = canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        if (mounted) {
          context.go(RoutePaths.dashboard);
        }
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please Authenticate to Unlock Vouch',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Unlock Vouch',
            signInHint: '',
          ),
          IOSAuthMessages(
            localizedFallbackTitle: '',
          ),
        ],
      );

      if (didAuthenticate) {
        if (mounted) {
          context.go(RoutePaths.dashboard);
        }
      } else {
        setState(() {
          _isLocked = true;
        });
      }
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      setState(() {
        _isLocked = true;
      });
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          _buildBackgroundDecorations(),
          if (!_isLocked)
            AnimatedBuilder(
              animation: _opacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Center(
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildLogo(),
                    ),
                  ),
                );
              },
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 40),
                    const Icon(
                      Icons.lock_outline,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vouch is Locked',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Authenticate to access your governance ecosystem',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _authenticateAndNavigate,
                      icon: const Icon(Icons.fingerprint, size: 22),
                      label: const Text(
                        'Unlock App',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 175,
      height: 175,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16.0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/logos/vouch.webp',
        fit: BoxFit.fill,
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: 70,
          right: -50,
          child: Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(120),
            ),
          ),
        ),
        Positioned(
          bottom: 170,
          left: -30,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(90),
            ),
          ),
        ),
      ],
    );
  }
}
