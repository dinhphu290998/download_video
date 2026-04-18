import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../helpers/ad_helper.dart';
import '../language/language_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {

  late final AnimationController _mainController;
  late final AnimationController _progressController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlow;
  late final Animation<double> _progress;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    /// ANIMATION (giữ nguyên)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _logoScale = Tween(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack),
    );

    _logoGlow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _progress = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _progressController.dispose();
    _timer?.cancel();

    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [

          /// 🌈 BACKGROUND
          const _Background(),

          /// 🎯 CONTENT
          _CenterContent(
            mainController: _mainController,
            logoScale: _logoScale,
            logoGlow: _logoGlow,
          ),

          /// ⚡ PROGRESS BAR
          Positioned(
            bottom: bottomSafe + 50 + 24,
            left: 30,
            right: 30,
            child: _ProgressBar(progress: _progress),
          ),
        ],
      ),
    );
  }

  // ---------------- TIMER ----------------
  void _startTimer() {
    _timer = Timer(const Duration(seconds: 0), () {
      if (!mounted) return; // ✅ tránh lỗi khi widget dispose

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LanguagePage()),
      );
    });
  }
}

/// ================= BACKGROUND =================
class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff0f2027),
                Color(0xff203a43),
                Color(0xff2c5364),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        /// Firework
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: Image.asset(
              'assets/firework.gif',
              fit: BoxFit.cover,
            ),
          ),
        ),

        /// Blur
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: const SizedBox(),
          ),
        ),
      ],
    );
  }
}

/// ================= CENTER CONTENT =================
class _CenterContent extends StatelessWidget {
  final AnimationController mainController;
  final Animation<double> logoScale;
  final Animation<double> logoGlow;

  const _CenterContent({
    required this.mainController,
    required this.logoScale,
    required this.logoGlow,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: mainController,
        builder: (_, __) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              /// LOGO
              Transform.scale(
                scale: logoScale.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent
                            .withOpacity(0.6 * logoGlow.value),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(80),
                    child: Image.asset(
                      'assets/logo/logo.png',
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                "Video Downloader",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                "Fast • HD • No Watermark",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ================= PROGRESS =================
class _ProgressBar extends StatelessWidget {
  final Animation<double> progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                height: 10,
                color: Colors.white.withOpacity(0.15),
              ),
              FractionallySizedBox(
                widthFactor: progress.value,
                child: Container(
                  height: 10,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xff00ffcc),
                        Color(0xff00ccff),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
