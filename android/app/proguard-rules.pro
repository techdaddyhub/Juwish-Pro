# Add project specific ProGuard rules here.
-keep public class org.dmillers.juwishpro.MainActivity { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

