import 'package:flutter/material.dart';
import 'package:shopify_app_bridge_flutter/shopify_app_bridge_flutter.dart';

/// Replace with your Shopify app's client ID from the Partner Dashboard.
const _apiKey = 'YOUR_API_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read the `?host=` parameter Shopify appends to the URL when loading your app.
  final host = ShopifyHostHelper.hostFromUrl();

  // Skip initialization when running outside a Shopify Admin iframe
  // (e.g., plain `flutter run -d chrome` for local UI development).
  if (ShopifyHostHelper.isEmbedded) {
    await ShopifyAppBridge.init(
      apiKey: _apiKey,
      host: host,
      forceRedirect: true,
    );
  }

  runApp(const ShopifyDemoApp());
}

class ShopifyDemoApp extends StatelessWidget {
  const ShopifyDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopify App Bridge Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF008060), // Shopify green
        ),
        useMaterial3: true,
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  String _sessionToken = '';
  bool _fetchingToken = false;
  String? _error;

  // ---- Toast ----------------------------------------------------------------

  void _showSuccessToast() {
    _guard(() => ShopifyToast.success('Order saved successfully!'));
  }

  void _showErrorToast() {
    _guard(() => ShopifyToast.error('Something went wrong — please retry.'));
  }

  void _showCustomToast() {
    _guard(() => ShopifyToast.show(
          'Custom toast for 10 seconds',
          duration: ToastDuration.long,
        ));
  }

  // ---- Redirect -------------------------------------------------------------

  void _redirectToProducts() {
    _guard(ShopifyRedirect.toProducts);
  }

  void _redirectToOrders() {
    _guard(ShopifyRedirect.toOrders);
  }

  void _redirectToAppPage() {
    _guard(() => ShopifyRedirect.toApp('/settings'));
  }

  void _redirectToRemote() {
    _guard(() => ShopifyRedirect.toRemote(
          'https://shopify.dev',
          newContext: true,
        ));
  }

  // ---- Title Bar / Loading / Modal -------------------------------------------

  void _updateTitle() {
    _guard(() => ShopifyTitleBar.set('Updated Demo Title!'));
  }

  void _showModal() {
    _guard(() => ShopifyModal.show(
          'Hello from Flutter!',
          'This is a native Shopify modal triggered from your Flutter web app.',
        ));
  }

  Future<void> _simulateLoading() async {
    if (!ShopifyAppBridge.isInitialized) return;
    ShopifyLoading.start();
    await Future.delayed(const Duration(seconds: 3));
    ShopifyLoading.stop();
  }

  // ---- Session token --------------------------------------------------------

  Future<void> _fetchSessionToken() async {
    if (!ShopifyAppBridge.isInitialized) {
      setState(() => _error = 'App Bridge not initialized (not in Shopify Admin).');
      return;
    }
    setState(() {
      _fetchingToken = true;
      _error = null;
    });
    try {
      final token = await ShopifyAuth.getSessionToken();
      setState(() => _sessionToken = token);
    } catch (e) {
      setState(() => _error = 'Failed to get session token: $e');
    } finally {
      setState(() => _fetchingToken = false);
    }
  }

  // ---- Guard ----------------------------------------------------------------

  void _guard(void Function() action) {
    if (!ShopifyAppBridge.isInitialized) {
      setState(() =>
          _error = 'App Bridge not initialized. Open this app inside Shopify Admin.');
      return;
    }
    setState(() => _error = null);
    action();
  }

  // ---- UI ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final isEmbedded = ShopifyHostHelper.isEmbedded;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: const Text('Shopify App Bridge Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            _StatusBanner(isEmbedded: isEmbedded),
            const SizedBox(height: 24),

            // Toast section
            _SectionCard(
              title: 'Toast Notifications',
              children: [
                _ActionButton(
                  label: 'Show Success Toast',
                  onPressed: _showSuccessToast,
                ),
                _ActionButton(
                  label: 'Show Error Toast',
                  color: Colors.redAccent,
                  onPressed: _showErrorToast,
                ),
                _ActionButton(
                  label: 'Show Custom Toast (10s)',
                  color: Colors.blueAccent,
                  onPressed: _showCustomToast,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Redirect section
            _SectionCard(
              title: 'Navigation / Redirect',
              children: [
                _ActionButton(
                  label: 'Go to Products',
                  onPressed: _redirectToProducts,
                ),
                _ActionButton(
                  label: 'Go to Orders',
                  onPressed: _redirectToOrders,
                ),
                _ActionButton(
                  label: 'Go to /settings (in-app)',
                  onPressed: _redirectToAppPage,
                ),
                _ActionButton(
                  label: 'Open shopify.dev (new tab)',
                  color: Colors.teal,
                  onPressed: _redirectToRemote,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // New UI Components section
            _SectionCard(
              title: 'Native UI Components',
              children: [
                _ActionButton(
                  label: 'Update Admin Title',
                  color: Colors.indigo,
                  onPressed: _updateTitle,
                ),
                _ActionButton(
                  label: 'Show Native Modal',
                  color: Colors.purple,
                  onPressed: _showModal,
                ),
                _ActionButton(
                  label: 'Simulate 3s Loading',
                  color: Colors.blueGrey,
                  onPressed: _simulateLoading,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Session token section
            _SectionCard(
              title: 'Session Token',
              children: [
                _ActionButton(
                  label: _fetchingToken ? 'Fetching…' : 'Get Session Token',
                  onPressed: _fetchingToken ? null : _fetchSessionToken,
                ),
                if (_sessionToken.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SelectableText(
                    _sessionToken,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ],
            ),

            // Error display
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widgets
// ---------------------------------------------------------------------------

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.isEmbedded});
  final bool isEmbedded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isEmbedded ? Colors.green.shade50 : Colors.orange.shade50,
        border: Border.all(
          color: isEmbedded ? Colors.green.shade300 : Colors.orange.shade300,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isEmbedded ? Icons.check_circle : Icons.warning_amber_rounded,
            color: isEmbedded ? Colors.green.shade700 : Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isEmbedded
                  ? 'Running inside Shopify Admin — App Bridge active.'
                  : 'Running outside Shopify Admin — App Bridge features disabled.',
              style: TextStyle(
                color: isEmbedded
                    ? Colors.green.shade800
                    : Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.color,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
