# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Google Mobile Ads rules
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# HTTP and networking
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# JSON parsing
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep R classes
-keep class **.R$* {
    public static <fields>;
}

# Keep custom application class
-keep class com.rwanda.trafficrules.MainActivity { *; }

# Keep notification related classes
-keep class * extends android.app.NotificationCompat { *; }
-keep class * extends android.app.NotificationManager { *; }

# Keep audio/video related classes
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Keep file picker related classes
-keep class com.mr.flutter.plugin.filepicker.** { *; }
-dontwarn com.mr.flutter.plugin.filepicker.**

# Keep PDF viewer related classes
-keep class com.shockwave.arts.** { *; }
-dontwarn com.shockwave.arts.**

# Keep shared preferences
-keep class android.content.SharedPreferences { *; }

# Keep device info related classes
-keep class io.flutter.plugins.deviceinfo.** { *; }
-dontwarn io.flutter.plugins.deviceinfo.**

# Keep connectivity related classes
-keep class io.flutter.plugins.connectivity.** { *; }
-dontwarn io.flutter.plugins.connectivity.**

# Keep local notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Keep upgrader related classes
-keep class com.larryaasen.** { *; }
-dontwarn com.larryaasen.**

# Keep screen protector
-keep class com.example.screen_protector.** { *; }
-dontwarn com.example.screen_protector.**

# Keep Play Core classes (for deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Keep XML Stream classes
-keep class javax.xml.stream.** { *; }
-dontwarn javax.xml.stream.**

# Keep Apache Tika classes
-keep class org.apache.tika.** { *; }
-dontwarn org.apache.tika.**

# General optimization rules
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep enum values
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep generic signatures
-keepattributes Signature

# Keep exceptions
-keepattributes Exceptions

# Keep inner classes
-keepattributes InnerClasses

# Keep line numbers for debugging (optional - remove for smaller size)
-keepattributes SourceFile,LineNumberTable

# Remove unused attributes for smaller size
-keepattributes *Annotation* 