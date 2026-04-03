import 'app_bridge.dart';
import 'js_bridge.dart';

/// Manages the top App Bridge TitleBar.
///
/// Requires [ShopifyAppBridge.init] to have been called first.
///
/// ```dart
/// ShopifyTitleBar.set('My New Title');
/// ```
class ShopifyTitleBar {
  ShopifyTitleBar._();

  /// Sets the title of the App Bridge top bar.
  static void set(String title) {
    jsSetTitle(ShopifyAppBridge.instance, title);
  }
}
