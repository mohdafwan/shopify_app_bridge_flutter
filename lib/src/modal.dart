import 'app_bridge.dart';
import 'js_bridge.dart';

/// Shows modal dialogs inside the Shopify Admin UI.
///
/// Requires [ShopifyAppBridge.init] to have been called first.
///
/// ```dart
/// ShopifyModal.show('Confirm Action', 'Are you sure you want to do this?');
/// ```
class ShopifyModal {
  ShopifyModal._();

  /// Displays an App Bridge Modal.
  static void show(String title, String message) {
    jsShowModal(ShopifyAppBridge.instance, title, message);
  }
}
