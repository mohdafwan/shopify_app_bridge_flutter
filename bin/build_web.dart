// shopify_app_bridge_flutter build tool
//
// Runs `flutter build web` then patches flutter_bootstrap.js for
// Shopify Admin iframe compatibility.
//
// Usage:
//   dart run shopify_app_bridge_flutter:build_web
//   dart run shopify_app_bridge_flutter:build_web --release
//   dart run shopify_app_bridge_flutter:build_web --profile --dart-define=FOO=bar
//
// Any flags you pass are forwarded directly to `flutter build web`.

import 'dart:io';

void main(List<String> args) async {
  // ── 1. Run flutter build web (forward all user-supplied args) ──────────────
  stdout.writeln('[shopify_app_bridge] Running: flutter build web ${args.join(' ')}');

  final buildResult = await Process.run(
    'flutter',
    ['build', 'web', ...args],
    runInShell: true,
    // Stream output in real-time
    stdoutEncoding: systemEncoding,
    stderrEncoding: systemEncoding,
  );

  // Print build output so the developer sees it
  if (buildResult.stdout.toString().isNotEmpty) {
    stdout.write(buildResult.stdout);
  }
  if (buildResult.stderr.toString().isNotEmpty) {
    stderr.write(buildResult.stderr);
  }

  if (buildResult.exitCode != 0) {
    stderr.writeln('\n❌ flutter build web failed (exit ${buildResult.exitCode})');
    exit(buildResult.exitCode);
  }

  // ── 2. Patch flutter_bootstrap.js ─────────────────────────────────────────
  const bootstrapPath = 'build/web/flutter_bootstrap.js';
  final file = File(bootstrapPath);

  if (!file.existsSync()) {
    stderr.writeln('❌ $bootstrapPath not found after build — cannot patch.');
    exit(1);
  }

  stdout.writeln('\n[shopify_app_bridge] Patching $bootstrapPath for Shopify iframe...');

  var content = file.readAsStringSync();

  if (content.contains('_isInIframe')) {
    stdout.writeln('✅ Already patched — skipping.');
    exit(0);
  }

  // Patch 1: add html renderer entry to buildConfig
  content = content.replaceFirst(
    '"builds":[{"compileTarget":"dart2js","renderer":"canvaskit","mainJsPath":"main.dart.js"},{}]',
    '"builds":[{"compileTarget":"dart2js","renderer":"canvaskit","mainJsPath":"main.dart.js"},'
        '{"compileTarget":"dart2js","renderer":"html","mainJsPath":"main.dart.js"},{}]',
  );

  // Patch 2: replace loader.load() with iframe-aware version
  final loaderPattern = RegExp(
    r'_flutter\.loader\.load\(\{\s*\n\s*serviceWorkerSettings:\s*\{\s*\n\s*serviceWorkerVersion:\s*"([^"]+)"[^\}]*\}\s*\}\);',
  );

  final match = loaderPattern.firstMatch(content);
  if (match == null) {
    stderr.writeln(
      '⚠️  Could not find loader.load() pattern in $bootstrapPath.\n'
      '   The Flutter version may have changed its bootstrap format.\n'
      '   Please open an issue: https://github.com/mohdafwan/shopify_app_bridge_flutter/issues',
    );
    // Don't fail the build — just warn
    exit(0);
  }

  final swVersion = match.group(1)!;
  final replacement = '''// Detect if running inside an iframe (cross-origin iframes block CanvasKit's SharedArrayBuffer)
const _isInIframe = (function() {
  try { return window.self !== window.top; }
  catch (e) { return true; } // Cross-origin: can't access window.top
})();

if (_isInIframe) console.log('[Flutter] Inside iframe — forcing HTML renderer');

// Unregister stale service workers in iframe (they serve cached CanvasKit assets → blank screen)
if (_isInIframe && 'serviceWorker' in navigator) {
  try {
    if (typeof navigator.serviceWorker.getRegistrations === 'function') {
      navigator.serviceWorker.getRegistrations().then(function(registrations) {
        for (let reg of registrations) {
          reg.unregister();
          console.log('[Flutter] Unregistered service worker in iframe:', reg.scope);
        }
      }).catch(function(e) {
        console.log('[Flutter] Could not unregister service workers in iframe (expected):', e);
      });
    }
  } catch(e) {
    console.log('[Flutter] serviceWorker API restricted in iframe:', e);
  }
}

_flutter.loader.load({
  config: {
    // CanvasKit needs crossOriginIsolated headers; HTML renderer works everywhere
    renderer: _isInIframe ? 'html' : 'canvaskit',
  },
  // Skip service worker in iframe — blocked by cross-origin security policies
  serviceWorkerSettings: _isInIframe ? undefined : {
    serviceWorkerVersion: "$swVersion"
  }
});''';

  content = content.replaceRange(match.start, match.end, replacement);
  file.writeAsStringSync(content);

  stdout.writeln('✅ Patch applied — flutter_bootstrap.js is ready for Shopify Admin iframe.');
}
