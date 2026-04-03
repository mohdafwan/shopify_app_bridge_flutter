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
  shopify_app_bridge_flutter: ^0.1.0
```

## Setup (Flutter Web)

This package is designed to be **plug-and-play**. You no longer need to manually copy JavaScript files or add extra `<script>` tags for interop.

1. Add the Shopify App Bridge CDN to the `<head>` of your `web/index.html`:

```html
<!-- Shopify App Bridge CDN -->
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
    apiKey: 'your_api_key_here',
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

## Additional Information

Building Shopify apps with Flutter is powerful! This package handles the complex JS interop layer so you can focus on building your features.

- **Issues**: Report bugs at our [GitHub Repository](https://github.com/your-org/shopify_app_bridge_flutter/issues).
- **Contribution**: PRs are welcome! 
