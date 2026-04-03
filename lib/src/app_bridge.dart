import 'dart:async';
import 'js_bridge.dart';
import 'js_bundle.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Manages the lifecycle of the Shopify App Bridge instance.
///
/// Call [ShopifyAppBridge.init] once at app startup (before using any other
/// API in this package).
///
/// ```dart
/// await ShopifyAppBridge.init(
///   apiKey: 'YOUR_API_KEY',
///   host: ShopifyHostHelper.hostFromUrl(),
/// );
/// ```
class ShopifyAppBridge {
  ShopifyAppBridge._();

  static JSAppObject? _app;

  /// The underlying app-bridge app instance.
  ///
  /// Throws [StateError] if [init] has not been called yet.
  static JSAppObject get instance {
    final app = _app;
    if (app == null) {
      throw StateError(
        'ShopifyAppBridge is not initialized. '
        'Call ShopifyAppBridge.init() before using any Shopify APIs.',
      );
    }
    return app;
  }

  /// Whether the App Bridge has been initialized.
  static bool get isInitialized => _app != null;

  /// Initializes the App Bridge with the given credentials.
  ///
  /// This method automatically handles:
  /// 1. Injecting the required JS interop helper (no manual index.html changes needed).
  /// 2. Optionally loading the Shopify App Bridge CDN script.
  /// 3. Initializing the app instance.
  ///
  /// Parameters:
  /// - [apiKey] — your Shopify app's API key (client ID).
  /// - [host] — the base64-encoded host string from the `?host=` URL param.
  ///   Use [ShopifyHostHelper.hostFromUrl()] to obtain it automatically.
  /// - [forceRedirect] — when `true` (default), Shopify will redirect
  ///   unauthenticated requests to the OAuth flow.
  /// - [loadScriptDynamically] — when `true` (default), loads the CDN script via JS.
  static Future<void> init({
    required String apiKey,
    required String host,
    bool forceRedirect = true,
    bool loadScriptDynamically = true,
    int waitTimeoutMs = 5000,
  }) async {
    // 0. Auto-inject the bridge helper if missing (Web only)
    _injectInteropScript();

    if (loadScriptDynamically) {
      await jsLoadAppBridgeScript();
    }
    // Wait for the App Bridge (new or old API) to become available.
    // This is a no-op when neither API is present (non-Shopify routes).
    await jsWaitForShopify(timeoutMs: waitTimeoutMs);
    _app = jsCreateApp(apiKey, host, forceRedirect);
  }

  static void _injectInteropScript() {
    try {
      // Check if window.ShopifyBridgeHelper exists (using dart:js for broad compatibility)
      final hasHelper = js.context.hasProperty('ShopifyBridgeHelper');
      
      if (!hasHelper) {
        final script = html.ScriptElement()
          ..id = 'shopify-bridge-interop-bundle'
          ..text = shopifyBridgeInteropJs;
        html.document.head?.append(script);
      }
    } catch (_) {
      // Non-web or unsupported environment — ignore
    }
  }

  /// Resets the App Bridge instance (useful for hot-restart in development).
  static void reset() => _app = null;
}
