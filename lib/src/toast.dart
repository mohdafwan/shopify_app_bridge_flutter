import 'app_bridge.dart';
import 'enums.dart';
import 'js_bridge.dart';

/// Shows toast notifications inside the Shopify Admin UI.
///
/// Requires [ShopifyAppBridge.init] to have been called first.
///
/// ```dart
/// ShopifyToast.show('Product saved!');
/// ShopifyToast.show('Something went wrong', isError: true);
/// ```
class ShopifyToast {
  ShopifyToast._();

  /// Displays a toast notification.
  ///
  /// - [message] — the text shown in the toast (required).
  /// - [duration] — how long the toast is visible; defaults to
  ///   [ToastDuration.normal] (5 000 ms).
  /// - [durationMs] — custom duration in milliseconds. When provided,
  ///   overrides [duration].
  /// - [isError] — when `true`, renders the toast with an error style.
  static void show(
    String message, {
    ToastDuration duration = ToastDuration.normal,
    int? durationMs,
    bool isError = false,
  }) {
    jsShowToast(
      ShopifyAppBridge.instance,
      message,
      durationMs ?? duration.ms,
      isError,
    );
  }

  /// Convenience helper that shows a success-styled toast.
  static void success(String message, {ToastDuration duration = ToastDuration.normal}) =>
      show(message, duration: duration, isError: false);

  /// Convenience helper that shows an error-styled toast.
  static void error(String message, {ToastDuration duration = ToastDuration.normal}) =>
      show(message, duration: duration, isError: true);
}
