import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';


Future<String> checkAppVersion() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 12),
  ));

  await remoteConfig.fetchAndActivate();
  String firebaseVersion = remoteConfig.getString("latest_version");

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appVersion = packageInfo.version;
  print("파이어 베이스=$firebaseVersion, 앱버전=$appVersion");

  // if (double.parse(firebaseVersion) > double.parse(appVersion)) {
  //   showUpdateDialog();
  //   print("업데이트 해야함");
  // } else {
  //   MainWebView();
  //   print("업데이트 안해도됨");
  // }

  return appVersion;
}
