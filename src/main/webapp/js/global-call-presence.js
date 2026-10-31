(function () {
    // If we are already on messages.jsp, messages.jsp has its own dedicated socket & calling UI
    if (window.location.pathname.endsWith("messages.jsp") || window.location.pathname.endsWith("/messages")) {
        return;
    }

    const scriptEl = document.currentScript || document.querySelector('script[src*="global-call-presence.js"]');
    let contextPath = scriptEl?.dataset?.contextPath || window.contextPath || "";
    if (contextPath === "/" || !contextPath) contextPath = "";
    let myName = scriptEl?.dataset?.user || document.querySelector('meta[name="current-user"]')?.content || window.currentUserName || "";

    let socket = null;
    let reconnectTimer = null;
    let pingInterval = null;
    let ringInterval = null;
    let ringAudioCtx = null;
    let ringOscillators = [];
    let currentIncomingCaller = null;
    let currentCallType = "voice";

    // 1. Audio Ringtone Synthesis (Facebook Messenger Chime)
    function initRingAudio() {
        if (!ringAudioCtx) {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            if (AudioContext) {
                ringAudioCtx = new AudioContext();
            }
        }
        if (ringAudioCtx && ringAudioCtx.state === "suspended") {
            ringAudioCtx.resume().catch(function () {});
        }
    }

    function playMessengerChime() {
        if (!ringAudioCtx) return;
        try {
            const now = ringAudioCtx.currentTime;
            const osc = ringAudioCtx.createOscillator();
            const gain = ringAudioCtx.createGain();

            osc.type = "triangle";
            // Classic Facebook Messenger 4-note chime
            osc.frequency.setValueAtTime(523.25, now);        // C5
            osc.frequency.setValueAtTime(659.25, now + 0.15); // E5
            osc.frequency.setValueAtTime(783.99, now + 0.30); // G5
            osc.frequency.setValueAtTime(1046.50, now + 0.45);// C6

            gain.gain.setValueAtTime(0, now);
            gain.gain.linearRampToValueAtTime(0.35, now + 0.05);
            gain.gain.setValueAtTime(0.35, now + 0.50);
            gain.gain.linearRampToValueAtTime(0, now + 0.75);

            osc.connect(gain);
            gain.connect(ringAudioCtx.destination);

            osc.start(now);
            osc.stop(now + 0.80);
            ringOscillators.push(osc);
        } catch (e) {
            console.debug("Chime playback error:", e);
        }
    }

    function startRingtone() {
        initRingAudio();
        stopRingtone();
        playMessengerChime();
        ringInterval = setInterval(playMessengerChime, 1400);

        if (navigator.vibrate) {
            try { navigator.vibrate([300, 200, 300, 200, 500]); } catch (e) {}
        }
    }

    function stopRingtone() {
        if (ringInterval) {
            clearInterval(ringInterval);
            ringInterval = null;
        }
        ringOscillators.forEach(function (osc) {
            try { osc.stop(); } catch (e) {}
        });
        ringOscillators = [];
        if (navigator.vibrate) {
            try { navigator.vibrate(0); } catch (e) {}
        }
    }

    // 2. Incoming Call UI Overlay
    function ensureCallOverlayDOM() {
        let overlay = document.getElementById("globalIncomingCallOverlay");
        if (overlay) return overlay;

        overlay = document.createElement("div");
        overlay.id = "globalIncomingCallOverlay";
        overlay.style.cssText = `
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(10, 15, 30, 0.88);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            z-index: 999999;
            display: none;
            align-items: center;
            justify-content: center;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
            color: #ffffff;
            touch-action: none;
        `;

        overlay.innerHTML = `
            <style>
                @keyframes globalCallPulse {
                    0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(37, 99, 235, 0.7); }
                    70% { transform: scale(1.05); box-shadow: 0 0 0 25px rgba(37, 99, 235, 0); }
                    100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(37, 99, 235, 0); }
                }
                @keyframes globalBtnBounce {
                    0%, 100% { transform: translateY(0); }
                    50% { transform: translateY(-4px); }
                }
                .global-call-avatar-pulse {
                    animation: globalCallPulse 1.8s infinite;
                }
                .global-call-answer-btn {
                    animation: globalBtnBounce 1.2s infinite ease-in-out;
                }
            </style>
            <div style="background: rgba(255, 255, 255, 0.1); border: 1px solid rgba(255, 255, 255, 0.2); border-radius: 28px; width: 90%; max-width: 360px; padding: 36px 24px; text-align: center; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);">
                <div id="globalCallTypeTag" style="display: inline-flex; align-items: center; gap: 6px; padding: 6px 14px; border-radius: 999px; background: rgba(37, 99, 235, 0.25); border: 1px solid rgba(59, 130, 246, 0.4); font-size: 13px; font-weight: 600; color: #93c5fd; margin-bottom: 24px;">
                    <i id="globalCallTypeIcon" class="fa-solid fa-phone"></i>
                    <span id="globalCallTypeLabel">Incoming Voice Call</span>
                </div>
                
                <div style="position: relative; width: 104px; height: 104px; margin: 0 auto 20px auto;">
                    <div id="globalCallAvatar" class="global-call-avatar-pulse" style="width: 104px; height: 104px; border-radius: 50%; background: linear-gradient(135deg, #3b82f6, #8b5cf6); display: flex; align-items: center; justify-content: center; font-size: 40px; font-weight: 800; color: #ffffff; text-shadow: 0 2px 4px rgba(0,0,0,0.3); border: 3px solid rgba(255,255,255,0.4);">
                        ?
                    </div>
                </div>

                <h3 id="globalCallCallerName" style="font-size: 22px; font-weight: 800; margin-bottom: 6px; letter-spacing: -0.3px;">User</h3>
                <p id="globalCallStatus" style="font-size: 14px; color: #94a3b8; margin-bottom: 36px;">Ringing...</p>

                <div style="display: flex; justify-content: space-around; align-items: center; gap: 20px;">
                    <!-- Decline Button -->
                    <button id="globalCallDeclineBtn" type="button" style="display: flex; flex-direction: column; align-items: center; gap: 8px; background: none; border: none; cursor: pointer; color: white;">
                        <div style="width: 64px; height: 64px; border-radius: 50%; background: #ef4444; display: flex; align-items: center; justify-content: center; font-size: 24px; box-shadow: 0 10px 20px rgba(239, 68, 68, 0.4); transition: transform 0.15s ease;">
                            <i class="fa-solid fa-phone-slash" style="transform: rotate(135deg);"></i>
                        </div>
                        <span style="font-size: 13px; font-weight: 600; color: #fca5a5;">Decline</span>
                    </button>

                    <!-- Accept Button -->
                    <button id="globalCallAcceptBtn" type="button" class="global-call-answer-btn" style="display: flex; flex-direction: column; align-items: center; gap: 8px; background: none; border: none; cursor: pointer; color: white;">
                        <div style="width: 64px; height: 64px; border-radius: 50%; background: #22c55e; display: flex; align-items: center; justify-content: center; font-size: 24px; box-shadow: 0 10px 20px rgba(34, 197, 94, 0.4); transition: transform 0.15s ease;">
                            <i class="fa-solid fa-phone"></i>
                        </div>
                        <span style="font-size: 13px; font-weight: 600; color: #86efac;">Answer</span>
                    </button>
                </div>
            </div>
        `;

        document.body.appendChild(overlay);

        document.getElementById("globalCallDeclineBtn").addEventListener("click", function () {
            declineIncomingCall();
        });

        document.getElementById("globalCallAcceptBtn").addEventListener("click", function () {
            acceptIncomingCall();
        });

        return overlay;
    }

    function showIncomingCall(caller, type) {
        currentIncomingCaller = caller;
        currentCallType = type || "voice";

        const overlay = ensureCallOverlayDOM();
        const avatarEl = document.getElementById("globalCallAvatar");
        const nameEl = document.getElementById("globalCallCallerName");
        const statusEl = document.getElementById("globalCallStatus");
        const typeIconEl = document.getElementById("globalCallTypeIcon");
        const typeLabelEl = document.getElementById("globalCallTypeLabel");

        if (avatarEl) avatarEl.textContent = caller ? caller.charAt(0).toUpperCase() : "?";
        if (nameEl) nameEl.textContent = caller;
        if (statusEl) statusEl.textContent = "Incoming " + (currentCallType === "video" ? "Video" : "Voice") + " Call...";
        if (typeIconEl) {
            typeIconEl.className = currentCallType === "video" ? "fa-solid fa-video" : "fa-solid fa-phone";
        }
        if (typeLabelEl) {
            typeLabelEl.textContent = currentCallType === "video" ? "Incoming Video Call" : "Incoming Voice Call";
        }

        overlay.style.display = "flex";
        startRingtone();
    }
    window.showGlobalIncomingCall = showIncomingCall;

    function hideIncomingCall() {
        stopRingtone();
        const overlay = document.getElementById("globalIncomingCallOverlay");
        if (overlay) overlay.style.display = "none";
        currentIncomingCaller = null;
    }

    function declineIncomingCall() {
        const caller = currentIncomingCaller;
        hideIncomingCall();
        if (caller && socket && socket.readyState === WebSocket.OPEN) {
            socket.send("CALL_REJECT|" + caller + "|declined");
        }
    }

    function acceptIncomingCall() {
        const caller = currentIncomingCaller;
        const type = currentCallType;
        hideIncomingCall();
        if (!caller) return;

        // Navigate immediately to messages.jsp with auto-accept parameters
        const targetUrl = contextPath + "/messages.jsp?userName=" + encodeURIComponent(caller) + "&callAction=accept&callType=" + encodeURIComponent(type);
        window.location.href = targetUrl;
    }

    // 3. WebSocket Connection & Heartbeat for Always Online Presence
    function connectSocket() {
        if (!myName || myName === "null" || myName.trim() === "") return;
        if (socket && (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING)) {
            return;
        }

        const protocol = window.location.protocol === "https:" ? "wss://" : "ws://";
        const host = window.location.host;
        const wsUrl = protocol + host + contextPath + "/ws/user/" + encodeURIComponent(myName);

        try {
            socket = new WebSocket(wsUrl);
        } catch (err) {
            console.debug("Presence socket error:", err);
            scheduleReconnect();
            return;
        }

        socket.onopen = function () {
            console.debug("Y-Chat Presence Online:", myName);
            if (reconnectTimer) clearTimeout(reconnectTimer);
            startHeartbeat();
        };

        socket.onclose = function () {
            stopHeartbeat();
            scheduleReconnect();
        };

        socket.onerror = function () {
            try { socket.close(); } catch (e) {}
        };

        socket.onmessage = function (event) {
            const data = event.data || "";
            if (data.startsWith("CALL_OFFER|")) {
                const parts = data.split("|", 3);
                const caller = parts[1];
                let payload = {};
                try { payload = JSON.parse(parts[2]); } catch (e) {}
                // If it's an initial call offer (not renegotiation SDP)
                if (!payload.sdp) {
                    showIncomingCall(caller, payload.type || "voice");
                }
            } else if (data.startsWith("CALL_END|") || data.startsWith("CALL_REJECT|")) {
                const parts = data.split("|", 3);
                if (currentIncomingCaller && parts[1] === currentIncomingCaller) {
                    hideIncomingCall();
                }
            } else if (data.startsWith("NOTIF|") || data.startsWith("CHAT|")) {
                window.dispatchEvent(new Event("ychat:notification"));
            }
        };
    }

    function scheduleReconnect() {
        if (reconnectTimer) clearTimeout(reconnectTimer);
        reconnectTimer = setTimeout(function () {
            connectSocket();
        }, 3000);
    }

    function startHeartbeat() {
        stopHeartbeat();
        pingInterval = setInterval(function () {
            if (socket && socket.readyState === WebSocket.OPEN) {
                socket.send("PING|server|heartbeat");
            }
        }, 25000);
    }

    function stopHeartbeat() {
        if (pingInterval) {
            clearInterval(pingInterval);
            pingInterval = null;
        }
    }

    // 4. Initialize & handle iOS / iPhone Sleep Wakeup
    async function init() {
        if (!myName || myName === "null" || myName.trim() === "") {
            // Try fetching from notification endpoint
            try {
                const res = await fetch(contextPath + "/NotificationServlet?action=count", {
                    cache: "no-store", credentials: "same-origin", headers: { "Accept": "application/json" }
                });
                if (res.ok) {
                    const data = await res.json();
                    if (data && data.username) {
                        myName = data.username;
                    }
                }
            } catch (e) {}
        }

        if (myName && myName.trim() !== "") {
            connectSocket();
        }
    }

    // iOS Safari / Mobile App Wakeup listeners
    document.addEventListener("visibilitychange", function () {
        if (document.visibilityState === "visible") {
            if (!socket || socket.readyState !== WebSocket.OPEN) {
                connectSocket();
            }
        }
    });

    window.addEventListener("pageshow", function () {
        if (!socket || socket.readyState !== WebSocket.OPEN) {
            connectSocket();
        }
    });

    window.addEventListener("online", function () {
        connectSocket();
    });

    window.addEventListener("focus", function () {
        if (!socket || socket.readyState !== WebSocket.OPEN) {
            connectSocket();
        }
    });

    // Touch unlock for Web Audio on iOS
    document.addEventListener("touchstart", function unlockAudio() {
        initRingAudio();
        document.removeEventListener("touchstart", unlockAudio);
    }, { once: true, passive: true });

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
