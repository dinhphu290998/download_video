import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../helpers/ad_helper.dart';
import '../splash/splash_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage>
    with TickerProviderStateMixin {

  late final AnimationController _mainController;
  late final AnimationController _textController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoGlow;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _textFade;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    /// 🎬 MAIN
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();

    _logoScale = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeOutBack),
    );

    _logoGlow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.easeIn),
    );

    /// 🧾 TEXT
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _textSlide = Tween(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });

    _initApp();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _textController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ================= INIT =================
  Future<void> _initApp() async {
    if (!kIsWeb) {
      await MobileAds.instance.initialize();
    }

    _startTimer();
  }

  // ================= TIMER =================
  void _startTimer() {
    _timer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SplashPage()),
      );
    });
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          const _Background(),

          /// 🎯 CONTENT (dùng animation từ parent)
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (_, __) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    /// LOGO
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent
                                  .withOpacity(0.6 * _logoGlow.value),
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

                    /// TEXT
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textFade,
                        child: Column(
                          children: const [
                            Text(
                              "Video Downloader",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Fast • HD • No Watermark",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const _PulseLoader(),
                        SizedBox(width: 12,),
                        const _PulseLoader(),
                        SizedBox(width: 12,),
                        const _PulseLoader(),
                      ],
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= BACKGROUND =================
class _Background extends StatelessWidget {
  const _Background();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff0f2027),
                Color(0xff203a43),
                Color(0xff2c5364),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0.25,
            child: Image.asset(
              'assets/firework.gif',
              fit: BoxFit.cover,
            ),
          ),
        ),
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

/// ================= LOADER =================
class _PulseLoader extends StatefulWidget {
  const _PulseLoader();

  @override
  State<_PulseLoader> createState() => _PulseLoaderState();
}

class _PulseLoaderState extends State<_PulseLoader>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 14,
        height: 14,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}