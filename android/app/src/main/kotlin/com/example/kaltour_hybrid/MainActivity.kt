package com.example.kaltour_hybrid

import android.content.ActivityNotFoundException
import android.content.Intent
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


class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result -> // here is the error
            when (call.method) {
                "getAppUrl" -> try {
                    val url: String? = call.argument("url")
                    Log.i("url", url.toString())
                    Log.i("시벌", "시발")
                    val intent: Intent = Intent.parseUri(url, Intent.URI_INTENT_SCHEME)
                    result.success(intent.dataString)
                } catch (e: URISyntaxException) {
                    result.notImplemented()
                    Log.i("니미","니미")
                } catch (e: ActivityNotFoundException ) {
                    result.notImplemented();
                }
            }
            setMixedContentMode()
        }
    }

    private fun setMixedContentMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val webView = WebView(this)
            val settings: WebSettings = webView.settings
            settings.mixedContentMode = WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
        }
    }


    companion object {
        private const val CHANNEL = "androidIntent"
    }
}


