// YChat Service Worker: Fast App Shell Caching & Reliable Incoming Call Push
const CACHE_NAME = 'ychat-app-cache-v21';
const STATIC_ASSETS = [
    'icons/icon-192.png',
    'icons/icon-512.png',
    'sounds/ringtone.wav',
    'sounds/outgoing.wav',
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

// Push Notifications (100% Compatible with iOS Safari PWA, Android, and Desktop)
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

    // Dismiss incoming call notification when call answered/declined/cancelled
    if (payload.action === 'dismiss_call' || payload.dismiss) {
        const callerName = payload.caller || '';
        const wasAnswered = Boolean(payload.wasAnswered);
        event.waitUntil(
            self.registration.getNotifications().then(function(notifications) {
                for (let i = 0; i < notifications.length; i++) {
                    let notif = notifications[i];
                    if (notif.tag && (notif.tag.includes('incoming-call-') || (callerName && notif.tag.includes(callerName)))) {
                        notif.close();
                    }
                }
                // If caller cancelled before answer, show a clean Missed Call banner
                if (!wasAnswered && callerName) {
                    return self.registration.showNotification('📞 Missed call from ' + callerName, {
                        body: 'Tap to open chat and call back',
                        icon: '/icons/icon-192.png',
                        badge: '/icons/icon-192.png',
                        tag: 'missed-call-' + callerName,
                        data: {
                            url: '/messages.jsp?friend=' + encodeURIComponent(callerName)
                        }
                    });
                }
            })
        );
        return;
    }

    const isCall = Boolean(payload.isCall || (payload.title && (payload.title.includes('calling') || payload.title.includes('Call'))));
    const iconUrl = new URL(payload.icon || 'icons/icon-192.png', self.location.origin).href;
    const badgeUrl = new URL(payload.badge || 'icons/icon-192.png', self.location.origin).href;

    // Wake up and trigger incoming call UI + full audio ring loop in any open/background tabs
    if (isCall && payload.caller) {
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (clientList) {
            clientList.forEach(function (c) {
                try {
                    c.postMessage({
                        action: 'incomingCallStart',
                        caller: payload.caller,
                        callType: payload.callType || 'voice'
                    });
                } catch (e) {}
            });
        }).catch(function() {});
    }

    // Strict, clean options guaranteed to work across all iOS Safari, Android, and Desktop browsers
    const options = {
        body: payload.body || 'Tap to answer incoming call',
        icon: iconUrl,
        badge: badgeUrl,
        tag: isCall ? ('incoming-call-' + (payload.caller || 'active')) : ('ychat-' + (payload.tag || 'general')),
        data: {
            url: payload.url || '/messages.jsp',
            isCall: isCall,
            caller: payload.caller
        }
    };

    // Advanced options only for Android/Desktop (iOS Safari throws or drops notifications if actions/vibrate are passed)
    const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
    if (!isIOS) {
        options.requireInteraction = true;
        options.renotify = isCall;
        options.vibrate = isCall ? [1000, 400, 1000, 400, 1000, 400, 1000] : [200, 100, 200];
    }

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

    // Dismiss any remaining incoming call notifications
    if (self.registration && self.registration.getNotifications) {
        self.registration.getNotifications().then(function(notifications) {
            for (let i = 0; i < notifications.length; i++) {
                let n = notifications[i];
                if (n.tag && n.tag.includes('incoming-call-')) {
                    n.close();
                }
            }
        }).catch(function() {});
    }

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
