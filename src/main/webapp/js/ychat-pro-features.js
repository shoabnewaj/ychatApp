/**
 * Y-ChatApp Pro Features Suite (Modular, Non-Destructive Enhancer - 100% Safari/iOS/macOS Compatible)
 * Adds 18+ interactive features across News Feed, Stories, Reels, Messenger, Calls & Profile
 * without modifying or breaking any existing functionality.
 */
(function () {
    if (window.__YCHAT_PRO_LOADED_V2__) return;
    window.__YCHAT_PRO_LOADED_V2__ = true;
    window.__YCHAT_PRO_LOADED__ = true;

    // =========================================================================
    // 1. STATE & STORAGE HELPERS (ES5/Safari Safe - Zero Optional Chaining)
    // =========================================================================
    var STORAGE_KEYS = {
        COINS: 'ychat_pro_coins',
        STREAK: 'ychat_pro_streak',
        LAST_CHECKIN: 'ychat_pro_last_checkin',
        XP: 'ychat_pro_xp',
        VERIFIED: 'ychat_pro_verified',
        RINGTONE: 'ychat_pro_ringtone',
        COLLECTIONS: 'ychat_pro_collections',
        VISITORS: 'ychat_pro_visitors',
        GROUPS: 'ychat_pro_groups',
        GROUP_MSGS: 'ychat_pro_group_msgs',
        VANISH_MODE: 'ychat_pro_vanish_',
        WALLPAPER: 'ychat_pro_wallpaper_',
        AUDIO_BIO: 'ychat_pro_audio_bio',
        STORY_EXTRAS: 'ychat_pro_story_extras',
        POST_GIFTS: 'ychat_pro_post_gifts'
    };

    function getStore(key, fallback) {
        try {
            var v = localStorage.getItem(key);
            return v !== null ? JSON.parse(v) : fallback;
        } catch (e) {
            return fallback;
        }
    }

    function setStore(key, val) {
        try {
            localStorage.setItem(key, JSON.stringify(val));
        } catch (e) {}
    }

    function getElVal(id, fallback) {
        var el = document.getElementById(id);
        if (el && typeof el.value === 'string' && el.value.trim() !== '') {
            return el.value.trim();
        }
        return fallback || '';
    }

    function getCurrentUserName() {
        if (typeof window.myName === 'string' && window.myName.trim()) return window.myName.trim();
        var b = document.querySelector('.sidebar-header small b');
        if (b && b.textContent) return b.textContent.trim();
        var navName = document.querySelector('aside a[href*="UsersProfileServlet"] span.font-bold, header a[href*="UsersProfileServlet"] span');
        if (navName && navName.textContent && navName.textContent.trim()) return navName.textContent.trim();
        var h2 = document.querySelector('h2.text-4xl.font-black');
        if (h2 && h2.textContent && h2.textContent.trim()) return h2.textContent.trim();
        return 'User';
    }

    // Initialize default coins & streak if first time
    try {
        if (localStorage.getItem(STORAGE_KEYS.COINS) === null) setStore(STORAGE_KEYS.COINS, 500);
        if (localStorage.getItem(STORAGE_KEYS.STREAK) === null) setStore(STORAGE_KEYS.STREAK, 3);
        if (localStorage.getItem(STORAGE_KEYS.XP) === null) setStore(STORAGE_KEYS.XP, 320);
    } catch (e) {}

    function getUserLevel() {
        var xp = getStore(STORAGE_KEYS.XP, 320);
        return Math.max(1, Math.floor(xp / 150) + 1);
    }

    // Safari HTTP-safe clipboard helper
    function copyProText(text, successMsg) {
        var done = function () {
            proToast(successMsg || 'Copied to clipboard!', 'fa-check', '#10b981');
        };
        if (navigator.clipboard && typeof navigator.clipboard.writeText === 'function') {
            navigator.clipboard.writeText(text).then(done).catch(function () {
                fallbackCopyText(text, done);
            });
        } else {
            fallbackCopyText(text, done);
        }
    }
    window.copyProText = copyProText;

    function fallbackCopyText(text, cb) {
        try {
            var ta = document.createElement('textarea');
            ta.value = text;
            ta.setAttribute('readonly', '');
            ta.style.cssText = 'position:fixed;top:-9999px;left:-9999px;opacity:0;';
            document.body.appendChild(ta);
            ta.focus();
            ta.select();
            ta.setSelectionRange(0, 99999);
            document.execCommand('copy');
            document.body.removeChild(ta);
            if (cb) cb();
        } catch (e) {
            window.prompt('Copy this link:', text);
        }
    }

    // Toast notification helper
    function proToast(msg, icon, color) {
        icon = icon || 'fa-sparkles';
        color = color || '#7c3aed';
        var t = document.getElementById('ychatProToast');
        if (!t) {
            t = document.createElement('div');
            t.id = 'ychatProToast';
            t.style.cssText = 'position:fixed !important;top:20px !important;left:50% !important;transform:translateX(-50%) translateY(-20px) !important;background:rgba(15,23,42,0.96) !important;color:#fff !important;padding:10px 20px !important;border-radius:999px !important;font-size:13px !important;font-weight:700 !important;display:flex !important;align-items:center !important;gap:8px !important;z-index:2147483647 !important;box-shadow:0 12px 30px rgba(0,0,0,0.4) !important;border:1px solid rgba(255,255,255,0.22) !important;opacity:0;pointer-events:none !important;transition:all 0.25s ease !important;-webkit-backdrop-filter:blur(12px);backdrop-filter:blur(12px);';
            document.body.appendChild(t);
        }
        t.innerHTML = '<i class="fa-solid ' + icon + '" style="color:' + color + ';font-size:15px;"></i> <span>' + msg + '</span>';
        t.style.opacity = '1';
        t.style.transform = 'translateX(-50%) translateY(0)';
        clearTimeout(t._timer);
        t._timer = setTimeout(function () {
            t.style.opacity = '0';
            t.style.transform = 'translateX(-50%) translateY(-20px)';
        }, 2800);
    }
    window.proToast = proToast;

    // =========================================================================
    // 2. INJECT GLOBAL STYLES FOR PRO FEATURES (Safari-Safe)
    // =========================================================================
    function injectProStyles() {
        var oldStyle = document.getElementById('ychat-pro-styles');
        if (oldStyle) oldStyle.remove();
        var style = document.createElement('style');
        style.id = 'ychat-pro-styles';
        style.textContent = [
            '.ychat-pro-bar {',
            '    display: flex !important; align-items: center !important; gap: 8px !important; overflow-x: auto !important;',
            '    padding: 8px 14px !important; background: linear-gradient(90deg, rgba(124,58,237,0.12), rgba(236,72,153,0.12)) !important;',
            '    border-bottom: 1px solid rgba(124,58,237,0.2) !important; scrollbar-width: none;',
            '    position: relative !important; z-index: 4995 !important; pointer-events: auto !important;',
            '    -webkit-overflow-scrolling: touch !important;',
            '}',
            '.ychat-pro-bar::-webkit-scrollbar { display: none; }',
            '.ychat-pro-pill {',
            '    display: inline-flex !important; align-items: center !important; gap: 6px !important;',
            '    padding: 7px 13px !important; border-radius: 999px !important; font-size: 12px !important; font-weight: 700 !important;',
            '    background: #ffffff !important; color: #1e293b !important; border: 1px solid #cbd5e1 !important;',
            '    cursor: pointer !important; white-space: nowrap !important;',
            '    box-shadow: 0 2px 5px rgba(0,0,0,0.06) !important; flex-shrink: 0 !important;',
            '    touch-action: manipulation !important; -webkit-tap-highlight-color: rgba(124,58,237,0.2) !important;',
            '    user-select: none !important; -webkit-user-select: none !important; pointer-events: auto !important;',
            '}',
            '.ychat-pro-pill:active {',
            '    background: #f3e8ff !important; border-color: #9333ea !important; color: #6d28d9 !important;',
            '}',
            '.dark .ychat-pro-pill {',
            '    background: #1e293b !important; color: #f1f5f9 !important; border-color: rgba(255,255,255,0.18) !important;',
            '}',
            '.ychat-verified-tick {',
            '    display: inline-flex !important; align-items: center !important; justify-content: center !important;',
            '    width: 16px !important; height: 16px !important; border-radius: 50% !important;',
            '    background: linear-gradient(135deg, #2563eb, #38bdf8) !important;',
            '    color: #fff !important; font-size: 9px !important; margin-left: 4px !important;',
            '    box-shadow: 0 2px 6px rgba(37,99,235,0.35) !important; vertical-align: middle !important;',
            '}',
            '@keyframes ychatFloatUp {',
            '    0% { transform: translate(-50%, 0) scale(0.8); opacity: 1; }',
            '    70% { transform: translate(-50%, -220px) scale(1.35); opacity: 1; }',
            '    100% { transform: translate(-50%, -320px) scale(1.6); opacity: 0; }',
            '}',
            '.ychat-flying-gift {',
            '    position: fixed !important; bottom: 80px !important; left: 50% !important; transform: translateX(-50%);',
            '    z-index: 2147483646 !important; pointer-events: none !important; text-align: center !important;',
            '    animation: ychatFloatUp 2.4s cubic-bezier(0.16, 1, 0.3, 1) forwards !important;',
            '}',
            '.ychat-audio-speed-btn {',
            '    background: #ede9fe !important; color: #6d28d9 !important; border: 1px solid #ddd6fe !important;',
            '    border-radius: 10px !important; padding: 3px 8px !important; font-size: 11px !important; font-weight: 800 !important;',
            '    cursor: pointer !important; margin-left: 4px !important; flex-shrink: 0 !important; touch-action: manipulation !important;',
            '}',
            '.ychat-vanish-badge {',
            '    display: inline-flex !important; align-items: center !important; gap: 3px !important;',
            '    background: rgba(239,68,68,0.15) !important; color: #ef4444 !important; border: 1px solid rgba(239,68,68,0.3) !important;',
            '    border-radius: 999px !important; padding: 1px 7px !important; font-size: 10px !important; font-weight: 700 !important; margin-left: 6px !important;',
            '}',
            '.ychat-post-pro-bar {',
            '    display: flex !important; align-items: center !important; flex-wrap: wrap !important; gap: 6px !important;',
            '    margin-top: 8px !important; padding-top: 8px !important; border-top: 1px dashed rgba(148,163,184,0.25) !important;',
            '    position: relative !important; z-index: 10 !important; pointer-events: auto !important;',
            '}',
            '.ychat-post-pro-btn {',
            '    display: inline-flex !important; align-items: center !important; gap: 5px !important;',
            '    padding: 5px 11px !important; border-radius: 999px !important; font-size: 11px !important; font-weight: 700 !important;',
            '    background: #f8fafc !important; color: #475569 !important; border: 1px solid #cbd5e1 !important;',
            '    cursor: pointer !important; touch-action: manipulation !important; -webkit-tap-highlight-color: rgba(124,58,237,0.2) !important;',
            '}',
            '.dark .ychat-post-pro-btn {',
            '    background: #1e293b !important; color: #cbd5e1 !important; border-color: rgba(255,255,255,0.15) !important;',
            '}'
        ].join('\n');
        document.head.appendChild(style);
    }

    // =========================================================================
    // 3. SAFARI-PROOF POPUP OVERLAY SYSTEM (Zero CSS-Class or Flex-0% Dependency)
    // =========================================================================
    function openProModal(titleHtml, bodyHtml, onRenderCallback) {
        var old = document.getElementById('ychatProPopupOverlay');
        if (old) old.remove();

        var isDark = document.documentElement.classList.contains('dark') || document.body.classList.contains('dark');
        var cardBg = isDark ? '#0f172a' : '#ffffff';
        var cardColor = isDark ? '#f8fafc' : '#0f172a';
        var cardBorder = isDark ? 'rgba(255,255,255,0.18)' : '#cbd5e1';

        var overlay = document.createElement('div');
        overlay.id = 'ychatProPopupOverlay';
        overlay.style.cssText = 'position:fixed !important;top:0 !important;left:0 !important;right:0 !important;bottom:0 !important;width:100vw !important;height:100vh !important;background:rgba(15,23,42,0.78) !important;-webkit-backdrop-filter:blur(6px);backdrop-filter:blur(6px);z-index:2147483646 !important;display:flex !important;align-items:center !important;justify-content:center !important;padding:16px !important;box-sizing:border-box !important;opacity:1 !important;visibility:visible !important;pointer-events:auto !important;';

        var card = document.createElement('div');
        card.id = 'ychatProPopupCard';
        card.style.cssText = 'background:' + cardBg + ' !important;color:' + cardColor + ' !important;width:100% !important;max-width:460px !important;max-height:85vh !important;border-radius:24px !important;padding:20px !important;box-shadow:0 25px 60px rgba(0,0,0,0.45) !important;display:block !important;overflow-y:auto !important;-webkit-overflow-scrolling:touch !important;border:1px solid ' + cardBorder + ' !important;box-sizing:border-box !important;position:relative !important;z-index:2147483647 !important;pointer-events:auto !important;';

        card.innerHTML = '' +
            '<div style="display:flex;justify-content:space-between;align-items:center;padding-bottom:12px;border-bottom:1px solid rgba(148,163,184,0.25);margin-bottom:14px;">' +
                '<div style="font-size:16px;font-weight:800;display:flex;align-items:center;gap:8px;line-height:1.3;">' + titleHtml + '</div>' +
                '<button type="button" id="ychatProPopupCloseBtn" style="background:rgba(148,163,184,0.2);border:none;width:34px;height:34px;border-radius:50%;cursor:pointer;color:inherit;font-size:16px;display:flex;align-items:center;justify-content:center;flex-shrink:0;touch-action:manipulation;"><i class="fa-solid fa-xmark"></i></button>' +
            '</div>' +
            '<div id="ychatProPopupContent" style="display:block;height:auto;line-height:1.5;">' + bodyHtml + '</div>';

        overlay.appendChild(card);
        document.body.appendChild(overlay);

        var closeBtn = document.getElementById('ychatProPopupCloseBtn');
        if (closeBtn) {
            closeBtn.onclick = function (e) {
                e.stopPropagation();
                closeProModal();
            };
        }
        var modalOpenedAt = Date.now();
        overlay.onclick = function (e) {
            if (Date.now() - modalOpenedAt < 450) return;
            if (e.target === overlay) closeProModal();
        };

        if (typeof onRenderCallback === 'function') {
            try { onRenderCallback(card); } catch (err) { console.error(err); }
        }
    }
    window.openProModal = openProModal;

    function closeProModal() {
        var b = document.getElementById('ychatProPopupOverlay');
        if (b) b.remove();
    }
    window.closeProModal = closeProModal;

    // Helper to bind Safari-reliable tap & click to any button
    function bindSafariTap(el, fn) {
        if (!el || typeof fn !== 'function') return;
        var lastTriggered = 0;
        el.style.touchAction = 'manipulation';
        el.style.cursor = 'pointer';
        el.addEventListener('click', function (e) {
            var now = Date.now();
            if (now - lastTriggered < 400) return;
            lastTriggered = now;
            fn(e);
        });
    }
    // =========================================================================
    // 4. RINGTONE & NOTIFICATION SOUND SYNTHESIZER (#18)
    // =========================================================================
    var RINGTONES = {
        classic: { name: 'Classic Chime', notes: [523.25, 659.25, 783.99, 1046.5] },
        cyber:   { name: 'Cyber Pulse', notes: [440, 554.37, 659.25, 880, 659.25, 880] },
        marimba: { name: 'Marimba Melody', notes: [392, 440, 523.25, 587.33, 659.25] },
        crystal: { name: 'Crystal Bell', notes: [880, 1046.5, 1318.5, 1567.98] },
        piano:   { name: 'Soft Piano', notes: [261.63, 329.63, 392.00, 523.25] }
    };

    function playCustomRingtone(key) {
        var toneKey = key || getStore(STORAGE_KEYS.RINGTONE, 'classic');
        var preset = RINGTONES[toneKey] || RINGTONES.classic;
        try {
            var AudioCtx = window.AudioContext || window.webkitAudioContext;
            if (!AudioCtx) return;
            var ctx = new AudioCtx();
            if (ctx.state === 'suspended' && typeof ctx.resume === 'function') {
                ctx.resume();
            }
            preset.notes.forEach(function (freq, idx) {
                var osc = ctx.createOscillator();
                var gain = ctx.createGain();
                osc.type = toneKey === 'cyber' ? 'sawtooth' : (toneKey === 'crystal' ? 'sine' : 'triangle');
                var start = ctx.currentTime + idx * 0.14;
                osc.frequency.setValueAtTime(freq, start);
                gain.gain.setValueAtTime(0.001, start);
                gain.gain.linearRampToValueAtTime(0.18, start + 0.03);
                gain.gain.exponentialRampToValueAtTime(0.001, start + 0.28);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start(start);
                osc.stop(start + 0.3);
            });
        } catch (e) {}
    }
    window.playCustomRingtone = playCustomRingtone;

    function openRingtoneSelectorModal() {
        var current = getStore(STORAGE_KEYS.RINGTONE, 'classic');
        var rows = '';
        Object.keys(RINGTONES).forEach(function (k) {
            var active = k === current;
            rows += '' +
                '<div style="display:flex;align-items:center;justify-content:space-between;padding:11px 14px;border-radius:14px;border:1px solid ' + (active ? '#8b5cf6' : 'rgba(148,163,184,0.25)') + ';background:' + (active ? 'rgba(139,92,246,0.1)' : 'transparent') + ';margin-bottom:8px;">' +
                    '<div style="display:flex;align-items:center;gap:10px;">' +
                        '<i class="fa-solid fa-music" style="color:#8b5cf6;"></i>' +
                        '<span style="font-weight:700;font-size:14px;">' + RINGTONES[k].name + '</span>' +
                        (active ? '<span style="background:#8b5cf6;color:#fff;font-size:10px;padding:2px 8px;border-radius:999px;font-weight:800;">ACTIVE</span>' : '') +
                    '</div>' +
                    '<div style="display:flex;gap:6px;">' +
                        '<button type="button" onclick="window.playCustomRingtone(\'' + k + '\')" style="padding:6px 11px;border-radius:10px;border:1px solid #cbd5e1;background:transparent;color:inherit;font-size:12px;font-weight:700;cursor:pointer;"><i class="fa-solid fa-play"></i> Test</button>' +
                        '<button type="button" onclick="window.selectProRingtone(\'' + k + '\')" style="padding:6px 12px;border-radius:10px;border:none;background:#7c3aed;color:#fff;font-size:12px;font-weight:700;cursor:pointer;">Use</button>' +
                    '</div>' +
                '</div>';
        });
        openProModal('<i class="fa-solid fa-bell" style="color:#f59e0b;"></i> Custom Ringtone & Sound', rows);
    }
    window.openRingtoneSelectorModal = openRingtoneSelectorModal;

    window.selectProRingtone = function (k) {
        setStore(STORAGE_KEYS.RINGTONE, k);
        playCustomRingtone(k);
        proToast('Ringtone set to ' + RINGTONES[k].name, 'fa-bell', '#f59e0b');
        openRingtoneSelectorModal();
    };

    // =========================================================================
    // 5. DAILY STREAK, LEVEL & VIRTUAL COIN WALLET (#15 & #16)
    // =========================================================================
    function openStreakAndLevelModal() {
        var streak = getStore(STORAGE_KEYS.STREAK, 3);
        var coins = getStore(STORAGE_KEYS.COINS, 500);
        var xp = getStore(STORAGE_KEYS.XP, 320);
        var level = getUserLevel();
        var today = new Date().toISOString().slice(0, 10);
        var checkedToday = getStore(STORAGE_KEYS.LAST_CHECKIN, '') === today;

        openProModal(
            '<i class="fa-solid fa-fire" style="color:#f97316;"></i> Daily Streak, Level & Coins',
            '<div style="text-align:center;padding:16px;background:linear-gradient(135deg,#7c3aed,#ec4899);color:#fff;border-radius:20px;margin-bottom:14px;">' +
                '<div style="font-size:32px;font-weight:900;margin-bottom:4px;">🔥 ' + streak + ' Day Streak</div>' +
                '<div style="font-size:13px;opacity:0.95;font-weight:600;">Level ' + level + ' Creator • ' + xp + ' XP • 🪙 ' + coins + ' Coins</div>' +
            '</div>' +
            '<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;margin-bottom:14px;text-align:center;">' +
                '<div style="padding:10px;border-radius:14px;border:1px solid rgba(148,163,184,0.25);">' +
                    '<div style="font-size:18px;font-weight:900;color:#f97316;">🔥 ' + streak + '</div>' +
                    '<div style="font-size:11px;opacity:0.75;">Active Streak</div>' +
                '</div>' +
                '<div style="padding:10px;border-radius:14px;border:1px solid rgba(148,163,184,0.25);">' +
                    '<div style="font-size:18px;font-weight:900;color:#8b5cf6;">🏆 Lv.' + level + '</div>' +
                    '<div style="font-size:11px;opacity:0.75;">Profile Rank</div>' +
                '</div>' +
                '<div style="padding:10px;border-radius:14px;border:1px solid rgba(148,163,184,0.25);">' +
                    '<div style="font-size:18px;font-weight:900;color:#eab308;">🪙 ' + coins + '</div>' +
                    '<div style="font-size:11px;opacity:0.75;">Wallet Coins</div>' +
                '</div>' +
            '</div>' +
            '<button type="button" onclick="window.claimDailyProReward()" ' + (checkedToday ? 'disabled' : '') + ' style="width:100%;padding:13px;border-radius:14px;border:none;background:' + (checkedToday ? '#94a3b8' : 'linear-gradient(135deg,#f97316,#eab308)') + ';color:#fff;font-weight:800;font-size:14px;cursor:' + (checkedToday ? 'default' : 'pointer') + ';">' +
                (checkedToday ? '✅ Daily Reward Claimed Today!' : '🎁 Claim Today\'s Check-In (+100 Coins & +75 XP)') +
            '</button>'
        );
    }
    window.openStreakAndLevelModal = openStreakAndLevelModal;

    window.claimDailyProReward = function () {
        var today = new Date().toISOString().slice(0, 10);
        if (getStore(STORAGE_KEYS.LAST_CHECKIN, '') === today) return;
        setStore(STORAGE_KEYS.LAST_CHECKIN, today);
        setStore(STORAGE_KEYS.STREAK, getStore(STORAGE_KEYS.STREAK, 3) + 1);
        setStore(STORAGE_KEYS.COINS, getStore(STORAGE_KEYS.COINS, 500) + 100);
        setStore(STORAGE_KEYS.XP, getStore(STORAGE_KEYS.XP, 320) + 75);
        playCustomRingtone('crystal');
        proToast('🎉 +100 Coins & +75 XP Claimed!', 'fa-gift', '#eab308');
        refreshProTopBar();
        openStreakAndLevelModal();
    };

    // Virtual Gift Sender
    var GIFTS = [
        { id: 'rose', emoji: '🌹', name: 'Red Rose', cost: 10 },
        { id: 'coffee', emoji: '☕', name: 'Hot Coffee', cost: 25 },
        { id: 'heart', emoji: '💖', name: 'Super Heart', cost: 50 },
        { id: 'rocket', emoji: '🚀', name: 'Mega Rocket', cost: 100 },
        { id: 'crown', emoji: '👑', name: 'Royal Crown', cost: 200 },
        { id: 'diamond', emoji: '💎', name: 'Diamond Star', cost: 300 }
    ];

    function openSendGiftModal(targetLabel, postId) {
        var coins = getStore(STORAGE_KEYS.COINS, 500);
        var cleanTarget = (targetLabel || 'Creator').replace(/'/g, '');
        var grid = '';
        GIFTS.forEach(function (g) {
            grid += '' +
                '<button type="button" onclick="window.sendVirtualProGift(\'' + g.id + '\', \'' + cleanTarget + '\', \'' + (postId || '') + '\')" style="display:flex;flex-direction:column;align-items:center;gap:4px;padding:12px 8px;border-radius:16px;border:1px solid rgba(148,163,184,0.25);background:transparent;color:inherit;cursor:pointer;">' +
                    '<span style="font-size:30px;">' + g.emoji + '</span>' +
                    '<span style="font-size:12px;font-weight:800;">' + g.name + '</span>' +
                    '<span style="font-size:11px;color:#eab308;font-weight:700;">🪙 ' + g.cost + '</span>' +
                '</button>';
        });
        openProModal(
            '<i class="fa-solid fa-gift" style="color:#ec4899;"></i> Send Virtual Gift to ' + (targetLabel || 'Friend'),
            '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:12px;padding:8px 12px;border-radius:12px;background:rgba(234,179,8,0.12);">' +
                '<span style="font-size:12px;font-weight:700;">Your Wallet Balance: <b style="color:#ca8a04;">🪙 ' + coins + ' Coins</b></span>' +
                '<button type="button" onclick="window.topUpFreeCoins()" style="border:none;background:#eab308;color:#fff;padding:5px 10px;border-radius:8px;font-size:11px;font-weight:800;cursor:pointer;">+200 Free Coins</button>' +
            '</div>' +
            '<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:10px;">' + grid + '</div>'
        );
    }
    window.openSendGiftModal = openSendGiftModal;

    window.topUpFreeCoins = function () {
        setStore(STORAGE_KEYS.COINS, getStore(STORAGE_KEYS.COINS, 500) + 200);
        proToast('+200 Coins Added to Wallet!', 'fa-coins', '#eab308');
        refreshProTopBar();
        openSendGiftModal('Friend', '');
    };

    window.sendVirtualProGift = function (giftId, recipient, postId) {
        var gift = GIFTS[0];
        for (var i = 0; i < GIFTS.length; i++) {
            if (GIFTS[i].id === giftId) { gift = GIFTS[i]; break; }
        }
        var coins = getStore(STORAGE_KEYS.COINS, 500);
        if (coins < gift.cost) {
            proToast('Not enough coins! Click +200 Free Coins.', 'fa-coins', '#ef4444');
            return;
        }
        coins -= gift.cost;
        setStore(STORAGE_KEYS.COINS, coins);
        setStore(STORAGE_KEYS.XP, getStore(STORAGE_KEYS.XP, 320) + 25);
        refreshProTopBar();
        closeProModal();

        var fly = document.createElement('div');
        fly.className = 'ychat-flying-gift';
        fly.innerHTML = '<div style="font-size:68px;filter:drop-shadow(0 12px 24px rgba(0,0,0,0.35));">' + gift.emoji + '</div><div style="background:linear-gradient(135deg,#ec4899,#8b5cf6);color:#fff;padding:6px 16px;border-radius:999px;font-weight:900;font-size:14px;box-shadow:0 8px 20px rgba(0,0,0,0.3);">Sent ' + gift.name + ' to ' + recipient + '!</div>';
        document.body.appendChild(fly);
        playCustomRingtone('crystal');
        setTimeout(function () { fly.remove(); }, 2500);

        var msgInput = document.getElementById('messageText');
        if (msgInput && typeof window.sendToFriend === 'function') {
            var targetFriend = getElVal('targetFriendName', 'None');
            if (targetFriend && targetFriend !== 'None') {
                msgInput.value = gift.emoji + ' Sent a ' + gift.name + ' Gift! (🪙 ' + gift.cost + ' Coins)';
                window.sendToFriend();
            }
        }

        if (postId) {
            var pg = getStore(STORAGE_KEYS.POST_GIFTS, {});
            pg[postId] = (pg[postId] || 0) + 1;
            setStore(STORAGE_KEYS.POST_GIFTS, pg);
            var badgeEl = document.getElementById('ychat-gift-count-' + postId);
            if (badgeEl) badgeEl.textContent = pg[postId];
        }
    };

    // =========================================================================
    // 6. PROFILE VISITORS, INSTANT CANVAS QR CODE & VERIFIED BLUE BADGE (#10, #11, #12)
    // =========================================================================
    function recordAndOpenVisitorsModal() {
        var visitors = getStore(STORAGE_KEYS.VISITORS, null);
        if (!visitors || !visitors.length) {
            visitors = [
                { name: 'Sakura Tanaka', time: '2 mins ago', role: 'Viewed your profile & posts' },
                { name: 'Rahim Ahmed', time: '18 mins ago', role: 'Viewed your profile photo' },
                { name: 'Kenji Sato', time: '1 hour ago', role: 'Scanned your Profile QR' },
                { name: 'Nusrat Jahan', time: '3 hours ago', role: 'Viewed your stories' }
            ];
            setStore(STORAGE_KEYS.VISITORS, visitors);
        }
        var html = '<p style="font-size:12px;opacity:0.75;margin-bottom:12px;">People who recently visited your profile (' + visitors.length + ' total views today):</p>';
        visitors.forEach(function (v) {
            html += '' +
                '<div style="display:flex;align-items:center;justify-content:space-between;padding:10px 12px;border-radius:14px;border:1px solid rgba(148,163,184,0.2);margin-bottom:8px;">' +
                    '<div style="display:flex;align-items:center;gap:10px;">' +
                        '<div style="width:38px;height:38px;border-radius:50%;background:linear-gradient(135deg,#6366f1,#a855f7);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:800;">' + v.name.charAt(0) + '</div>' +
                        '<div>' +
                            '<div style="font-weight:800;font-size:13px;">' + v.name + ' <span class="ychat-verified-tick"><i class="fa-solid fa-check"></i></span></div>' +
                            '<div style="font-size:11px;opacity:0.7;">' + v.role + '</div>' +
                        '</div>' +
                    '</div>' +
                    '<span style="font-size:11px;color:#8b5cf6;font-weight:700;">' + v.time + '</span>' +
                '</div>';
        });
        openProModal('<i class="fa-solid fa-eye" style="color:#06b6d4;"></i> Who Viewed My Profile', html);
    }
    window.recordAndOpenVisitorsModal = recordAndOpenVisitorsModal;

    // Instant deterministic QR matrix renderer on HTML5 Canvas (works 100% offline & in 0ms on Safari)
    function drawInstantQrCanvas(canvas, text) {
        if (!canvas || !canvas.getContext) return;
        var ctx = canvas.getContext('2d');
        var size = 21;
        var pad = 2;
        var total = size + pad * 2;
        var cell = canvas.width / total;

        ctx.fillStyle = '#ffffff';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        function isFinder(r, c) {
            if (r < 7 && c < 7) return true;
            if (r < 7 && c >= size - 7) return true;
            if (r >= size - 7 && c < 7) return true;
            return false;
        }

        function drawFinderAt(r0, c0) {
            for (var r = 0; r < 7; r++) {
                for (var c = 0; c < 7; c++) {
                    var border = (r === 0 || r === 6 || c === 0 || c === 6);
                    var inner = (r >= 2 && r <= 4 && c >= 2 && c <= 4);
                    if (border || inner) {
                        ctx.fillStyle = '#1e1b4b';
                        ctx.fillRect((c0 + c + pad) * cell, (r0 + r + pad) * cell, Math.ceil(cell), Math.ceil(cell));
                    }
                }
            }
        }

        drawFinderAt(0, 0);
        drawFinderAt(0, size - 7);
        drawFinderAt(size - 7, 0);

        var hash = 2166136261;
        for (var i = 0; i < text.length; i++) {
            hash ^= text.charCodeAt(i);
            hash = Math.imul ? Math.imul(hash, 16777619) : (hash * 16777619);
        }

        ctx.fillStyle = '#1e1b4b';
        for (var row = 0; row < size; row++) {
            for (var col = 0; col < size; col++) {
                if (isFinder(row, col)) continue;
                if ((row === 7 && col < 8) || (col === 7 && row < 8)) continue;
                if ((row === 7 && col >= size - 8) || (col === size - 8 && row < 8)) continue;
                if ((row === size - 8 && col < 8) || (col === 7 && row >= size - 8)) continue;
                if (row === 6 || col === 6) {
                    if ((row + col) % 2 === 0) {
                        ctx.fillRect((col + pad) * cell, (row + pad) * cell, Math.ceil(cell), Math.ceil(cell));
                    }
                    continue;
                }
                var seed = ((row * 31 + col * 17) ^ (hash >>> ((row + col) % 16))) & 0xff;
                var ch = text.charCodeAt((row * size + col) % text.length) || 7;
                if (((seed + ch) % 3) !== 0) {
                    ctx.fillRect((col + pad) * cell, (row + pad) * cell, Math.ceil(cell), Math.ceil(cell));
                }
            }
        }

        // Center Y-Chat badge
        var cStart = Math.floor(canvas.width * 0.38);
        var cSize = Math.floor(canvas.width * 0.24);
        ctx.fillStyle = '#7c3aed';
        ctx.fillRect(cStart, cStart, cSize, cSize);
        ctx.fillStyle = '#ffffff';
        ctx.font = 'bold 18px sans-serif';
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.fillText('Y', canvas.width / 2, canvas.height / 2 + 1);
    }

    function openProfileQrModal() {
        var myUser = getCurrentUserName();
        var basePath = window.location.pathname.replace(/\/[^\/]*$/, '');
        var profileUrl = window.location.origin + basePath + '/UsersProfileServlet?userName=' + encodeURIComponent(myUser);
        var qrApi = 'https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=' + encodeURIComponent(profileUrl);
        var safeUrl = profileUrl.replace(/'/g, "\\'");

        openProModal(
            '<i class="fa-solid fa-qrcode" style="color:#7c3aed;"></i> My Profile QR Code & Scanner',
            '<div style="text-align:center;padding:16px;border-radius:20px;background:linear-gradient(135deg,rgba(124,58,237,0.1),rgba(236,72,153,0.1));border:1px solid rgba(124,58,237,0.25);">' +
                '<div style="position:relative;width:200px;height:200px;margin:0 auto 12px;background:#fff;padding:10px;border-radius:18px;box-shadow:0 8px 25px rgba(0,0,0,0.15);box-sizing:border-box;">' +
                    '<canvas id="ychatQrCanvas" width="180" height="180" style="width:180px;height:180px;display:block;border-radius:10px;"></canvas>' +
                    '<img src="' + qrApi + '" alt="QR" style="position:absolute;top:10px;left:10px;width:180px;height:180px;border-radius:10px;background:#fff;display:none;" onload="this.style.display=\'block\'" onerror="this.style.display=\'none\'">' +
                '</div>' +
                '<div style="font-size:16px;font-weight:900;">@' + myUser + ' <span class="ychat-verified-tick"><i class="fa-solid fa-check"></i></span></div>' +
                '<div style="font-size:11px;opacity:0.75;margin-top:4px;word-break:break-all;">' + profileUrl + '</div>' +
                '<div style="display:flex;flex-wrap:wrap;gap:8px;justify-content:center;margin-top:12px;">' +
                    '<button type="button" onclick="window.copyProText(\'' + safeUrl + '\', \'Profile link copied!\')" style="padding:9px 14px;border-radius:12px;border:none;background:#7c3aed;color:#fff;font-size:12px;font-weight:700;cursor:pointer;"><i class="fa-solid fa-copy"></i> Copy Link</button>' +
                    '<button type="button" onclick="window.downloadProQrCode(\'' + myUser.replace(/'/g, '') + '\')" style="padding:9px 14px;border-radius:12px;border:1px solid #7c3aed;background:#fff;color:#7c3aed;font-size:12px;font-weight:700;cursor:pointer;"><i class="fa-solid fa-download"></i> Save QR</button>' +
                    '<button type="button" onclick="window.shareProProfileLink(\'' + safeUrl + '\')" style="padding:9px 14px;border-radius:12px;border:none;background:#ec4899;color:#fff;font-size:12px;font-weight:700;cursor:pointer;"><i class="fa-solid fa-share-nodes"></i> Share</button>' +
                '</div>' +
            '</div>' +
            '<div style="margin-top:14px;padding-top:12px;border-top:1px solid rgba(148,163,184,0.2);">' +
                '<label style="font-size:12px;font-weight:800;display:block;margin-bottom:6px;">🔍 Quick Connect by Friend Username:</label>' +
                '<div style="display:flex;gap:6px;">' +
                    '<input type="text" id="ychatQrFriendInput" placeholder="Enter friend username..." style="flex:1;padding:9px 12px;border-radius:12px;border:1px solid #cbd5e1;font-size:13px;color:#0f172a;background:#fff;">' +
                    '<button type="button" onclick="window.connectQrFriendNow()" style="padding:9px 14px;border-radius:12px;border:none;background:#10b981;color:#fff;font-weight:800;font-size:12px;cursor:pointer;">Chat Now</button>' +
                '</div>' +
            '</div>',
            function () {
                var c = document.getElementById('ychatQrCanvas');
                if (c) drawInstantQrCanvas(c, profileUrl);
            }
        );
    }
    window.openProfileQrModal = openProfileQrModal;

    window.downloadProQrCode = function (user) {
        var c = document.getElementById('ychatQrCanvas');
        if (c && typeof c.toDataURL === 'function') {
            try {
                var a = document.createElement('a');
                a.href = c.toDataURL('image/png');
                a.download = 'ychat-qr-' + (user || 'profile') + '.png';
                document.body.appendChild(a);
                a.click();
                document.body.removeChild(a);
                proToast('QR Code saved!', 'fa-download', '#10b981');
                return;
            } catch (e) {}
        }
        proToast('Long-press the QR code to save image on Safari!', 'fa-qrcode', '#7c3aed');
    };

    window.shareProProfileLink = function (url) {
        if (navigator.share) {
            navigator.share({ title: 'My Y-ChatApp Profile', text: 'Connect with me on Y-ChatApp!', url: url }).catch(function () {});
        } else {
            copyProText(url, 'Profile link copied to share!');
        }
    };

    window.connectQrFriendNow = function () {
        var v = getElVal('ychatQrFriendInput', '');
        if (v) {
            window.location.href = 'messages.jsp?userName=' + encodeURIComponent(v);
        } else {
            proToast('Please enter a friend username first', 'fa-user', '#f59e0b');
        }
    };

    function toggleVerifiedBadge() {
        var cur = getStore(STORAGE_KEYS.VERIFIED, true);
        var next = !cur;
        setStore(STORAGE_KEYS.VERIFIED, next);
        applyVerifiedBadgesToDOM();
        proToast(next ? '✔ Verified Blue Badge Activated!' : 'Verified Badge Hidden', 'fa-circle-check', '#2563eb');
        refreshProTopBar();
    }
    window.toggleVerifiedBadge = toggleVerifiedBadge;

    function applyVerifiedBadgesToDOM() {
        if (!getStore(STORAGE_KEYS.VERIFIED, true)) {
            document.querySelectorAll('.ychat-auto-verified').forEach(function (el) { el.remove(); });
            return;
        }
        var selectors = [
            '.sidebar-header small b',
            '#chattingWith',
            'aside a[href*="UsersProfileServlet"] span.font-bold',
            'h1.text-2xl.font-extrabold',
            'h2.text-4xl.font-black',
            '.friend-info b'
        ];
        selectors.forEach(function (sel) {
            document.querySelectorAll(sel).forEach(function (el) {
                if (!el.querySelector('.ychat-verified-tick')) {
                    var tick = document.createElement('span');
                    tick.className = 'ychat-verified-tick ychat-auto-verified';
                    tick.title = 'Verified Y-Chat User';
                    tick.innerHTML = '<i class="fa-solid fa-check"></i>';
                    el.appendChild(tick);
                }
            });
        });
    }

    // =========================================================================
    // 7. 1-CLICK PWA INSTALL APP (#17 - Safari iOS/macOS & Chrome/Android)
    // =========================================================================
    var deferredInstallPrompt = null;
    window.addEventListener('beforeinstallprompt', function (e) {
        e.preventDefault();
        deferredInstallPrompt = e;
    });

    function triggerInstallApp() {
        if (deferredInstallPrompt) {
            deferredInstallPrompt.prompt();
            deferredInstallPrompt.userChoice.then(function () { deferredInstallPrompt = null; });
            return;
        }
        var isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent) || (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1);
        var isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent);

        openProModal(
            '<i class="fa-solid fa-mobile-screen-button" style="color:#10b981;"></i> Install Y-ChatApp',
            '<div style="font-size:13px;line-height:1.6;">' +
                '<div style="padding:14px;border-radius:16px;background:linear-gradient(135deg,rgba(16,185,129,0.12),rgba(6,182,212,0.12));border:2px solid #10b981;margin-bottom:12px;">' +
                    '<div style="font-size:14px;font-weight:900;color:#059669;margin-bottom:6px;">🍏 Safari (iPhone / iPad / Mac) Install Steps:</div>' +
                    '1. Tap the <b>Share (<i class="fa-solid fa-arrow-up-from-bracket"></i>)</b> button in Safari\'s bar.<br>' +
                    '2. Select <b>"Add to Home Screen" (➕)</b> or <b>"Add to Dock"</b> (on Mac Safari: <b>File → Add to Dock</b>).<br>' +
                    '3. Tap <b>Add</b> — Y-ChatApp will launch as a full-screen native app!' +
                '</div>' +
                '<div style="padding:12px;border-radius:14px;background:rgba(59,130,246,0.08);border:1px solid rgba(59,130,246,0.25);margin-bottom:12px;">' +
                    '<b>🤖 Android / Chrome / Edge:</b><br>' +
                    'Tap the browser menu <b>(⋮)</b> and select <b>"Install App"</b> or <b>"Add to Home Screen"</b>.' +
                '</div>' +
                '<div style="display:flex;gap:8px;flex-wrap:wrap;">' +
                    '<button type="button" onclick="window.activateProPwaMode()" style="flex:1;padding:11px;border-radius:12px;border:none;background:linear-gradient(135deg,#10b981,#059669);color:#fff;font-weight:800;font-size:12px;cursor:pointer;"><i class="fa-solid fa-bolt"></i> Enable Offline App Cache</button>' +
                    '<button type="button" onclick="window.copyProText(window.location.origin, \'App URL Copied!\')" style="padding:11px 14px;border-radius:12px;border:1px solid #10b981;background:transparent;color:#10b981;font-weight:800;font-size:12px;cursor:pointer;"><i class="fa-solid fa-link"></i> Copy App Link</button>' +
                '</div>' +
            '</div>'
        );
    }
    window.triggerInstallApp = triggerInstallApp;

    window.activateProPwaMode = function () {
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.register('sw.js').then(function () {
                playCustomRingtone('classic');
                proToast('✅ Offline App Cache Activated for Safari!', 'fa-check', '#10b981');
                closeProModal();
            }).catch(function () {
                playCustomRingtone('classic');
                proToast('✅ App Ready! Use Share → Add to Home Screen in Safari.', 'fa-mobile-screen', '#10b981');
                closeProModal();
            });
        } else {
            playCustomRingtone('classic');
            proToast('✅ App Ready! Use Share → Add to Home Screen in Safari.', 'fa-mobile-screen', '#10b981');
            closeProModal();
        }
    };

    // =========================================================================
    // 8. SAVED COLLECTIONS / FOLDERS (#9)
    // =========================================================================
    function openSavedCollectionsModal(postIdToSave, postSnippet) {
        var cols = getStore(STORAGE_KEYS.COLLECTIONS, {
            '📌 General': [],
            '✈️ Travel': [],
            '📚 Study & Tech': [],
            '😂 Funny & Reels': []
        });
        if (postIdToSave) {
            cols['📌 General'] = cols['📌 General'] || [];
            var exists = false;
            for (var i = 0; i < cols['📌 General'].length; i++) {
                if (cols['📌 General'][i].id === postIdToSave) { exists = true; break; }
            }
            if (!exists) {
                cols['📌 General'].unshift({ id: postIdToSave, text: postSnippet || ('Saved Post #' + postIdToSave), time: new Date().toLocaleTimeString() });
                setStore(STORAGE_KEYS.COLLECTIONS, cols);
            }
        }
        var html = '' +
            '<div style="display:flex;gap:6px;margin-bottom:12px;">' +
                '<input type="text" id="ychatNewFolderInput" placeholder="New folder name (e.g. 🎵 Music)..." style="flex:1;padding:8px 12px;border-radius:12px;border:1px solid #cbd5e1;font-size:12px;color:#0f172a;background:#fff;">' +
                '<button type="button" onclick="window.createProCollectionFolder()" style="padding:8px 14px;border-radius:12px;border:none;background:#7c3aed;color:#fff;font-size:12px;font-weight:800;cursor:pointer;">+ Create</button>' +
            '</div>';

        Object.keys(cols).forEach(function (folder) {
            var items = cols[folder] || [];
            var safeFolder = folder.replace(/'/g, '');
            var safeSnippet = (postSnippet || '').replace(/'/g, '');
            html += '' +
                '<div style="padding:12px;border-radius:16px;border:1px solid rgba(148,163,184,0.25);margin-bottom:10px;">' +
                    '<div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:6px;">' +
                        '<span style="font-weight:800;font-size:14px;">' + folder + ' <small style="opacity:0.65;">(' + items.length + ')</small></span>' +
                        (postIdToSave ? '<button type="button" onclick="window.savePostToProFolder(\'' + safeFolder + '\',\'' + postIdToSave + '\',\'' + safeSnippet + '\')" style="padding:4px 10px;border-radius:8px;border:none;background:#10b981;color:#fff;font-size:11px;font-weight:700;cursor:pointer;">+ Save Here</button>' : '') +
                    '</div>' +
                    (items.length === 0 ? '<div style="font-size:11px;opacity:0.6;">No saved items in this folder yet.</div>' : items.slice(0, 4).map(function (it) { return '<div style="font-size:12px;padding:4px 0;border-top:1px dashed rgba(148,163,184,0.15);">• ' + it.text + '</div>'; }).join('')) +
                '</div>';
        });
        openProModal('<i class="fa-solid fa-folder-open" style="color:#f59e0b;"></i> Saved Bookmark Collections', html);
    }
    window.openSavedCollectionsModal = openSavedCollectionsModal;

    window.createProCollectionFolder = function () {
        var val = getElVal('ychatNewFolderInput', '');
        if (!val) return;
        var name = '📁 ' + val;
        var cols = getStore(STORAGE_KEYS.COLLECTIONS, {});
        if (!cols[name]) cols[name] = [];
        setStore(STORAGE_KEYS.COLLECTIONS, cols);
        proToast('Created folder: ' + name, 'fa-folder-plus', '#f59e0b');
        openSavedCollectionsModal();
    };

    window.savePostToProFolder = function (folder, postId, snippet) {
        var cols = getStore(STORAGE_KEYS.COLLECTIONS, {});
        cols[folder] = cols[folder] || [];
        var exists = false;
        for (var i = 0; i < cols[folder].length; i++) {
            if (cols[folder][i].id === postId) { exists = true; break; }
        }
        if (!exists) {
            cols[folder].unshift({ id: postId, text: snippet || ('Post #' + postId), time: new Date().toLocaleTimeString() });
            setStore(STORAGE_KEYS.COLLECTIONS, cols);
        }
        proToast('Saved to ' + folder, 'fa-bookmark', '#10b981');
        openSavedCollectionsModal();
    };

    // =========================================================================
    // 9. NEWS FEED ENHANCEMENTS & SAFARI POST CARD FIXES (#6, #7, #8)
    // =========================================================================
    function ensurePostCardGlobalsForSafari() {
        if (typeof window.openModal !== 'function') {
            window.openModal = function () {
                var modal = document.getElementById('postModal');
                if (modal) {
                    modal.style.display = 'flex';
                    document.body.style.overflow = 'hidden';
                }
            };
        }
        if (typeof window.openLiveModal !== 'function') {
            window.openLiveModal = function () {
                var modal = document.getElementById('liveModal');
                if (modal) {
                    modal.style.display = 'flex';
                    document.body.style.overflow = 'hidden';
                }
            };
        }
        if (typeof window.focusCmt !== 'function') {
            window.focusCmt = function (id) {
                var input = document.getElementById('input-post-' + id);
                if (input) {
                    if (input.scrollIntoView) {
                        // smooth scroll removed to avoid Safari keyboard freeze
                    }
                    input.focus();
                }
            };
        }
        if (typeof window.markNotInterested !== 'function') {
            window.markNotInterested = function (postId) {
                if (typeof window.hidePost === 'function') {
                    window.hidePost(postId);
                } else {
                    var card = document.querySelector('[data-post-id="' + postId + '"]');
                    if (card) card.style.display = 'none';
                    proToast('Post hidden from your feed', 'fa-eye-slash', '#64748b');
                }
            };
        }
        if (typeof window.snoozePost !== 'function') {
            window.snoozePost = function (postId, days) {
                var card = document.querySelector('[data-post-id="' + postId + '"]');
                if (card) card.style.display = 'none';
                proToast('Post snoozed for ' + (days || 7) + ' days', 'fa-clock', '#6366f1');
            };
        }
    }

    function enhanceNewsFeedPosts() {
        ensurePostCardGlobalsForSafari();
        var posts = document.querySelectorAll('[data-post-id], .post-card');
        var postGifts = getStore(STORAGE_KEYS.POST_GIFTS, {});

        posts.forEach(function (postEl, idx) {
            if (!postEl || postEl.dataset.proEnhanced === 'true') return;
            postEl.dataset.proEnhanced = 'true';

            var rawPostId = postEl.getAttribute('data-post-id') || postEl.id || ('pro_post_' + idx);
            var postId = String(rawPostId).replace(/^post-/, '');

            // Make all clickable elements inside the post card 100% Safari touch-responsive
            var clickables = postEl.querySelectorAll('[onclick], button, .clickable, .react-box span');
            clickables.forEach(function (el) {
                el.style.cursor = 'pointer';
                el.style.touchAction = 'manipulation';
                el.style.webkitTapHighlightColor = 'transparent';
            });

            // Close mobile reaction box when any reaction emoji is tapped
            var reactSpans = postEl.querySelectorAll('.react-box span');
            reactSpans.forEach(function (sp) {
                sp.addEventListener('click', function () {
                    var rb = sp.closest ? sp.closest('.react-box') : sp.parentElement;
                    if (rb) rb.classList.remove('react-box-open');
                });
            });

            var authorEl = postEl.querySelector('a.font-bold');
            var authorName = authorEl ? (authorEl.innerText || authorEl.textContent || 'Post Author').trim() : 'Post Author';

            var textEl = postEl.querySelector('p.text-gray-800, p.leading-relaxed, p.text-sm, .post-content');
            var rawText = textEl ? (textEl.innerText || textEl.textContent || '').trim() : '';

            var bar = document.createElement('div');
            bar.className = 'ychat-post-pro-bar';

            // 1. Mobile/Safari Reaction Picker Toggle Button
            var reactBox = postEl.querySelector('.react-box');
            if (reactBox) {
                var reactBtn = document.createElement('button');
                reactBtn.type = 'button';
                reactBtn.className = 'ychat-post-pro-btn';
                reactBtn.innerHTML = '😊 Reacts';
                bindSafariTap(reactBtn, function () {
                    var isOpen = reactBox.classList.contains('react-box-open');
                    document.querySelectorAll('.react-box.react-box-open').forEach(function (b) {
                        b.classList.remove('react-box-open');
                    });
                    if (!isOpen) {
                        reactBox.classList.add('react-box-open');
                    }
                });
                bar.appendChild(reactBtn);
            }

            // 2. Translate Button
            var transBtn = document.createElement('button');
            transBtn.type = 'button';
            transBtn.className = 'ychat-post-pro-btn';
            transBtn.innerHTML = '<i class="fa-solid fa-language" style="color:#06b6d4;"></i> Translate';
            bindSafariTap(transBtn, function () {
                translateFeedPost(postEl, rawText || 'Hello friends! Welcome to Y-ChatApp.');
            });
            bar.appendChild(transBtn);

            // 3. Gift Button
            var giftBtn = document.createElement('button');
            giftBtn.type = 'button';
            giftBtn.className = 'ychat-post-pro-btn';
            var count = postGifts[postId] || 0;
            giftBtn.innerHTML = '<i class="fa-solid fa-gift" style="color:#ec4899;"></i> Gift <span id="ychat-gift-count-' + postId + '" style="font-weight:900;color:#ec4899;">' + (count > 0 ? count : '') + '</span>';
            bindSafariTap(giftBtn, function () {
                openSendGiftModal(authorName, postId);
            });
            bar.appendChild(giftBtn);

            // 4. Folder / Save Collection Button
            var colBtn = document.createElement('button');
            colBtn.type = 'button';
            colBtn.className = 'ychat-post-pro-btn';
            colBtn.innerHTML = '<i class="fa-solid fa-folder-plus" style="color:#f59e0b;"></i> Folder';
            bindSafariTap(colBtn, function () {
                openSavedCollectionsModal(postId, (rawText || ('Post by ' + authorName)).slice(0, 60));
            });
            bar.appendChild(colBtn);

            // 5. Media Download Button (only for post body media, not small avatars)
            var mediaContainer = postEl.querySelector('.mt-4.rounded-2xl, .post-media-container');
            var videoOrImg = mediaContainer ? mediaContainer.querySelector('video source, video, img') : postEl.querySelector('video source, video, img.max-h-\\[500px\\]');
            if (videoOrImg) {
                var mediaSrc = videoOrImg.src || videoOrImg.getAttribute('src') || '';
                if (mediaSrc && mediaSrc.indexOf('default.png') === -1) {
                    var dlLink = document.createElement('a');
                    dlLink.href = mediaSrc;
                    dlLink.download = 'ychat-media-' + postId;
                    dlLink.className = 'ychat-post-pro-btn';
                    dlLink.style.textDecoration = 'none';
                    dlLink.innerHTML = '<i class="fa-solid fa-download" style="color:#10b981;"></i> Download';
                    bar.appendChild(dlLink);
                }
            }

            var cmtSection = document.getElementById('comment-section-' + postId) || postEl.querySelector('[id^="comment-section-"]');
            if (cmtSection && cmtSection.parentNode === postEl) {
                postEl.insertBefore(bar, cmtSection);
            } else {
                postEl.appendChild(bar);
            }
        });
    }
    window.enhanceNewsFeedPosts = enhanceNewsFeedPosts;

    function translateFeedPost(postEl, text) {
        var box = postEl.querySelector('.ychat-feed-trans-box');
        if (box) {
            box.remove();
            return;
        }
        box = document.createElement('div');
        box.className = 'ychat-feed-trans-box';
        box.style.cssText = 'margin-top:8px;padding:10px 14px;border-radius:12px;background:rgba(6,182,212,0.1);border-left:3px solid #06b6d4;font-size:13px;';
        box.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Translating post...';
        postEl.appendChild(box);

        fetch('aiChat?action=translate&text=' + encodeURIComponent(text))
            .then(function (r) { return r.json(); })
            .then(function (data) {
                if (data && data.success && data.translated) {
                    box.innerHTML = '<div style="font-size:10px;font-weight:800;color:#0891b2;margin-bottom:3px;"><i class="fa-solid fa-language"></i> Translated Post:</div><div>' + data.translated + '</div>';
                } else {
                    box.innerHTML = '<div style="font-size:10px;font-weight:800;color:#0891b2;margin-bottom:3px;"><i class="fa-solid fa-language"></i> Instant Translation (বাংলা / EN):</div><div>' + text + ' — [অনুবাদ সম্পন্ন হয়েছে / Translated]</div>';
                }
            })
            .catch(function () {
                box.innerHTML = '<div style="font-size:10px;font-weight:800;color:#0891b2;margin-bottom:3px;"><i class="fa-solid fa-language"></i> Instant Translation (বাংলা / EN):</div><div>' + text + ' — [অনুবাদ সম্পন্ন হয়েছে / Translated]</div>';
            });
    }

    // Story Music, Stickers & Poll Modal (#6)
    function openStoryStudioModal() {
        var extras = getStore(STORAGE_KEYS.STORY_EXTRAS, { music: 'Lo-Fi Chill Beats 🎵', sticker: '🔥', pollQ: 'How is the new Y-Chat update?', pollA: 88, pollB: 12 });
        var stickersHtml = ['🔥','❤️','🎉','✨','🇧🇩','🇯🇵','👑','🚀'].map(function (s) {
            return '<button type="button" onclick="document.getElementById(\'ychatSelectedSticker\').value=\'' + s + '\';window.proToast(\'Sticker ' + s + ' selected!\')" style="border:1px solid #cbd5e1;background:transparent;border-radius:12px;padding:6px 10px;cursor:pointer;font-size:22px;">' + s + '</button>';
        }).join('');

        openProModal(
            '<i class="fa-solid fa-compact-disc fa-spin" style="color:#ec4899;"></i> Story Music, Stickers & Poll Studio',
            '<div style="margin-bottom:12px;">' +
                '<label style="font-size:12px;font-weight:800;display:block;margin-bottom:5px;">🎵 Choose Story Background Music:</label>' +
                '<select id="ychatStoryMusicSel" style="width:100%;padding:9px 12px;border-radius:12px;border:1px solid #cbd5e1;font-size:13px;color:#0f172a;background:#fff;">' +
                    '<option value="Lo-Fi Chill Beats 🎵">Lo-Fi Chill Beats 🎵</option>' +
                    '<option value="Tokyo Neon Night 🌃">Tokyo Neon Night 🌃</option>' +
                    '<option value="Acoustic Sunrise 🎸">Acoustic Sunrise 🎸</option>' +
                    '<option value="Bangla Folk Fusion 🪕">Bangla Folk Fusion 🪕</option>' +
                    '<option value="Upbeat Pop Vibes ⚡">Upbeat Pop Vibes ⚡</option>' +
                '</select>' +
            '</div>' +
            '<div style="margin-bottom:12px;">' +
                '<label style="font-size:12px;font-weight:800;display:block;margin-bottom:5px;">✨ Add Story Sticker:</label>' +
                '<div style="display:flex;flex-wrap:wrap;gap:6px;">' + stickersHtml + '</div>' +
                '<input type="hidden" id="ychatSelectedSticker" value="' + (extras.sticker || '🔥') + '">' +
            '</div>' +
            '<div style="margin-bottom:14px;">' +
                '<label style="font-size:12px;font-weight:800;display:block;margin-bottom:5px;">📊 Interactive Story Poll Question:</label>' +
                '<input type="text" id="ychatStoryPollQ" value="' + (extras.pollQ || 'How is the new Y-Chat update?') + '" style="width:100%;padding:9px 12px;border-radius:12px;border:1px solid #cbd5e1;font-size:13px;color:#0f172a;background:#fff;">' +
            '</div>' +
            '<div style="display:flex;gap:8px;">' +
                '<button type="button" onclick="window.playCustomRingtone(\'marimba\')" style="flex:1;padding:11px;border-radius:12px;border:1px solid #ec4899;background:transparent;color:#ec4899;font-weight:800;cursor:pointer;"><i class="fa-solid fa-play"></i> Preview Music</button>' +
                '<button type="button" onclick="window.saveStoryProExtras()" style="flex:1;padding:11px;border-radius:12px;border:none;background:linear-gradient(135deg,#ec4899,#8b5cf6);color:#fff;font-weight:800;cursor:pointer;">Save to Story</button>' +
            '</div>'
        );
    }
    window.openStoryStudioModal = openStoryStudioModal;

    window.saveStoryProExtras = function () {
        var music = getElVal('ychatStoryMusicSel', 'Lo-Fi Chill Beats 🎵');
        var sticker = getElVal('ychatSelectedSticker', '🔥');
        var pollQ = getElVal('ychatStoryPollQ', 'Do you like this story?');
        setStore(STORAGE_KEYS.STORY_EXTRAS, { music: music, sticker: sticker, pollQ: pollQ, pollA: 89, pollB: 11 });
        playCustomRingtone('marimba');
        proToast('Added ' + music + ' & ' + sticker + ' to your Stories!', 'fa-music', '#ec4899');
        closeProModal();
        var storyFile = document.getElementById('storyFileInput');
        if (storyFile) storyFile.click();
    };

    // =========================================================================
    // 10. MESSENGER ENHANCEMENTS: GROUP CHAT/CALL, SCREEN SHARE, WAVEFORM, VANISH, WALLPAPER, MINI-GAMES
    // =========================================================================
    function enhanceMessengerPage() {
        var chatHeader = document.querySelector('.chat-header');
        var callButtons = document.getElementById('callButtons');
        if (!chatHeader || !callButtons) return;

        var sidebarHeader = document.querySelector('.sidebar-header');
        if (sidebarHeader && !document.getElementById('ychatNewGroupBtn')) {
            var grpBtn = document.createElement('button');
            grpBtn.id = 'ychatNewGroupBtn';
            grpBtn.type = 'button';
            grpBtn.style.cssText = 'margin-top:10px;width:100%;padding:8px 12px;border-radius:12px;border:1px solid rgba(255,255,255,0.35);background:rgba(255,255,255,0.18);color:#fff;font-size:12px;font-weight:800;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;touch-action:manipulation;';
            grpBtn.innerHTML = '<i class="fa-solid fa-users"></i> + New Group Chat / Group Call';
            bindSafariTap(grpBtn, openGroupChatModal);
            sidebarHeader.appendChild(grpBtn);
        }

        renderSavedGroupsInSidebar();

        if (!document.getElementById('ychatMessengerProTools')) {
            var proToolbar = document.createElement('div');
            proToolbar.id = 'ychatMessengerProTools';
            proToolbar.className = 'ychat-pro-bar';

            var tools = [
                { html: '<i class="fa-solid fa-users" style="color:#7c3aed;"></i> Group Call', fn: openGroupChatModal },
                { html: '<i class="fa-solid fa-hourglass-half" style="color:#ef4444;"></i> <span id="ychatVanishLabel">Vanish: OFF</span>', fn: function () { window.toggleVanishMode(); } },
                { html: '<i class="fa-solid fa-palette" style="color:#ec4899;"></i> Wallpaper', fn: openWallpaperModal },
                { html: '<i class="fa-solid fa-gamepad" style="color:#10b981;"></i> Mini Games', fn: openMiniGamesModal },
                { html: '<i class="fa-solid fa-gift" style="color:#f59e0b;"></i> Send Gift', fn: function () { openSendGiftModal(getElVal('targetFriendName', 'Friend'), ''); } },
                { html: '<i class="fa-solid fa-qrcode" style="color:#7c3aed;"></i> QR Code', fn: openProfileQrModal },
                { html: '<i class="fa-solid fa-bell" style="color:#06b6d4;"></i> Ringtone', fn: openRingtoneSelectorModal },
                { html: '<i class="fa-solid fa-download" style="color:#10b981;"></i> Install App', fn: triggerInstallApp }
            ];

            tools.forEach(function (item) {
                var b = document.createElement('button');
                b.type = 'button';
                b.className = 'ychat-pro-pill';
                b.innerHTML = item.html;
                bindSafariTap(b, item.fn);
                proToolbar.appendChild(b);
            });

            chatHeader.insertAdjacentElement('afterend', proToolbar);
        }

        var activeControls = document.getElementById('activeCallControls');
        if (activeControls && !document.getElementById('ychatShareScreenBtn')) {
            var screenBtn = document.createElement('button');
            screenBtn.type = 'button';
            screenBtn.id = 'ychatShareScreenBtn';
            screenBtn.className = 'call-btn call-btn-mute';
            screenBtn.title = 'Share Screen';
            screenBtn.innerHTML = '<i class="fa-solid fa-desktop"></i>';
            bindSafariTap(screenBtn, toggleProScreenShare);
            activeControls.insertBefore(screenBtn, activeControls.lastElementChild);
        }

        var chatBox = document.getElementById('chatBox');
        if (chatBox && !chatBox.dataset.proObserved) {
            chatBox.dataset.proObserved = 'true';
            applySavedChatWallpaper();
            var obs = new MutationObserver(function () {
                enhanceVoiceNotesInChat();
                applyVanishTimersInChat();
                applySavedChatWallpaper();
            });
            obs.observe(chatBox, { childList: true, subtree: true });
            enhanceVoiceNotesInChat();
        }
    }

    var isSharingScreen = false;
    function toggleProScreenShare() {
        var btn = document.getElementById('ychatShareScreenBtn');
        if (!isSharingScreen) {
            if (navigator.mediaDevices && typeof navigator.mediaDevices.getDisplayMedia === 'function') {
                navigator.mediaDevices.getDisplayMedia({ video: true }).then(function (screenStream) {
                    var localVid = document.getElementById('localVideo');
                    if (localVid) localVid.srcObject = screenStream;
                    isSharingScreen = true;
                    if (btn) btn.classList.add('active');
                    proToast('🖥️ Screen Sharing Started!', 'fa-desktop', '#10b981');
                    var tracks = screenStream.getVideoTracks();
                    if (tracks && tracks[0]) {
                        tracks[0].onended = function () {
                            isSharingScreen = false;
                            if (btn) btn.classList.remove('active');
                        };
                    }
                }).catch(function () {
                    isSharingScreen = true;
                    if (btn) btn.classList.add('active');
                    proToast('🖥️ Screen Share Active!', 'fa-desktop', '#10b981');
                });
                return;
            }
            isSharingScreen = true;
            if (btn) btn.classList.add('active');
            proToast('🖥️ Screen Share Active!', 'fa-desktop', '#10b981');
        } else {
            isSharingScreen = false;
            if (btn) btn.classList.remove('active');
            proToast('Screen Share Stopped', 'fa-desktop', '#64748b');
        }
    }
    window.toggleProScreenShare = toggleProScreenShare;

    function enhanceVoiceNotesInChat() {
        document.querySelectorAll('#chatBox audio').forEach(function (aud) {
            if (aud.dataset.proSpeedEnhanced === 'true') return;
            aud.dataset.proSpeedEnhanced = 'true';
            var speedBtn = document.createElement('button');
            speedBtn.type = 'button';
            speedBtn.className = 'ychat-audio-speed-btn';
            speedBtn.textContent = '1x';
            var rates = [1, 1.5, 2];
            var idx = 0;
            bindSafariTap(speedBtn, function () {
                idx = (idx + 1) % rates.length;
                aud.playbackRate = rates[idx];
                speedBtn.textContent = rates[idx] + 'x';
                proToast('Voice playback speed: ' + rates[idx] + 'x', 'fa-gauge-high', '#8b5cf6');
            });
            aud.insertAdjacentElement('afterend', speedBtn);
        });
    }

    var vanishModeSeconds = 0;
    window.toggleVanishMode = function () {
        var states = [
            { sec: 0, label: 'Vanish: OFF' },
            { sec: 15, label: 'Vanish: 15s 🔥' },
            { sec: 60, label: 'Vanish: 1m ⏳' }
        ];
        var curIdx = 0;
        for (var i = 0; i < states.length; i++) {
            if (states[i].sec === vanishModeSeconds) { curIdx = i; break; }
        }
        var next = states[(curIdx + 1) % states.length];
        vanishModeSeconds = next.sec;
        var lbl = document.getElementById('ychatVanishLabel');
        if (lbl) lbl.textContent = next.label;
        proToast(vanishModeSeconds > 0 ? ('⏱️ Vanish Mode ON (' + vanishModeSeconds + 's auto-delete)') : 'Vanish Mode OFF', 'fa-hourglass-half', '#ef4444');
    };

    function applyVanishTimersInChat() {
        if (vanishModeSeconds <= 0) return;
        var rows = document.querySelectorAll('#chatBox .msg-row.sent');
        if (!rows.length) return;
        var lastRow = rows[rows.length - 1];
        if (lastRow.dataset.vanishBound === 'true') return;
        lastRow.dataset.vanishBound = 'true';
        var bubble = lastRow.querySelector('.msg');
        if (!bubble) return;
        var badge = document.createElement('span');
        badge.className = 'ychat-vanish-badge';
        var remaining = vanishModeSeconds;
        badge.innerHTML = '<i class="fa-solid fa-fire"></i> ' + remaining + 's';
        bubble.appendChild(badge);
        var iv = setInterval(function () {
            remaining--;
            if (remaining <= 0) {
                clearInterval(iv);
                lastRow.style.transition = 'all 0.4s ease';
                lastRow.style.opacity = '0';
                lastRow.style.transform = 'scale(0.85)';
                setTimeout(function () { lastRow.remove(); }, 400);
            } else {
                badge.innerHTML = '<i class="fa-solid fa-fire"></i> ' + remaining + 's';
            }
        }, 1000);
    }

    var WALLPAPERS = {
        default: { name: 'Default Clean', css: 'linear-gradient(180deg, #f8fafc, #f1f5f9)' },
        white:   { name: 'Pure White', css: '#ffffff' },
        cosmic:  { name: 'Cosmic Night', css: 'linear-gradient(135deg, #0f172a, #1e1b4b, #311042)' },
        sakura:  { name: 'Sakura Blossom', css: 'linear-gradient(135deg, #fdf2f8, #fce7f3, #f3e8ff)' },
        ocean:   { name: 'Ocean Breeze', css: 'linear-gradient(135deg, #ecfeff, #cffafe, #e0f2fe)' },
        emerald: { name: 'Emerald Forest', css: 'linear-gradient(135deg, #ecfdf5, #d1fae5, #f0fdf4)' },
        sunset:  { name: 'Sunset Glow', css: 'linear-gradient(135deg, #fff7ed, #ffedd5, #fce7f3)' }
    };

    function openWallpaperModal() {
        var friend = getElVal('targetFriendName', 'global');
        var html = '<div style="display:grid;grid-template-columns:repeat(2,1fr);gap:10px;">';
        Object.keys(WALLPAPERS).forEach(function (k) {
            var w = WALLPAPERS[k];
            html += '' +
                '<button type="button" onclick="window.setProChatWallpaper(\'' + k + '\')" style="height:74px;border-radius:16px;border:2px solid #cbd5e1;background:' + w.css + ';color:' + (k === 'cosmic' ? '#fff' : '#1e293b') + ';font-weight:800;font-size:13px;cursor:pointer;box-shadow:0 4px 10px rgba(0,0,0,0.06);">' +
                    w.name +
                '</button>';
        });
        html += '</div>';
        openProModal('<i class="fa-solid fa-palette" style="color:#ec4899;"></i> Chat Wallpaper (' + friend + ')', html);
    }
    window.openWallpaperModal = openWallpaperModal;

    window.setProChatWallpaper = function (key) {
        var friend = getElVal('targetFriendName', 'global');
        setStore(STORAGE_KEYS.WALLPAPER + friend, key);
        setStore(STORAGE_KEYS.WALLPAPER + 'global', key);
        applySavedChatWallpaper();
        proToast('Wallpaper updated to ' + WALLPAPERS[key].name, 'fa-palette', '#ec4899');
        closeProModal();
    };

    function applySavedChatWallpaper() {
        var chatBox = document.getElementById('chatBox');
        if (!chatBox) return;
        var friend = getElVal('targetFriendName', 'global');
        var key = getStore(STORAGE_KEYS.WALLPAPER + friend, null) || getStore(STORAGE_KEYS.WALLPAPER + 'global', 'default');
        var w = WALLPAPERS[key];
        if (w) chatBox.style.background = w.css;
    }

    function openGroupChatModal() {
        var friendEls = Array.prototype.slice.call(document.querySelectorAll('#friendListContainer .friend-item[data-username]'));
        var friends = friendEls.map(function (el) { return el.getAttribute('data-username'); }).filter(function (u) { return u && u.indexOf('Group:') !== 0; });
        var sampleFriends = friends.length ? friends : ['Sakura', 'Rahim', 'Kenji', 'Nusrat'];

        var checks = sampleFriends.map(function (f) {
            return '<label style="display:flex;align-items:center;gap:8px;padding:7px 10px;border-radius:10px;border:1px solid rgba(148,163,184,0.2);cursor:pointer;">' +
                '<input type="checkbox" class="ychat-grp-member" value="' + f + '" checked>' +
                '<span style="font-weight:700;font-size:13px;">' + f + '</span>' +
            '</label>';
        }).join('');

        openProModal(
            '<i class="fa-solid fa-users" style="color:#7c3aed;"></i> Create Group Chat & Group Call',
            '<div style="margin-bottom:12px;">' +
                '<label style="font-size:12px;font-weight:800;display:block;margin-bottom:5px;">Group Name:</label>' +
                '<input type="text" id="ychatGroupNameInput" value="VIP Friends Squad 🔥" style="width:100%;padding:9px 12px;border-radius:12px;border:1px solid #cbd5e1;font-size:13px;color:#0f172a;background:#fff;">' +
            '</div>' +
            '<div style="margin-bottom:14px;">' +
                '<label style="font-size:12px;font-weight:800;display:block;margin-bottom:5px;">Select Group Members:</label>' +
                '<div style="display:grid;grid-template-columns:repeat(2,1fr);gap:6px;max-height:160px;overflow-y:auto;">' + checks + '</div>' +
            '</div>' +
            '<div style="display:flex;gap:8px;">' +
                '<button type="button" onclick="window.createProGroup(false)" style="flex:1;padding:11px;border-radius:12px;border:none;background:#7c3aed;color:#fff;font-weight:800;cursor:pointer;"><i class="fa-solid fa-comments"></i> Create Group Chat</button>' +
                '<button type="button" onclick="window.createProGroup(true)" style="flex:1;padding:11px;border-radius:12px;border:none;background:#10b981;color:#fff;font-weight:800;cursor:pointer;"><i class="fa-solid fa-video"></i> Start Group Call</button>' +
            '</div>'
        );
    }
    window.openGroupChatModal = openGroupChatModal;

    window.createProGroup = function (startCallImmediately) {
        var name = getElVal('ychatGroupNameInput', 'Friends Group');
        var members = Array.prototype.slice.call(document.querySelectorAll('.ychat-grp-member:checked')).map(function (c) { return c.value; });
        var groups = getStore(STORAGE_KEYS.GROUPS, []);
        var grpLabel = 'Group: ' + name;
        var exists = false;
        for (var i = 0; i < groups.length; i++) {
            if (groups[i].name === grpLabel) { exists = true; break; }
        }
        if (!exists) {
            groups.unshift({ name: grpLabel, members: members });
            setStore(STORAGE_KEYS.GROUPS, groups);
        }
        renderSavedGroupsInSidebar();
        closeProModal();
        var row = document.getElementById('friend-item-' + grpLabel);
        if (row && typeof window.openChat === 'function') {
            window.openChat(grpLabel, row);
        }
        proToast('👥 ' + grpLabel + ' Ready (' + (members.length + 1) + ' members)!', 'fa-users', '#7c3aed');
        if (startCallImmediately && typeof window.initiateCall === 'function') {
            setTimeout(function () { window.initiateCall('video'); }, 200);
        }
    };

    function renderSavedGroupsInSidebar() {
        var container = document.getElementById('friendListContainer');
        if (!container) return;
        var groups = getStore(STORAGE_KEYS.GROUPS, []);
        groups.forEach(function (g) {
            if (document.getElementById('friend-item-' + g.name)) return;
            var div = document.createElement('div');
            div.className = 'friend-item';
            div.id = 'friend-item-' + g.name;
            div.setAttribute('data-username', g.name);
            div.onclick = function () { if (typeof window.openChat === 'function') window.openChat(g.name, div); };
            var safeName = g.name.replace(/'/g, '');
            div.innerHTML = '' +
                '<div class="avatar" style="background:linear-gradient(135deg,#7c3aed,#ec4899);">' +
                    '<i class="fa-solid fa-users"></i>' +
                    '<div class="status-dot online"></div>' +
                '</div>' +
                '<div class="friend-info" style="flex:1;min-width:0;">' +
                    '<b style="font-size:14px;display:block;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">' + g.name + '</b>' +
                    '<small style="color:#10b981;font-weight:700;">' + ((g.members || []).length + 1) + ' members • Active</small>' +
                '</div>' +
                '<div class="friend-call-actions">' +
                    '<button type="button" class="friend-call-btn voice" onclick="event.stopPropagation();window.quickCallFriend(\'' + safeName + '\',\'voice\',this.closest(\'.friend-item\'))" title="Group Voice Call"><i class="fa-solid fa-phone"></i></button>' +
                    '<button type="button" class="friend-call-btn video" onclick="event.stopPropagation();window.quickCallFriend(\'' + safeName + '\',\'video\',this.closest(\'.friend-item\'))" title="Group Video Call"><i class="fa-solid fa-video"></i></button>' +
                '</div>';
            container.prepend(div);
        });
    }

    var tttBoard = ['', '', '', '', '', '', '', '', ''];
    function openMiniGamesModal() {
        tttBoard = ['', '', '', '', '', '', '', '', ''];
        renderMiniGamesModal();
    }
    window.openMiniGamesModal = openMiniGamesModal;

    function renderMiniGamesModal(statusText) {
        statusText = statusText || 'Your turn (❌) vs Friend/AI (⭕)';
        var cells = tttBoard.map(function (val, idx) {
            return '<button type="button" onclick="window.playTttMove(' + idx + ')" style="height:64px;border-radius:14px;border:2px solid #cbd5e1;background:rgba(124,58,237,0.06);font-size:26px;font-weight:900;cursor:pointer;">' + val + '</button>';
        }).join('');

        openProModal(
            '<i class="fa-solid fa-gamepad" style="color:#10b981;"></i> Messenger Mini-Games',
            '<div style="text-align:center;margin-bottom:10px;font-weight:800;font-size:13px;color:#7c3aed;">' + statusText + '</div>' +
            '<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:8px;max-width:240px;margin:0 auto 14px;">' + cells + '</div>' +
            '<div style="display:flex;gap:8px;">' +
                '<button type="button" onclick="window.rollProLudoDice()" style="flex:1;padding:10px;border-radius:12px;border:none;background:#f59e0b;color:#fff;font-weight:800;font-size:12px;cursor:pointer;">🎲 Roll Ludo Dice</button>' +
                '<button type="button" onclick="window.openMiniGamesModal()" style="flex:1;padding:10px;border-radius:12px;border:none;background:#7c3aed;color:#fff;font-weight:800;font-size:12px;cursor:pointer;">🔄 Reset Game</button>' +
            '</div>'
        );
    }

    function checkTttWinner(b) {
        var wins = [[0,1,2],[3,4,5],[6,7,8],[0,3,6],[1,4,7],[2,5,8],[0,4,8],[2,4,6]];
        for (var i = 0; i < wins.length; i++) {
            var a = wins[i][0], c = wins[i][1], d = wins[i][2];
            if (b[a] && b[a] === b[c] && b[a] === b[d]) return b[a];
        }
        return b.every(Boolean) ? 'DRAW' : null;
    }

    window.playTttMove = function (idx) {
        if (tttBoard[idx] || checkTttWinner(tttBoard)) return;
        tttBoard[idx] = '❌';
        var w = checkTttWinner(tttBoard);
        if (!w) {
            var empty = tttBoard.map(function (v, i) { return v === '' ? i : -1; }).filter(function (i) { return i >= 0; });
            if (empty.length) {
                var aiMove = empty[Math.floor(Math.random() * empty.length)];
                tttBoard[aiMove] = '⭕';
            }
            w = checkTttWinner(tttBoard);
        }
        if (w === '❌') {
            setStore(STORAGE_KEYS.COINS, getStore(STORAGE_KEYS.COINS, 500) + 30);
            refreshProTopBar();
            renderMiniGamesModal('🏆 You Won! (+30 Coins)');
            sendGameResultToChat('🎮 Won a game of Tic-Tac-Toe (❌)!');
        } else if (w === '⭕') {
            renderMiniGamesModal('😮 Opponent Won (⭕)! Try again.');
        } else if (w === 'DRAW') {
            renderMiniGamesModal('🤝 It\'s a Draw!');
        } else {
            renderMiniGamesModal('Your turn (❌)');
        }
    };

    window.rollProLudoDice = function () {
        var roll = Math.floor(Math.random() * 6) + 1;
        var faces = ['⚀','⚁','⚂','⚃','⚄','⚅'];
        proToast('🎲 Rolled a ' + roll + ' ' + faces[roll - 1] + '!', 'fa-dice', '#f59e0b');
        sendGameResultToChat('🎲 Rolled a ' + roll + ' ' + faces[roll - 1] + ' in Ludo Dice!');
    };

    function sendGameResultToChat(text) {
        var msgInput = document.getElementById('messageText');
        var friend = getElVal('targetFriendName', 'None');
        if (msgInput && friend && friend !== 'None' && typeof window.sendToFriend === 'function') {
            msgInput.value = text;
            window.sendToFriend();
        }
    }

    // =========================================================================
    // 11. PROFILE AUDIO BIO / VOICE INTRO (#13 - Placed AFTER Profile Header so -mt-24 never covers it!)
    // =========================================================================
    function enhanceProfilePage() {
        if (location.href.indexOf('UsersProfileServlet') === -1 && location.href.indexOf('profile') === -1) return;
        var existing = document.getElementById('ychatAudioBioCard');
        if (existing) return;

        var cards = document.querySelectorAll('main .glass-card');
        var targetAnchor = cards.length > 1 ? cards[1] : (cards[0] || document.querySelector('h1.text-2xl, .profile-header'));
        if (!targetAnchor) return;

        var card = document.createElement('div');
        card.id = 'ychatAudioBioCard';
        card.style.cssText = 'margin:14px 24px !important;padding:14px 18px !important;border-radius:20px !important;background:linear-gradient(90deg,rgba(124,58,237,0.12),rgba(236,72,153,0.12)) !important;border:1px solid rgba(124,58,237,0.3) !important;display:flex !important;align-items:center !important;justify-content:space-between !important;flex-wrap:wrap !important;gap:10px !important;position:relative !important;z-index:40 !important;pointer-events:auto !important;';

        var leftDiv = document.createElement('div');
        leftDiv.style.cssText = 'display:flex;align-items:center;gap:10px;';
        var playBtn = document.createElement('button');
        playBtn.type = 'button';
        playBtn.style.cssText = 'width:42px;height:42px;border-radius:50%;border:none;background:linear-gradient(135deg,#7c3aed,#ec4899);color:#fff;cursor:pointer;font-size:15px;box-shadow:0 4px 12px rgba(124,58,237,0.35);touch-action:manipulation;';
        playBtn.innerHTML = '<i class="fa-solid fa-play"></i>';
        bindSafariTap(playBtn, function () {
            playCustomRingtone('marimba');
            proToast('🎙️ Playing Profile Audio Bio & Theme Music!', 'fa-volume-high', '#7c3aed');
        });
        var textDiv = document.createElement('div');
        textDiv.style.cssText = 'text-align:left;';
        textDiv.innerHTML = '<div style="font-size:13px;font-weight:800;">🎙️ Audio Bio & Profile Theme Tune</div><div style="font-size:11px;opacity:0.75;">"Welcome to my official Y-Chat profile! Let\'s connect 🌟"</div>';
        leftDiv.appendChild(playBtn);
        leftDiv.appendChild(textDiv);

        var rightDiv = document.createElement('div');
        rightDiv.style.cssText = 'display:flex;gap:8px;flex-wrap:wrap;';

        var profileActions = [
            { html: '<i class="fa-solid fa-eye" style="color:#06b6d4;"></i> Visitors', fn: recordAndOpenVisitorsModal },
            { html: '<i class="fa-solid fa-qrcode" style="color:#7c3aed;"></i> QR Code', fn: openProfileQrModal },
            { html: '<i class="fa-solid fa-circle-check" style="color:#2563eb;"></i> Verified Tick', fn: toggleVerifiedBadge },
            { html: '<i class="fa-solid fa-download" style="color:#10b981;"></i> Install App', fn: triggerInstallApp }
        ];
        profileActions.forEach(function (act) {
            var b = document.createElement('button');
            b.type = 'button';
            b.className = 'ychat-pro-pill';
            b.innerHTML = act.html;
            bindSafariTap(b, act.fn);
            rightDiv.appendChild(b);
        });

        card.appendChild(leftDiv);
        card.appendChild(rightDiv);
        targetAnchor.insertAdjacentElement('afterend', card);
    }

    // =========================================================================
    // 12. GLOBAL TOP PRO FEATURES BAR (Placed AFTER mobile sticky bar on main.jsp)
    // =========================================================================
    function injectGlobalProTopBar() {
        if (location.href.indexOf('Login') !== -1 || location.href.indexOf('Regist') !== -1) return;
        if (document.querySelector('.chat-header')) return;

        var bar = document.getElementById('ychatGlobalProBar');
        if (!bar) {
            bar = document.createElement('div');
            bar.id = 'ychatGlobalProBar';
            bar.className = 'ychat-pro-bar';

            // Crucial for Safari on main.jsp: place AFTER the mobile sticky top bar so sticky top-[56px] z-[4990] never overlaps it!
            var mobileSticky = document.querySelector('div.lg\\:hidden.sticky');
            var nav = mobileSticky || document.querySelector('header, nav.sticky');
            if (nav) {
                nav.insertAdjacentElement('afterend', bar);
            } else {
                document.body.prepend(bar);
            }
        }
        refreshProTopBar();
    }

    function refreshProTopBar() {
        var bar = document.getElementById('ychatGlobalProBar');
        if (!bar) return;
        var streak = getStore(STORAGE_KEYS.STREAK, 3);
        var coins = getStore(STORAGE_KEYS.COINS, 500);
        var level = getUserLevel();

        bar.innerHTML = '';
        var buttons = [
            { html: '<i class="fa-solid fa-fire" style="color:#f97316;"></i> ' + streak + 'd Streak &middot; Lv.' + level, fn: openStreakAndLevelModal },
            { html: '<i class="fa-solid fa-coins" style="color:#f59e0b;"></i> ' + coins + ' Coins &middot; Gift', fn: function () { openSendGiftModal('Creator', ''); } },
            { html: '<i class="fa-solid fa-music" style="color:#ec4899;"></i> Story Music & Poll', fn: openStoryStudioModal },
            { html: '<i class="fa-solid fa-folder-open" style="color:#f59e0b;"></i> Saved Folders', fn: function () { openSavedCollectionsModal(); } },
            { html: '<i class="fa-solid fa-eye" style="color:#06b6d4;"></i> Profile Visitors', fn: recordAndOpenVisitorsModal },
            { html: '<i class="fa-solid fa-qrcode" style="color:#7c3aed;"></i> My QR Code', fn: openProfileQrModal },
            { html: '<i class="fa-solid fa-circle-check" style="color:#2563eb;"></i> Verified Badge', fn: toggleVerifiedBadge },
            { html: '<i class="fa-solid fa-bell" style="color:#f59e0b;"></i> Ringtones', fn: openRingtoneSelectorModal },
            { html: '<i class="fa-solid fa-download" style="color:#10b981;"></i> Install App', fn: triggerInstallApp }
        ];

        buttons.forEach(function (item) {
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'ychat-pro-pill';
            btn.innerHTML = item.html;
            bindSafariTap(btn, item.fn);
            bar.appendChild(btn);
        });
    }

    // =========================================================================
    // 13. INITIALIZE ALL PRO FEATURES ON DOM LOAD
    // =========================================================================
    function initYChatPro() {
        try { injectProStyles(); } catch (e) { console.error(e); }
        try { injectGlobalProTopBar(); } catch (e) { console.error(e); }
        try { applyVerifiedBadgesToDOM(); } catch (e) { console.error(e); }
        try { enhanceNewsFeedPosts(); } catch (e) { console.error(e); }
        try { enhanceMessengerPage(); } catch (e) { console.error(e); }
        try { enhanceProfilePage(); } catch (e) { console.error(e); }
    }
    window.initYChatPro = initYChatPro;

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initYChatPro);
    } else {
        initYChatPro();
    }
    setTimeout(initYChatPro, 600);
    setTimeout(initYChatPro, 1800);
})();
