package com.uydosh.app

import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Do not add SplashScreen.setOnExitAnimationListener { it.remove() } — it can NPE in
 *  SurfaceControl$Transaction.hide on some Android 12+ (flutter/flutter#125122). */
class MainActivity : FlutterActivity() {
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "uydosh/mapkit_locale")
      .setMethodCallHandler { call, result ->
        when (call.method) {
          "setLocale" -> {
            val code = call.argument<String>("languageCode").orEmpty()
            if (code.isEmpty()) {
              result.error("bad_args", "Expected languageCode", null)
              return@setMethodCallHandler
            }
            MapKitFactory.setLocale(MainApplication.localeTagForLanguageCode(code))
            result.success(true)
          }
          else -> result.notImplemented()
        }
      }
  }
}
