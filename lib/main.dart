import 'dart:io';
import 'package:download_video/splash/start_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:download_video/share/extensions/color_extensions.dart';
import 'package:download_video/share/utils/navigation_service.dart';

import 'helpers/ad_helper.dart';
import 'helpers/config.dart';
import 'home/home_page.dart';

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}

void main() async {
  // ✅ BẮT BUỘC – PHẢI CÓ DÒNG NÀY ĐẦU TIÊN
  WidgetsFlutterBinding.ensureInitialized();

  // Enter full-screen (ẩn system bar)
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );

  //firebase initialization
  await Firebase.initializeApp();

  //initializing remote config
  await Config.initConfig();

  await AdHelper.initAds();

  //for setting orientation to portrait only
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
    runApp(const DownloadvideoApp());
  });
}

class DownloadvideoApp extends StatelessWidget {
  const DownloadvideoApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: MaterialApp(
        navigatorKey: NavigationService.navigatorKey,// set property
        debugShowCheckedModeBanner: false,
        color: HexColor.fromHex("#FE0000"),
        theme: ThemeData(

        ),
        home: StartPage(),
        builder: EasyLoading.init(),
      ),
    );
  }
}