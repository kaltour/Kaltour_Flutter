import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:kaltour_flutter/View/MainWebView.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';



Future<bool> _isPromotionalAllowed() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('promotional_notifications') ?? false;
}

Future<void> _setPromotionalAllowed(bool allowed) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('promotional_notifications', allowed);
}

