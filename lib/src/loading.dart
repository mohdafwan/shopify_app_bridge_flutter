import 'app_bridge.dart';
import 'js_bridge.dart';

/// Controls the App Bridge global Loading indicator.
///
/// Requires [ShopifyAppBridge.init] to have been called first.
///
/// ```dart
/// ShopifyLoading.start();
/// // do some long work...
/// ShopifyLoading.stop();
/// ```
class ShopifyLoading {
  ShopifyLoading._();

  /// Starts the full-page loading indicator.
  static void start() {
    jsShowLoading(ShopifyAppBridge.instance);
  }

  /// Stops the full-page loading indicator.
  static void stop() {
    jsHideLoading(ShopifyAppBridge.instance);
  }
}
