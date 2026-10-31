(function () {
    const appContextPath = document.currentScript?.dataset.contextPath || window.contextPath || "";

    // Register Service Worker
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register(appContextPath + '/sw.js').catch(err => {
                console.debug('ServiceWorker registration:', err);
            });
        });
    }

    // Auto-request notification permission on first user interaction
    function requestPushPermission() {
        if ('Notification' in window && Notification.permission === 'default') {
            Notification.requestPermission();
        }
    }
    document.addEventListener('click', requestPushPermission, { once: true });
    document.addEventListener('touchstart', requestPushPermission, { once: true });

    function findBellTargets() {
        const candidates = document.querySelectorAll('a[href*="NotificationServlet"], [onclick*="NotificationServlet"]');
        return Array.from(candidates).filter(node => node.querySelector('.fa-bell, .fa-regular.fa-bell, .fa-solid.fa-bell') || node.getAttribute('href')?.includes('NotificationServlet'));
    }

    function renderCount(count) {
        findBellTargets().forEach(target => {
            target.style.position = target.style.position || 'relative';
            let badge = target.querySelector('[data-notification-count-badge]');
            if (!badge) {
                badge = document.createElement('span');
                badge.dataset.notificationCountBadge = 'true';
                badge.setAttribute('aria-live', 'polite');
                badge.className = 'notification-count-badge';
                Object.assign(badge.style, {
                    position: 'absolute', top: '-5px', right: '-5px', minWidth: '18px', height: '18px',
                    padding: '0 5px', borderRadius: '999px', border: '2px solid white', background: '#dc2626',
                    color: 'white', font: 'bold 10px/14px Arial,sans-serif', textAlign: 'center', zIndex: '20',
                    boxShadow: '0 1px 4px rgba(0,0,0,.25)'
                });
                target.appendChild(badge);
            }
            badge.textContent = count > 99 ? '99+' : String(count);
            badge.style.display = count > 0 ? 'block' : 'none';
            target.setAttribute('aria-label', count > 0 ? Notifications ( unread) : 'Notifications');
        });
    }

    function findMessengerTargets() {
        return Array.from(document.querySelectorAll('a[href*="messages.jsp"], a[href$="/messages"], a[href*="/MessagesServlet"]'));
    }

    function renderMessengerCount(count) {
        findMessengerTargets().forEach(target => {
            target.style.position = target.style.position || 'relative';
            let badge = target.querySelector('[data-message-count-badge]');
            if (!badge) {
                badge = document.createElement('span');
                badge.dataset.messageCountBadge = 'true';
                badge.setAttribute('aria-live', 'polite');
                badge.className = 'message-count-badge';
                Object.assign(badge.style, {
                    position: 'absolute', top: '-5px', right: '-5px', minWidth: '18px', height: '18px',
                    padding: '0 5px', borderRadius: '999px', border: '2px solid white', background: '#2563eb',
                    color: 'white', font: 'bold 10px/14px Arial,sans-serif', textAlign: 'center', zIndex: '20',
                    boxShadow: '0 1px 4px rgba(0,0,0,.25)'
                });
                target.appendChild(badge);
            }
            badge.textContent = count > 99 ? '99+' : String(count);
            badge.style.display = count > 0 ? 'block' : 'none';
            target.setAttribute('aria-label', count > 0 ? Messenger ( unread) : 'Messenger');
        });
    }

    // ==========================================
    // GLOBAL INCOMING CALL UI & AUDIO SYSTEM
    // ==========================================
    let ringtoneInterval = null;
    let globalAudioCtx = null;
    let currentIncomingCallBanner = null;

    function playGlobalRingtone() {
        stopGlobalRingtone();
        try {
            const AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;
            globalAudioCtx = new AudioCtx();
            function ringCadence() {
                if (!globalAudioCtx) return;
                if (globalAudioCtx.state === 'suspended') {
                    globalAudioCtx.resume().catch(() => {});
                }
                const now = globalAudioCtx.currentTime;
                [440, 480].forEach(freq => {
                    const osc = globalAudioCtx.createOscillator();
                    const gain = globalAudioCtx.createGain();
                    osc.type = 'sine';
                    osc.frequency.value = freq;
                    gain.gain.setValueAtTime(0, now);
                    gain.gain.linearRampToValueAtTime(0.2, now + 0.05);
                    gain.gain.setValueAtTime(0.2, now + 1.8);
                    gain.gain.linearRampToValueAtTime(0, now + 2.0);
                    osc.connect(gain);
                    gain.connect(globalAudioCtx.destination);
                    osc.start(now);
                    osc.stop(now + 2.0);
                });
                if (navigator.vibrate) {
                    navigator.vibrate([400, 200, 400, 200, 800]);
                }
            }
            ringCadence();
            ringtoneInterval = setInterval(ringCadence, 4000);
        } catch (e) {
            console.debug("Global ringtone error:", e);
        }
    }

    function stopGlobalRingtone() {
        if (ringtoneInterval) {
            clearInterval(ringtoneInterval);
            ringtoneInterval = null;
        }
        if (globalAudioCtx) {
            try { globalAudioCtx.close(); } catch(e) {}
            globalAudioCtx = null;
        }
    }

    if (typeof window.showGlobalIncomingCall !== 'function') {
        window.showGlobalIncomingCall = function(caller, type) {
            if (currentIncomingCallBanner && currentIncomingCallBanner.dataset.caller === caller) {
                return;
            }
            if (currentIncomingCallBanner) {
                currentIncomingCallBanner.remove();
            }

            playGlobalRingtone();

            if ('Notification' in window && Notification.permission === 'granted') {
                try {
                    const n = new Notification("📞 " + caller + " is calling...", {
                        body: "Incoming " + (type === 'video' ? 'Video' : 'Voice') + " Call. Tap to answer.",
                        icon: appContextPath + "/images/icons/icon-192x192.png",
                        tag: "incoming-call-" + caller,
                        requireInteraction: true
                    });
                    n.onclick = function() {
                        window.focus();
                        stopGlobalRingtone();
                        if (currentIncomingCallBanner) currentIncomingCallBanner.remove();
                        window.location.href = appContextPath + "/messages.jsp?friend=" + encodeURIComponent(caller) + "&callAction=accept&callType=" + (type || 'voice');
                    };
                } catch(e) {}
            }

            const banner = document.createElement('div');
            banner.dataset.caller = caller;
            currentIncomingCallBanner = banner;
            banner.id = 'ychatGlobalCallBanner';
            Object.assign(banner.style, {
                position: 'fixed',
                top: '20px',
                left: '50%',
                transform: 'translateX(-50%)',
                zIndex: '999999',
                backgroundColor: '#0f172a',
                color: '#ffffff',
                borderRadius: '18px',
                boxShadow: '0 20px 40px rgba(0,0,0,0.6), 0 0 0 2px #3b82f6',
                padding: '14px 18px',
                display: 'flex',
                alignItems: 'center',
                gap: '14px',
                minWidth: '300px',
                maxWidth: '92vw',
                fontFamily: 'system-ui, -apple-system, sans-serif'
            });

            const initial = (caller || 'U').charAt(0).toUpperCase();
            banner.innerHTML = 
                <div style="width:46px;height:46px;border-radius:50%;background:linear-gradient(135deg,#3b82f6,#8b5cf6);display:flex;align-items:center;justify-content:center;font-size:20px;font-weight:bold;color:#fff;flex-shrink:0;">
                    \
                </div>
                <div style="flex:1;overflow:hidden;">
                    <div style="font-weight:700;font-size:15px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">\</div>
                    <div style="font-size:12px;color:#94a3b8;display:flex;align-items:center;gap:6px;">
                        <span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#22c55e;"></span>
                        Incoming \ Call...
                    </div>
                </div>
                <div style="display:flex;align-items:center;gap:10px;flex-shrink:0;">
                    <button id="ychatGlobalCallDecline" style="width:40px;height:40px;border-radius:50%;border:none;background:#ef4444;color:#fff;font-size:16px;display:flex;align-items:center;justify-content:center;cursor:pointer;box-shadow:0 4px 10px rgba(239,68,68,0.4);" title="Decline">
                        ✕
                    </button>
                    <button id="ychatGlobalCallAccept" style="width:40px;height:40px;border-radius:50%;border:none;background:#22c55e;color:#fff;font-size:18px;display:flex;align-items:center;justify-content:center;cursor:pointer;box-shadow:0 4px 10px rgba(34,197,94,0.4);" title="Accept">
                        📞
                    </button>
                </div>
            ;

            document.body.appendChild(banner);

            document.getElementById('ychatGlobalCallAccept').addEventListener('click', () => {
                stopGlobalRingtone();
                banner.remove();
                currentIncomingCallBanner = null;
                window.location.href = appContextPath + "/messages.jsp?friend=" + encodeURIComponent(caller) + "&callAction=accept&callType=" + (type || 'voice');
            });

            document.getElementById('ychatGlobalCallDecline').addEventListener('click', () => {
                stopGlobalRingtone();
                banner.remove();
                currentIncomingCallBanner = null;
            });

            setTimeout(() => {
                if (currentIncomingCallBanner === banner) {
                    stopGlobalRingtone();
                    banner.remove();
                    currentIncomingCallBanner = null;
                }
            }, 45000);
        };
    }

    let refreshInFlight = false;
    async function refreshNotificationCount() {
        if (refreshInFlight) return;
        refreshInFlight = true;
        try {
            const response = await fetch(appContextPath + '/NotificationServlet?action=count', {
                cache: 'no-store', credentials: 'same-origin', headers: { 'Accept': 'application/json' }
            });
            if (!response.ok) return;
            const data = await response.json();
            renderCount(Math.max(0, Number(data.unreadCount) || 0));
            renderMessengerCount(Math.max(0, Number(data.unreadMessages) || 0));

            if (data.incomingCall && data.incomingCall.caller) {
                const isMessagesPage = window.location.pathname.endsWith("messages.jsp") || window.location.pathname.endsWith("/messages");
                if (!isMessagesPage) {
                    window.showGlobalIncomingCall(data.incomingCall.caller, data.incomingCall.type || 'voice');
                }
            } else if (currentIncomingCallBanner) {
                stopGlobalRingtone();
                currentIncomingCallBanner.remove();
                currentIncomingCallBanner = null;
            }
        } catch (error) {
            console.debug('Notification badge refresh failed:', error);
        } finally {
            refreshInFlight = false;
        }
    }

    document.addEventListener('DOMContentLoaded', () => {
        refreshNotificationCount();
        window.setInterval(refreshNotificationCount, 3000);
        window.addEventListener('ychat:notification', refreshNotificationCount);
        document.addEventListener('visibilitychange', refreshNotificationCount);
    });
})();