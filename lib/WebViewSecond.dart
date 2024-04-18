import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(RealMyApp());
}

class RealMyApp extends StatefulWidget {
  @override
  _RealMyAppState createState() => _RealMyAppState();
}

class _RealMyAppState extends State<RealMyApp> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String _initialUrl = 'https://m.naver.com'; // 초기 웹 페이지 URL

  @override
  void initState() {
    super.initState();
    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() {
    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message: ${message.data}");
      // 푸시 알림을 클릭하여 앱이 실행되었을 때, 해당 URL을 초기 URL로 설정
      setState(() {
        _initialUrl = message.data['sequence'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WebView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('WebView Demo'),
        ),
        body: WebView(
          initialUrl: _initialUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
