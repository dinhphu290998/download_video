import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../helpers/ad_helper.dart';
import '../share/extensions/language_service.dart';
import '../splash/onboarding_page.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selected = "English";
  String query = "";

  final List<Map<String, String>> languages = const [
    {"name": "English", "flag": "🇺🇸"},
    {"name": "Tiếng Việt", "flag": "🇻🇳"},
    {"name": "Русский", "flag": "🇷🇺"},
    {"name": "Indonesia", "flag": "🇮🇩"},
    {"name": "हिंदी", "flag": "🇮🇳"},
    {"name": "العربية", "flag": "🇸🇦"},
    {"name": "ภาษาไทย", "flag": "🇹🇭"},
    {"name": "Español", "flag": "🇪🇸"},
    {"name": "Türkçe", "flag": "🇹🇷"},
    {"name": "Français", "flag": "🇫🇷"},
    {"name": "Português", "flag": "🇧🇷"},
    {"name": "Deutsch", "flag": "🇩🇪"},
    {"name": "Italiano", "flag": "🇮🇹"},
  ];

  List<Map<String, String>> filtered = [];

  /// Thêm vào _LanguagePageState
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();

    /// Detect language
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final systemLang = LanguageService.detectSystemLanguage(context);
      if (mounted) {
        setState(() {
          selected = systemLang;
        });
      }
    });

    // Fallback: nếu 5 giây trôi qua mà ad chưa load thì vẫn cho bấm
    Future.delayed(const Duration(seconds: 0), () {
      if (mounted && !_canContinue) {
        setState(() => _canContinue = true);
      }
    });

    /// Preload Interstitial
    AdHelper.loadInterstitial();

    filtered = languages;
  }

  void _onSearch(String value) {
    setState(() {
      query = value;
      filtered = languages.where((e) {
        return e["name"]!.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paddingTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          /// BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff141e30), Color(0xff243b55)],
              ),
            ),
          ),

          Column(
            children: [
              /// SEARCH
              Padding(
                padding: EdgeInsets.fromLTRB(16, paddingTop, 16, 0),
                child: TextField(
                  onChanged: _onSearch,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search language...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              /// LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 12),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final lang = filtered[i];
                    final isSelected = selected == lang["name"];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            setState(() {
                              selected = lang["name"]!;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.05),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  lang["flag"]!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    lang["name"]!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check, color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// BUTTON
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: GestureDetector(
                  onTap: _canContinue
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OnboardingPage(),
                      ),
                    );
                  }
                      : null, // chưa bật thì không làm gì
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 55,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: _canContinue
                          ? const LinearGradient(
                        colors: [Color(0xff00ffcc), Color(0xff00ccff)],
                      )
                          : const LinearGradient(
                        colors: [Color(0xff555555), Color(0xff777777)],
                      ),
                      boxShadow: _canContinue
                          ? [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ]
                          : [],
                    ),
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _canContinue ? Colors.white : Colors.white38,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
