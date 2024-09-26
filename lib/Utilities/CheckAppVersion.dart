import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'dart:io';

Future<String> checkAppVersion() async {
  print("checkAppVersion 실행");
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 11),
  ));

  await remoteConfig.fetchAndActivate();

  // 플랫폼에 따라 다른 버전 키 사용
  String firebaseVersion;
  if (Platform.isAndroid) {
    firebaseVersion = remoteConfig.getString("latest_version_android"); // Android용 버전 키
    print("Android Remote Config 버전 = $firebaseVersion");
  } else if (Platform.isIOS) {
    firebaseVersion = remoteConfig.getString("latest_version_ios"); // iOS용 버전 키
    print("iOS Remote Config 버전 = $firebaseVersion ");
    // firebaseVersion = remoteConfig.getString("latest_version");
  } else {
    print("Unsupported platform");
  }

  // 현재 앱 버전 가져오기
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appVersion = packageInfo.version;
  print("앱 버전=$appVersion");

  // if (double.parse(firebaseVersion) > double.parse(appVersion)) {
  //   showUpdateDialog();
  //   print("업데이트 해야함");
  // } else {
  //   MainWebView();
  //   print("업데이트 안해도됨");
  // }

  return appVersion;
}
