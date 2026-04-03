## 1.1.0

* **Improved Setup**: Automatic JS interop script injection. No manual `index.html` changes required for the bridge.
* **Bug Fix**: Fixed a runtime error where `hostFromUrl()` was called before JS interop was ready. Now uses pure Dart for URL parsing.

## 1.0.0

* **Initial Stable Release!**
* Added support for `ShopifyAuth` (Session Tokens).
* Added support for `ShopifyToast` (Success/Error).
* Added support for `ShopifyRedirect` (Admin Sections, External, Admin Paths).
* Added support for `ShopifyTitleBar` (Dynamic title updates).
* Added support for `ShopifyLoading` (Global loading indicator).
* Added support for `ShopifyModal` (Native modal dialogs).
* Implemented hybrid JS interop for App Bridge v4 Web Components and legacy Action API fallbacks.
