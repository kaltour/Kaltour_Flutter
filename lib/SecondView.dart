// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(home: WebViewExample()));

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  late WebViewController completerController;
  static const platform = MethodChannel('androidIntent');

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _goBack(context),
        child: Scaffold(
          // We're using a Builder here so we have a context that is below the Scaffold
          // to allow calling Scaffold.of(context) so we can show a snackbar.
            body: SafeArea(
              top: true,
              bottom: false,
              child: Builder(builder: (BuildContext context) {
                return WebView(
                  //initialUrl: 'http://10.22.10.97:3000',
                  initialUrl: 'https://m.kaltour.com/',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller.complete(webViewController);
                    completerController = webViewController;
                  },
                  // onProgress: (int progress) {
                  //   print("WebView is loading (progress : $progress%)");
                  // },
                  javascriptChannels: <JavascriptChannel>{
                    _toasterJavascriptChannel(context),
                  },
                  // navigationDelegate: (NavigationRequest request) {
                  //   if (request.url.startsWith('https://www.youtube.com/')) {
                  //     print('blocking navigation to $request}');
                  //     return NavigationDecision.prevent;
                  //   }
                  //   print('allowing navigation to $request');
                  //   return NavigationDecision.navigate;
                  // },
                  navigationDelegate: (NavigationRequest request) async {
                    if(!request!.url.startsWith("http") && !request.url.startsWith("https")) {
                      if(Platform.isAndroid) {
                        getAppUrl(request.url.toString());
                        return NavigationDecision.prevent;
                      }
                    }else if(Platform.isIOS) {
                      if (await canLaunchUrl(Uri.parse(request.url))) {
                        await launchUrl(Uri.parse(request.url),);
                        return NavigationDecision.prevent;
                      }
                    }
                    String url = request.url;
                    //print(request);
                    if (isAppLink(url) && url != "about:blank") {
                      String getUrl = await getAppUrl(url);
                      if (await canLaunch(getUrl)) {
                        await launch(getUrl);
                      } else {
                        print("앱 노설치");
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('앱이 설치되어있지 않습니다.'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('확인'),
                                ),
                              ],
                            ));
                      }
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                  // onPageStarted: (String url) {
                  //   print('Page started loading: $url');
                  // },
                  // onPageFinished: (String url) {
                  //   print('Page finished loading: $url');
                  // },
                  gestureNavigationEnabled: true,
                );
              }),
            )));
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          // Scaffold.of(context).showSnackBar(
          //   SnackBar(content: Text(message.message)),
          // );
        });
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await completerController.canGoBack()) {
      completerController.goBack();
      return Future.value(false);
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('앱을 종료하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('확인'),
              ),
            ],
          ));
      return Future.value(true);
    }
  }

  Future<String> getAppUrl(String url) async {
    if (Platform.isAndroid) {
      //print("안드로이드");
      return await platform
          .invokeMethod('getAppUrl', <String, Object>{'url': url});
    } else {
      //print("ios");
      return url;
    }
  }

  Future<String> getMarketUrl(String url) async {
    if (Platform.isAndroid) {
      return await platform
          .invokeMethod('getMarketUrl', <String, Object>{'url': url});
    } else {
      return url;
    }
  }

  bool isAppLink(String url) {
    final appScheme = Uri.parse(url).scheme;

    return appScheme != 'http' &&
        appScheme != 'https' &&
        appScheme != 'about:blank' &&
        appScheme != 'data';
  }
}