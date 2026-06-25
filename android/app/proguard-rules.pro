# Flutter specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom models
-keep class com.accessiblespiritual.talking_tasbih.** { *; }

# flutter_compass - keep sensor event classes
-keep class com.hemanthraj.fluttercompass.** { *; }
-dontwarn com.hemanthraj.fluttercompass.**

# geolocator - keep location classes
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# permission_handler - keep permission classes
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# vibration - keep vibration classes
-keep class io.sourcya.playx.vibration.** { *; }
-keep class xyz.luan.vibration.** { *; }
-dontwarn xyz.luan.vibration.**

# Keep Android sensor and location classes used by plugins
-keep class android.hardware.Sensor { *; }
-keep class android.hardware.SensorEvent { *; }
-keep class android.hardware.SensorManager { *; }
-keep class android.location.Location { *; }
-keep class android.location.LocationManager { *; }

# Keep Google Play Services location (used by geolocator on Android)
-keep class com.google.android.gms.location.** { *; }
-dontwarn com.google.android.gms.location.**
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.common.**

# flutter_tts
-keep class com.tundralabs.fluttertts.** { *; }
-dontwarn com.tundralabs.fluttertts.**

# hive - keep generated adapters
-keep class * extends com.hivedb.hive.HiveObject { *; }
-keep class * implements com.hivedb.hive.TypeAdapter { *; }
-dontwarn com.hivedb.**
