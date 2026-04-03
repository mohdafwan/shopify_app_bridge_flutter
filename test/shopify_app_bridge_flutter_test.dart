import 'package:flutter_test/flutter_test.dart';
import 'package:shopify_app_bridge_flutter/shopify_app_bridge_flutter.dart';

void main() {
  // ---------------------------------------------------------------------------
  // ShopifyAppBridge
  // ---------------------------------------------------------------------------
  group('ShopifyAppBridge', () {
    tearDown(ShopifyAppBridge.reset);

    test('isInitialized returns false before init', () {
      expect(ShopifyAppBridge.isInitialized, isFalse);
    });

    test('instance throws StateError when not initialized', () {
      expect(() => ShopifyAppBridge.instance, throwsStateError);
    });

    // Note: full init() requires a browser environment with the JS interop
    // helper loaded. Integration tests should be run with `flutter test -d
    // chrome` against a real Shopify Admin iframe.
  });

  // ---------------------------------------------------------------------------
  // Enums
  // ---------------------------------------------------------------------------
  group('AdminSection', () {
    test('jsValue matches Shopify App Bridge expectation', () {
      expect(AdminSection.product.jsValue, 'Product');
      expect(AdminSection.order.jsValue, 'Order');
      expect(AdminSection.customer.jsValue, 'Customer');
      expect(AdminSection.discount.jsValue, 'Discount');
      expect(AdminSection.draftOrder.jsValue, 'DraftOrder');
      expect(AdminSection.collection.jsValue, 'Collection');
    });
  });

  group('ToastDuration', () {
    test('ms values are correct', () {
      expect(ToastDuration.short.ms, 3000);
      expect(ToastDuration.normal.ms, 5000);
      expect(ToastDuration.long.ms, 10000);
    });
  });

  // ---------------------------------------------------------------------------
  // ShopifyHostHelper — non-JS parts
  // ---------------------------------------------------------------------------
  group('ShopifyHostHelper', () {
    // hostFromUrl() and isEmbedded require a browser environment; skip here.
    test('class exists and exports expected API', () {
      // Verify the static API surface compiles correctly.
      // Actual URL-reading tests belong in integration tests.
      expect(ShopifyHostHelper.queryParam, isA<Function>());
    });
  });
}
