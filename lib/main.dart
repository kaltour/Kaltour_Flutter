import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

 const platform = MethodChannel('androidIntent');

void main() async { //시작점

  print("!!!RUN APP!!!");
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // initializeNotification();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  sendToken(); // 토큰 받아서 서버에 전송


  FirebaseMessaging.instance.requestPermission(
    badge: true,
    alert: true,
    sound: true,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("FirebaseMessaging.onMessage.listen");
    print('Foreground에서 푸시 받음');
    print('Message data: ${message.data}');

    String url = message.data['sequence'];
    if(url != null) {
      print("Foreground 데이터 URL = $url");

    }
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
              android: AndroidNotificationDetails(
                  'high_importance_channel', 'high_importance_notifications',
                  importance: Importance.max)));
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

@pragma('vm:entry-point')
void backgroundHandler(NotificationResponse details) {}


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  print("_firebaseMessagingBackgroundHandler");
  print("백그라운드 메시지 처리.. ${message.notification!.body!}");
  print("백그라운드 데이터 처리 ${message.data}");

  await Firebase.initializeApp();
  // 백그라운드에서 메세지 처리
  flutterLocalNotificationsPlugin.show(
      message.notification.hashCode,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id, channel.name,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: message.notification!.android!.smallIcon,
        ),
      ));

  print('Handling a background message ${message.messageId}');

}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  // 'This channel is used for important notifications', //description
  importance: Importance.max,
);

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();


void sendToken() async { // 토큰 발송
  // String? _fcmToken = await FirebaseMessaging.instance.getToken();
  // print("토큰 = $_fcmToken");

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
    var initialzationsettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initialzationsettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    return MaterialApp(
      // navigatorKey: GlobalVariable.navState,
      debugShowCheckedModeBanner: true, //디버깅시 띠 가리기
      home: MyWebView(),
    );
  }
}

void _handleMessageOpenedApp(RemoteMessage message, BuildContext context) { //포그라운드에서 푸시 클릭시 작동되는 함수
  print("오픈 메시지");
  print("컨텍스트 = $context"); //"MyApp"
  String url = message.data['sequence'];

  print("유알엘 ===== $url");
  if (url != null) {
    print("시퀀스 데이터 유알엘 = $url");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PushWebView(url)),
    );
  } else {
    print("시퀀스가 없음");
  }
}

void _configureFirebaseMessaging(BuildContext context) {
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleMessageOpenedApp(message, context);
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

  Future<String> _convertIntentToMarketUrl(String text) async { // 마켁 URL 받기
    return await platform.invokeMethod('getMarketUrl',  <String, Object>{'url': text});
  }
  void _handleMessage(RemoteMessage message) {

    String url = message.data["sequence"];
    if(url != null) {
      // Fluttertoast.showToast(msg: "${message.data}");
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=> PushWebView(url)),
      );
    }
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
                              var parsingURl = await platform
                                  .invokeMethod('getMarketUrl', <String, Object>{'url': url});
                              return parsingURl;
                            }
                            NavigationActionPolicy.CANCEL;
                            var value = await getMarketUrl(url.toString());
                            String marketUrl = value.toString();
                            await launchUrl(Uri.parse(marketUrl));
                        }

                        // if (await canLaunch(getUrl)) {
                        //   print("유알엘을 받음");
                        //   await launch(getUrl);
                        //   print("겟 유알엘 = $getUrl");
                        //   return NavigationActionPolicy.CANCEL;
                        //
                        //
                        // }else { // 앱이 없을때!!
                        //   print("앱 설치되지 않음");
                        //   getMarketUrl(String url) async {
                        //     var parsingURl = await platform
                        //         .invokeMethod('getMarketUrl', <String, Object>{'url': url});
                        //     return parsingURl;
                        //   }
                        //   NavigationActionPolicy.CANCEL;
                        //   var value = await getMarketUrl(url.toString());
                        //   String marketUrl = value.toString();
                        //   await launchUrl(Uri.parse(marketUrl));
                        // }
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

  final String url;
  PushWebView(this.url);

  @override
  Widget build(BuildContext context) {

    // Future<String> getAppUrl(String url) async {//앱 URL 받기
    //   if (Platform.isAndroid) {
    //     //print("안드로이드");
    //     return await platform
    //         .invokeMethod('getAppUrl', <String, Object>{'url': url});
    //   } else {
    //     //print("ios");
    //     return url;
    //   }
    // }
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
