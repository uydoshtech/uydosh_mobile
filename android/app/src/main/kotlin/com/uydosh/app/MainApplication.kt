package com.uydosh.app

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
  override fun onCreate() {
    super.onCreate()
    // MapKitFactory.setLocale("en_US") // Let it default to system language
    MapKitFactory.setApiKey("b7e30079-55fe-44d0-960c-50a03c3715e6") // Your generated API key
  }
}
