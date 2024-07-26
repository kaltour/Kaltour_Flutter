import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/route_manager.dart';
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
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:kaltour_flutter/main.dart';
import 'package:kaltour_flutter/Utilities/requestPermissions.dart';
import 'package:kaltour_flutter/Model/RealUrl.dart';
import 'package:kaltour_flutter/Test/WebBridgeView.dart';
import 'package:kaltour_flutter/Utilities/requestPermissions.dart';
import 'package:kaltour_flutter/View/PushedWebView.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

// const platform = MethodChannel('androidIntent');
const MethodChannel methodChannel = MethodChannel('androidIntent');

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("백그라운드 메시지 처리.. ${message.notification!.body!}");
  print("백그라운드 데이터 키 메시지 처리.. ${message.data.keys}");
  print("백그라운드 데이터 밸류 메시지 처리.. ${message.data.values}");
}

class MainWebView extends StatefulWidget {
  const MainWebView({super.key});

  @override
  State<MainWebView> createState() => _MainWebViewState();
}

//************************************************************
class _MainWebViewState extends State<MainWebView> {
  // static const platform = MethodChannel('fcm_default_channel')
  double progress = 0;
  DateTime now = DateTime.now();
  late bool adAllowPush = false; //광고성 푸시 허용/비허용 변수
  // bool _notificationEnabled = true;
  String? _token;
  late InAppWebViewController webViewController;

  // late WebViewController _controller;
  String appUserAgent = "APP_WISHROOM_Android";
  String webUserAgent =
      "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1";

  // final _cookieManager = WebViewCookieManager();
  // final CookieManager cookieManager = CookieManager.instance();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    print("MainWebView실행");
    setupInteractedMessage();
    // checkAppVersion();
    _initializeNotification();
    loadFixedValue();
    print("토큰 = $_token");
    _checkLoginUserStatus();
    // _androidOnly();
    // _showPromotionalAlert();
    // fetchData();
    // _setCookie();
    // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    // const AndroidInitializationSettings initializationSettingsAndroid =
    // AndroidInitializationSettings('app_icon');
    // final InitializationSettings initializationSettings = InitializationSettings(
    //   android: initializationSettingsAndroid,
    // );
    //
    // flutterLocalNotificationsPlugin.initialize(initializationSettings);
    // _createNotificationChannel();
  }

  void _fetchData() async {
    var url = Uri.parse('https://m.kaltour.com/');
    var response = await http.get(
      url,
      headers: {
        'Cookie': 'appCookie=isApp',
      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  void _setCookie() async {
    print("셋쿠키");
    CookieManager.instance().setCookie(
      url: Uri.parse("https://m.kaltour.com/"),
      name: "appCookie",
      value: "isApp",
      domain: ".kaltour.com/",
    );
  }

  void _getCookies() async {
    // 쿠키 가져오기
    List<Cookie> cookies = await CookieManager.instance()
        .getCookies(url: Uri.parse("https://m.kaltour.com/"));
    for (var cookie in cookies) {
      print('Cookie: ${cookie.name}=${cookie.value}');
    }
  }

  void _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'kaltour',
      'My_Channel',
      // 'This is an example notification channel',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0,
      'New Alert',
      'How to show Local Notification',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  // void toggleFixedValue() {
  //   setState(() {
  //     adAllowPush = !adAllowPush; // true <-> false 토글
  //   });
  // }

  void _toggleFixedValue() {
    setState(() {
      adAllowPush = !adAllowPush; // 값 토글
      saveFixedValue(adAllowPush); // 변경된 값 저장하기
    });
  }

  // void _getCookies() async {
  //   final cookies = await cookieManager.getCookies(url: Uri.parse('https://qa-m.kaltour.com/'));
  //   print('Cookies for https://qa-m.kaltour.com/:');
  //   cookies.forEach((cookie) {
  //     print('Name: ${cookie.name}, Value: ${cookie.value}');
  //   });
  // }

  // Future<void> _setCookies() async {
  //   await _cookieManager.setCookie(
  //     WebViewCookie(
  //       name: 'appCookie',
  //       value: 'isApp',
  //       domain: '.kaltour.com/', // 도메인은 앞에 점을 붙여 서브도메인에서도 사용할 수 있게 설정
  //       path: '/'
  //     ),
  //   );
  //
  //   print("setCookies");
  //
  // }
  void _showPromotionalAlert(BuildContext context) async {
    print("_showPromotionalAlert");
    late DateTime currentDateTime = DateTime.now();
    return showCupertinoDialog<void>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          // title: Text('앱 알림 (선택)'),
          content: Text('특가 상품 및 이벤트 정보 알림을\n 수신하겠습니까?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                '아니오',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                //거부시
                setState(() {
                  print("광고성 앱푸신 거부 $adAllowPush");
                });
                // _setPromotionalAllowed(false);
                // adAllowPush == false;
                // print("MainWeb에서 푸시 = $adAllowPush");
                //

                FirebaseMessaging.instance.deleteToken();
                print("토큰 삭제됨");
                var now = new DateTime
                    .now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
                String formatDate =
                    DateFormat('yy/MM/dd - HH:mm:ss').format(now); //
                Fluttertoast.showToast(
                    msg:
                        "${currentDateTime.year}년 ${currentDateTime.month}월 ${currentDateTime.day}일에 이벤트 정보 알림 수신을\n 거부하였습니다",
                    fontSize: 12.0,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP

                    // fontSize: 16.0
                    );
                Navigator.pop(context, false);
              },
            ),
            CupertinoDialogAction(
              child: Text(
                '네',
                style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              onPressed: () {
                //허용시
                setState(() {
                  adAllowPush = true;
                  print("MainWeb에서 푸시 = $adAllowPush");
                  saveFixedValue(adAllowPush);
                });
                _getToken();
                var now = new DateTime
                    .now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
                String formatDate =
                    DateFormat('yy/MM/dd - HH:mm:ss').format(now); //
                Fluttertoast.showToast(
                    msg:
                        "${currentDateTime.year}년 ${currentDateTime.month}월 ${currentDateTime.day}일에 이벤트 정보 알림 수신을\n 동의하였습니다 ",
                    fontSize: 12.0,
                    backgroundColor: Colors.blue,
                    textColor: Colors.white,
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP);
                // Navigator.of(context).pop();

                Navigator.pop(context, true);
              },
              // style: const ButtonStyle(
              //   backgroundColor: MaterialStatePropertyAll<Color>(
              //       Color.fromRGBO(1, 123, 178, 0.6)
              //   ),
              // ),
            ),
          ],
        );
      },
    );
  }

  void _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    setState(() {
      _token = token;
    });
    print("FCM Token(토큰) : $_token");

  }


  // void check_time(BuildContext context) {
  //   //context는 Snackbar용, 다른 방식으로 출력할거면 필요없음.
  //   var now = new DateTime.now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
  //   String formatDate =
  //       DateFormat('yy/MM/dd - HH:mm:ss').format(now); //format변경
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //     //출력용 snackbar
  //     content: Text('$formatDate'),
  //     duration: Duration(seconds: 20),
  //   ));
  // }
  //

  void _requestPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isPermissionGranted = prefs.getBool('isPermissionGranted') ?? false;

    if (!isPermissionGranted) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await prefs.setBool('isPermissionGranted', true);
        _showPromotionalAlert(context);
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print("광고 알럿 거부됨");
      }
    }

    // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
    // NotificationSettings settings = await _firebaseMessaging.requestPermission(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );

    // if (settings.authorizationStatus == AuthorizationStatus.authorized) { //시스템 권한
    //
    //   _showPromotionalAlert(context);
    //   print("시스템 푸시 권한 허용");
    //   // bool isPromoAllowed = await _isPromotionalAllowed();
    //   // if(!isPromoAllowed) {
    //   //   _showPromotionalAlert();
    //   // }
    //
    // } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    //   // Fluttertoast.showToast(msg: '임시 푸시 알림이 거부되었습니다');
    //
    //
    //   FirebaseMessaging.instance.deleteToken();
    //   // adAllowPush = false;
    //
    //   print("임시 푸시 알림이 거부되었습니다");
    // } else {
    //   // Fluttertoast.showToast(msg: '푸시 알림이 허용되지 않았습니다');
    //   FirebaseMessaging.instance.deleteToken();
    //   // adAllowPush = false;
    //   print("푸시 알림이 허용되지 않았습니다");
    // }
  }

  void _initializeNotification() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            'kaltour', '한진관광',
            importance: Importance.high));

    await flutterLocalNotificationsPlugin
        .initialize(const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ));
  }

  void _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
        "kaltour", "My_Channel",
        importance: Importance.high);

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        importance: Importance.max,
        priority: Priority.high,
      ),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true, // URL 로딩 제어
        mediaPlaybackRequiresUserGesture: false, // 미디어 자동 재생
        javaScriptEnabled: true, // 자바스크립트 실행 여부
        javaScriptCanOpenWindowsAutomatically: true,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ));

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // var now = DateTime.now();
      // Fluttertoast.showToast(msg: "$initialMessage, $now");

      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<String> getAppUrl(String url) async {
    //앱 URL 받기
    if (Platform.isAndroid) {
      print("안드로이드");
      return await methodChannel
          .invokeMethod('getAppUrl', <String, Object>{'url': url});
    } else {
      print("iOS");
      return url;
    }
  }

  void _handleMessage(RemoteMessage message) {
    String url = message.data["ActionURL"];
    String messageKey = message.data.keys.toString();

    if (url != null) {
      print("메시지 키 = $messageKey, URL = $url");
      // webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));// url을 받으면 새로고침

      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PushedWebView(myUrl: url)));// 이 코드로해야 백그라운드에서 잘 받아짐..
    } else {
      print("url못받음");
    }
  }

  Future<void> checkAppVersion() async {
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

    if (double.parse(firebaseVersion) > double.parse(appVersion)) {
      showUpdateDialog();
      print("업데이트 해야함");
    } else {
      MainWebView();
      print("업데이트 안해도됨");
    }
  }

  Future<void> showUpdateDialog() {
    print("showUpdateDialog");
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Center(child: Text("업데이트 알림")),
            content: const Text(
              "더 나은 서비스를 위해\n한진관광 앱이 업데이트 되었습니다.\n최신 앱을 설치해주세요.",
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              ElevatedButton(
                  onPressed: () async {
                    const url =
                        'https://play.google.com/store/apps/details?id=m.kaltour.ver2';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    }
                  },
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll<Color>(
                          Color.fromRGBO(1, 123, 178, 0.6))),
                  child: const Text(
                    "업데이트하기",
                    style: TextStyle(color: Colors.black),
                  )),
              ElevatedButton(
                  onPressed: () async {
                    // 앱 종료
                    if (Platform.isAndroid) {
                      SystemNavigator.pop(); //앱 종료
                      // Navigator.pop(context); // 다이알로그만 끄기
                    } else if (Platform.isIOS) {
                      exit(0);
                    }
                  },
                  child: const Text(
                    "종료",
                    style: TextStyle(color: Colors.black),
                  ))
            ],
          );
        });
  }

  Future<void> loadFixedValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      adAllowPush =
          prefs.getBool('adAllowPush') ?? false; // 저장된 값 불러오기, 없으면 기본값은 false
    });
  }

  Future<void> saveFixedValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adAllowPush', value); // 값 저장하기
  }

  Future<void> _checkLoginUserStatus() async {
    final cookieManager = CookieManager.instance();
    final cookies = await cookieManager.getCookies(url: Uri.parse('https://m.kaltour.com'));
    final userIdCookie = cookies.firstWhere(
          (cookie) => cookie.name == 'KALTOUR_USER_ID',
      orElse: () => Cookie(
        name: 'KALTOUR_USER_ID',

        value: '',
        domain: '.kaltour.com',
      ),
    );

    final userMemCookie = cookies.firstWhere(
          (cookie) => cookie.name == 'KALTOUR_USER_MEM_NUMBER',
      orElse: () => Cookie(
        name: 'KALTOUR_USER_MEM_NUMBER',

        value: '',
        domain: '.kaltour.com',
      ),
    );

    if (userIdCookie.value.isNotEmpty || userMemCookie.value.isNotEmpty) {
      print('유저 User is logged in with ID: ${userIdCookie.value}, MemNum: ${userMemCookie.value}');
      // 여기서 추가적인 로그인 처리 로직을 구현할 수 있습니다.
    } else {
      print('유저 User is not logged in.');
    }
  }

  // Future<void> _checkLoginMemNumStatus() async {
  //   final cookieManager = CookieManager.instance();
  //   final cookies = await cookieManager.getCookies(url: Uri.parse('https://m.kaltour.com'));
  //   final loggedInCookie = cookies.firstWhere(
  //         (cookie) => cookie.name == 'KALTOUR_USER_MEM_NUMBER',
  //     orElse: () => Cookie(
  //       name: 'KALTOUR_USER_MEM_NUMBER',
  //
  //       value: '',
  //       domain: '.kaltour.com',
  //     ),
  //   );
  //
  //   if (loggedInCookie.value.isNotEmpty|| loggedInCookie.value.) {
  //     print('유저 User is logged in with MemNum: ${loggedInCookie.value}');
  //     // 여기서 추가적인 로그인 처리 로직을 구현할 수 있습니다.
  //   } else {
  //     print('유저 UserMemNum is not logged in.');
  //   }
  // }




  // Future<void> _setPromotionalAllowed(bool allowed) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('promotional_notifications', allowed);
  // }
  //
  // Future<bool> _isPromotionalAllowed() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool('promotional_notifications') ?? false;
  // }

  @override
  Widget build(BuildContext context) {
    // _configureFirebaseMessaging(context);
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     ElevatedButton(onPressed: toggleFixedValue, child: Text("Toggle $adAllowPush")),
      //   ],
      //
      // ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _goBack(context),
          child: Column(
            children: <Widget>[
              Expanded(
                  child: Stack(
                children: [
                  InAppWebView(
                    initialUrlRequest: URLRequest(url: myUrl),

                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        // mediaPlaybackRequiresUserGesture: false, 여담용
                          // userAgent: customUserAgent,
                          useShouldOverrideUrlLoading: true),
                      android: AndroidInAppWebViewOptions(
                          mixedContentMode: AndroidMixedContentMode
                              .MIXED_CONTENT_ALWAYS_ALLOW),

                      // android: AndroidInAppWebViewOptions(
                      //   mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
                      // )
                    ),
                    shouldOverrideUrlLoading:
                        (controller, navigationAction) async {

                      // await controller.setOptions(options: InAppWebViewGroupOptions(crossPlatform: InAppWebViewOptions(
                      //   userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"
                      // )));
                      bool isApplink(String url) {
                        final appScheme = Uri.parse(url).scheme;
                        var uri = navigationAction.request.url;

                        print("앱스킴 = $appScheme"); //https
                        return appScheme != 'http' &&
                            appScheme != 'https' &&
                            appScheme != 'about:blank' &&
                            // appScheme != 'intent://' &&
                            appScheme != 'data';
                      }

                      final url = navigationAction.request.url.toString();
                      print("유알엘 = $url");
                      if (isApplink(url) && url != "about:blank") {
                        print("넘어간다");
                        String getUrl = await getAppUrl(url);

                        if (await canLaunch(getUrl)) {
                          getAppUrl(String url) async {
                            var parsingUrl = await methodChannel.invokeMethod(
                                'getAppUrl', <String, Object>{'url': url});
                            return parsingUrl;
                          }
                          NavigationActionPolicy.CANCEL;
                          var value = await getAppUrl(url.toString());
                          String getUrl = value.toString();
                          await launchUrl(Uri.parse(getUrl));
                          return NavigationActionPolicy.CANCEL;
                        } else {
                          print("앱 설치되지 않음");
                          getMarketUrl(String url) async {
                            var parsingURl = await methodChannel.invokeMethod(
                                'getMarketUrl', <String, Object>{'url': url});
                            return parsingURl;
                          }

                          NavigationActionPolicy.CANCEL;
                          var value = await getMarketUrl(url.toString());
                          String marketUrl = value.toString();
                          await launchUrl(Uri.parse(marketUrl));
                          return NavigationActionPolicy.CANCEL;
                        }
                      }



                      // final url = navigationAction.request.url.toString();
                      // print("유알엘 = $url");
                      // if (isApplink(url) && url != "about:blank") {
                      //   print("넘어간다");
                      //   String getUrl = await getAppUrl(url);
                      //
                      //   if (await canLaunch(getUrl)) {
                      //     getAppUrl(String url) async {
                      //       var parsingUrl = await methodChannel.invokeMethod(
                      //           'getAppUrl', <String, Object>{'url': url});
                      //       print("canLaunch $url");
                      //       // NavigationActionPolicy.CANCEL;
                      //       return parsingUrl;
                      //     }
                      //     // NavigationActionPolicy.CANCEL;
                      //     var value = await getAppUrl(url.toString());
                      //     String getUrl = value.toString();
                      //     await launchUrl(Uri.parse(getUrl));
                      //   } else {
                      //     print("앱 설치되지 않음"); //왜 안깔려잇다고 나오노?
                      //     getMarketUrl(String url) async {
                      //       var parsingURl = await methodChannel.invokeMethod(
                      //           'getMarketUrl', <String, Object>{'url': url});
                      //       // return NavigationActionPolicy.CANCEL;
                      //       return parsingURl;
                      //     }
                      //     NavigationActionPolicy.CANCEL;
                      //     var value = await getMarketUrl(url.toString());
                      //     String marketUrl = value.toString();
                      //     await launchUrl(Uri.parse(marketUrl));
                      //     return NavigationActionPolicy.CANCEL;
                      //   }
                      // }
                    },
                    onLoadStart: (InAppWebViewController controller, uri) {
                      print("onLoadStart");
                      setState(() {
                        myUrl = uri!;
                        _checkLoginUserStatus();
                        // _checkLoginMemNumStatus();
                      });
                      // webViewController!.addJavaScriptHandler(
                      //   handlerName: 'appView',
                      //   callback: (args) {
                      //     // args는 JavaScript에서 전달된 인수입니다.
                      //     print("JavaScript에서 받은 데이터: $args");
                      //     // SecondView();
                      //     // Flutter에서의 처리 로직
                      //     // return {SecondView};
                      //
                      //     Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (context) => WebBridge())
                      //     );
                      //   },
                      // );
                    },
                    onLoadStop: (InAppWebViewController controller, uri) {
                      //웹 페이지 로딩이 완료될 때 호출되는 콜백입니다.

                      setState(() {
                        print("onLoadStop");
                        myUrl = uri!;
                      });
                    },
                    onProgressChanged: (controller, progress) {
                      // if (progress == 100) {pullToRefreshController.endRefreshing();}
                      setState(() {
                        print("onProgressChanged");
                        this.progress = progress / 100;
                      });
                    },
                    onWebViewCreated: (controller) async {
                      //여기다 setcookie, WebView가 생성될 때 호출되는 콜백입니다. InAppWebViewController를 초기화하거나 설정할 수 있습니다.
                      print("onWebViewCreated");
                      // _setCookie();
                      await CookieManager.instance().setCookie(
                        url: Uri.parse("https://m.kaltour.com/"),
                        name: "appCookie",
                        value: "isApp",
                        domain: ".kaltour.com",
                        isSecure: false,
                        isHttpOnly: false,
                        // expiresDate: 99,
                        // maxAge: 99,
                      );
                      //
                      // await CookieManager.instance().setCookie(
                      //   url: Uri.parse("uri"),
                      //   name: "KALTOUR_USER_ID",
                      //   value: "value",
                      //   domain: ".kaltour.com",
                      //   isSecure: false,
                      //   isHttpOnly: false,
                      // );

                      webViewController = controller;
                      webViewController!.addJavaScriptHandler(
                        handlerName: 'appView',
                        callback: (args) {
                          // args는 JavaScript에서 전달된 인수입니다.
                          print("JavaScript에서 받은 데이터: $args");
                          // SecondView();
                          // Flutter에서의 처리 로직
                          // return {SecondView};

                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => PermissionScreen(
                                      adAllowPushValue: adAllowPush,
                                      notiPermissiontime: "$now")));

                          // Navigator.of(context).push(CupertinoPageRoute(
                          //     builder: (context) => PermissionScreen(
                          //         adAllowPushValue: adAllowPush,
                          //         notiPermissiontime: "$now")
                          // ));

                          // Navigator.push(context, MaterialPageRoute (
                          //   builder: (context) => PermissionScreen(
                          //       adAllowPushValue: adAllowPush,
                          //       notiPermissiontime: "notiPermissiontime")
                          // ));
                        },
                      );

                      // webViewController!.addJavaScriptHandler(
                      //   handlerName: 'appView',
                      //   callback: (args) {
                      //     // args는 JavaScript에서 전달된 인수입니다.
                      //     print("JavaScript에서 받은 데이터: $args");
                      //     // SecondView();
                      //     // Flutter에서의 처리 로직
                      //     // return {SecondView};
                      //
                      //     Navigator.of(context).push(MaterialPageRoute(
                      //         builder: (context) => WebBridge())
                      //     );
                      //   },
                      // );
                    },
                    androidOnPermissionRequest:
                        (controller, origin, resources) async {
                      return PermissionRequestResponse(
                          resources: resources,
                          action: PermissionRequestResponseAction.GRANT);
                    },
                  ),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
