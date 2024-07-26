
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  print("백그라운드 메시지 처리.. ${message.notification!.body!}");
  print("백그라운드 데이터 키 메시지 처리.. ${message.data.keys}");
  print("백그라운드 데이터 밸류 메시지 처리.. ${message.data.values}");
  // flutterLocalNotificationsPlugin.show(
  //   message.notification.hashCode,
  //   message.notification!.title,
  //   message.notification!.body,
  //   NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       'high_importance_channel', 'high_importance_notification',
  //       icon: message.notification!.android!.smallIcon,
  //
  //       // channel.id,
  //       // 'high_importance_notification',
  //       // importance: Importance.max,
  //       // icon: message.notification!.android!.smallIcon,
  //     )
  //   )
  // );
}

void initializeNotification() async {

  print("Firebase Noti 초기화");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(

      'kaltour',
      '한진관광',
      importance: Importance.high));

  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings("@mipmap/ic_launcher"),
  ));

}