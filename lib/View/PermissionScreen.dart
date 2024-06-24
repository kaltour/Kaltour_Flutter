import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';



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

  PermissionStatus _permissionStatus = PermissionStatus.granted;
  //
  // bool _isNotificationEnabled = false;
  // bool _isAnotherFeatureEnabled = false;

  @override
  void initState() {
    super.initState();
    // _checkPermissionStatus();
    //
    // _checkNotificationPermission();
    _adAllowPush = widget.adAllowPush;

  }

  void _toggleSwitch(bool value) {
    setState(() {
      _adAllowPush = value;
    });

    if (_adAllowPush) {
      _showSnackBar('스위치가 켜졌습니다');
    } else {
      _showSnackBar('스위치가 꺼졌습니다');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
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

    bool isSystemPermissionOff =
        _permissionStatus.isDenied || _permissionStatus.isPermanentlyDenied;

    return Scaffold(
      appBar: AppBar(
        title: Text('한진관광 푸시 알림 설정'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '시스템 알림 권한',
                  style: TextStyle(fontSize: 16),
                ),
                CupertinoSwitch(
                  value: _permissionStatus.isGranted,
                  onChanged: isSystemPermissionOff
                      ? (newValue) {
                          print("System notification permission is off.");
                          openAppSettings();
                        }
                      : (newValue) async {
                    print("뉴뱔류");
                          if (newValue) {
                            await Permission.notification.request();
                            print("if문");
                          } else {
                            print("else문");
                            // await Permission.notification.revoke();
                          }
                          PermissionStatus status =
                              await Permission.notification.status;
                          setState(() {
                            _permissionStatus = status;
                          });
                        },
                  activeColor: CupertinoColors.activeBlue,
                  // activeTrackColor: Colors.lightBlueAccent,
                  // inactiveThumbColor: Colors.grey,
                  // inactiveTrackColor: Colors.grey[300],
                ),

              ],
            ),

            // SizedBox(width: 10), // Text와 Switch 사이의 간격

            if (_permissionStatus.isGranted)
              Visibility(
                  visible: _permissionStatus.isGranted == true,
                  child: Row(

                    children: [
                      Text("광고성 동의?"),
                      CupertinoSwitch(
                        value: _adAllowPush,
                        onChanged: _toggleSwitch,
                        activeColor: Colors.blue,

                      ),
                      Text(
                        _adAllowPush ? "허용" : "비허용"
                      )

                    ],
                  )
              ),

            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

