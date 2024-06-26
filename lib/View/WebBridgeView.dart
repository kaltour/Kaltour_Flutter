import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kaltour_flutter/Utilities/checkNotificationPermission.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class WebBridgeView extends StatefulWidget {
  late final bool data;
  final String time;

  WebBridgeView({
    required this.data,
    required this.time
  });

  // const WebBridge({super.key});
  @override
  // _WebBridgeState createState() => _WebBridgeState();
  State<WebBridgeView> createState() => _WebBridgeViewState();
}
class _WebBridgeViewState extends State<WebBridgeView> {
  String? _token;
  bool isSwitched = false;
  var now = new DateTime.now(); //반드시 다른 함수에서 해야함, Mypage같은 클래스에서는 사용 불가능
  // String formatDate = DateFormat('yy/MM/dd - HH:mm:ss').format(now);

  PermissionStatus _permissionStatus = PermissionStatus.granted;

  void _toggleSwitch(bool value) {
    setState(() {
      isSwitched = value;
      if (isSwitched) {
        print("on");
        _showNotification("$now에 푸시 켜짐");
      _getToken();

      }else {
        print("off");
        FirebaseMessaging.instance.deleteToken();
        print("토큰 삭제됨");
        _showNotification("$now에 푸시 꺼짐");
      }
    });
  }
  void _showNotification(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("알림"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("확인"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  // void _requestPermission() async {
  //   if (_permissionStatus.isGranted) {
  //     PermissionStatus status = await Permission.notification.request();
  //     setState(() {
  //       _permissionStatus = status;
  //     });
  //   }
  // }

  Future<void> _getToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      setState(() {
        _token = token;
      });
      print("FCM Token 토큰: $_token");
    } catch (e) {
      print("Error fetching FCM token: $e");
    }
  }

  Future<void> _checkPermissionStatus() async {
    PermissionStatus status = await Permission.notification.status;
    setState(() {
      _permissionStatus = status;
    });
  }
  void _requestPermission() async {
    if (_permissionStatus.isGranted || _permissionStatus.isDenied) {
      PermissionStatus status = await Permission.notification.request();
      setState(() {
        _permissionStatus = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isSystemPermissionOff = _permissionStatus.isDenied || _permissionStatus.isPermanentlyDenied;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("토글 버튼 맨들기"),
        ),
        body: Center(
          child: isSystemPermissionOff
          ? Text("System notification permission is off.",
              style: TextStyle(color: Colors.red),
          )
          : Switch(
            value: _permissionStatus.isGranted,
            onChanged:(newValue) async {
              if(newValue) {
                await Permission.notification.request();

              }else {
                print("else문");
              }
              PermissionStatus status = await Permission.notification.status;
              setState(() {
                _permissionStatus = status;
              });


            },
            activeColor: Colors.blue,
            activeTrackColor: Colors.lightBlueAccent,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],

      )
        ),
        // body: Center(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Switch(value: !_permissionStatus.isDenied,
        //           onChanged: (newValue) async {
        //         if(newValue) {
        //           // await Permission.notification.request();// 알림을 허용하눈 함수
        //           openAppSettings();
        //           print("if문");
        //         }else {
        //           print("else문");
        //         }
        //         PermissionStatus status = await Permission.notification.status;
        //         setState(() {
        //           _permissionStatus = status;
        //         });
        //
        //           }),
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.center,
        //         children: [
        //           Text("광고성 정보 수신 설정"),
        //           SizedBox(height: 20),
        //
        //           Switch(
        //             value: isSwitched,
        //             onChanged: _toggleSwitch,
        //             activeTrackColor: Colors.blue,
        //             activeColor: Colors.white,
        //             inactiveTrackColor: Colors.grey,
        //             inactiveThumbColor: Colors.grey[200],
        //           )
        //         ],
        //       ),
        //       Text(
        //         widget.time
        //
        //       )
        //     ],
        //   ),
        //  
        // ),
        
        

      )
    );
  }
}
