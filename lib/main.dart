import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
// import 'package:get/get.dart';

const platform = MethodChannel('androidIntent');
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

  print("백그라운드 메시지 처리.. ${message.notification!.body!}");

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
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(

      'high_importance_channel',
      'high_importance_notification',
      importance: Importance.high));



  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings("@mipmap/ic_launcher"),


  ));

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}
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
  initializeNotification();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  sendToken(); // 토큰 받아서 서버에 전송



  FirebaseMessaging.instance.requestPermission(
    badge: true,
    alert: true,
    sound: true,
  );
  // await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);


  // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //   String url = message.data['sequence'];
  //
  //   if (url != null) {
  //     print('Message also contained a notification: ${message.notification}');
  //     flutterLocalNotificationsPlugin.show(
  //         message.hashCode,
  //         message.notification?.title,
  //         message.notification?.body,
  //         NotificationDetails(
  //             // android: AndroidNotificationDetails(
  //             //   'high_importance_channel',
  //             //   'high_importance_notification',
  //             //   // channelDescription: channel.description,
  //             //   icon: '@mipmap/ic_launcher',
  //             // ),
  //          ));
  //
  //   }
  //
  //
  // });

  // FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
  //   // save token to server
  // });
  runApp(MyApp());
}


// void backgroundHandler(NotificationResponse details) {}


// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//
//   print("_firebaseMessagingBackgroundHandler");
//   print("백그라운드 메시지 처리.. ${message.notification!.body!}");
//   print("백그라운드 데이터 처리 ${message.data}");
//
//   await Firebase.initializeApp();
//   // 백그라운드에서 메세지 처리
//   flutterLocalNotificationsPlugin.show(
//       message.notification.hashCode,
//       message.notification!.title,
//       message.notification!.body,
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id, channel.name,
//           // TODO add a proper drawable resource to android, for now using
//           //      one that already exists in example app.
//           icon: message.notification!.android!.smallIcon,
//         ),
//       ));
//
//   print('Handling a background message ${message.messageId}');
//
// }

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   importance: Importance.max,
// );



void sendToken() async { // 토큰 발송


  final dio = Dio();
  Response response;
  final myToken = await FirebaseMessaging.instance.getToken();
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
      "PTH": "AOS",
      "AK": "X%2FWnoeM%2BhLdu9VP7ncdF5A%3D%3D"
    },
  );
  print("리스폰스");
  print(response.data.toString());
}

class MyApp extends StatelessWidget { //메인 함수에서 실행되는 첫번째 뷰

  @override
  Widget build(BuildContext context) {
    // var initialzationsettingsAndroid =
    //     AndroidInitializationSettings('@mipmap/ic_launcher');
    // var initializationSettings =
    //     InitializationSettings(android: initialzationsettingsAndroid);
    //
    // flutterLocalNotificationsPlugin.initialize(initializationSettings);



    return MaterialApp(
      // navigatorKey: GlobalVariable.navState,
      debugShowCheckedModeBanner: true, //디버깅시 띠 가리기
      home: MyWebView(),
    );
  }



}

void _handleMessageOpenedApp(RemoteMessage message, BuildContext context) { //포그라운드에서 푸시 클릭시 작동되는 함수
  String url = message.data['sequence'];
  print("유알엘 ===== $url");

  // print("유알엘 ===== $url");
  // if (url != null) {
  //
  //   print("시퀀스 데이터 유알엘 = $url");
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => PushWebView(url)),
  //   );
  // } else {
  //   print("시퀀스가 없음");
  // }
}

void _configureFirebaseMessaging(BuildContext context) {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleMessageOpenedApp(message, context);

    print("_configureFirebaseMessaging 정 $message + $context");
  });
}

class MyWebView extends StatefulWidget {
  const MyWebView({super.key});
  @override
  State<MyWebView> createState() => _MyWebViewState();
}


//************************************************************
class _MyWebViewState extends State<MyWebView> {
  // static const platform = MethodChannel('fcm_default_channel');

  double progress = 0;
  Uri myUrl = Uri.parse("https://m.kaltour.com/");
  void clearWebViewCache(WebViewController controller) async {
    await controller.clearCache();
    print('WebView 캐시가 삭제되었습니다.');
  }
  // final String url;
  // _MyWebViewState(this.url);

  // InAppWebViewController? webViewController;

  Future<bool> _goBack(BuildContext context) async{
    if(await webViewController.canGoBack()){
      webViewController.goBack();
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

  late final InAppWebViewController webViewController;

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true, // URL 로딩 제어
        mediaPlaybackRequiresUserGesture: false, // 미디어 자동 재생
        javaScriptEnabled: true, // 자바스크립트 실행 여부
        javaScriptCanOpenWindowsAutomatically: true, //
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      )
  );

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null){
      // Fluttertoast.showToast(msg: "$initialMessage");

      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<String> getAppUrl(String url) async {//앱 URL 받기
    if (Platform.isAndroid) {
      //print("안드로이드");
      return await platform
          .invokeMethod('getAppUrl', <String, Object>{'url': url});
    } else {
      //print("ios");
      return url;
    }
  }

  void _handleMessage(RemoteMessage message) {
    String url = message.data["sequence"];
    if(url != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> PushWebView(url)),
      );
    }


    // if(url != null) {
    //   print("#푸시 들어옴#");
    //   var pushSeq = url;
    //   var pushUrl = "https://m.kaltour.com/ProductPlan/mobileIndex?exiSeq=";
    //   var fullUrl = pushUrl+pushSeq;
    //
    //   myUrl = Uri.parse(fullUrl);
    //
    //   // Fluttertoast.showToast(msg: "${message.data}")
    //   // Navigator.push( // PushWebView로 감
    //   //     context,
    //   //     MaterialPageRoute(builder: (context)=> PushWebView(url)),
    //   // );
    // }
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    _configureFirebaseMessaging(context);
    return Scaffold(
      body: SafeArea(
        child: WillPopScope (
          onWillPop: () => _goBack(context),
          child: Column(children:<Widget> [
            Expanded(child: Stack(children: [
              InAppWebView(

                initialUrlRequest: URLRequest(url: myUrl) ,
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true
                  ),
                  android: AndroidInAppWebViewOptions(
                    mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
                  )
                ),
                shouldOverrideUrlLoading:(controller, navigationAction) async {

                  bool isApplink(String url) {
                    final appScheme = Uri.parse(url).scheme;

                    print("앱스킴 = $appScheme"); //https

                    return appScheme != 'http' &&
                        appScheme != 'https' &&
                        appScheme != 'about:blank' &&
                        appScheme != 'intent://' &&
                        appScheme != 'data';
                  }

                  final url = navigationAction.request.url.toString();
                  print("유알엘 = $url");
                      if(isApplink(url) && url != "about:blank") {
                        print("넘어간다");

                        String getUrl = await getAppUrl(url);

                        if(await canLaunch(getUrl)) {
                          getAppUrl(String url) async {
                            var parsingUrl = await platform.invokeMethod('getAppUrl', <String, Object>{'url':url});
                            return parsingUrl;
                          }
                          NavigationActionPolicy.CANCEL;
                          var value = await getAppUrl(url.toString());
                          String getUrl = value.toString();
                          await launchUrl(Uri.parse(getUrl));
                          return NavigationActionPolicy.CANCEL;
                        }else {
                            print("앱 설치되지 않음");
                            getMarketUrl(String url) async {
                              var parsingURl = await platform.invokeMethod('getMarketUrl', <String, Object>{'url': url});
                              return parsingURl;
                            }
                            NavigationActionPolicy.CANCEL;
                            var value = await getMarketUrl(url.toString());
                            String marketUrl = value.toString();
                            await launchUrl(Uri.parse(marketUrl));
                            return NavigationActionPolicy.CANCEL;
                        }
                      }
                },
                onLoadStart: (InAppWebViewController controller, uri) {
                  print("onLoadStart");
                  setState(() {myUrl = uri!;});
                },
                onLoadStop: (InAppWebViewController controller, uri) {
                  setState(() {myUrl = uri!;});
                },
                onProgressChanged: (controller, progress) {
                  // if (progress == 100) {pullToRefreshController.endRefreshing();}
                  setState(() {this.progress = progress / 100;});
                },
                androidOnPermissionRequest: (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                onWebViewCreated: (InAppWebViewController controller) {
                  print("onWebViewCreated");
                  webViewController = controller;
                },


              )
            ],))

          ],),
        ),
      ),
    );
  }
}

class PushWebView extends StatelessWidget {

  late final InAppWebViewController webViewController;

  Future<bool> _goBack(BuildContext context) async{
    if(await webViewController.canGoBack()){
      webViewController.goBack();
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

  // Future<String> getAppUrl(String url) async {//앱 URL 받기
  //   if (Platform.isAndroid) {
  //     print("받음?");
  //     //print("안드로이드");
  //     return await platform
  //         .invokeMethod('getAppUrl', <String, Object>{'url': url});
  //   } else {
  //     //print("ios");
  //     return url;
  //   }
  // }

  final String url;
  PushWebView(this.url);

  @override
  Widget build(BuildContext context) {

    print("푸시웹뷰로 넘어감");
    const webPush = "https://m.kaltour.com/ProductPlan/mobileIndex?exiSeq="; //시퀀스만 빠진 url
    var fullUrl = webPush + url; // url과 시

    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(fullUrl)),
          initialOptions: InAppWebViewGroupOptions(
              android: AndroidInAppWebViewOptions(
                  mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
              )
          ),
        )
      ),

    );
  }
}
