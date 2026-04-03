/// Conditional export: web implementation on Flutter Web, stubs elsewhere.
///
/// Importing this file gives you [JSAppObject] (the platform-appropriate
/// app-instance type) plus all `js*` bridge functions.
library;

export 'js_bridge_stub.dart'
    if (dart.library.html) 'js_bridge_web.dart';
