import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HistoryUtil {
  static const String keyHistory = "video_history";

  static Future<void> addHistory(Map<String, dynamic> video) async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(keyHistory) ?? [];

    final medias = video["medias"] as List? ?? [];

    for (var media in medias) {
      list.add(jsonEncode({
        "video": {
          "title": video["title"] ?? "No title",
          "thumbnail": video["thumbnail"] ?? "",
          "url": media["url"],
          "quality": media["quality"] ?? "",
          "extension": media["extension"] ?? "mp4",
        },
        "time": DateTime.now().toIso8601String(),
      }));
    }

    await prefs.setStringList(keyHistory, list);
  }

  static Future<List<Map<String, dynamic>>> getHistory() async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    List<String> list = prefs.getStringList(keyHistory) ?? [];
    return list.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }
}