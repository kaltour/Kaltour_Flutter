import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kaltour_hybrid/GlobalVariable.dart';
// import 'package:kaltour_hybrid/WebViewSecond.dart';
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

void main() async {
  print("!!!RUN APP!!!");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  initializeNotification();
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  sendToken(); // 토큰 받아서 서버에 전송

  FirebaseMessaging.instance.requestPermission(
    badge: true,
    alert: true,
    sound: true,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print('Foreground에서 푸시 받음');
    print('Message data: ${message.data}');

    RemoteNotification? notification = message.notification;
    if(notification != null) {
      FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notifications',
              importance: Importance.max
            )
          )
      );
    }

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');



    }
  });

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    // save token to server
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    return MaterialApp(
      navigatorKey: GlobalVariable.navState,
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }

}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    _configureFirebaseMessaging(context);


    // return MaterialApp(
    //   home: Scaffold(
    //     body: SafeArea(
    //       child: WebView(
    //         initialUrl: "https://m.kaltour.com/",
    //         javascriptMode: JavascriptMode,
    //       ),
    //     ),
    //   )
    // );

    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: "https://m.kaltour.com/",
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}


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


  RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();
  if (message != null) {
  }
}


class WebViewExample extends StatelessWidget {

  final String url;

  WebViewExample(this.url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
      // body: WebView(
      //   initialUrl: url,
      //   javascriptMode: JavascriptMode.unrestricted,
      // ),
    );
  }
}
void sendToken() async {
  String? _fcmToken = await FirebaseMessaging.instance.getToken();
  print("토큰 = $_fcmToken");

  final dio = Dio();
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
  print("리스폰스");
  print(response.data.toString());

}
void _handleMessageOpenedApp(RemoteMessage message, BuildContext context) {
  print("오픈 메시지");
  print("컨텍스트 = $context"); //"MyApp"
  String url = message.data['sequence'];
  if (url != null) {
    print("시퀀스 데이터 유알엘 = $url");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WebViewExample(url)),
    );
  }else {
    print("시퀀스가 없음");
  }
}
void _configureFirebaseMessaging(BuildContext context) {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleMessageOpenedApp(message, context);
  });
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text("두번째 페이지"),
    );
  }
}



//
// class WebViewExample extends StatefulWidget {
//
//
//
//   @override
//   _WebViewExampleState createState() => _WebViewExampleState();
//
//
// }
// class _WebViewExampleState extends State<WebViewExample> {
//   var messageString = "";
//
//   void getMyDeviceToken() async {
//
//     final token = await FirebaseMessaging.instance.getToken();
//     print("내 디바이스 토큰: $token");
//   }
//
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
//
//   @override
//
//   void initState() {
//     getMyDeviceToken();
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async { // FCM 수신
//       RemoteNotification? notification = message.notification;
//       if (notification != null) {
//         FlutterLocalNotificationsPlugin().show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'high_importance_channel',
//               'high_importance_notifications',
//               importance: Importance.max,
//             ),
//           ),
//         );
//         setState(() {
//           messageString = message.notification!.body!;
//           print("Foreground 메시지 수신: $messageString");
//         });
//       }
//
//     });
//
//     super.initState();
//
//   }
//
//   Widget build(BuildContext context) {
//
//     var realUrl = "https://m.kaltour.com/";
//
//     return Scaffold(
//       // appBar: AppBar(
//       //   // title: Text('WebView Example'),
//       // ),
//       body: SafeArea (
//         child: WebView (
//           initialUrl: realUrl,
//           javascriptMode: JavascriptMode.unrestricted,
//         ),
//
//       )
//
//     );
//   }
// }