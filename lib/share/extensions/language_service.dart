import 'package:flutter/material.dart';

class LanguageService {
  static const _key = "app_language";

  /// 🌍 Detect hệ thống
  static String detectSystemLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context);

    switch (locale.languageCode) {
      case 'vi':
        return "Tiếng Việt";
      case 'fr':
        return "Français";
      case 'ar':
        return "العربية";
      case 'es':
        return "Español";
      case 'id':
        return "Indonesia";
      case 'pt':
        return "Português";
      case 'hi':
        return "हिंदी";
      case 'th':
        return "ภาษาไทย";
      case 'tr':
        return "Türkçe";
      case 'ru':
        return "Русский";
      case 'de':
        return "Deutsch";
      case 'it':
        return "Italiano";
      default:
        return "English";
    }
  }
}