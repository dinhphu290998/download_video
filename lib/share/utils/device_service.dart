import 'dart:io';

class DeviceService {

  static Future<bool> hasNetwork() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static double heightScreen = 0;
  static double widthScreen = 0;
  static double viewPaddingTop = 0;
}