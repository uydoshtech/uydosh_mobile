package com.uydosh.app

import io.flutter.embedding.android.FlutterActivity

/** Do not add SplashScreen.setOnExitAnimationListener { it.remove() } — it can NPE in
 *  SurfaceControl$Transaction.hide on some Android 12+ (flutter/flutter#125122). */
class MainActivity : FlutterActivity()
