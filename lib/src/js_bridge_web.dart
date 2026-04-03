// ignore_for_file: avoid_web_libraries_in_flutter

/// Web implementation of the JS interop layer.
/// Only compiled on web targets.
library;

import 'dart:js_interop';

/// Extension type wrapping the [ShopifyBridgeHelper] JS object.
extension type _HelperJS._(JSObject _) implements JSObject {
  external JSPromise<JSAny?> waitForShopify(int timeoutMs);
  external JSPromise<JSAny?> loadAppBridgeScript();
  external JSObject createApp(String apiKey, String host, bool forceRedirect);
  external void showToast(
      JSObject app, String message, int duration, bool isError);
  external void redirectToApp(JSObject app, String path);
  external void redirectToAdminPath(JSObject app, String path);
  external void redirectToAdminSection(JSObject app, String name);
  external void redirectToRemote(JSObject app, String url, bool newContext);
  external JSPromise<JSString> getSessionToken(JSObject app);
  external void setTitle(JSObject app, String title);
  external void showLoading(JSObject app);
  external void hideLoading(JSObject app);
  external void showModal(JSObject app, String title, String message);
}

/// Accesses [window.ShopifyBridgeHelper] defined by the interop JS script.
@JS('ShopifyBridgeHelper')
external _HelperJS? get _helper;

_HelperJS _requireHelper() {
  final h = _helper;
  if (h == null) {
    throw StateError(
      'ShopifyBridgeHelper is not defined. '
      'Include shopify_bridge_interop.js in your web/index.html.',
    );
  }
  return h;
}

// ---------------------------------------------------------------------------
// Public wrappers — use JSAppObject so callers don't need dart:js_interop
// ---------------------------------------------------------------------------

/// Type alias exposing the platform-specific app instance type.
/// On web this is [JSObject]; on other platforms see [js_bridge_stub.dart].
typedef JSAppObject = JSObject;

/// Waits up to [timeoutMs] for the Shopify App Bridge to become available.
Future<void> jsWaitForShopify({int timeoutMs = 5000}) =>
    _requireHelper().waitForShopify(timeoutMs).toDart;

Future<void> jsLoadAppBridgeScript() =>
    _requireHelper().loadAppBridgeScript().toDart;

JSAppObject jsCreateApp(String apiKey, String host, bool forceRedirect) =>
    _requireHelper().createApp(apiKey, host, forceRedirect);

void jsShowToast(
  JSAppObject app,
  String message,
  int duration,
  bool isError,
) =>
    _requireHelper().showToast(app, message, duration, isError);

void jsRedirectToApp(JSAppObject app, String path) =>
    _requireHelper().redirectToApp(app, path);

void jsRedirectToAdminPath(JSAppObject app, String path) =>
    _requireHelper().redirectToAdminPath(app, path);

void jsRedirectToAdminSection(JSAppObject app, String name) =>
    _requireHelper().redirectToAdminSection(app, name);

void jsRedirectToRemote(JSAppObject app, String url,
        {bool newContext = false}) =>
    _requireHelper().redirectToRemote(app, url, newContext);

Future<String> jsGetSessionToken(JSAppObject app) async {
  final jsStr = await _requireHelper().getSessionToken(app).toDart;
  return jsStr.toDart;
}

void jsSetTitle(JSAppObject app, String title) =>
    _requireHelper().setTitle(app, title);

void jsShowLoading(JSAppObject app) => _requireHelper().showLoading(app);

void jsHideLoading(JSAppObject app) => _requireHelper().hideLoading(app);

void jsShowModal(JSAppObject app, String title, String message) =>
    _requireHelper().showModal(app, title, message);
