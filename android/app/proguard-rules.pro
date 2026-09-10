# Flutter Engine Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }
-keep class io.flutter.plugin.editing.** { *; }

# Play Integrity API & Google Play Services Rules
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.gms.tasks.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Firebase Cloud Messaging & Firebase Core
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Hive Local Database
-keep class com.hive.** { *; }
-keepclassmembers class * extends com.hive.** { *; }

# Supabase & Http Clients
-keep class com.supabase.** { *; }
-keep class io.ktor.** { *; }

# Preserve Serialized Models & Annotations
-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
