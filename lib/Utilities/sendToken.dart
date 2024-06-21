// lib/src/utils/date_utils.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';

void sendToken() async { // 토큰 발송

  final dio = Dio();
  Response response;

  final myToken = await FirebaseMessaging.instance.getToken();

  const token = "X%2FWnoeM%2BhLdu9VP7ncdF5A%3D%3D";
  // The below request is the same as above.
  response = await dio.get(
    'https://www.kaltour.com/API/WebPush/call',//
    queryParameters: {
      // "TOK": myToken,
      "TYP": "M",
      "GNT": "",
      "CID": "",
      "URL": "gohanway.kaltour.com",
      "PTH": "AOS",
      "AK": token
    },
  );
  print("리스폰스");
  print(response.data.toString());
}