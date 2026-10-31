(function () {
    const appContextPath = document.currentScript?.dataset.contextPath || window.contextPath || "";
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
            target.setAttribute('aria-label', count > 0 ? `Notifications (${count} unread)` : 'Notifications');
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
            target.setAttribute('aria-label', count > 0 ? `Messenger (${count} unread)` : 'Messenger');
        });
    }

    let refreshInFlight = false;
    async function refreshNotificationCount() {
        if (refreshInFlight || document.visibilityState === 'hidden') return;
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
                if (!isMessagesPage && typeof window.showGlobalIncomingCall === 'function') {
                    window.showGlobalIncomingCall(data.incomingCall.caller, data.incomingCall.type || 'voice');
                }
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
