/**
 * Shopify App Bridge Interop Helper
 *
 * Supports BOTH APIs:
 *   - New API (App Bridge v4+): window.shopify global, auto-initialized via data-api-key
 *   - Old API (App Bridge v3): window['app-bridge'] UMD export (also set by the same CDN script)
 *
 * The CDN script sets BOTH window.shopify (new) AND window['app-bridge'] (UMD).
 * window.shopify only provides idToken(); Toast and Redirect need the old API.
 * createApp() builds an old-style app instance (forceRedirect:false, no OAuth) for that.
 *
 * Include this script AFTER the App Bridge conditional loader in index.html.
 */
(function () {
  'use strict';

  /** Returns the new App Bridge global (window.shopify) if available. */
  function newAB() {
    return (typeof shopify !== 'undefined') ? shopify : null;
  }

  /** Returns the old App Bridge UMD module (window['app-bridge']) if available. */
  function oldAB() {
    return window['app-bridge'] || null;
  }

  // Cached old-style app instance — needed for Toast and Redirect actions.
  var _oldAppInstance = null;

  /**
   * Returns (or lazily creates) an old-style app instance.
   * forceRedirect is always false so this never triggers the OAuth flow.
   */
  function getOldApp(apiKey, host) {
    if (_oldAppInstance) return _oldAppInstance;
    var ab = oldAB();
    if (!ab || !apiKey || !host) return null;
    try {
      var fn = (typeof ab.default === 'function') ? ab.default : ab;
      _oldAppInstance = fn({ apiKey: apiKey, host: host, forceRedirect: false });
      console.log('[ShopifyBridgeHelper] ✅ Old-style app instance created for Toast/Redirect');
    } catch (e) {
      console.warn('[ShopifyBridgeHelper] Could not create old-style app instance:', e.message);
    }
    return _oldAppInstance;
  }

  window.ShopifyBridgeHelper = {

    /**
     * Waits up to timeoutMs for any App Bridge API to become available.
     * Resolves (never rejects) — missing App Bridge is non-fatal on non-Shopify routes.
     */
    waitForShopify: function (timeoutMs) {
      var t = timeoutMs || 5000;
      return new Promise(function (resolve) {
        if (newAB() || oldAB()) { resolve(); return; }
        var elapsed = 0;
        var id = setInterval(function () {
          elapsed += 100;
          if (newAB() || oldAB()) {
            clearInterval(id);
            resolve();
          } else if (elapsed >= t) {
            clearInterval(id);
            console.warn('[ShopifyBridgeHelper] App Bridge not ready after ' + t + 'ms — proceeding without it.');
            resolve();
          }
        }, 100);
      });
    },

    /**
     * Dynamically loads the App Bridge CDN script.
     * No-op if already loaded.
     */
    loadAppBridgeScript: function () {
      return new Promise(function (resolve, reject) {
        if (newAB() || oldAB()) { resolve(); return; }
        var s = document.createElement('script');
        s.src = 'https://cdn.shopify.com/shopifycloud/app-bridge.js';
        s.onload = resolve;
        s.onerror = function () { reject(new Error('Failed to load Shopify App Bridge CDN script.')); };
        document.head.appendChild(s);
      });
    },

    /**
     * Initializes the bridge.
     *  - Stores apiKey/host for lazy old-style instance creation.
     *  - Creates the old-style instance immediately if window['app-bridge'] is ready.
     *    (needed for Toast — window.shopify does NOT expose .toast in this CDN version)
     */
    createApp: function (apiKey, host, forceRedirect) {
      // Always stash credentials so getOldApp() can use them later
      window._shopifyApiKey = apiKey;
      window._shopifyHost = host;

      if (newAB()) {
        // New API is active.  Pre-create the old-style instance for Toast/Redirect.
        getOldApp(apiKey, host);
        return { _bridge: 'shopify_new_api' };
      }

      var ab = oldAB();
      if (ab) {
        var fn = (typeof ab.default === 'function') ? ab.default : ab;
        _oldAppInstance = fn({ apiKey: apiKey, host: host, forceRedirect: !!forceRedirect });
        return _oldAppInstance;
      }

      console.warn('[ShopifyBridgeHelper] App Bridge not available — running outside Shopify Admin.');
      return { _bridge: 'unavailable' };
    },

    /**
     * Shows a toast notification.
     * Priority:
     *  1. shopify.toast.show()  — new API (if exposed by this CDN build)
     *  2. old API Toast actions — works reliably with the stored app instance
     */
    showToast: function (app, message, duration, isError) {
      // 1. Try new API first
      var nb = newAB();
      if (nb) {
        if (nb.toast && typeof nb.toast.show === 'function') {
          nb.toast.show(message, { duration: duration, isError: !!isError });
          return;
        }
        if (typeof nb.toast === 'function') {
          nb.toast(message);
          return;
        }
        // shopify.toast not available in this CDN build — fall through to old API
      }

      // 2. Old API: use stored or passed instance
      var ab = oldAB();
      var realApp = _oldAppInstance ||
                    getOldApp(window._shopifyApiKey, window._shopifyHost) ||
                    (app && app._bridge === undefined ? app : null);

      if (ab && ab.actions && ab.actions.Toast && realApp) {
        var Toast = ab.actions.Toast;
        var t = Toast.create(realApp, { message: message, duration: duration, isError: !!isError });
        t.dispatch(Toast.Action.SHOW);
        return;
      }

      console.warn('[ShopifyBridgeHelper] Toast unavailable — no App Bridge instance ready.');
    },

    /** Navigates within the embedded app. */
    redirectToApp: function (app, path) {
      var nb = newAB();
      if (nb) {
        if (typeof nb.navigate === 'function') { nb.navigate(path); return; }
        if (typeof nb.open   === 'function') { nb.open(path);     return; }
      }
      var realApp = _oldAppInstance || app;
      var ab = oldAB();
      if (ab && ab.actions && realApp && realApp._bridge === undefined) {
        ab.actions.Redirect.create(realApp).dispatch(ab.actions.Redirect.Action.APP, path);
        return;
      }
      window.location.href = path;
    },

    /** Navigates to a Shopify Admin path (e.g. /products). */
    redirectToAdminPath: function (app, path) {
      var nb = newAB();
      if (nb) {
        var url = 'shopify://admin' + path;
        if (typeof nb.navigate === 'function') { nb.navigate(url); return; }
        if (typeof nb.open   === 'function') { nb.open(url);     return; }
      }
      var realApp = _oldAppInstance || app;
      var ab = oldAB();
      if (ab && ab.actions && realApp && realApp._bridge === undefined) {
        ab.actions.Redirect.create(realApp).dispatch(ab.actions.Redirect.Action.ADMIN_PATH, path);
        return;
      }
      if (window.top) window.top.location.href = 'https://admin.shopify.com' + path;
    },

    /** Navigates to a Shopify Admin resource section by name string. */
    redirectToAdminSection: function (app, name) {
      var paths = {
        Product: '/products', Order: '/orders', Customer: '/customers',
        Discount: '/discounts', DraftOrder: '/draft_orders',
        Collection: '/collections', Analytics: '/analytics',
      };
      var realApp = _oldAppInstance || app;
      var ab = oldAB();
      if (ab && ab.actions && realApp && realApp._bridge === undefined) {
        ab.actions.Redirect.create(realApp)
          .dispatch(ab.actions.Redirect.Action.ADMIN_SECTION, { name: name });
        return;
      }
      var p = paths[name] || ('/' + name.toLowerCase() + 's');
      if (window.top) window.top.location.href = 'https://admin.shopify.com' + p;
    },

    /** Navigates to an external URL. */
    redirectToRemote: function (app, url, newContext) {
      if (newContext) { window.open(url, '_blank'); return; }
      var realApp = _oldAppInstance || app;
      var ab = oldAB();
      if (ab && ab.actions && realApp && realApp._bridge === undefined) {
        ab.actions.Redirect.create(realApp)
          .dispatch(ab.actions.Redirect.Action.REMOTE, { url: url, newContext: false });
        return;
      }
      window.location.href = url;
    },

    /**
     * Returns a Promise<string> — a Shopify session JWT.
     *  1. shopify.idToken()            — new API (preferred)
     *  2. old API getSessionToken(app) — fallback
     *  3. id_token URL param           — last resort (may be stale)
     */
    getSessionToken: function (app) {
      var nb = newAB();
      if (nb && typeof nb.idToken === 'function') return nb.idToken();

      var realApp = _oldAppInstance || app;
      var ab = oldAB();
      if (ab && ab.utilities && realApp && realApp._bridge === undefined) {
        return ab.utilities.getSessionToken(realApp);
      }

      var urlToken = new URLSearchParams(window.location.search).get('id_token');
      if (urlToken) {
        console.warn('[ShopifyBridgeHelper] Using id_token from URL (may be expired)');
        return Promise.resolve(urlToken);
      }
      return Promise.reject(new Error('No App Bridge available for session token'));
    },

    /** Reads the `host` query parameter from the current URL. */
    getHostFromUrl: function () {
      return new URLSearchParams(window.location.search).get('host') || '';
    },

    /** Reads any named query parameter from the current URL. */
    getQueryParam: function (name) {
      return new URLSearchParams(window.location.search).get(name) || '';
    },
  };

  console.log('[ShopifyBridgeHelper] ✅ Loaded.',
    'shopify global:', typeof shopify !== 'undefined',
    '| app-bridge module:', !!oldAB());
})();
