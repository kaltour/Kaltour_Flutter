import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
// import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'Model/RealUrl.dart';
import 'Utilities/sendToken.dart';
import 'View/MainWebView.dart';
import 'Utilities/initializeNotification.dart';
import 'Utilities/checkNotificationPermission.dart';
import 'View/PushedWebView.dart';


const platform = MethodChannel('androidIntent');
// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//
//   print("백그라운드 메시지 처리.. ${message.notification!.body!}");
//   print("백그라운드 데이터 키 메시지 처리.. ${message.data.keys}");
//   print("백그라운드 데이터 밸류 메시지 처리.. ${message.data.values}");
//   // flutterLocalNotificationsPlugin.show(
//   //   message.notification.hashCode,
//   //   message.notification!.title,
//   //   message.notification!.body,
//   //   NotificationDetails(
//   //     android: AndroidNotificationDetails(
//   //       'high_importance_channel', 'high_importance_notification',
//   //       icon: message.notification!.android!.smallIcon,
//   //
//   //       // channel.id,
//   //       // 'high_importance_notification',
//   //       // importance: Importance.max,
//   //       // icon: message.notification!.android!.smallIcon,
//   //     )
//   //   )
//   // );
// }
// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'high_importance_notification', // title
//   // 'This channel is used for important notifications', //description
//   importance: Importance.high,
// );


void main() async { //시작점
  // print("채널! = =$channel");
  print("!!!RUN APP!!!");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // sendToken(); // 토큰 받아서 서버에 전송
  // final myToken = await FirebaseMessaging.instance.getToken();
  // print("나의 토큰: $myToken");
  // FirebaseMessaging.instance.requestPermission( //푸시 알림 토스트
  //   badge: true,
  //   alert: true,
  //   sound: true,
  // );
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String appVersion = packageInfo.version;

  print("###앱 버전 = $appVersion");
  // await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  checkNotificationPermission(); // 시스템 푸시 허용 확인 함수
  // initializeNotification(); // 노티 초기화 함수
  runApp(MyApp());
}

class MyApp extends StatelessWidget { //메인 함수에서 실행되는 첫번째 뷰

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      // navigatorKey: GlobalVariable.navState,
      debugShowCheckedModeBanner: true, //디버깅시 띠 가리기 (false일때 가려짐)
      home: MainWebView(), // 스크린
    );
  }
}

void _handleMessageOpenedApp(RemoteMessage message, BuildContext context) { //백그라운드에서 푸시 클릭시 작동되는 함수
  String url = message.data['ActionURL'];
  String messageDatakey = message.data.keys.toString();

  print("메시지 데이타 키 = $messageDatakey");
  print("유알엘 ===== $url");

}

void _configureFirebaseMessaging(BuildContext context) {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleMessageOpenedApp(message, context);

    print("_configureFirebaseMessaging $message + $context");
  });
}
