import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../helpers/ad_helper.dart';
import '../helpers/history_util.dart';
import 'home_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> videos = [];
  bool isLoading = true;

  // Download
  double progress = 0.0;
  bool isDownloading = false;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  /// Load video history
  void loadHistory() async {
    setState(() => isLoading = true);
    List<Map<String, dynamic>> list = await HistoryUtil.getHistory();
    setState(() {
      videos = list.map((e) => e["video"] as Map<String, dynamic>).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          leading: IconButton(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            "Video History",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.cyanAccent.shade700, Colors.cyan.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
            ),
          ),
          elevation: 4,
          shadowColor: Colors.cyanAccent.withOpacity(0.4),
          backgroundColor: Colors.transparent,
        ),
      ),
      backgroundColor: const Color(0xff0f2027),
      body: Stack(
        children: [
          // Nội dung chính
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.cyanAccent),
                )
              : videos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.history, size: 80, color: Colors.cyanAccent),
                      SizedBox(height: 16),
                      Text(
                        "No history yet",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : Container(
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      var video = videos[index];
                      return _buildVideoCard(video);
                    },
                  ),
                )
              ],
            ),
          ),
          // Overlay loading khi đang download video
          if (isDownloading) _buildLoading(),
        ],
      ),
    );
  }

  /// Widget overlay download
  Widget _buildLoading() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.5), // overlay semi-transparent
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

  /// Widget card video
  Widget _buildVideoCard(Map<String, dynamic> video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.cyanAccent.withOpacity(0.2),
            Colors.blueAccent.withOpacity(0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.cyanAccent.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: video["thumbnail"] != null && video["thumbnail"] != ""
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  video["thumbnail"],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              )
            : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.videocam, color: Colors.white70),
              ),
        title: Text(
          video["title"] ?? "No title",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Quality: ${video["quality"] ?? "HD"}",
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download, color: Colors.cyanAccent, size: 48),
          onPressed: () async {
            setState(() => isDownloading = true);

            AdHelper.showRewarded(() async {
              await downloadVideo(video["url"]);
            });
          },
        ),
      ),
    );
  }

  /// Lấy path lưu video
  getPathFile() async {
    var now = DateTime.now().millisecondsSinceEpoch;
    var dir = await getDownloadDirectory();
    return "$dir/$now.mp4";
  }

  Future<String> getDownloadDirectory() async {
    final directory = Directory('/storage/emulated/0/Download');
    if (await directory.exists()) {
      return directory.path;
    } else {
      throw Exception("Download folder not found!");
    }
  }

  /// Download video
  Future downloadVideo(String link) async {
    Dio dio = Dio();
    String savePath = await getPathFile();

    try {
      await dio.download(
        link,
        savePath,
        onReceiveProgress: (received, total) {
          setState(() {
            progress = received / total;
          });
        },
      );

      if (await File(savePath).exists()) {
        await GallerySaverUtil.saveVideoToGallery(savePath);

        if (context.mounted) {
          Flushbar(
            margin: const EdgeInsets.all(16),
            borderRadius: BorderRadius.circular(12),
            backgroundGradient: const LinearGradient(
              colors: [Colors.cyan, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            messageText: const Text(
              "Download Successful! 🎉",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ).show(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        Flushbar(
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(12),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.white),
          messageText: Text(
            "Download Failed: $e",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ).show(context);
      }
    } finally {
      if (mounted) setState(() => isDownloading = false);
    }
  }
}
