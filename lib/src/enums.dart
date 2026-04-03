/// Type-safe enums for Shopify App Bridge actions and resource types.
library;

// ---------------------------------------------------------------------------
// Redirect
// ---------------------------------------------------------------------------

/// Targets available for [ShopifyRedirect] actions.
enum RedirectTarget {
  /// Navigate to a path within the embedded app.
  app,

  /// Navigate to a Shopify Admin path (e.g. `/products`).
  adminPath,

  /// Navigate to a Shopify Admin resource section (e.g. Products list).
  adminSection,

  /// Navigate to an external URL.
  remote,
}

/// Shopify Admin resource section names used with [RedirectTarget.adminSection].
///
/// Maps to the string values Shopify App Bridge expects for
/// `Redirect.Action.ADMIN_SECTION`.
enum AdminSection {
  /// Products list: `/products`
  product('Product'),

  /// Orders list: `/orders`
  order('Order'),

  /// Customers list: `/customers`
  customer('Customer'),

  /// Discounts list: `/discounts`
  discount('Discount'),

  /// Draft orders: `/draft_orders`
  draftOrder('DraftOrder'),

  /// Collections: `/collections`
  collection('Collection'),

  /// Analytics: `/analytics`
  analytics('Analytics'),

  /// Marketing: `/marketing`
  marketing('Marketing'),

  /// Apps page: `/apps`
  apps('Apps');

  /// The string value expected by the Shopify App Bridge JS SDK.
  final String jsValue;
  const AdminSection(this.jsValue);
}

// ---------------------------------------------------------------------------
// Toast
// ---------------------------------------------------------------------------

/// Duration presets (milliseconds) for [ShopifyToast].
enum ToastDuration {
  /// 3 000 ms
  short(3000),

  /// 5 000 ms — Shopify default
  normal(5000),

  /// 10 000 ms
  long(10000);

  final int ms;
  const ToastDuration(this.ms);
}
