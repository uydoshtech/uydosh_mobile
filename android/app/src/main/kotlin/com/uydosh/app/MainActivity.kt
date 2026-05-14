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
            val localeTag = MainApplication.localeTagForLanguageCode(code)
            try {
              MapKitFactory.setLocale(localeTag)
            } catch (_: AssertionError) {
              // yandex_mapkit calls MapKitFactory.initialize() when the first map is created;
              // setLocale is only valid before that. Cold start locale is already applied in
              // [MainApplication.onCreate]; in-app changes match iOS (effective after restart).
            }
            result.success(true)
          }
          else -> result.notImplemented()
        }
      }
  }
}
