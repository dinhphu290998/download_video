import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../helpers/ad_helper.dart';
import '../home/home_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  double page = 0;

  final pages = const [
    {
      "title": "Download Videos",
      "desc": "Save videos instantly from any platform",
      "icon": Icons.download_rounded,
    },
    {
      "title": "Ultra Quality",
      "desc": "Full HD, 4K, No quality loss",
      "icon": Icons.high_quality_rounded,
    },
    {
      "title": "Fast & Smooth",
      "desc": "One tap download, no watermark",
      "icon": Icons.flash_on_rounded,
    },
  ];

  // 🔥 Native Ad Controllers
  // final List<NativeAdController> _adControllers = [
  //   NativeAdController(),
  //   NativeAdController(),
  //   NativeAdController(),
  // ];

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (!mounted) return;
      setState(() {
        page = _controller.page ?? 0;
      });
    });

    // ✅ Load Native Ads cho từng page
    // _adControllers[0].ad = AdHelper.loadNativePage1Ad(adController: _adControllers[0]);
    // _adControllers[1].ad = AdHelper.loadNativePage2Ad(adController: _adControllers[1]);
    // _adControllers[2].ad = AdHelper.loadNativePage3Ad(adController: _adControllers[2]);

    // ✅ Preload Interstitial
    AdHelper.loadInterstitial();
  }

  @override
  void dispose() {
    _controller.dispose();
    // for (var ad in _adControllers) {
    //   ad.dispose();
    //   ad.ad?.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = page.round().clamp(0, pages.length - 1);

    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(const Color(0xff0f2027), const Color(0xff2c5364), page / 2)!,
                  Color.lerp(const Color(0xff203a43), const Color(0xff00c6ff), page / 2)!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// GLASS EFFECT
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: Colors.black.withOpacity(0.1)),
            ),
          ),

          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  itemBuilder: (_, i) {
                    final p = pages[i];
                    final progress = (page - i).abs();
                    // final adController = _adControllers[i];

                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                /// ICON CARD
                                Transform.translate(
                                  offset: Offset(progress * 50, 0),
                                  child: Opacity(
                                    opacity: (1 - progress).clamp(0.0, 1.0),
                                    child: Transform.scale(
                                      scale: 1 - (progress * 0.2),
                                      child: Container(
                                        padding: const EdgeInsets.all(28),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(24),
                                          gradient: const LinearGradient(
                                            colors: [Color(0xff00ffcc), Color(0xff00ccff)],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.cyanAccent.withOpacity(0.5),
                                              blurRadius: 30,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          p["icon"] as IconData,
                                          size: 56,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 40),

                                /// TITLE
                                Text(
                                  p["title"] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                /// DESCRIPTION
                                Text(
                                  p["desc"] as String,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white70,
                                    height: 1.5,
                                  ),
                                ),

                                const SizedBox(height: 30),

                                /// SLOT ADS
                                // Container(
                                //   height: 120,
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// DOT INDICATOR
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pages.length, (i) {
                  final active = currentIndex == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: active
                          ? const LinearGradient(colors: [Color(0xff00ffcc), Color(0xff00ccff)])
                          : null,
                      color: active ? null : Colors.white24,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              /// BUTTON
              Padding(
                padding: const EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: () {
                    if (currentIndex == pages.length - 1) {
                      AdHelper.showInterstitial(() => _goHome());
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Container(
                    height: 55,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(colors: [Color(0xff00ffcc), Color(0xff00ccff)]),
                      boxShadow: [
                        BoxShadow(color: Colors.cyanAccent.withOpacity(0.4), blurRadius: 20),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      currentIndex == pages.length - 1 ? "Get Started" : "Next",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  void _goHome() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => HomePage(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 0.9, end: 1.0).animate(anim),
              child: child,
            ),
          );
        },
      ),
    );
  }
}