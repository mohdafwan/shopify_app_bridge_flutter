import 'app_bridge.dart';
import 'js_bridge.dart';

/// Provides Shopify session token retrieval for backend authentication.
///
/// Requires [ShopifyAppBridge.init] to have been called first.
///
/// The returned JWT should be sent in the `Authorization: Bearer <token>`
/// header when calling your backend. Your backend validates it against
/// Shopify's public keys.
///
/// ```dart
/// final token = await ShopifyAuth.getSessionToken();
/// final response = await http.get(
///   Uri.parse('https://your-backend.com/api/data'),
///   headers: {'Authorization': 'Bearer $token'},
/// );
/// ```
class ShopifyAuth {
  ShopifyAuth._();

  /// Fetches a short-lived Shopify session JWT.
  ///
  /// Throws if App Bridge is not initialized or if the token request fails.
  static Future<String> getSessionToken() =>
      jsGetSessionToken(ShopifyAppBridge.instance);
}
