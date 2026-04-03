/// Stub implementation for non-web platforms (Dart VM, native).
///
/// All functions throw [UnsupportedError] except URL-reading helpers which
/// return safe empty strings, allowing [ShopifyHostHelper.isEmbedded] to
/// return `false` on non-web platforms.
library;

/// Platform-specific app instance type.
/// On web this is [dart:js_interop.JSObject]; here it's plain [Object].
typedef JSAppObject = Object;

const _webOnly = 'shopify_app_bridge_flutter only runs on Flutter Web.';

Future<void> jsWaitForShopify({int timeoutMs = 5000}) =>
    Future<void>.value(); // no-op on non-web

Future<void> jsLoadAppBridgeScript() => throw UnsupportedError(_webOnly);

JSAppObject jsCreateApp(String apiKey, String host, bool forceRedirect) =>
    throw UnsupportedError(_webOnly);

void jsShowToast(JSAppObject app, String message, int duration, bool isError) =>
    throw UnsupportedError(_webOnly);

void jsRedirectToApp(JSAppObject app, String path) =>
    throw UnsupportedError(_webOnly);

void jsRedirectToAdminPath(JSAppObject app, String path) =>
    throw UnsupportedError(_webOnly);

void jsRedirectToAdminSection(JSAppObject app, String name) =>
    throw UnsupportedError(_webOnly);

void jsRedirectToRemote(JSAppObject app, String url,
        {bool newContext = false}) =>
    throw UnsupportedError(_webOnly);

Future<String> jsGetSessionToken(JSAppObject app) =>
    throw UnsupportedError(_webOnly);

void jsSetTitle(JSAppObject app, String title) =>
    throw UnsupportedError(_webOnly);

void jsShowLoading(JSAppObject app) => throw UnsupportedError(_webOnly);

void jsHideLoading(JSAppObject app) => throw UnsupportedError(_webOnly);

void jsShowModal(JSAppObject app, String title, String message) =>
    throw UnsupportedError(_webOnly);
