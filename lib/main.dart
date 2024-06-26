import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kaltour_flutter/View/PermissionScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
// import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:app_version_update/app_version_update.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:notifications/notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:intl/intl.dart';
// import 'package:http/http.dart'as http;
import 'View/WebBridgeView.dart';
import 'package:flutter/cupertino.dart';
import 'Model/RealUrl.dart';
import 'View/PushedWebView.dart';
import 'Utilities/sendToken.dart';
import 'View/MainWebView.dart';
import 'Utilities/initializeNotification.dart';
import 'Utilities/checkNotificationPermission.dart';

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
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'high_importance_notification', // title
  // 'This channel is used for important notifications', //description
  importance: Importance.high,
);


void main() async { //시작점
  print("채널! = =$channel");
  print("!!!RUN APP!!!");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  sendToken(); // 토큰 받아서 서버에 전송
  final myToken = await FirebaseMessaging.instance.getToken();
  print("나의 토큰: $myToken");
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
  initializeNotification(); // 노티 초기화 함수

  runApp(MyApp());
}


// void sendToken() async { // 토큰 발송
//
//   final dio = Dio();
//   Response response;
//
//   final myToken = await FirebaseMessaging.instance.getToken();
//
//   const token = "X%2FWnoeM%2BhLdu9VP7ncdF5A%3D%3D";
//   // The below request is the same as above.
//   response = await dio.get(
//     'https://www.kaltour.com/API/WebPush/call',//
//     queryParameters: {
//       // "TOK": myToken,
//       "TYP": "M",
//       "GNT": "",
//       "CID": "",
//       "URL": "gohanway.kaltour.com",
//       "PTH": "AOS",
//       "AK": token
//     },
//   );
//   print("리스폰스");
//   print(response.data.toString());
// }

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

// class MyWebView extends StatefulWidget {
//   const MyWebView({super.key});
//   @override
//   State<MyWebView> createState() => _MyWebViewState();
// }
//
// //************************************************************
// class _MyWebViewState extends State<MyWebView> {
//   // static const platform = MethodChannel('fcm_default_channel')
//   double progress = 0;
//   // Uri myUrl = Uri.parse("https://qa-m.kaltour.com/");
//   DateTime now = DateTime.now();
//   // bool adAllowPush = false; //광고성 푸시 허용/비허용 변수
//   bool _notificationEnabled = true;
//
//
//   late final InAppWebViewController webViewController;
//
//   @override
//   void initState() {
//     super.initState();
//     setupInteractedMessage();
//     checkAppVersion();
//     initializeNotification();
//     _requestPermissions();
//     sendToken();
//
//   }
//
//   void check_time(BuildContext context){ //context는 Snackbar용, 다른 방식으로 출력할거면 필요없음.
//     var now = new DateTime.now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
//     String formatDate = DateFormat('yy/MM/dd - HH:mm:ss').format(now); //format변경
//     ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar( //출력용 snackbar
//           content: Text('$formatDate'),
//           duration: Duration(seconds: 20),
//         )
//     );
//   }
//
//
//
//   void _requestPermissions() async {
//
//     final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) { //시스템 권한
//
//       print("시스템 푸시 권한 허용");
//       // bool isPromoAllowed = await _isPromotionalAllowed();
//       // if(!isPromoAllowed) {
//       //   _showPromotionalAlert();
//       // }
//
//     } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
//       // Fluttertoast.showToast(msg: '임시 푸시 알림이 거부되었습니다');
//
//
//       FirebaseMessaging.instance.deleteToken();
//       // adAllowPush = false;
//
//       print("임시 푸시 알림이 거부되었습니다");
//     } else {
//       // Fluttertoast.showToast(msg: '푸시 알림이 허용되지 않았습니다');
//       FirebaseMessaging.instance.deleteToken();
//       // adAllowPush = false;
//       print("푸시 알림이 허용되지 않았습니다");
//     }
//   }
//
//   void initializeNotification() async {
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//     final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(const AndroidNotificationChannel(
//
//         'high_importance_channel',
//         'high_importance_notification',
//         importance: Importance.high));
//
//     await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
//       android: AndroidInitializationSettings("@mipmap/ic_launcher"),
//     ));
//
//   }
//
//   Future<bool> _goBack(BuildContext context) async{
//     if(await webViewController.canGoBack()){
//       webViewController.goBack();
//       return Future.value(false);
//     }else{
//       return Future.value(true);
//     }
//   }
//
//
//
//   InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
//       crossPlatform: InAppWebViewOptions(
//         useShouldOverrideUrlLoading: true, // URL 로딩 제어
//         mediaPlaybackRequiresUserGesture: false, // 미디어 자동 재생
//         javaScriptEnabled: true, // 자바스크립트 실행 여부
//         javaScriptCanOpenWindowsAutomatically: true,
//
//
//       ),
//       android: AndroidInAppWebViewOptions(
//         useHybridComposition: true,
//       )
//   );
//
//   Future<void> setupInteractedMessage() async {
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//
//     if (initialMessage != null){
//       // var now = DateTime.now();
//       Fluttertoast.showToast(msg: "$initialMessage, $now");
//
//       _handleMessage(initialMessage);
//     }
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
//   }
//
//   Future<String> getAppUrl(String url) async {//앱 URL 받기
//     if (Platform.isAndroid) {
//       //print("안드로이드");
//       return await platform
//           .invokeMethod('getAppUrl', <String, Object>{'url': url});
//     } else {
//       //print("ios");
//       return url;
//     }
//   }
//
//   void _handleMessage(RemoteMessage message) {
//     String url = message.data["ActionURL"];
//     String messageKey = message.data.keys.toString();
//
//     if(url != null) {
//       print("메시지 키 입니다 = $messageKey");
//       Navigator.push(
//         context,
//         // MaterialPageRoute(builder: (context)=> PushWebView(url)),
//         MaterialPageRoute(builder: (context)=>SecondView(myUrl: url))
//       );
//     }else{
//       print("url못받음");
//     }
//   }
//
//   Future<void> checkAppVersion() async {
//     final remoteConfig = FirebaseRemoteConfig.instance;
//     await remoteConfig.setConfigSettings(RemoteConfigSettings(
//       fetchTimeout: const Duration(minutes: 1),
//       minimumFetchInterval: const Duration(hours: 12),
//     ));
//
//     await remoteConfig.fetchAndActivate();
//     String firebaseVersion = remoteConfig.getString("latest_version");
//
//     PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     String appVersion = packageInfo.version;
//     print("파이어 베이스=$firebaseVersion, 앱버전=$appVersion");
//
//     if (double.parse(firebaseVersion) > double.parse(appVersion)) {
//       showUpdateDialog();
//       print("업데이트 해야함");
//     }
//     else {
//       MyWebView();
//       print("업데이트 안해도됨");
//     }
//   }
//
//   Future<void> showUpdateDialog() {
//     print("showUpdateDialog");
//     return showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) {
//           return AlertDialog(
//             title: const Center(child: Text("업데이트 알림")),
//             content: const Text(
//               "더 나은 서비스를 위해\n한진관광 앱이 업데이트 되었습니다.\n최신 앱을 설치해주세요.",
//               textAlign: TextAlign.center,
//             ),
//             actions: <Widget>[
//               ElevatedButton(
//                   onPressed: () async {
//                     const url =
//                         'https://play.google.com/store/apps/details?id=m.kaltour.ver2';
//                     if (await canLaunchUrl(Uri.parse(url))) {
//                       await launchUrl(Uri.parse(url));
//                     }
//                   },
//                   style: const ButtonStyle(
//                       backgroundColor: MaterialStatePropertyAll<Color>(
//                           Color.fromRGBO(1, 123, 178, 0.6))),
//                   child: const Text(
//                     "업데이트하기",
//                     style: TextStyle(color: Colors.black),
//                   )),
//               ElevatedButton(
//                   onPressed: () async {
//                     // 앱 종료
//                     if (Platform.isAndroid) {
//                       SystemNavigator.pop(); //앱 종료
//                       // Navigator.pop(context); // 다이알로그만 끄기
//                     } else if (Platform.isIOS) {
//                       exit(0);
//                     }
//                   },
//                   child: const Text(
//                     "종료",
//                     style: TextStyle(color: Colors.black),
//                   ))
//             ],
//           );
//         });
//   }
//
//   Future<void> _showPromotionalAlert() async {
//     return showDialog<void>(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('앱 알림 (선택)'),
//           content: Text('광고성 앱 푸시를 수신하겠습니까?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _setPromotionalAllowed(false);
//
//                 FirebaseMessaging.instance.deleteToken();
//                 print("토큰 삭제됨");
//                 var now = new DateTime.now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
//                 String formatDate = DateFormat('yy/MM/dd - HH:mm:ss').format(now); //
//                 Fluttertoast.showToast(msg: "$formatDate에 광고성 알럿 거부되었습니다.",
//                     fontSize: 16.0
//                     // fontSize: 16.0
//                 );
//
//                 Navigator.of(context).pop();
//               },
//               child: Text(
//                   '아니오',
//                 style: TextStyle(
//                   color: Colors.black
//                 ),
//
//               ),
//             ),
//             TextButton(//허용시
//               onPressed: () {
//                 _setPromotionalAllowed(true);
//                 Navigator.of(context).pop();
//                 // adAllowPush = true;
//                 var now = new DateTime.now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
//                 String formatDate = DateFormat('yy/MM/dd - HH:mm:ss').format(now); //
//                 Fluttertoast.showToast(msg: "$formatDate에 광고성 알럿 허용되었습니다.",
//                     fontSize: 16.0
//                 );
//
//               },
//               style: const ButtonStyle(
//                 backgroundColor: MaterialStatePropertyAll<Color>(
//                   Color.fromRGBO(1, 123, 178, 0.6)
//                 ),
//               ),
//               child: Text(
//                 '네',
//                 style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                   color: Colors.black
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _setPromotionalAllowed(bool allowed) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('promotional_notifications', allowed);
//   }
//
//   Future<bool> _isPromotionalAllowed() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('promotional_notifications') ?? false;
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     _configureFirebaseMessaging(context);
//     return Scaffold(
//       appBar:AppBar(
//         title: Text("한진관광 LIVE"),
//       ),
//       body: SafeArea(
//
//         child: WillPopScope (
//           onWillPop: () => _goBack(context),
//           child: Column(children:<Widget> [
//             Expanded(child: Stack(children: [
//               InAppWebView(
//                 initialUrlRequest: URLRequest(url: myUrl) ,
//                 initialOptions: InAppWebViewGroupOptions(
//                   crossPlatform: InAppWebViewOptions(
//                       userAgent: 'APP_WISHROOM_IOS',
//                       useShouldOverrideUrlLoading: true
//
//                   ),
//                   android: AndroidInAppWebViewOptions(
//                     mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
//                   ),
//
//
//                   // android: AndroidInAppWebViewOptions(
//                   //   mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
//                   // )
//
//                 ),
//                 shouldOverrideUrlLoading:(controller, navigationAction) async {
//
//                   bool isApplink(String url) {
//                     final appScheme = Uri.parse(url).scheme;
//
//                     print("앱스킴 = $appScheme"); //https
//
//                     return appScheme != 'http' &&
//                         appScheme != 'https' &&
//                         appScheme != 'about:blank' &&
//                         appScheme != 'intent://' &&
//                         appScheme != 'data';
//                   }
//                   final url = navigationAction.request.url.toString();
//                   print("유알엘 = $url");
//                       if(isApplink(url) && url != "about:blank") {
//                         print("넘어간다");
//
//                         String getUrl = await getAppUrl(url);
//
//                         if(await canLaunch(getUrl)) {
//                           getAppUrl(String url) async {
//                             var parsingUrl = await platform.invokeMethod('getAppUrl', <String, Object>{'url':url});
//                             return parsingUrl;
//                           }
//                           NavigationActionPolicy.CANCEL;
//                           var value = await getAppUrl(url.toString());
//                           String getUrl = value.toString();
//                           await launchUrl(Uri.parse(getUrl));
//                           return NavigationActionPolicy.CANCEL;
//                         }else {
//                             print("앱 설치되지 않음");
//                             getMarketUrl(String url) async {
//                               var parsingURl = await platform.invokeMethod('getMarketUrl', <String, Object>{'url': url});
//                               return parsingURl;
//                             }
//                             NavigationActionPolicy.CANCEL;
//                             var value = await getMarketUrl(url.toString());
//                             String marketUrl = value.toString();
//                             await launchUrl(Uri.parse(marketUrl));
//                             return NavigationActionPolicy.CANCEL;
//                         }
//                       }
//                 },
//                 onLoadStart: (InAppWebViewController controller, uri) {
//                   print("onLoadStart");
//                   setState(() {myUrl = uri!;});
//                   //
//                   // webViewController!.addJavaScriptHandler(
//                   //   handlerName: 'appView',
//                   //   callback: (args) {
//                   //     // args는 JavaScript에서 전달된 인수입니다.
//                   //     print("JavaScript에서 받은 데이터: $args");
//                   //     // SecondView();
//                   //     // Flutter에서의 처리 로직
//                   //     // return {SecondView};
//                   //
//                   //     Navigator.of(context).push(MaterialPageRoute(
//                   //         builder: (context) => WebBridge())
//                   //     );
//                   //   },
//                   // );
//
//
//                 },
//                 onLoadStop: (InAppWebViewController controller, uri) {
//                   setState(() {myUrl = uri!;});
//                 },
//                 onProgressChanged: (controller, progress) {
//                   // if (progress == 100) {pullToRefreshController.endRefreshing();}
//                   setState(() {this.progress = progress / 100;});
//                 },
//                 androidOnPermissionRequest: (controller, origin, resources) async {
//                   return PermissionRequestResponse(
//                       resources: resources,
//                       action: PermissionRequestResponseAction.GRANT);
//                 },
//                 onWebViewCreated: ( controller) {
//                   webViewController = controller;
//
//                   webViewController!.addJavaScriptHandler(
//                     handlerName: 'appView',
//                     callback: (args) {
//                       // args는 JavaScript에서 전달된 인수입니다.
//                       print("JavaScript에서 받은 데이터: $args");
//                       // SecondView();
//                       // Flutter에서의 처리 로직
//                       // return {SecondView};
//
//                       Navigator.of(context).push(MaterialPageRoute(
//                           builder: (context) => WebBridgeView(data: true, time: "time")));
//                     },
//                   );
//
//                   // webViewController!.addJavaScriptHandler(
//                   //   handlerName: 'appView',
//                   //   callback: (args) {
//                   //     // args는 JavaScript에서 전달된 인수입니다.
//                   //     print("JavaScript에서 받은 데이터: $args");
//                   //     // SecondView();
//                   //     // Flutter에서의 처리 로직
//                   //     // return {SecondView};
//                   //
//                   //     Navigator.of(context).push(MaterialPageRoute(
//                   //         builder: (context) => WebBridge())
//                   //     );
//                   //   },
//                   // );
//
//                 },
//               ),
//
//
//             ],))
//           ],),
//         ),
//       ),
//     );
//   }
// }
//
//
