import 'app_bridge.dart';
import 'enums.dart';
import 'js_bridge.dart';

/// Handles navigation and redirects inside the Shopify Admin.
///
/// Requires [ShopifyAppBridge.init] to have been called first.
///
/// ```dart
/// ShopifyRedirect.toAdminPath('/products');
/// ShopifyRedirect.toAdminSection(AdminSection.order);
/// ShopifyRedirect.toApp('/settings');
/// ShopifyRedirect.toRemote('https://example.com');
/// ```
class ShopifyRedirect {
  ShopifyRedirect._();

  /// Navigates to a path within the embedded app (same iframe).
  ///
  /// Example: `ShopifyRedirect.toApp('/settings')`
  static void toApp(String path) =>
      jsRedirectToApp(ShopifyAppBridge.instance, path);

  /// Navigates to a Shopify Admin path.
  ///
  /// Example: `ShopifyRedirect.toAdminPath('/products')`
  static void toAdminPath(String path) =>
      jsRedirectToAdminPath(ShopifyAppBridge.instance, path);

  /// Navigates to a Shopify Admin resource section.
  ///
  /// Example: `ShopifyRedirect.toAdminSection(AdminSection.product)`
  static void toAdminSection(AdminSection section) =>
      jsRedirectToAdminSection(ShopifyAppBridge.instance, section.jsValue);

  /// Navigates to an external URL.
  ///
  /// Set [newContext] to `true` to open in a new browser tab.
  ///
  /// Example: `ShopifyRedirect.toRemote('https://example.com')`
  static void toRemote(String url, {bool newContext = false}) =>
      jsRedirectToRemote(ShopifyAppBridge.instance, url,
          newContext: newContext);

  // ----- Convenience shortcuts -----

  /// Navigates to the Shopify Admin Products list.
  static void toProducts() => toAdminSection(AdminSection.product);

  /// Navigates to the Shopify Admin Orders list.
  static void toOrders() => toAdminSection(AdminSection.order);

  /// Navigates to the Shopify Admin Customers list.
  static void toCustomers() => toAdminSection(AdminSection.customer);

  /// Navigates to the Shopify Admin Discounts list.
  static void toDiscounts() => toAdminSection(AdminSection.discount);
}
