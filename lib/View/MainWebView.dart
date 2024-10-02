import 'dart:ffi';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/route_manager.dart';
import 'package:kaltour_flutter/View/PermissionScreen.dart';
import 'package:tosspayments_widget_sdk_flutter/webview/payment_window_webview.dart';
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
import 'package:kaltour_flutter/Utilities/CheckLoginUserStatus.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_url.dart';
import 'package:kaltour_flutter/Utilities/CheckAppVersion.dart';


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
  String? _initialUrl = "https://m.kaltour.com/";
  bool isWebViewReady = false;  // WebView가 준비되었는지 여부를 나타내는 플래그
  late InAppWebViewController _webViewController;

  // late WebViewController _controller;
  String appUserAgent = "APP_WISHROOM_Android";
  String webUserAgent =
      "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1";

  // final _cookieManager = WebViewCookieManager();
  // final CookieManager cookieManager = CookieManager.instance();
  final CookieManager _cookieManager = CookieManager.instance();

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
    _requestPermissions();
    print("MainWebView 초기화");
    setupInteractedMessage();
    checkAppVersion();
    _initializeNotification();
    _loadFixedValue();
    print("FCM 토큰 = $_token");
    // _checkLoginUserStatus();
    _getToken();
    checkLoginUserStatus();
    // _showPromotionalAlert();
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
    // handleInitialMessage();
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
  void _showPromotionalAlert(BuildContext context) async { //광고성 푸시 알럿
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
                  _getToken();
                });

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


    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      setState(() {
        _token = token;
      });
      print("FCM Token: $_token");
    }catch(e) {
      print("Error getting FCM token: $e");
    }
    // FirebaseMessaging messaging = FirebaseMessaging.instance;
    // String? token = await messaging.getToken();
    // setState(() {
    //   _token = token;
    // });
    // print("FCM Token(토큰) : $_token");
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
    print("_requestPermissions 실행");
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
            'kaltour', //알림 채널 ID
        '한진관광', // 알림 채널 이름
            importance: Importance.high));

    await flutterLocalNotificationsPlugin
        .initialize(const InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    ));
  }

  void _createNotificationChannel() async { // Not Use
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
    if (await _webViewController.canGoBack()) {
      _webViewController.goBack();
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
        domStorageEnabled: true,

        useHybridComposition: true,
      ));

  Future<void> setupInteractedMessage() async { //앱이 종료된 상태에서 푸시 알림 클릭하여 열릴 경우 메세지 가져옴
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {

      _handleMessage(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);// 앱이 백그라운드 상태에서 푸시 알림 클릭 하여 열릴 경우 메세지 스트림을 통해 처리
  }

  // void _initializeFirebaseMessaging() { //NOT USED
  //   _firebaseMessaging.requestPermission();
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     _handleMessage(message);
  //   });
  //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  //
  //   // 앱이 종료된 상태에서 알림을 클릭하여 시작된 경우
  //   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
  //     if (message != null) {
  //       _handleMessage(message);
  //     }
  //   });
  // }

  Future<String> getAppUrl(String url) async {
    //앱 URL 받기
    if (Platform.isAndroid) {
      print("안드로이드");
      return await methodChannel
          .invokeMethod('getAppUrl', <String, Object>{'url': url});
    } else {
      return url;
    }
  }

  // Future<void> handleInitialMessage() async { //NOT USED
  //   RemoteMessage? initialMessage =
  //       await FirebaseMessaging.instance.getInitialMessage();
  //   if (initialMessage != null) {
  //     String? url = initialMessage.data["ActionURL"];
  //     String messageKey = initialMessage.data.keys.toString();
  //
  //     // loadUrlInWebView(url);
  //     print(" $url, $messageKey");
  //
  //     if (url != null && url.isNotEmpty) {
  //       if (isWebViewReady) {
  //         print("url 있음");
  //         loadUrlInWebView(url);
  //       } else {
  //         setState(() {
  //           _initialUrl = url;
  //         });
  //       }
  //     }
  //   } else {
  //     print("없음");
  //   }
  // }

  // void loadUrlInWebView(String url) { //NOT USED
  //   if (_webViewController != null) {
  //     _webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)));
  //
  //     print("loadUrlInWebView의 $url");
  //   } else {
  //     setState(() {
  //       _initialUrl = url;
  //     });
  //   }
  // }
  void _handleMessage(RemoteMessage message) async {
    String url = message.data["ActionURL"];
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('PUSH_URL', url);

    if(url != null && url.isNotEmpty) {
      String? savedUrl = prefs.getString('PUSH_URL');
      if (savedUrl != null && url.isNotEmpty) {
        setState(() {
          print("savedURL이 비어있지 않음: $savedUrl");
          _initialUrl = savedUrl;

          if (_webViewController != null) {
            _webViewController!.loadUrl(
              urlRequest: URLRequest(url: Uri.parse(savedUrl)),
            );
          } else {
            print("_webViewController가 아직 초기화되지 않음");
          }

        });
      }
      
    }

  }

  Future<void> checkAppVersion() async {

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
      return;
    }

    // 현재 앱 버전 가져오기
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    print("앱 버전=$appVersion");

    // 버전 비교
    if (double.parse(firebaseVersion) > double.parse(appVersion)) {
      if (Platform.isAndroid) {
        showUpdateDialog(); // Android 업데이트 다이얼로그
      } else if (Platform.isIOS) {
        showUpdateDialog(); // iOS 업데이트 다이얼로그
      }
      print("업데이트 필요");
    }
    else {
      print("업데이트 불필요");
    }
  }

  Future<void> showUpdateDialog() { // 최신 앱 요청 알럿
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
                    if(Platform.isAndroid) {
                      const url =
                          'https://play.google.com/store/apps/details?id=m.kaltour.ver2';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    }else if (Platform.isIOS) {
                      const url = "https://apps.apple.com/kr/app/%ED%95%9C%EC%A7%84%EA%B4%80%EA%B4%91/id1068782555";
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }

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

  Future<void> _loadFixedValue() async {
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

  // Future<void> _launchURL(String url) async {
  //   // 유튜브 앱을 여는 링크 형식
  //   final Uri youtubeUri = Uri.parse(url);
  //   if (await canLaunch(youtubeUri.toString())) {
  //     await launch(youtubeUri.toString());
  //   } else {
  //     // 앱이 없을 경우 웹 브라우저에서 열기
  //     await launch(url);
  //   }
  // }



  String _extractPackageName(String url) {
    // Extract package name from intent URL
    RegExp regExp = RegExp(r'package=([^;,\s]+)');
    Match? match = regExp.firstMatch(url);
    return match?.group(1) ?? "";
  }


  // Future<void> _checkLoginUserStatus() async {
  //   final cookieManager = CookieManager.instance();
  //   final cookies =
  //       await cookieManager.getCookies(url: Uri.parse('https://m.kaltour.com'));
  //   final userIdCookie = cookies.firstWhere(
  //     (cookie) => cookie.name == 'KALTOUR_USER_ID',
  //     orElse: () => Cookie(
  //       name: 'KALTOUR_USER_ID',
  //       value: '',
  //       domain: '.kaltour.com',
  //     ),
  //   );
  //
  //   final userMemCookie = cookies.firstWhere(
  //     (cookie) => cookie.name == 'KALTOUR_USER_MEM_NUMBER',
  //     orElse: () => Cookie(
  //       name: 'KALTOUR_USER_MEM_NUMBER',
  //       value: '',
  //       domain: '.kaltour.com',
  //     ),
  //   );
  //
  //   if (userIdCookie.value.isNotEmpty || userMemCookie.value.isNotEmpty) {
  //     print(
  //         '유저 User is logged in with ID: ${userIdCookie.value}, MemNum: ${userMemCookie.value}');
  //     // 여기서 추가적인 로그인 처리 로직을 구현할 수 있습니다.
  //   } else {
  //     print('유저 User is not logged in.');
  //   }
  // }

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

  Future<bool> _isAppInstalled(String packageName) async {
    try {
      final result = await Process.run('pm', ['list', 'packages', packageName]);
      return result.stdout.toString().contains(packageName);
    } catch (e) {
      return false; // 예외 발생 시 false 반환
    }
  }

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

      // appBar: AppBar(
      //   title: Text("LIVE"),
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
                    initialUrlRequest: URLRequest(url: Uri.parse(_initialUrl!)),
                    initialOptions: InAppWebViewGroupOptions(
                      crossPlatform: InAppWebViewOptions(
                        cacheEnabled: true,
                          clearCache: true,
                          transparentBackground: true,
                          javaScriptEnabled: true,
                          // mediaPlaybackRequiresUserGesture: false, 여담용
                          // userAgent: customUserAgent,
                          useShouldOverrideUrlLoading: true),
                      android: AndroidInAppWebViewOptions(
                        useHybridComposition: true,
                          mixedContentMode: AndroidMixedContentMode
                              .MIXED_CONTENT_ALWAYS_ALLOW),

                      // android: AndroidInAppWebViewOptions(
                      //   mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW
                      // )
                    ),

                    shouldOverrideUrlLoading: (controller, navigationAction) async{
                      print("=====shouldOverrideUrlLoading======");

                      var curUrl = navigationAction.request.url;
                      print("curUrl === $curUrl");

                      tossPaymentsWebview(url) {
                        final appScheme = ConvertUrl(url);

                        if(appScheme.isAppLink()) {
                          appScheme.launchApp(mode: LaunchMode.externalApplication);

                          return NavigationDecision.prevent;

                        }
                      }

                      var uri = navigationAction.request.url;
                      if (uri == null) {
                        return NavigationActionPolicy.ALLOW;

                      }

                      if (uri.scheme == "mailto" ||
                          uri.scheme == "tel" ||
                          uri.scheme == "sms"

                      ) {
                        if(await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                          return NavigationActionPolicy.CANCEL;
                        }

                      }

                      bool isAppLink(Uri url) {
                        final appScheme = url.scheme;
                        // final appScheme = Uri.parse(Uri).scheme;
                        return appScheme != 'http' &&
                            appScheme != 'https' &&
                            appScheme != 'about:blank' &&
                            appScheme != 'data';
                      }

                      if(curUrl == null) return NavigationActionPolicy.CANCEL;

                      final url = navigationAction.request.url.toString();
                      print("유알엘 = $url");


                      if(isAppLink(curUrl)) {
                        await controller.stopLoading();

                        var scheme = curUrl.scheme;

                        if(scheme == "intent") {
                          if(Platform.isAndroid) {
                            try {
                              final parsedIntent = await methodChannel.invokeMethod('getAppUrl', {'url': curUrl.toString()});
                              print("parsedIntent == $parsedIntent");



                              if (await canLaunchUrl(Uri.parse(parsedIntent))) {
                                await launchUrl(Uri.parse(parsedIntent));
                                return NavigationActionPolicy.CANCEL;
                              }

                              else {

                                final marketUrl = await methodChannel.invokeMethod('getMarketUrl', {'url': curUrl.toString()});
                                print(" 앱 설치되지 않음, 마켓 URL = $marketUrl");
                                await launchUrl(Uri.parse(marketUrl));
                                return NavigationActionPolicy.CANCEL;
;                              }
                            }catch (e) {
                              print('ERROR ==  $e');
                            }
                          }else if (Platform.isIOS) {
                            var value = await getAppUrl(url.toString());
                            String getUrl = value.toString();
                            tossPaymentsWebview(getUrl);
                          }
                        }

                        return NavigationActionPolicy.CANCEL;

                      }else {
                        return NavigationActionPolicy.ALLOW;
                      }


                    },


                    onLoadStart: (InAppWebViewController controller, uri) {
                      print("onLoadStart");

                      // if(uri != null && uri.toString().contains("youtube")) {
                      //   _launchURL(uri.toString());
                      // }
                      setState(() {
                        myUrl = uri!;
                        checkLoginUserStatus();
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
                    onWebViewCreated: (InAppWebViewController webViewController)  {
                      _webViewController = webViewController;
                      print("WebViewController가 초기화되었습니다."); // 초기화 로그 추가
                      if (_initialUrl != null) {
                        print("초기 URL 로드: $_initialUrl");
                        _webViewController!.loadUrl(
                          urlRequest: URLRequest(url: Uri.parse(_initialUrl!)),
                        );
                      }
                      //여기다 setcookie, WebView가 생성될 때 호출되는 콜백입니다. InAppWebViewController를 초기화하거나 설정할 수 있습니다.
                      print("onWebViewCreated");
                      // _setCookie();

                      // if (_initialUrl != null) {
                      //   webViewController!.loadUrl(urlRequest: URLRequest(url: Uri.parse(_initialUrl!)));
                      //   setState(() {
                      //     print("onWebViewCreated에서 이동");
                      //     _initialUrl = null; // 초기 URL을 로드한 후 초기화
                      //   });
                      // }

                       CookieManager.instance().setCookie(
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

                      // webViewController = controller;
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
                    onCreateWindow: (controller, createWindowRequest) async {
                      showDialog(context: context,
                          builder: (context) {
                        return AlertDialog(
                          content: Container (
                            width: MediaQuery.of(context).size.width,
                            height: 400,
                            child: InAppWebView (
                              windowId: createWindowRequest.windowId,
                              initialOptions: InAppWebViewGroupOptions(
                                android: AndroidInAppWebViewOptions(
                                  builtInZoomControls: true,
                                  thirdPartyCookiesEnabled: true,
                                ),
                                crossPlatform: InAppWebViewOptions(
                                  cacheEnabled: true,
                                  javaScriptEnabled: true,
                                ),
                              ),

                              onWebViewCreated:(InAppWebViewController controller) {

                              },
                              onCloseWindow: (controller) {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              },

                            ),


                          ),

                        );

                          });
                      return true;

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
