/// Bundled App Bridge Interop JS.
/// This is automatically injected by [ShopifyAppBridge.init].
const String shopifyBridgeInteropJs = r'''
(function () {
  'use strict';

  function newAB() {
    return (typeof shopify !== 'undefined') ? shopify : null;
  }

  function oldAB() {
    return window['app-bridge'] || null;
  }

  var _oldAppInstance = null;

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

    createApp: function (apiKey, host, forceRedirect) {
      window._shopifyApiKey = apiKey;
      window._shopifyHost = host;

      if (newAB()) {
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

    showToast: function (app, message, duration, isError) {
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
      }

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
      console.warn('[ShopifyBridgeHelper] Toast unavailable.');
    },

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
        console.warn('[ShopifyBridgeHelper] Using id_token from URL');
        return Promise.resolve(urlToken);
      }
      return Promise.reject(new Error('No App Bridge available for session token'));
    },

    getHostFromUrl: function () {
      return new URLSearchParams(window.location.search).get('host') || '';
    },

    getQueryParam: function (name) {
      return new URLSearchParams(window.location.search).get(name) || '';
    },

    setTitle: function (app, title) {
      if (typeof shopify !== 'undefined') {
        var tb = document.querySelector('ui-title-bar');
        if (!tb) {
           tb = document.createElement('ui-title-bar');
           document.body.appendChild(tb);
        }
        tb.setAttribute('title', title);
        return;
      }
      var realApp = _oldAppInstance || app;
      var ab = oldAB();
      if (ab && ab.actions && ab.actions.TitleBar && realApp) {
        var TitleBar = ab.actions.TitleBar;
        TitleBar.create(realApp, { title: title });
        return;
      }
      console.warn('[ShopifyBridgeHelper] TitleBar unavailable.');
    },

    showLoading: function (app) {
      if (typeof shopify !== 'undefined') {
        if (typeof shopify.loading === 'function') {
          shopify.loading(true);
        } else {
          shopify.loading && shopify.loading.start && shopify.loading.start();
        }
        return;
      }
      var realApp = _oldAppInstance || app;
      var ab = oldAB();
      if (ab && ab.actions && ab.actions.Loading && realApp) {
        var Loading = ab.actions.Loading;
        var loading = Loading.create(realApp);
        loading.dispatch(Loading.Action.START);
        return;
      }
      console.warn('[ShopifyBridgeHelper] Loading unavailable.');
    },

    hideLoading: function (app) {
      if (typeof shopify !== 'undefined') {
        if (typeof shopify.loading === 'function') {
          shopify.loading(false);
        } else {
          shopify.loading && shopify.loading.stop && shopify.loading.stop();
        }
        return;
      }
      var realApp = _oldAppInstance || app;
      var ab = oldAB();
      if (ab && ab.actions && ab.actions.Loading && realApp) {
        var Loading = ab.actions.Loading;
        var loading = Loading.create(realApp);
        loading.dispatch(Loading.Action.STOP);
        return;
      }
      console.warn('[ShopifyBridgeHelper] Loading unavailable.');
    },

    showModal: function (app, title, message) {
      if (typeof shopify !== 'undefined') {
        var modalId = 'shopify-flutter-modal';
        var m = document.getElementById(modalId);
        if (m) m.remove();
        
        m = document.createElement('ui-modal');
        m.id = modalId;
        m.innerHTML = '<p style="padding: 1rem;">' + message + '</p>' +
                      '<ui-title-bar title="' + title + '">' +
                        '<button variant="primary" onclick="shopify.modal.hide(\'' + modalId + '\')">OK</button>' +
                      '</ui-title-bar>';
        document.body.appendChild(m);
        shopify.modal.show(modalId);
        return;
      }
      var realApp = _oldAppInstance || app;
      var ab = oldAB();
      if (ab && ab.actions && ab.actions.Modal && realApp) {
        var Modal = ab.actions.Modal;
        var modal = Modal.create(realApp, { title: title, message: message });
        modal.dispatch(Modal.Action.OPEN);
        return;
      }
      console.warn('[ShopifyBridgeHelper] Modal unavailable.');
    },
  };

  console.log('[ShopifyBridgeHelper] ✅ Injected dynamically.');
})();
''';
