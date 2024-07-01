import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';


const platform = MethodChannel('androidIntent');


class PushedWebView extends StatefulWidget {
  const PushedWebView({
    required this.myUrl,
    super.key});

  final String myUrl;

  @override
  State<PushedWebView> createState() => _PushedWebViewState();

}

class _PushedWebViewState extends State<PushedWebView> {

  Future<bool> _goBack(BuildContext context) async{
    if(await webViewController.canGoBack()){
      webViewController.goBack();
      return Future.value(false);
    }else{
      return Future.value(true);
    }
  }

  late final InAppWebViewController webViewController;


  Future<String> getAppUrl(String url) async {//앱 URL 받기
    if (Platform.isAndroid) {
      print("안드로이드");
      return await platform
          .invokeMethod('getAppUrl', <String, Object>{'url': url});
    } else {
      print("ios");
      return url;
    }
  }

  @override

  Widget build(BuildContext context) {

    String myUrl = widget.myUrl;

    // _configureFirebaseMessaging(context);
    return Scaffold(
      body: SafeArea(
        child: WillPopScope (
          onWillPop: () => _goBack(context),
          child: Column(children:<Widget> [
            Expanded(child: Stack(children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(myUrl)) ,
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
                        var parsingURl = await platform.invokeMethod('getMarketUrl', <String, Object>{'url': url});
                        return parsingURl;
                      }
                      NavigationActionPolicy.CANCEL;
                      var value = await getMarketUrl(url.toString());
                      String marketUrl = value.toString();
                      await launchUrl(Uri.parse(marketUrl));
                      return NavigationActionPolicy.CANCEL;
                    }
                  }
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
