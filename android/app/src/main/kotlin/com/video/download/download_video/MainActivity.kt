package com.video.download.download_video
import android.content.ContentValues
import android.os.Build
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.save_video/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveVideoToGallery") {
                val path = call.argument<String>("path")
                if (path != null) {
                    val success = saveVideoToGallery(path)
                    if (success) result.success(true)
                    else result.error("ERROR", "Save failed", null)
                } else {
                    result.error("ERROR", "Path null", null)
                }
            } else result.notImplemented()
        }
    }

    private fun saveVideoToGallery(videoPath: String): Boolean {
        return try {
            val file = File(videoPath)
            val values = ContentValues().apply {
                put(MediaStore.Video.Media.DISPLAY_NAME, file.name)
                put(MediaStore.Video.Media.MIME_TYPE, "video/mp4")
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/MyAppVideos")
                    put(MediaStore.Video.Media.IS_PENDING, 1)
                }
            }

            val resolver = contentResolver
            val uri = resolver.insert(MediaStore.Video.Media.EXTERNAL_CONTENT_URI, values)

            uri?.let {
                resolver.openOutputStream(uri).use { out ->
                    FileInputStream(file).use { input ->
                        input.copyTo(out!!)
                    }
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    values.clear()
                    values.put(MediaStore.Video.Media.IS_PENDING, 0)
                    resolver.update(uri, values, null, null)
                }
            }

            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}

