import 'package:flutter_inappwebview/flutter_inappwebview.dart';


Future<void> checkLoginUserStatus() async {
  final cookieManager = CookieManager.instance();
  final cookies =
  await cookieManager.getCookies(url: Uri.parse('https://m.kaltour.com'));
  final userIdCookie = cookies.firstWhere(
        (cookie) => cookie.name == 'KALTOUR_USER_ID',
    orElse: () => Cookie(
      name: 'KALTOUR_USER_ID',
      value: '',
      domain: '.kaltour.com',
    ),
  );

  final userMemCookie = cookies.firstWhere(
        (cookie) => cookie.name == 'KALTOUR_USER_MEM_NUMBER',
    orElse: () => Cookie(
      name: 'KALTOUR_USER_MEM_NUMBER',
      value: '',
      domain: '.kaltour.com',
    ),
  );

  if (userIdCookie.value.isNotEmpty || userMemCookie.value.isNotEmpty) {
    print(
        '유저 User is logged in with ID: ${userIdCookie.value}, MemNum: ${userMemCookie.value}');
    // 여기서 추가적인 로그인 처리 로직을 구현할 수 있습니다.
  } else {
    print('유저 User is not logged in.');
  }
}