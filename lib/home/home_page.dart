import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:download_video/helpers/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/ad_helper.dart';
import '../helpers/history_util.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();

  List<dynamic> medias = [];
  bool isEnable = false;

  String title = "";
  String imageLink = "";
  double progress = 0.0;
  bool isDownloading = false;
  bool isLoading = false;
  String textLoading = "Loading...";
  String link = "";

  List<String> listKeys = [];
  List<String> listYoutubeKeys = [];

  final InAppReview _inAppReview = InAppReview.instance;

  void _showRatingDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Người dùng phải bấm mới tắt
      builder: (context) =>
          CustomRatingDialog(), // Đây là dialog đánh giá đã viết ở trên
    );
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _showRatingDialog();
      }
    });

    listKeys = Config.listKeysRemotes;
    print(listKeys);

    listYoutubeKeys = Config.listKeysYoutube;
    print(listYoutubeKeys);
  }

  Future<String> getLink(text) async {
    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(text);
    String link = "";
    if (text.contains("http://xhslink.com")) {
      for (var match in matches) {
        link = text.substring(match.start, match.end);
      }
    } else {
      link = text;
    }
    return link;
  }

  Future<Map<String, dynamic>?> fetchTikTokAPI(String url) async {
    try {
      final uri = Uri.parse("https://tikwm.com/api/?url=$url");

      final response = await get(uri);
      dev.log("TikTok response: $response");

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        /// Check chuẩn theo response bạn gửi
        if (json["code"] == 0 && json["data"] != null) {
          final data = json["data"];

          /// BẮT BUỘC phải có link video
          if (data["play"] != null && data["play"].toString().isNotEmpty) {
            return json;
          }
        }
      }
    } catch (e) {
      dev.log("TikTok API error: $e");
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchFacebookAPI(String url) async {
    try {
      final uri = Uri.parse("https://fdown.isuru.eu.org/info");

      final response = await post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"url": url}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["status"] == "success" && json["available_formats"] != null) {
          return json;
        }
      }
    } catch (e) {
      dev.log("Facebook API error: $e");
    }

    return null;
  }

  Future<Map<String, dynamic>?> fetchYoutubeAPI(String url) async {
    try {
      String id = extractYoutubeId(url) ?? "";
      String key = listYoutubeKeys[Random().nextInt(listYoutubeKeys.length)];
      dev.log("API key: $key");
      final uri = Uri.parse(
        "https://ytstream-download-youtube-videos.p.rapidapi.com/dl?id=$id",
      );

      final response = await get(
        uri,
        headers: {
          "Content-Type": "application/json",
          "x-rapidapi-host": "ytstream-download-youtube-videos.p.rapidapi.com",
          "x-rapidapi-key": key,
        },
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json["status"] == "OK") {
          return json;
        }
      }
    } catch (e) {
      dev.log("Youtube API error: $e");
    }

    return null;
  }

  String? extractYoutubeId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:shorts\/|watch\?v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );

    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Map<String, String> getHeaders() {
    String key = listKeys[Random().nextInt(listKeys.length)];
    dev.log("API key: $key");
    return {
      "Content-Type": "application/x-www-form-urlencoded",
      "x-rapidapi-host": "snap-video3.p.rapidapi.com",
      "x-rapidapi-key": key,
    };
  }

  Future<Map<String, dynamic>> postAPI([Object? body]) async {
    const int maxRetries = 10;
    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final uri = Uri.parse("https://snap-video3.p.rapidapi.com/download");

        final response = await post(
          uri,
          headers: getHeaders(), // 🔥 luôn lấy header mới mỗi lần retry
          body: body,
        );

        final json = jsonDecode(response.body);

        /// Check response hợp lệ
        if (response.statusCode == 200 && json != null) {
          return json;
        } else {
          throw Exception("Invalid response or status code");
        }
      } catch (e) {
        attempt++;

        dev.log("Retry $attempt/$maxRetries - Error: $e");

        /// Nếu đã thử đủ 5 lần → throw lỗi
        if (attempt >= maxRetries) {
          throw Exception("API failed after $maxRetries attempts");
        }

        /// Delay nhẹ tránh spam API (optional nhưng nên có)
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    throw Exception("Unexpected error"); // fallback
  }

  Future _getClipboardText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    link = await getLink(data?.text);
    setState(() {
      controller.text = link;
      isEnable = false;
      medias = [];
    });
  }

  Future<void> getData() async {
    if (link.isEmpty) {
      _showError("Please paste a valid link");
      return;
    }

    try {
      /// ================== ƯU TIÊN TIKTOK ==================
      if (link.contains("tiktok.com")) {
        setState(() {
          textLoading = "Tiktok...";
          isLoading = true;
        });

        dev.log("link tiktok: $link");

        final tiktokJson = await fetchTikTokAPI(link);
        dev.log("tiktokJson: $tiktokJson");

        if (tiktokJson != null) {
          final data = tiktokJson["data"];

          final videoUrl = data["play"];
          final cover = data["cover"];
          final desc = data["title"] ?? "TikTok Video";

          if (videoUrl != null && videoUrl.toString().isNotEmpty) {
            final List mediasTikTok = [
              {"url": videoUrl, "quality": "hd", "extension": "mp4"},
            ];

            if (!mounted) return;

            dev.log("API tiktok: success");

            setState(() {
              title = desc;
              imageLink = cover ?? "";
              medias = mediasTikTok;
              isEnable = true;
              isLoading = false;
            });

            /// SAVE HISTORY
            await HistoryUtil.addHistory({
              "title": title,
              "thumbnail": imageLink,
              "medias": mediasTikTok,
            });
            dev.log("TikTok API OK");

            return; // ✅ QUAN TRỌNG: dừng tại đây nếu TikTok OK
          }
        }

        /// ❌ Nếu TikTok API fail → fallback
        dev.log("TikTok API failed → fallback to default API");
      }

      /// ================== FACEBOOK ==================
      if (link.contains("facebook.com") || link.contains("fb.watch")) {
        setState(() {
          textLoading = "Facebook...";
          isLoading = true;
        });

        dev.log("link facebook: $link");

        final fbJson = await fetchFacebookAPI(link);

        if (fbJson != null) {
          final info = fbJson["video_info"];
          final formats = fbJson["available_formats"] as List;

          /// 🔥 lấy video chất lượng cao nhất
          formats.sort((a, b) {
            final qa = int.tryParse(a["quality"].replaceAll("p", "")) ?? 0;
            final qb = int.tryParse(b["quality"].replaceAll("p", "")) ?? 0;
            return qb.compareTo(qa); // giảm dần
          });

          final best = formats.first;

          final mediasFB = [
            {
              "url": best["url"],
              "quality": best["quality"],
              "extension": "mp4",
            },
          ];

          if (!mounted) return;

          setState(() {
            title = info["title"] ?? "Facebook Video";
            imageLink = info["thumbnail"] ?? "";
            medias = mediasFB;
            isEnable = true;
            isLoading = false;
          });

          await HistoryUtil.addHistory({
            "title": title,
            "thumbnail": imageLink,
            "medias": mediasFB,
          });
          dev.log("Facebook API OK");

          return;
        }

        dev.log("Facebook fail → fallback");
      }

      /// ================== ƯU TIÊN YOUTUBE ==================
      if (link.contains("youtube.com")) {
        if(Config.checkYouTube == true) {
          _showError("Cannot get Youtube video !");
          return;
        }
        setState(() {
          textLoading = "Youtube...";
          isLoading = true;
        });

        dev.log("link youtube: $link");

        final youtubeJson = await fetchYoutubeAPI(link);
        if (youtubeJson != null) {
          List<dynamic> thumbnail = youtubeJson["thumbnail"];
          dev.log("thumbnail: $thumbnail");
          String cover = "";
          if (thumbnail.isNotEmpty) {
            cover = thumbnail.last["url"];
          }
          final desc = youtubeJson["title"] ?? "Youtube Video";
          dev.log("desc: $desc");
          List<dynamic> adaptiveFormats = youtubeJson["adaptiveFormats"];
          final mp4Videos = adaptiveFormats.where((item) {
            final mimeType = item["mimeType"] ?? "";
            return mimeType.contains("video/mp4");
          }).toList();
          dev.log("mp4Videos: $mp4Videos");
          String videoUrl = "";

          if (mp4Videos.isNotEmpty) {
            videoUrl = mp4Videos.first["url"];
          }

          if (videoUrl.toString().isNotEmpty) {
            final List mediasYoutube = [
              {"url": videoUrl, "quality": "hd", "extension": "mp4"},
            ];

            if (!mounted) return;

            dev.log("API tiktok: success");

            setState(() {
              title = desc;
              imageLink = cover ?? "";
              medias = mediasYoutube;
              isEnable = true;
              isLoading = false;
            });

            /// SAVE HISTORY
            await HistoryUtil.addHistory({
              "title": title,
              "thumbnail": imageLink,
              "medias": mediasYoutube,
            });
            dev.log("Youtube API OK");

            return; // ✅ QUAN TRỌNG: dừng tại đây nếu TikTok OK
          }
        }

        /// ❌ Nếu Youtube API fail → fallback
        dev.log("Youtube API failed → fallback to default API");
      }

      setState(() {
        textLoading = "Loading...";
        isLoading = true;
      });

      final jsons = await postAPI({"url": link});

      dev.log("API response: $jsons");

      /// CHECK API FAIL
      if (jsons.isEmpty || jsons["medias"] == null) {
        throw Exception("Invalid response");
      }

      final List mediasRaw = jsons["medias"] as List;

      /// FILTER VIDEO
      final filtered = mediasRaw
          .where(
            (e) =>
                e["extension"] == "mp4" &&
                (e["quality"] == "hd" || e["quality"] == "720p"),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        title = jsons["title"] ?? "No title";
        imageLink = jsons["thumbnail"] ?? "";
        medias = filtered;
        isEnable = true;
        isLoading = false;
      });

      /// NO VIDEO FOUND
      if (filtered.isEmpty) {
        _showError("No HD video found!");
        return;
      }

      /// SAVE HISTORY
      await HistoryUtil.addHistory({
        "title": title,
        "thumbnail": imageLink,
        "medias": filtered,
      });
    } catch (e) {
      dev.log("ERROR: $e");

      if (!mounted) return;

      setState(() {
        isLoading = false;
        isEnable = false;
      });

      _showError("Cannot get video. Try again!");
    }
  }

  void _showError(String msg) {
    Flushbar(
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      backgroundGradient: const LinearGradient(
        colors: [Colors.redAccent, Colors.deepOrange],
      ),
      duration: const Duration(seconds: 2),
      icon: const Icon(Icons.error, color: Colors.white),
      messageText: Text(
        msg,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ).show(context);
  }

  Widget _buildLoading() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.cyanAccent.withOpacity(0.2),
                  Colors.blueAccent.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                        color: Colors.cyanAccent,
                      ),
                    ),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const Text(
                  "Downloading...",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 80,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.cyanAccent,
                    ),
                    backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future downloadVideo(String url) async {
    setState(() => isDownloading = true);

    Dio dio = Dio();
    String path =
        "/storage/emulated/0/Download/${DateTime.now().millisecondsSinceEpoch}.mp4";

    try {
      await dio.download(
        url,
        path,
        onReceiveProgress: (r, t) {
          setState(() => progress = r / t);
        },
      );

      await GallerySaverUtil.saveVideoToGallery(path);

      Flushbar(
        message: "Downloaded Successfully 🎉",
        duration: const Duration(seconds: 2),
      ).show(context);
    } catch (_) {
      Flushbar(
        message: "Download Failed ❌",
        duration: const Duration(seconds: 2),
      ).show(context);
    }

    setState(() => isDownloading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _bg(),

          SafeArea(
            child: Column(
              children: [
                _header(),
                _search(),
                _mainButton(),

                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: isEnable ? _preview() : _emptyWithAds(),
                  ),
                ),
              ],
            ),
          ),

          if (isLoading) _loadingOverlay(textLoading),
          if (isDownloading) _buildLoading(),
        ],
      ),
    );
  }

  /// ================= UI =================

  Widget _bg() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xff0f2027), Color(0xff203a43), Color(0xff2c5364)],
      ),
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Snap Video",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            );
          },
        ),
      ],
    ),
  );

  Widget _search() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    height: 55,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white.withOpacity(0.08),
    ),
    child: Row(
      children: [
        const Icon(Icons.link, color: Colors.cyanAccent),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            readOnly: true,
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Paste video link...",
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.paste, color: Colors.white),
          onPressed: _getClipboardText,
        ),
      ],
    ),
  );

  Widget _mainButton() => Padding(
    padding: const EdgeInsets.all(16),
    child: _button(
      text: "Get Video",
      onTap: () {
        if (link.isEmpty) return;
        AdHelper.showInterstitial(() => getData());
      },
    ),
  );

  Widget _preview() => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 10),
        _buildVideoPreview(),
        const SizedBox(height: 16),
        ...medias.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _button(
              text: "Download HD",
              onTap: () => {
                setState(() => isLoading = true),
                AdHelper.showInterstitial(() {
                  setState(() => isLoading = false);
                  downloadVideo(m["url"]);
                }),
              },
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildVideoPreview() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// ẢNH VIDEO
          AspectRatio(
            aspectRatio: 1 / 1,
            child: Image.network(imageLink, fit: BoxFit.cover),
          ),

          /// GRADIENT OVERLAY (CHO ĐẸP + RÕ NÚT PLAY)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),

          /// NÚT PLAY (NEON GLASS)
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.9, end: 1.1),
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            onEnd: () {
              if (mounted) setState(() {});
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.15),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),

          /// HIỆU ỨNG CLICK (optional)
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // 👉 sau này bạn có thể mở preview video
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyWithAds() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 🔥 ICON + BACKGROUND (modern style)
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withOpacity(0.8),
                  Colors.purpleAccent.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.download_rounded,
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 32),

          // 🎯 TITLE
          const Text(
            "Paste Link to Download",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // 📝 SUBTEXT
          Text(
            "Download videos instantly in HD quality\nNo watermark • Fast • Free",
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 28),

          // 🚀 CTA BUTTON (clean + modern)
          GestureDetector(
            onTap: () {
              // focus input hoặc paste clipboard
              _getClipboardText();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.paste, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Paste & Download",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ✨ FEATURE ROW (đồng bộ + gọn)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              _feature("No Watermark"),
              _feature("HD Quality"),
              _feature("Fast"),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _feature(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
      ),
    );
  }

  /// ================= COMPONENT =================

  Widget _button({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Color(0xff00ffcc), Color(0xff00ccff)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.5),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _loadingOverlay(String text) => Container(
    color: Colors.black.withOpacity(0.5),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Colors.cyanAccent),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    ),
  );

  Widget _downloadOverlay() => _loadingOverlay("Downloading...");
}

class GallerySaverUtil {
  static const MethodChannel _channel = MethodChannel(
    "com.example.save_video/gallery",
  );

  static Future<void> saveVideoToGallery(String path) async {
    if (Platform.isAndroid) {
      await _channel.invokeMethod("saveVideoToGallery", {"path": path});
    }
  }
}

class CustomRatingDialog extends StatefulWidget {
  @override
  _CustomRatingDialogState createState() => _CustomRatingDialogState();
}

class _CustomRatingDialogState extends State<CustomRatingDialog> {
  int _selectedRating = 5;
  final InAppReview _inAppReview = InAppReview.instance;

  void _submitRating() async {
    if (_selectedRating >= 4) {
      try {
        if (await _inAppReview.isAvailable()) {
          await _inAppReview.requestReview();
        } else {
          await _inAppReview.openStoreListing();
        }
      } catch (e) {
        await launchUrl(
          Uri.parse(
            "https://play.google.com/store/apps/details?id=com.ndp.snapvideo",
          ),
          mode: LaunchMode.externalApplication,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thanks for loving our video downloader! ❤️"),
        ),
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Thanks! We'll improve your download experience 💪"),
        ),
      );
    }

    Navigator.of(context).pop();
  }

  Widget _buildStar(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRating = index + 1;
        });
      },
      child: Icon(
        index < _selectedRating ? Icons.star : Icons.star_border,
        color: Colors.yellow,
        size: 40,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 🚀 ICON
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyanAccent.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.download_rounded,
                    color: Colors.cyanAccent,
                    size: 30,
                  ),
                ),

                const SizedBox(height: 16),

                /// TITLE
                const Text(
                  "Enjoying Downloads?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                /// SUBTITLE
                const Text(
                  "Tap a star to rate your experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 20),

                /// ⭐ STARS (ANIMATED)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isActive = index < _selectedRating;

                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedRating = index + 1);
                      },
                      child: AnimatedScale(
                        scale: isActive ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Icon(
                            isActive ? Icons.star : Icons.star_border,
                            color: isActive
                                ? Colors.yellowAccent
                                : Colors.white30,
                            size: 36,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 24),

                /// 🔥 BUTTON SUBMIT (GRADIENT)
                GestureDetector(
                  onTap: _submitRating,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xff00ffcc), Color(0xff00ccff)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Text(
                      "RATING",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
