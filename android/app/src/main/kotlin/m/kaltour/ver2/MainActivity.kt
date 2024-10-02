package m.kaltour.ver2

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.net.URISyntaxException
import android.webkit.WebSettings
import android.webkit.WebView
import android.os.Build
import android.os.Bundle


//class MainActivity : FlutterActivity() {
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        GeneratedPluginRegistrant.registerWith(flutterEngine);
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result -> // here is the error
//            when {
//                // Intent 스킴 URL을 안드로이드 웹뷰에서 접근가능하도록 변환
//                call.method.equals("getAppUrl") -> {
//                    val url: String = call.argument("url")!!
//
//                    var intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
//                    //여기서 Null이 뜸
//
//                    result.success(intent.dataString)
//                }
//
//                // Intent 스킴 URL을 playStore Market URL로 변환
//                call.method.equals("getMarketUrl") -> {
//                    val url: String = call.argument("url")!!
//                    val packageName = Intent.parseUri(url, Intent.URI_INTENT_SCHEME).getPackage()
//                    val marketUrl = Intent(
//                        Intent.ACTION_VIEW,
////                        Uri.parse("market://details?id=$packageName")
//                        Uri.parse("market://details?id=$packageName")
//                    )
//                    result.success(marketUrl.dataString)
//                }
//            }
//
//        }
//    }
//
//    private fun setMixedContentMode() {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//            val webView = WebView(this)
//            val settings: WebSettings = webView.settings
//            settings.mixedContentMode = WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
//        }
//    }
//
//
//    companion object {
//        private const val CHANNEL = "androidIntent"
//    }
//}


class MainActivity: FlutterActivity() {
    private val CHANNEL = "androidIntent"

    //MethodChannel 구현
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if(call.method == "getAppUrl") {                // Intent:// 스키마를 통한 URL파싱
                try {
                    val url: String? = call.argument("url")

                    if(url == null) {
                        result.error("9999", "URL PARAMETER IS NULL", null)
                    } else {
                        Log.i("안드로이드 로그 [getAppUrl] url", url)
                        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                        result.success(intent.dataString)
                    }
                } catch (e: URISyntaxException) {
                    result.notImplemented()
                } catch (e: ActivityNotFoundException) {
                    result.notImplemented()
                }
            } else if(call.method == "getMarketUrl") {          // 들어온 URL을 통해 package 명 및 market 다운로드 주소 반환
                try {
                    val url: String? = call.argument("url")
                    if(url == null) {
                        result.error("9999", "URL PARAMETER IS NULL", null)
                    } else {
                        Log.i("[getMarketUrl] url", url)
                        val intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                        val scheme = intent.scheme
                        val packageName = intent.getPackage()
                        if (packageName != null) {
                            result.success("market://details?id=$packageName")
                        }
                        result.notImplemented()
                    }
                } catch (e: URISyntaxException) {
                    result.notImplemented()
                } catch (e: ActivityNotFoundException) {
                    result.notImplemented()
                }
            } else {
                result.notImplemented()
            }
        }
    }

}

