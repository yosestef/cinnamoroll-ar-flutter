import 'package:flutter/material.dart';

class AppConstants {
  // Backend config
  static const String backendIp = String.fromEnvironment('BACKEND_IP', defaultValue: '10.0.2.2');
  static const int backendPort = int.fromEnvironment('BACKEND_PORT', defaultValue: 8000);
  static String get backendBaseUrl => 'http://$backendIp:$backendPort';
  
  // AR config
  static const double gridHorizontalScale = 0.1;
  static const double gridVerticalScale = 0.08;
  
  // Grid colors
  static const Color horizontalGridColor = Color(0x9964B4FF); // rgba(100, 180, 255, 0.6)
  static const Color horizontalBorderColor = Color(0xE664B4FF); // rgba(100, 180, 255, 0.9)
  
  static const Color verticalGridColor = Color(0x9964FFB4); // rgba(100, 255, 180, 0.6)
  static const Color verticalBorderColor = Color(0xE664FFB4); // rgba(100, 255, 180, 0.9)
  
  static const String modelFileName = 'cinnamoroll.glb';
}
