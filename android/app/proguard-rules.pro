# UyDosh ProGuard / R8 rules.
#
# Most plugin AARs ship their own `consumer-rules.pro`, so the rules below are
# only the minimum extras we need on top of the AGP defaults.
#
# If you hit a runtime crash that mentions `ClassNotFoundException` or
# `NoSuchMethodError` after enabling minification, prefer adding a narrow
# `-keep class` rule over disabling minification globally.

# -------- Flutter / Dart --------
# The Flutter Gradle plugin already injects `-keep class io.flutter.**`, but
# we keep deferred-component infrastructure as well in case we add it later.
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# -------- Firebase Crashlytics --------
# Preserve original line numbers / source files so de-obfuscated stack traces
# uploaded by the Crashlytics Gradle plugin remain useful.
-keepattributes SourceFile,LineNumberTable
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# Keep Firebase auto-init metadata + ComponentRegistrar entries (these are
# discovered via reflection through the metadata file).
-keep class com.google.firebase.components.ComponentRegistrar
-keep class * implements com.google.firebase.components.ComponentRegistrar { *; }

# -------- Yandex MapKit --------
# Yandex MapKit calls into native code via reflective JNI bindings. The lite
# AAR ships consumer rules but we keep an explicit -dontwarn just in case
# upstream forgets a transitive dependency.
-keep class com.yandex.** { *; }
-dontwarn com.yandex.**

# -------- google_sign_in --------
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# -------- Kotlin metadata --------
# Some libraries (kotlinx-serialization, coroutines reflection helpers) inspect
# kotlin.Metadata. AGP defaults already keep this; line below is defensive.
-keep class kotlin.Metadata { *; }

# -------- Suppress warnings for optional desugar / annotation libs --------
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.animal_sniffer.**
-dontwarn java.lang.invoke.StringConcatFactory
