package com.uydosh.app

import android.app.Application
import android.content.Context
import com.yandex.mapkit.MapKitFactory
import java.util.Locale

class MainApplication : Application() {
  override fun onCreate() {
    super.onCreate()
    MapKitFactory.setLocale(resolveInitialYandexLocale(this))
    MapKitFactory.setApiKey("b7e30079-55fe-44d0-960c-50a03c3715e6") // Your generated API key
  }

  companion object {
    fun localeTagForLanguageCode(languageCode: String): String {
      return when (languageCode.lowercase(Locale.US)) {
        "ru" -> "ru_RU"
        "uz" -> "uz_UZ"
        "en" -> "en_US"
        else -> Locale.getDefault().toLanguageTag().replace('-', '_')
      }
    }

    private fun resolveInitialYandexLocale(context: Context): String {
      val prefs = context.getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
      val raw =
        prefs
          .getString("flutter.selected_language", null)
          ?.trim()
          ?.trim('"')
          ?.takeIf { it.isNotEmpty() }
      val code = raw ?: Locale.getDefault().language
      return localeTagForLanguageCode(code)
    }
  }
}
