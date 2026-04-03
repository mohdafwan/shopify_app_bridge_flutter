/// Flutter Web package for integrating with the Shopify App Bridge JS SDK.
///
/// Allows Flutter apps to run as embedded Shopify Admin apps with access to:
/// - Toast notifications
/// - Admin navigation / redirects
/// - Session tokens for backend auth
///
/// ## Setup
///
/// 1. Copy `web/shopify_bridge_interop.js` (from this package) into your
///    app's `web/` directory.
/// 2. In `web/index.html`, include both scripts **before** `main.dart.js`:
///    ```html
///    <script src="https://cdn.shopify.com/shopifycloud/app-bridge.js"></script>
///    <script src="shopify_bridge_interop.js"></script>
///    ```
/// 3. Initialize in `main.dart`:
///    ```dart
///    import 'package:shopify_app_bridge_flutter/shopify_app_bridge_flutter.dart';
///
///    void main() async {
///      WidgetsFlutterBinding.ensureInitialized();
///      await ShopifyAppBridge.init(
///        apiKey: 'YOUR_API_KEY',
///        host: ShopifyHostHelper.hostFromUrl(),
///      );
///      runApp(const MyApp());
///    }
///    ```
library;

export 'src/app_bridge.dart' show ShopifyAppBridge;
export 'src/auth.dart' show ShopifyAuth;
export 'src/enums.dart' show AdminSection, RedirectTarget, ToastDuration;
export 'src/host_helper.dart' show ShopifyHostHelper;
export 'src/loading.dart';
export 'src/modal.dart';
export 'src/redirect.dart' show ShopifyRedirect;
export 'src/title_bar.dart';
export 'src/toast.dart' show ShopifyToast;
