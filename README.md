# shopify_app_bridge_flutter

A Flutter Web package that seamlessly wraps the **Shopify App Bridge JS SDK**. This enables your Flutter applications to run inside the Shopify Admin as embedded apps with access to native UI components and deep integration.

![Shopify App Bridge Demo](https://res.cloudinary.com/dludrejgr/image/upload/q_auto/f_auto/v1775250649/way_fy9t3a.gif)

## Features

- 🔐 **Native Authentication**: Securely fetch Shopify session tokens (JWT) directly from the App Bridge.
- 🍞 **Toast Notifications**: Display native Shopify notification toasts (success and error states).
- 🧭 **Seamless Navigation**: Redirect to native Shopify Admin sections (Products, Orders, Customers, etc.) or external URLs without breaking the iframe.
- 🏗️ **Native UI Components**:
  - **Title Bar**: Dynamically update the Shopify Admin header title.
  - **Modals**: Trigger native Shopify modal dialogs.
  - **Loading State**: Control the Shopify Admin global loading indicator.
- 🚀 **Hybrid Compatibility**: Supports both the New App Bridge (v4+) and reliable fallback for Action-based APIs.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  shopify_app_bridge_flutter: ^1.1.2
```

## Setup (Flutter Web)

This package is designed to be **plug-and-play**. You no longer need to manually copy JavaScript files or add extra `<script>` tags for interop.

1. Add the Shopify App Bridge CDN to the `<head>` of your `web/index.html`:

```html
<!-- Shopify App Bridge CDN -->
<meta name="shopify-api-key" content="509606f*******00da0d89" /> <!-- your_api_key_here -->
<script src="https://cdn.shopify.com/shopifycloud/app-bridge.js"></script>
```

2. That's it! The interop helper is automatically injected when you call `ShopifyAppBridge.init()`.

## Usage

### Initialization

Initialize the bridge in your `main()` function:

```dart
import 'package:shopify_app_bridge_flutter/shopify_app_bridge_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await ShopifyAppBridge.init(
    apiKey: '509606f*******00da0d89', // your_api_key_here
    host: ShopifyHostHelper.hostFromUrl(),
  );

  runApp(const MyApp());
}
```

### Authentication / Session Tokens

```dart
final token = await ShopifyAuth.getSessionToken();
print('Shopify JWT: $token');
```

### Native Toasts

```dart
ShopifyToast.success('Product updated!');
ShopifyToast.error('Failed to save changes.');
```

### UI Components

```dart
// Update Title Bar
ShopifyTitleBar.set('My Awesome App');

// Native Modal
ShopifyModal.show('Confirm', 'Are you sure you want to proceed?');

// Loading Indicator
ShopifyLoading.start();
await Future.delayed(Duration(seconds: 2));
ShopifyLoading.stop();
```

### Navigation

```dart
ShopifyRedirect.toProducts();
ShopifyRedirect.toOrders();
ShopifyRedirect.toAdminPath('/settings');
```

## Building for Shopify Admin (Web)

Flutter's default `flutter build web` uses the **CanvasKit renderer**, which requires `crossOriginIsolated` headers that Shopify Admin iframes do not provide — resulting in a black screen or blank app after the splash.

Instead of `flutter build web`, use the build tool included in this package:

```bash
dart run shopify_app_bridge_flutter:build_web
```

This runs `flutter build web` and then automatically patches `build/web/flutter_bootstrap.js` to:

- **Force the HTML renderer** when running inside a cross-origin iframe (no black screen)
- **Unregister stale service workers** in iframe context (prevents blank screen after splash)

All standard `flutter build web` flags are supported:

```bash
dart run shopify_app_bridge_flutter:build_web --release
dart run shopify_app_bridge_flutter:build_web --dart-define=ENV=production
```

> The patch is idempotent — safe to re-run. If `flutter_bootstrap.js` is already patched it exits immediately.

## Additional Information

Building Shopify apps with Flutter is powerful! This package handles the complex JS interop layer so you can focus on building your features.

- **Issues**: Report bugs at our [GitHub Repository](https://github.com/your-org/shopify_app_bridge_flutter/issues).
- **Contribution**: PRs are welcome! Open source contributions of any kind — bug fixes, new features, docs improvements — are encouraged and appreciated.
