import 'package:flutter/material.dart';
import '../../splash/splash_page.dart';

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  static voidLogoutWhenExpired() {
    final context = NavigationService.navigatorKey.currentContext;
    Navigator.popUntil(context!, (route) => false);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => SplashPage()));
  }
}