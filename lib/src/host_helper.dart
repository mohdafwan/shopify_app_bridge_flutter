/// Utility for reading Shopify-specific URL query parameters.
///
/// When Shopify loads your embedded app, it appends a base64-encoded `host`
/// parameter to the URL. You must pass this value to [ShopifyAppBridge.init].
///
/// ```dart
/// final host = ShopifyHostHelper.hostFromUrl();
/// await ShopifyAppBridge.init(apiKey: 'KEY', host: host);
/// ```
class ShopifyHostHelper {
  ShopifyHostHelper._();

  /// Returns the `host` query parameter from the current page URL.
  ///
  /// Returns an empty string if the parameter is absent (e.g. when running
  /// outside a Shopify Admin iframe during local development).
  static String hostFromUrl() => Uri.base.queryParameters['host'] ?? '';

  /// Returns any named query parameter from the current page URL.
  ///
  /// Returns an empty string if the parameter is absent.
  static String queryParam(String name) => Uri.base.queryParameters[name] ?? '';

  /// Returns `true` when running inside a Shopify Admin iframe.
  ///
  /// Detected by the presence of the `host` parameter in the URL.
  static bool get isEmbedded => hostFromUrl().isNotEmpty;
}
