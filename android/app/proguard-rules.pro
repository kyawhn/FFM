# Flutter specific
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.flutter.** { *; }

# Hive
-keep class com.hive.** { *; }
-keep class com.hive.** { <fields>; }

# Keep model classes for serialization
-keep class io.codex.ffm.data.** { *; }
-keep class * extends com.hive.** { *; }
