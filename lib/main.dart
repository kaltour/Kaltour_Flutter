import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("백그라운드 메시지 처리.. ${message.notification!.body!}");
  print("백그라운드 데이터 처리 ${message.data}");
}
@pragma('vm:entry-point')
void backgroundHandler(NotificationResponse details) {

}

void main()  async {
  WidgetsFlutterBinding.ensureInitialized();
  print("!!!RUN APP!!!");

  await Firebase.initializeApp();
  initializeNotification();
  initNoti();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.requestPermission(
    badge: true,
    alert: true,
    sound: true,
  );

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    // save token to server
  });

  runApp(MyApp());

}
class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter WebView Sample',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebViewExample(),
    );
  }
}


// void initializeNotification() async {
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(const AndroidNotificationChannel(
//
//       'high_importance_channel', 'high_importance_notification',
//       importance: Importance.max));
//
//   await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
//
//     android: AndroidInitializationSettings("@mipmap/ic_launcher"),
//
//
//   ));
//
//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
//
// }

void initializeNotification() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
      'high_importance_channel', 'high_importance_notification',
      importance: Importance.max));
  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings("@mipmap/ic_launcher"),

  ));

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,

  );
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("오픈 메시지 데이터 처리 ${message.data}");
  });
  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {

  }
}

void initNoti() async {


}




class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();


}
class _WebViewExampleState extends State<WebViewExample> {
  var messageString = "";
  void getMyDeviceToken() async {

    final token = await FirebaseMessaging.instance.getToken();
    print("내 디바이스 토큰: $token");
  }

  final dio = Dio();
  void request() async {
    Response response;
    final myToken = FirebaseMessaging.instance.getToken();
    print("나의 토큰: $myToken");
    const token = "X%2FWnoeM%2BhLdu9VP7ncdF5A%3D%3D";
    // The below request is the same as above.
    response = await dio.get(
      'https://www.kaltour.com/API/WebPush/call',
      queryParameters: {
        "TOK": myToken,
        "TYP": "M",
        "GNT": "",
        "CID": "",
        "URL": "gohanway.kaltour.com",
        "PTH": "IOS",
        "AK" : "X%2FWnoeM%2BhLdu9VP7ncdF5A%3D%3D"
      },
    );
    print(response.data.toString());
  }

  @override

  void initState() {
    getMyDeviceToken();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async { // FCM 수신
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notifications',
              importance: Importance.max,
            ),
          ),
        );
        setState(() {
          messageString = message.notification!.body!;
          print("Foreground 메시지 수신: $messageString");
        });
      }

    });

    super.initState();

  }

  Widget build(BuildContext context) {

    var realUrl = "https://m.kaltour.com/";

    return Scaffold(
      // appBar: AppBar(
      //   // title: Text('WebView Example'),
      // ),
      body: SafeArea (
        child: WebView (
          initialUrl: realUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ),

      )

    );
  }
}