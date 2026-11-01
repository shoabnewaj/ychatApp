// YChat Service Worker: Fast App Shell Caching & Reliable Incoming Call Push
const CACHE_NAME = 'ychat-app-cache-v5';
const STATIC_ASSETS = [
    'icons/icon-192.png',
    'icons/icon-512.png',
    'js/notification-badge.js',
    'js/global-call-presence.js',
    'js/script.js',
    'js/theme.js'
];

self.addEventListener('install', function (event) {
    event.waitUntil(
        caches.open(CACHE_NAME).then(function (cache) {
            return cache.addAll(STATIC_ASSETS).catch(function () {});
        }).then(function () {
            return self.skipWaiting();
        })
    );
});

self.addEventListener('activate', function (event) {
    event.waitUntil(
        caches.keys().then(function (cacheNames) {
            return Promise.all(
                cacheNames.map(function (cache) {
                    if (cache !== CACHE_NAME) {
                        return caches.delete(cache);
                    }
                })
            );
        }).then(function () {
            return self.clients.claim();
        })
    );
});

// Cache-First strategy for static assets
self.addEventListener('fetch', function (event) {
    const req = event.request;
    const url = new URL(req.url);

    if (req.method !== 'GET' || 
        url.pathname.includes('Servlet') || 
        url.pathname.includes('/ws/') || 
        url.pathname.includes('/userws/')) {
        return;
    }

    const isStaticAsset = (
        url.pathname.endsWith('.js') ||
        url.pathname.endsWith('.css') ||
        url.pathname.endsWith('.png') ||
        url.pathname.endsWith('.jpg') ||
        url.pathname.endsWith('.jpeg') ||
        url.pathname.endsWith('.svg') ||
        url.pathname.endsWith('.woff2') ||
        url.pathname.endsWith('.woff') ||
        url.pathname.endsWith('.ttf') ||
        url.hostname.includes('cdn.tailwindcss.com') ||
        url.hostname.includes('cdnjs.cloudflare.com') ||
        url.hostname.includes('fonts.googleapis.com') ||
        url.hostname.includes('fonts.gstatic.com')
    );

    if (isStaticAsset) {
        event.respondWith(
            caches.match(req).then(function (cached) {
                if (cached) {
                    fetch(req).then(function (networkRes) {
                        if (networkRes && networkRes.status === 200) {
                            caches.open(CACHE_NAME).then(function (cache) {
                                cache.put(req, networkRes);
                            });
                        }
                    }).catch(function () {});
                    return cached;
                }
                return fetch(req).then(function (networkRes) {
                    if (networkRes && networkRes.status === 200) {
                        const copy = networkRes.clone();
                        caches.open(CACHE_NAME).then(function (cache) {
                            cache.put(req, copy);
                        });
                    }
                    return networkRes;
                });
            })
        );
    }
});

// Push Notifications (Compatible with 100% of iOS Safari, Android, and Desktop)
self.addEventListener('push', function (event) {
    let payload = {
        title: '📞 Incoming Call',
        body: 'Incoming call... Tap to answer',
        icon: '/icons/icon-192.png',
        badge: '/icons/icon-192.png',
        url: '/messages.jsp'
    };

    if (event.data) {
        try {
            payload = Object.assign(payload, event.data.json());
        } catch (e) {
            payload.body = event.data.text();
        }
    }

    const isCall = (payload.title && (payload.title.includes('calling') || payload.title.includes('Call')));
    const iconUrl = new URL(payload.icon || 'icons/icon-192.png', self.location.origin).href;
    const badgeUrl = new URL(payload.badge || 'icons/icon-192.png', self.location.origin).href;

    const options = {
        body: payload.body || 'Tap to answer incoming call',
        icon: iconUrl,
        badge: badgeUrl,
        tag: isCall ? ('call-' + (payload.caller || 'call') + '-' + Date.now()) : ('ychat-' + Date.now()),
        renotify: true,
        requireInteraction: true,
        vibrate: [500, 250, 500, 250, 500],
        data: {
            url: payload.url || '/messages.jsp',
            isCall: isCall,
            caller: payload.caller
        }
    };

    event.waitUntil(
        self.registration.showNotification(payload.title || '📞 Incoming Call', options).catch(function(err) {
            console.error('showNotification error:', err);
            return self.registration.showNotification(payload.title || '📞 Incoming Call', {
                body: payload.body || 'Tap to open call'
            });
        })
    );
});

self.addEventListener('notificationclick', function (event) {
    event.notification.close();
    const data = event.notification.data || {};
    const targetUrl = data.url || '/messages.jsp';

    if (event.action === 'decline' || event.action === 'dismiss') {
        return;
    }

    const fullUrl = new URL(targetUrl, self.location.origin).href;

    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (clientList) {
            for (let i = 0; i < clientList.length; i++) {
                const client = clientList[i];
                if ('navigate' in client && 'focus' in client) {
                    client.navigate(fullUrl);
                    return client.focus();
                }
            }
            if (clients.openWindow) {
                return clients.openWindow(fullUrl);
            }
        })
    );
});
