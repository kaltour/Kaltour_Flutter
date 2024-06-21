import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';
import 'package:intl/intl.dart';

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



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("토글 버튼 맨들기"),

        ),
        body: Center(
          child: Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("광고성 정보 수신 설정"),
                  SizedBox(height: 20),
                  // IconButton(
                  //   icon: Icon(
                  //     isSwitched ? Icons.toggle_on : Icons.toggle_off,
                  //     color: isSwitched? Colors.blue : Colors.grey ,
                  //     size: 50,
                  //   ),
                  //   onPressed: () {
                  //     setState(() {
                  //       isSwitched = !isSwitched;
                  //       // widget.data = !widget.data;
                  //
                  //       print("토글 버튼 눌러보기");
                  //
                  //     });
                  //   },
                  // ),
                  Switch(
                    value: isSwitched,
                    onChanged: _toggleSwitch,
                    activeTrackColor: Colors.blue,
                    activeColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    inactiveThumbColor: Colors.grey[200],
                  )
                ],
              ),

              // Text(
              //   widget.data ? 'Button is ON' : 'Button is OFF',
              //   style: TextStyle(fontSize: 20),
              // ),


              Text(
                widget.time

              )
            ],
          ),
        ),
      )
    );
  }
}
