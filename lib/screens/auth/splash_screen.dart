import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:society_manager/screens/auth/pending_approval_screen.dart';
import 'package:society_manager/screens/resident/resident_home_screen.dart';
import 'package:society_manager/screens/auth/role_selector_screen.dart';

import '../admin/admin_home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _mainController;
  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _textController;
  late AnimationController _dotsController;

  // Logo Animations
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<Offset> _logoFloatAnimation;
  late Animation<double> _logoGlowAnimation;

  // Text Animations
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;

  // Loading Dots Animations
  late Animation<double> _dot1Animation;
  late Animation<double> _dot2Animation;
  late Animation<double> _dot3Animation;
  late Animation<double> _dotsScaleAnimation;

  // Particle Effect Animation
  late Animation<double> _particleAnimation;

  // Background Gradient Animation
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _logoRotationAnimation =
        Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
          CurvedAnimation(
            parent: _logoController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
          ),
        );

    _logoFloatAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: const Offset(0, -0.02),
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );

    _logoGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _dot1Animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotsController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    _dot2Animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotsController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeInOut),
      ),
    );

    _dot3Animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _dotsController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeInOut),
      ),
    );

    _dotsScaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _dotsController,
        curve: Curves.easeInOut,
      ),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _particleController,
        curve: Curves.easeInOut,
      ),
    );

    _gradientAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _startAnimationSequence() async {
    _mainController.forward();

    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _logoController.forward();
        _logoController.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _logoController.repeat(reverse: true);
          }
        });
      }
    });

    Timer(const Duration(milliseconds: 800), () {
      if (mounted) _particleController.forward();
    });

    Timer(const Duration(milliseconds: 1200), () {
      if (mounted) _textController.forward();
    });

    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) _dotsController.repeat(reverse: true);
    });

    // Wait for splash, then check login status
    Timer(const Duration(milliseconds: 4500), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    if (!mounted) return;

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      User? currentUser = auth.currentUser;
      Widget targetScreen;

      if (currentUser == null) {
        // No user logged in → Go to Login
        targetScreen = LoginScreen();
      } else {
        // Get user data from Firestore
        final doc = await firestore.collection('users').doc(currentUser.uid).get();

        if (!doc.exists) {
          targetScreen = SignupScreen(); // No profile in DB
        } else {
          final data = doc.data()!;
          bool isActive = data['isActive'] ?? false;
          List roles = List.from(data['roles'] ?? []);

          if (!isActive) {
            targetScreen =  PendingApprovalScreen();
          } else if (roles.contains("resident") && roles.contains("admin")) {
            targetScreen =  RoleSelectorScreen();
          } else if (roles.contains("admin")) {
            targetScreen =  AdminHomeScreen();
          } else {
            targetScreen =  ResidentHomeScreen();
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => targetScreen,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _logoController.dispose();
    _particleController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _logoController,
          _particleController,
          _textController,
          _dotsController,
        ]),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    const Color(0xFF1565C0),
                    const Color(0xFF0D47A1),
                    _gradientAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF1976D2),
                    const Color(0xFF1565C0),
                    _gradientAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF2196F3),
                    const Color(0xFF1976D2),
                    _gradientAnimation.value,
                  )!,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: ParticlePainter(_particleAnimation.value),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      _buildAnimatedLogo(),
                      const SizedBox(height: 32),
                      _buildAnimatedTitle(),
                      const SizedBox(height: 12),
                      _buildAnimatedSubtitle(),
                      const Spacer(),
                      _buildLoadingDots(),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Transform.scale(
      scale: _logoScaleAnimation.value,
      child: SlideTransition(
        position: _logoFloatAnimation,
        child: Transform.rotate(
          angle: _logoRotationAnimation.value * 0.1,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white
                      .withValues(alpha: _logoGlowAnimation.value * 0.3),
                  blurRadius: 20 * _logoGlowAnimation.value,
                  spreadRadius: 5 * _logoGlowAnimation.value,
                ),
                BoxShadow(
                  color: const Color(0xFF0057FF).withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.article_outlined,
              size: 64,
              color: Color(0xFF0057FF),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return SlideTransition(
      position: _titleSlideAnimation,
      child: FadeTransition(
        opacity: _titleFadeAnimation,
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFFE3F2FD)],
          ).createShader(bounds),
          child: const Text(
            'SocietySphere',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSubtitle() {
    return SlideTransition(
      position: _subtitleSlideAnimation,
      child: FadeTransition(
        opacity: _subtitleFadeAnimation,
        child: Text(
          'Manage your community with ease',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDots() {
    return Transform.scale(
      scale: _dotsScaleAnimation.value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildAnimatedDot(_dot1Animation),
          const SizedBox(width: 12),
          _buildAnimatedDot(_dot2Animation),
          const SizedBox(width: 12),
          _buildAnimatedDot(_dot3Animation),
        ],
      ),
    );
  }

  Widget _buildAnimatedDot(Animation<double> animation) {
    return Transform.scale(
      scale: animation.value,
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: animation.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: animation.value * 0.5),
              blurRadius: 8 * animation.value,
              spreadRadius: 2 * animation.value,
            ),
          ],
        ),
      ),
    );
  }
}

// Particle Painter
class ParticlePainter extends CustomPainter {
  final double animationValue;
  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20)) +
          (math.sin(animationValue * 2 * math.pi + i) * 50);
      final y = (size.height * ((i * 0.7) % 1)) +
          (math.cos(animationValue * 2 * math.pi + i) * 30);

      final opacity = (math.sin(animationValue * 2 * math.pi + i) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: opacity * 0.3);

      canvas.drawCircle(
        Offset(x, y),
        2 + (math.sin(animationValue * 4 * math.pi + i) + 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}