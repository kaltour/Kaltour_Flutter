import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebBridge extends StatefulWidget {
  const WebBridge({super.key});

  @override
  State<WebBridge> createState() => _WebBridgeState();
}

class _WebBridgeState extends State<WebBridge> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Scaffold(
          body: Text(

            "웹브릿지 네이티브 텍스트입니다"
          ),
        ),

      ),
    );
  }
}
