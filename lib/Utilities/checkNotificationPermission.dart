import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> checkNotificationPermission() async {
  var status = await Permission.notification.status;
  if (status.isGranted) {
    print('Notification permission is granted. 권한 허용');
  } else if (status.isDenied) {
    print('Notification permission is denied.권한 거부');
    // 권한 요청을 처리하고 싶다면 아래 코드를 사용하세요:
    // Permission.notification.request();

  } else if (status.isPermanentlyDenied) {
    print('Notification permission is permanently denied.영구적 권한 거부');
    // 사용자가 앱 설정에서 권한을 수동으로 변경해야 함
    openAppSettings();

  }
}