import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';


class PermissionScreen extends StatefulWidget {
  final bool adAllowPush;
  String notiPermissiontime;

  PermissionScreen(
      {required this.adAllowPush, required this.notiPermissiontime});

  @override
  _PermissionScreenState createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  late bool _adAllowPush;
  late DateTime currentDateTime = DateTime.now();
  bool isSwitchEnabled = false;
  bool _isNotificationEnabled = false;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  String? _token;


  @override
  void initState() {
    super.initState();
    // _checkPermissionStatus();
    _checkNotificationPermission();
    _adAllowPush = widget.adAllowPush;
    checkPermissionStatus();
    _loadSwitchValue();


  }
  void _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    setState(() {
      _token = token;
    });
    print("FCM Token(토큰) : $_token");
  }
  void _toggleSwitch(bool value) {
    //광고성
    setState(() {
      _adAllowPush = value;
    });

    if (_adAllowPush) {
      //광고성
      // _showSnackBar('광고성 켜졌습니다');
      _showAlert(context);
      // FirebaseMessaging.instance.getToken();

      _getToken();

      setState(() {
        _adAllowPush = true;
      });

    } else {
      // _showSnackBar('광고성 꺼졌습니다');
      print("Firebase 토큰 삭제됨");
      _showAlert(context);
      FirebaseMessaging.instance.deleteToken();


      setState(() {
        _adAllowPush = false;
      });
    }
  }

  // void _requestPermission() async {
  //   if (_permissionStatus.isGranted || _permissionStatus.isDenied) {
  //     PermissionStatus status = await Permission.notification.request();
  //     setState(() {
  //       _permissionStatus = status;
  //     });
  //   }
  // }

  _loadSwitchValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _adAllowPush = (prefs.getBool('adAllowPush') ?? false);
    });
  }
  _saveSwitchValue(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('adAllowPush', value);
  }



  void _checkNotificationPermission() async {
    final status = await Permission.notification.status;
    setState(() {
      _permissionStatus = status;
      _isNotificationEnabled = _permissionStatus == PermissionStatus.granted;
    });
  }

  void _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _permissionStatus = status;
      _isNotificationEnabled = _permissionStatus == PermissionStatus.granted;
    });
  }
  void checkPermissionStatus() async {
    PermissionStatus pushStatus = await Permission.notification.status;
    setState(() {
      // 푸시 권한이 거부된 경우 스위치를 비활성화
      isSwitchEnabled = pushStatus != PermissionStatus.denied;
    });
  }

  void _showAlert(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              // title: Text("한진관광",
              //   style: TextStyle(
              //     color: Colors.blue
              //   ),
              // ),

              content: Text(
                  "이벤트 및 마케팅 정보 수신에 \n ${_adAllowPush ? "동의" : "거부"}하였습니다. ${currentDateTime.year}년 ${currentDateTime.month}월 ${currentDateTime.day}일"),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text(
                    "확인",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.w500),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                  },
                ),
                // CupertinoDialogAction(child: Text("cancel"),
                //
                //   onPressed: () {
                //   print("취소");
                //   Navigator.of(context).pop();
                //   },
                // )
              ],
            ));
  }

  // void _systemToggleNotification(bool value) {
  //   //시스템 푸시
  //   if (_permissionStatus == PermissionStatus.denied) {
  //     print("시스템 알림 켜기");
  //     _requestNotificationPermission();
  //     openAppSettings();
  //     // return;
  //   } else {
  //     print("시스템 알림 끄기");
  //     // openAppSettings();
  //
  //   }
  //
  //   setState(() {
  //     _isNotificationEnabled = value;
  //   });
  //
  //
  //   String message = value ? '알림이 켜졌습니다' : '알림이 꺼졌습니다';
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       duration: Duration(seconds: 1),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    bool isSystemPermissionOff =
        _permissionStatus.isGranted || _permissionStatus.isPermanentlyDenied;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '한진관광 앱 설정',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(children: [
        Container(
          padding: EdgeInsets.all(18.0),
          child: Row(
            children: [
              Text(
                _permissionStatus == PermissionStatus.granted
                    ? '시스템 알림'
                    : '시스템 알림',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600
                    // fontWeight: FontWeight.w400
                    ),
              ),
              Spacer(),
              Visibility(
                visible: _permissionStatus.isGranted == false,
                child: CupertinoButton(
                  // color: CupertinoColors.activeBlue,
                  onPressed: () {
                    openAppSettings();
                    if(Platform.isIOS) {
                      print("ios에서");
                    }
                  },
                  child: Text(
                    "설정하기",
                    style: TextStyle(fontSize: 18.0, color: Colors.blue,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          child: Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 24, right: 18, top: 19, bottom: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("특가 상품 및 이벤트 정보 알림",
                      style: TextStyle(
                        fontSize: 17.0,
                      )),
                  SizedBox(width: 70),
                  CupertinoSwitch(
                    value: _adAllowPush == true,
                    onChanged: isSwitchEnabled ? (value) {
                      // _adAllowPush = value;
                      setState(() {
                        _adAllowPush = value;
                        _toggleSwitch(value);
                        _adAllowPush = value;
                      });
                      _saveSwitchValue(value);
                    } : null,
                    activeColor: Colors.blue,
                    trackColor: Colors.grey,
                    // activeColor: CupertinoColors.activeBlue,
                  ),
                ],
              ),
              // Visibility(
              //   visible: _permissionStatus.isGranted == true,
              //
              // )
            ],
          ),
        ),
      ]),
    );
  }
}
