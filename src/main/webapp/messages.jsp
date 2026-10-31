<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="ychatapp.model.beans.UsersBeans" %>
<%@ page import="ychatapp.model.dao.UsersDAO" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%
    UsersBeans ub = (UsersBeans) session.getAttribute("ub");
    if (ub == null) {
        response.sendRedirect(request.getContextPath() + "/UsersLoginServlet");
        return;
    }
    pageContext.setAttribute("ub", ub);
    ychatapp.model.dao.MessageDAO messageDAO = new ychatapp.model.dao.MessageDAO();
    pageContext.setAttribute("archivedPartnerNames", messageDAO.getArchivedConversationPartners(ub.getName()));
    pageContext.setAttribute("unreadPartnerNames", messageDAO.getUnreadConversationPartners(ub.getName()));
    UsersDAO uDao = new UsersDAO();
    List<UsersBeans> dbFriendList = uDao.getFriends(ub.getId());
    if (dbFriendList == null) {
        dbFriendList = new java.util.ArrayList<>();
    }
    for (String partnerName : new ychatapp.model.dao.MessageDAO().getConversationPartners(ub.getName())) {
        UsersBeans partner = uDao.getUserByName(partnerName);
        boolean listed = false;
        for (UsersBeans existing : dbFriendList) {
            if (existing.getName().equalsIgnoreCase(partnerName)) {
                listed = true;
                break;
            }
        }
        if (partner != null && !listed) {
            dbFriendList.add(partner);
        }
    }

    // Resolve target user from URL parameters (?userId=... or ?userName=...)
    String targetUserNameParam = request.getParameter("userName");
    String targetUserIdParam = request.getParameter("userId");
    UsersBeans targetUserBean = null;

    if (targetUserIdParam != null && !targetUserIdParam.trim().isEmpty()) {
        try {
            int tid = Integer.parseInt(targetUserIdParam.trim());
            targetUserBean = uDao.getUserById(tid);
            if (targetUserBean != null && (targetUserNameParam == null || targetUserNameParam.trim().isEmpty())) {
                targetUserNameParam = targetUserBean.getName();
            }
        } catch (Exception ignored) {}
    }

    if (targetUserBean == null && targetUserNameParam != null && !targetUserNameParam.trim().isEmpty()) {
        targetUserBean = uDao.getUserByName(targetUserNameParam.trim());
    }

    // If target user is valid and not self, add to the list so they appear in sidebar
    if (targetUserBean != null && targetUserBean.getId() != ub.getId()) {
        boolean alreadyInList = false;
        for (UsersBeans f : dbFriendList) {
            if (f.getId() == targetUserBean.getId() || f.getName().equalsIgnoreCase(targetUserBean.getName())) {
                alreadyInList = true;
                break;
            }
        }
        if (!alreadyInList) {
            dbFriendList.add(0, targetUserBean);
        }
    }
    pageContext.setAttribute("dbFriendList", dbFriendList);
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Messenger | Y-ChatApp</title>
    <!-- PWA & Mobile Web App Meta Tags -->
    <link rel="manifest" href="<%=request.getContextPath()%>/manifest.json">
    <link rel="icon" type="image/png" sizes="192x192" href="<%=request.getContextPath()%>/icons/icon-192.png">
    <link rel="icon" type="image/png" sizes="512x512" href="<%=request.getContextPath()%>/icons/icon-512.png">
    <link rel="apple-touch-icon" href="<%=request.getContextPath()%>/icons/icon-192.png">
    <link rel="apple-touch-icon" sizes="152x152" href="<%=request.getContextPath()%>/icons/icon-192.png">
    <link rel="apple-touch-icon" sizes="180x180" href="<%=request.getContextPath()%>/icons/icon-192.png">
    <link rel="apple-touch-icon" sizes="192x192" href="<%=request.getContextPath()%>/icons/icon-192.png">
    <link rel="apple-touch-icon" sizes="512x512" href="<%=request.getContextPath()%>/icons/icon-512.png">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <meta name="apple-mobile-web-app-title" content="Y-ChatApp">
    <meta name="application-name" content="Y-ChatApp">
    <meta name="theme-color" content="#1877f2">
    <link rel="icon" type="image/png" href="<%=request.getContextPath()%>/icons/icon-192.png">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <script src="<%=request.getContextPath()%>/js/notification-badge.js" data-context-path="<%=request.getContextPath()%>" defer></script>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', sans-serif; }
        body { background-color: #f0f2f5; display: flex; height: 100vh; overflow: hidden; }

        /* Sidebar Design */
        .sidebar { width: 360px; background: white; border-right: 1px solid #ddd; display: flex; flex-direction: column; }
        .sidebar-header { padding: 20px; background: purple; color: white; }
        
        /* 🔥 Search Bar Styles */
        .search-container { padding: 10px 15px; border-bottom: 1px solid #eee; }
        .search-box {
            width: 100%; padding: 10px 15px; border: none; border-radius: 20px;
            background: #f0f2f5; outline: none; font-size: 14px;
        }

        /* Chat List */
        #friendListContainer { flex: 1; overflow-y: auto; padding: 10px; }
        .friend-item { 
            display: flex; align-items: center; padding: 12px; border-radius: 12px; 
            cursor: pointer; transition: 0.2s; margin-bottom: 5px;
        }
        .friend-item:hover { background-color: #f3e8ff; }
        .friend-item.active { background-color: #ede9fe; border-left: 4px solid purple; }

        .avatar { 
            width: 45px; height: 45px; background: #9333ea; color: white; 
            border-radius: 50%; margin-right: 12px; display: flex; 
            align-items: center; justify-content: center; font-weight: bold; position: relative;
            flex-shrink: 0;
        }
        .status-dot { 
            width: 13px; height: 13px; border: 2.5px solid white;
            border-radius: 50%; position: absolute; bottom: 0; right: 0;
            transition: all 0.3s ease;
        }
        .status-dot.online, .online-dot { 
            background: #22c55e !important;
            box-shadow: 0 0 6px rgba(34, 197, 94, 0.7);
        }
        .status-dot.offline, .offline-dot { 
            background: #94a3b8 !important;
            box-shadow: none !important;
        }
        .dark .status-dot {
            border-color: #0f172a !important;
        }

        /* Chat Window */
        .main-chat { flex: 1; display: flex; flex-direction: column; background: white; }
        .chat-header { padding: 15px 25px; border-bottom: 1px solid #eee; font-weight: bold; font-size: 18px; color: purple; display: flex; justify-content: space-between; align-items: center; }
        .call-buttons { display: flex; gap: 20px; font-size: 22px; opacity: 0.3; pointer-events: none; }
        .call-buttons.active { opacity: 1; pointer-events: auto; }
        .call-buttons i { cursor: pointer; transition: 0.2s; color: purple; }
        .call-buttons i:hover { color: #31a24c; transform: scale(1.1); }
        #chatBox { flex: 1; padding: 20px; overflow-y: auto; background: #f9f9f9; display: flex; flex-direction: column; gap: 8px; }
        
        /* Messages & Enhancements */
        .msg-row {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px;
            position: relative;
            width: 100%;
        }
        .msg-row.sent {
            justify-content: flex-end;
        }
        .msg-row.received {
            justify-content: flex-start;
        }
        .msg {
            max-width: 72%;
            padding: 10px 14px;
            border-radius: 18px;
            font-size: 15px;
            word-wrap: break-word;
            position: relative;
            box-shadow: 0 1px 3px rgba(0,0,0,0.06);
        }
        .msg.sent {
            align-self: flex-end;
            background: linear-gradient(135deg, #9333ea, #7e22ce);
            color: white;
            border-bottom-right-radius: 3px;
        }
        .msg.received {
            align-self: flex-start;
            background: #e2e8f0;
            color: #0f172a;
            border-bottom-left-radius: 3px;
        }
        .msg-deleted {
            font-style: italic;
            opacity: 0.8;
            background: rgba(148, 163, 184, 0.18) !important;
            color: #64748b !important;
            border: 1px dashed rgba(148, 163, 184, 0.45);
        }
        .msg-quote-card {
            background: rgba(0, 0, 0, 0.15);
            border-left: 3px solid #fbcfe8;
            padding: 4px 8px;
            border-radius: 6px;
            margin-bottom: 6px;
            font-size: 12px;
            cursor: pointer;
            line-height: 1.35;
        }
        .msg-row.received .msg-quote-card {
            background: rgba(0, 0, 0, 0.06);
            border-left-color: #9333ea;
            color: #334155;
        }
        .msg-quote-card .quote-author {
            font-weight: 700;
            font-size: 11px;
            display: block;
        }
        .msg-quote-card .quote-snippet {
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            display: block;
        }
        .msg-actions {
            opacity: 0;
            display: flex;
            align-items: center;
            gap: 4px;
            transition: opacity 0.2s;
            pointer-events: none;
        }
        .msg-row:hover .msg-actions, .msg-row:focus-within .msg-actions {
            opacity: 1;
            pointer-events: auto;
        }
        .msg-action-btn {
            background: white;
            border: 1px solid #e2e8f0;
            color: #64748b;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            cursor: pointer;
            box-shadow: 0 2px 6px rgba(0,0,0,0.08);
            transition: all 0.15s;
        }
        .msg-action-btn:hover {
            color: #9333ea;
            transform: scale(1.15);
        }
        .reaction-picker-menu {
            position: absolute;
            bottom: calc(100% + 4px);
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 30px;
            padding: 4px 8px;
            display: none;
            gap: 6px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.18);
            z-index: 100;
            animation: popUp 0.15s ease-out;
        }
        .msg-row.sent .reaction-picker-menu {
            right: 0;
        }
        .msg-row.received .reaction-picker-menu {
            left: 0;
        }
        .reaction-picker-menu.active {
            display: flex;
        }
        .reaction-emoji-btn {
            font-size: 18px;
            background: none;
            border: none;
            cursor: pointer;
            transition: transform 0.15s;
            padding: 2px 4px;
            line-height: 1;
        }
        .reaction-emoji-btn:hover {
            transform: scale(1.3);
        }
        .reaction-close-btn {
            background: none;
            border: none;
            cursor: pointer;
            color: #94a3b8;
            font-size: 12px;
            padding: 2px 4px;
            border-radius: 50%;
            line-height: 1;
            margin-left: 2px;
            transition: color 0.2s, background 0.2s;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }
        .reaction-close-btn:hover {
            color: #ef4444;
            background: rgba(239,68,68,0.1);
        }
        .msg-reaction-pill {
            position: absolute;
            bottom: -9px;
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 1px 6px;
            font-size: 12px;
            box-shadow: 0 2px 6px rgba(0,0,0,0.12);
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 2px;
            color: #1e293b;
            z-index: 2;
        }
        .msg-row.sent .msg-reaction-pill {
            right: 10px;
        }
        .msg-row.received .msg-reaction-pill {
            left: 10px;
        }
        .edited-tag {
            font-size: 10px;
            opacity: 0.65;
            margin-left: 4px;
            font-style: italic;
        }
        .typing-bubble {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 8px 14px;
            background: #e2e8f0;
            border-radius: 18px;
            border-bottom-left-radius: 4px;
            width: fit-content;
            margin-bottom: 8px;
        }
        .typing-bubble .dot {
            width: 7px;
            height: 7px;
            background: #64748b;
            border-radius: 50%;
            animation: typingBounce 1.4s infinite ease-in-out both;
        }
        .typing-bubble .dot:nth-child(1) { animation-delay: -0.32s; }
        .typing-bubble .dot:nth-child(2) { animation-delay: -0.16s; }
        @keyframes typingBounce {
            0%, 80%, 100% { transform: scale(0.2); opacity: 0.4; }
            40% { transform: scale(1); opacity: 1; }
        }
        @keyframes popUp {
            from { transform: scale(0.7); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }

        /* ､・AI Feature Styles */
        .smart-reply-chip {
            background: white;
            border: 1px solid #c084fc;
            color: #7e22ce;
            padding: 5px 12px;
            border-radius: 16px;
            font-size: 12px;
            font-weight: 600;
            cursor: pointer;
            white-space: nowrap;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
            flex-shrink: 0;
        }
        .smart-reply-chip:hover {
            background: #9333ea;
            color: white;
            border-color: #9333ea;
            transform: translateY(-1px);
            box-shadow: 0 3px 8px rgba(147, 51, 234, 0.3);
        }
        .msg-translation-card {
            margin-top: 6px;
            padding: 6px 10px;
            background: rgba(0, 0, 0, 0.05);
            border-radius: 10px;
            font-size: 13px;
            border-left: 3px solid #06b6d4;
            animation: popUp 0.15s ease-out;
        }
        .msg.sent .msg-translation-card {
            background: rgba(255, 255, 255, 0.18);
            border-left-color: #38bdf8;
            color: #f8fafc;
        }
        .dark .smart-reply-chip {
            background: #1e1b4b;
            color: #d8b4fe;
            border-color: #9333ea;
        }
        .dark .smart-reply-chip:hover {
            background: #9333ea;
            color: white;
        }
        .dark .msg-translation-card {
            background: rgba(255, 255, 255, 0.08);
            border-left-color: #22d3ee;
            color: #e2e8f0;
        }

        .input-area { padding: 20px; border-top: 1px solid #eee; display: flex; gap: 10px; }
        .input-area input { flex: 1; padding: 12px 20px; border: 1px solid #ddd; border-radius: 25px; outline: none; }
        .btn-send { background: purple; color: white; border: none; padding: 10px 25px; border-radius: 25px; cursor: pointer; font-weight: bold; }
        .back-link { display: block; padding: 15px; text-align: center; text-decoration: none; color: purple; font-weight: bold; border-top: 1px solid #eee; }

        /* ==========================================
           到 PREMIUM CALLING SYSTEM STYLES (PERFECT SIZE)
        ========================================== */
        .call-overlay {
            position: fixed;
            top: 0; left: 0; width: 100vw; height: 100vh;
            background: rgba(8, 5, 18, 0.92);
            backdrop-filter: blur(25px);
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 10000;
            color: white;
            flex-direction: column;
            padding: 20px;
        }

        /* Default / Voice Call Container: Spacious, Elegant & Focused */
        .call-container {
            background: linear-gradient(145deg, rgba(32, 20, 52, 0.95), rgba(16, 10, 30, 0.95));
            border: 1px solid rgba(168, 85, 247, 0.35);
            border-radius: 36px;
            padding: 50px 40px 45px;
            width: 94%;
            max-width: 520px;
            min-height: 560px;
            text-align: center;
            box-shadow: 0 35px 90px rgba(0, 0, 0, 0.75), 0 0 50px rgba(168, 85, 247, 0.2);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: space-between;
            position: relative;
            animation: zoomInCall 0.35s cubic-bezier(0.16, 1, 0.3, 1);
            overflow: hidden;
            transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }

        /* 磁 Video Mode Container: Large, Cinema Fullscreen Feel */
        .call-container.video-mode {
            width: 95vw;
            max-width: 1240px;
            height: 88vh;
            max-height: 840px;
            min-height: unset;
            padding: 0;
            border-radius: 28px;
            background: #08060f;
            border: 1px solid rgba(255, 255, 255, 0.15);
            box-shadow: 0 35px 100px rgba(0, 0, 0, 0.85);
        }

        /* Fullscreen Video on Mobile screens */
        @media (max-width: 768px) {
            .call-overlay {
                padding: 0;
            }
            .call-container:not(.video-mode) {
                width: 94%;
                max-width: 440px;
                min-height: 520px;
                padding: 40px 24px 35px;
                border-radius: 28px;
            }
            .call-container.video-mode {
                width: 100vw !important;
                height: 100vh !important;
                max-width: 100vw !important;
                max-height: 100vh !important;
                border-radius: 0 !important;
                border: none !important;
            }
        }

        @keyframes zoomInCall {
            from { transform: scale(0.92) translateY(15px); opacity: 0; }
            to { transform: scale(1) translateY(0); opacity: 1; }
        }

        .call-avatar {
            width: 140px; height: 140px;
            border-radius: 50%;
            background: linear-gradient(135deg, #a855f7, #c084fc);
            display: flex; align-items: center; justify-content: center;
            font-size: 58px; font-weight: 800;
            margin: 15px auto 20px;
            box-shadow: 0 20px 45px rgba(168, 85, 247, 0.5);
            position: relative;
            z-index: 2;
        }

        .pulsing-rings {
            position: absolute;
            width: 140px; height: 140px;
            top: 65px; left: 50%;
            transform: translateX(-50%);
            border-radius: 50%;
            border: 2px solid rgba(168, 85, 247, 0.55);
            animation: pulseRingCall 2s infinite cubic-bezier(0.25, 0, 0, 1);
            z-index: 1;
            pointer-events: none;
        }

        .pulsing-rings:nth-child(2) {
            animation-delay: 0.6s;
        }

        @keyframes pulseRingCall {
            0% { transform: translateX(-50%) scale(1); opacity: 1; }
            100% { transform: translateX(-50%) scale(2.8); opacity: 0; }
        }

        .call-status {
            font-size: 16px; color: #d8b4fe; margin-bottom: 25px; font-weight: 500; letter-spacing: 0.5px;
        }

        .call-username {
            font-size: 30px; font-weight: 800; margin-bottom: 8px; letter-spacing: -0.5px;
        }

        .call-actions {
            display: flex; gap: 30px; justify-content: center; width: 100%; z-index: 5; margin-top: auto;
        }

        .call-btn {
            width: 68px; height: 68px; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 26px; cursor: pointer; transition: all 0.25s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            border: none; outline: none; color: white;
            box-shadow: 0 10px 25px rgba(0,0,0,0.3);
        }

        .call-btn-decline { background: #ef4444; }
        .call-btn-decline:hover { background: #dc2626; transform: scale(1.15) rotate(-10deg); box-shadow: 0 12px 30px rgba(239,68,68,0.5); }

        .call-btn-accept { background: #10b981; }
        .call-btn-accept:hover { background: #059669; transform: scale(1.15) rotate(10deg); box-shadow: 0 12px 30px rgba(16,185,129,0.5); }

        .call-btn-mute { background: rgba(255,255,255,0.14); }
        .call-btn-mute:hover { background: rgba(255,255,255,0.25); transform: scale(1.12); }
        .call-btn-mute.active { background: #ef4444; box-shadow: 0 8px 25px rgba(239, 68, 68, 0.4); }

        .call-btn-speaker { background: rgba(255,255,255,0.14); position: relative; }
        .call-btn-speaker:hover { background: rgba(255,255,255,0.25); transform: scale(1.12); }
        .call-btn-speaker.active { 
            background: linear-gradient(135deg, #2563eb, #3b82f6); 
            box-shadow: 0 0 22px rgba(59, 130, 246, 0.8), 0 8px 25px rgba(37, 99, 235, 0.5); 
            border: 2px solid rgba(147, 197, 253, 0.8);
        }
        .call-speaker-toast {
            position: absolute;
            top: 65px;
            left: 50%;
            transform: translateX(-50%) translateY(-15px);
            background: rgba(15, 23, 42, 0.94);
            border: 1px solid rgba(255, 255, 255, 0.22);
            color: #ffffff;
            padding: 8px 20px;
            border-radius: 24px;
            font-size: 13px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
            opacity: 0;
            pointer-events: none;
            transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            z-index: 60;
            backdrop-filter: blur(14px);
            box-shadow: 0 10px 30px rgba(0,0,0,0.5);
        }
        .call-speaker-toast.show {
            opacity: 1;
            transform: translateX(-50%) translateY(0);
        }

        /* Top Bar Overlay on Video Call */
        .call-top-bar {
            position: absolute; top: 22px; left: 25px; right: 25px;
            display: none; align-items: center; justify-content: space-between;
            z-index: 30; pointer-events: auto;
        }
        .call-top-info {
            display: flex; align-items: center; gap: 10px;
            background: rgba(15, 10, 25, 0.65); backdrop-filter: blur(15px);
            padding: 8px 18px; border-radius: 30px; border: 1px solid rgba(255,255,255,0.15);
            font-size: 14px; font-weight: 600;
        }
        .call-top-btn {
            background: rgba(15, 10, 25, 0.65); border: 1px solid rgba(255,255,255,0.2);
            color: white; width: 42px; height: 42px; border-radius: 50%;
            cursor: pointer; backdrop-filter: blur(15px); display: flex;
            align-items: center; justify-content: center; font-size: 16px;
            transition: 0.2s;
        }
        .call-top-btn:hover { background: rgba(168, 85, 247, 0.6); transform: scale(1.1); }

        /* Video Session Grid */
        .video-grid {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            display: none; border-radius: inherit; overflow: hidden; z-index: 10;
        }

        .remote-video-container {
            width: 100%; height: 100%; background: #08060f;
            display: flex; align-items: center; justify-content: center;
            position: relative;
        }

        .remote-video-container video {
            width: 100%; height: 100%; object-fit: cover;
        }

        .local-video-container {
            position: absolute; top: 25px; right: 25px;
            width: 200px; height: 260px; background: rgba(20, 15, 30, 0.85);
            border-radius: 20px; overflow: hidden; border: 2px solid rgba(255,255,255,0.7);
            box-shadow: 0 15px 40px rgba(0,0,0,0.6);
            z-index: 25;
            backdrop-filter: blur(15px);
            transition: all 0.3s ease;
        }

        @media (max-width: 768px) {
            .local-video-container {
                width: 110px; height: 155px;
                top: 75px; right: 18px;
                border-radius: 14px;
            }
        }

        .local-video-container video {
            width: 100%; height: 100%; object-fit: cover;
        }

        /* Modern Floating Control Dock */
        .active-call-controls {
            position: absolute; bottom: 30px; left: 50%;
            transform: translateX(-50%); display: flex; gap: 18px;
            z-index: 30;
            background: rgba(15, 10, 25, 0.82);
            backdrop-filter: blur(25px);
            padding: 12px 26px;
            border-radius: 60px;
            border: 1px solid rgba(255,255,255,0.2);
            box-shadow: 0 20px 50px rgba(0,0,0,0.6);
        }

        @media (max-width: 768px) {
            .active-call-controls {
                bottom: 25px;
                padding: 10px 18px;
                gap: 14px;
            }
            .active-call-controls .call-btn {
                width: 54px; height: 54px; font-size: 20px;
            }
        }

        .voice-waves {
            display: none; gap: 8px; height: 55px; align-items: center; justify-content: center; margin: 15px 0 30px;
        }
        .voice-wave-bar {
            width: 6px; height: 100%; background: linear-gradient(to top, #a855f7, #e879f9);
            border-radius: 4px;
            animation: wavePulseCall 1.2s infinite ease-in-out;
            box-shadow: 0 0 12px rgba(168, 85, 247, 0.6);
        }
        .voice-wave-bar:nth-child(1) { animation-delay: 0.1s; height: 35%; }
        .voice-wave-bar:nth-child(2) { animation-delay: 0.3s; height: 65%; }
        .voice-wave-bar:nth-child(3) { animation-delay: 0.5s; height: 95%; }
        .voice-wave-bar:nth-child(4) { animation-delay: 0.2s; height: 55%; }
        .voice-wave-bar:nth-child(5) { animation-delay: 0.4s; height: 80%; }
        .voice-wave-bar:nth-child(6) { animation-delay: 0.6s; height: 40%; }
        .voice-wave-bar:nth-child(7) { animation-delay: 0.25s; height: 70%; }

        @keyframes wavePulseCall {
            0%, 100% { transform: scaleY(0.2); }
            50% { transform: scaleY(1); }
        }

        /* Mobile responsive styling */
        .mobile-back-btn { display: none; margin-right: 15px; font-size: 20px; color: purple; cursor: pointer; border: none; background: none; }

        @media (max-width: 768px) {
            .sidebar {
                width: 100%;
                display: flex;
                padding-bottom: 65px !important;
            }
            .main-chat {
                display: none;
                width: 100%;
                padding-bottom: 65px !important;
            }
            .mobile-back-btn {
                display: block;
            }

            body.chat-open .sidebar {
                display: none;
            }
            body.chat-open .main-chat {
                display: flex;
            }
        }

        /* Refined Messenger layout */
        :root { --chat-violet: #6d28d9; --chat-indigo: #4f46e5; --chat-ink: #172033; --chat-muted: #64748b; }
        body { background: radial-gradient(circle at top left, #ede9fe 0, #f8fafc 38%, #eef2ff 100%); color: var(--chat-ink); }
        .sidebar { width: 348px; border: 1px solid rgba(226,232,240,.9); border-right: 1px solid #e2e8f0; box-shadow: 12px 0 36px rgba(15,23,42,.05); z-index: 2; }
        .sidebar-header { padding: 24px 20px 19px; background: linear-gradient(135deg, #4f46e5, #7c3aed 62%, #a855f7); }
        .sidebar-header h3 { display: flex; align-items: center; gap: 9px; font-size: 22px; letter-spacing: -.4px; }
        .sidebar-header h3::before { content: '\f075'; font-family: 'Font Awesome 6 Free'; font-weight: 900; font-size: 17px; opacity: .9; }
        .sidebar-header small { display: block; margin-top: 7px; opacity: .82; font-size: 12px; }
        .search-container { padding: 14px 15px 10px; border: 0; background: #fff; }
        .search-box { padding: 12px 15px; background: #f1f5f9; border: 1px solid transparent; border-radius: 14px; transition: .2s ease; }
        .search-box:focus { background: #fff; border-color: #c4b5fd; box-shadow: 0 0 0 4px rgba(124,58,237,.1); }
        #friendListContainer { padding: 7px 9px 14px; background: #fff; }
        .friend-item { padding: 11px; margin: 2px 0; border: 1px solid transparent; border-radius: 15px; }
        .friend-item:hover { background: #f5f3ff; border-color: #ede9fe; transform: translateX(2px); }
        .friend-item.active { background: linear-gradient(90deg, #ede9fe, #f5f3ff); border: 1px solid #ddd6fe; border-left: 4px solid var(--chat-violet); }
        .avatar { width: 48px; height: 48px; margin-right: 12px; box-shadow: 0 4px 12px rgba(109,40,217,.18); }
        .main-chat { background: rgba(255,255,255,.7); min-width: 0; }
        .chat-header { min-height: 78px; padding: 15px 26px; background: rgba(255,255,255,.94); border-bottom: 1px solid #e9edf5; color: var(--chat-ink); box-shadow: 0 2px 12px rgba(15,23,42,.035); flex-wrap: wrap; gap: 8px; }
        #chattingWith { color: var(--chat-violet); }
        #chatHeaderStatus { display: block; color: var(--chat-muted); font-size: 12px; font-weight: 500; margin-top: 3px; }
        .call-buttons { display: flex; align-items: center; gap: 8px; opacity: 1 !important; pointer-events: auto !important; flex-shrink: 0; }
        .call-buttons i { width: 38px; height: 38px; display: inline-flex !important; align-items: center; justify-content: center; border-radius: 12px; background: #f5f3ff; color: var(--chat-violet); font-size: 16px; flex-shrink: 0; box-shadow: 0 2px 6px rgba(109,40,217,.12); }
        .call-buttons i.fa-phone { background: #dcfce7; color: #16a34a; }
        .call-buttons i.fa-video { background: #ede9fe; color: #7c3aed; }
        .call-buttons i:hover { background: var(--chat-violet); color: #fff; transform: translateY(-2px); }
        .friend-call-actions { display: flex; align-items: center; gap: 6px; margin-left: 8px; flex-shrink: 0; }
        .friend-call-btn { width: 36px; height: 36px; border-radius: 50%; border: none; display: inline-flex; align-items: center; justify-content: center; cursor: pointer; font-size: 14px; transition: .2s; box-shadow: 0 2px 5px rgba(0,0,0,0.08); }
        .friend-call-btn.voice { background: #dcfce7; color: #16a34a; }
        .friend-call-btn.video { background: #ede9fe; color: #7c3aed; }
        .friend-call-btn:hover { transform: scale(1.1); filter: brightness(0.95); }
        #chatBox { padding: 28px clamp(18px, 5vw, 72px); gap: 10px; background: linear-gradient(180deg, #f8fafc, #f1f5f9); }
        #chatBox > div[style*='Select a user'] { margin: auto !important; padding: 20px 24px; background: #fff; border: 1px solid #e2e8f0; border-radius: 18px; box-shadow: 0 10px 30px rgba(15,23,42,.06); }
        .msg-row { margin-bottom: 9px; }
        .msg { max-width: min(70%, 620px); padding: 11px 15px; line-height: 1.45; box-shadow: 0 4px 14px rgba(15,23,42,.08); }
        .msg.sent { background: linear-gradient(135deg, #4f46e5, #7c3aed); border-bottom-right-radius: 6px; }
        .msg.received { background: #fff; color: #1e293b; border: 1px solid #e7eaf0; border-bottom-left-radius: 6px; }
        .input-area { padding: 14px 22px 17px; align-items: center; background: #fff; border-top: 1px solid #e7eaf0; box-shadow: 0 -8px 22px rgba(15,23,42,.035); }
        .input-area input { min-width: 0; padding: 13px 17px; background: #f8fafc; border-color: #e2e8f0; border-radius: 15px; transition: .2s; }
        .input-area input:focus { background: #fff; border-color: #a78bfa; box-shadow: 0 0 0 4px rgba(124,58,237,.10); }
        .btn-send { padding: 12px 20px; border-radius: 14px; background: linear-gradient(135deg, #4f46e5, #7c3aed); box-shadow: 0 7px 14px rgba(109,40,217,.24); }
        .btn-send:hover { filter: brightness(1.06); transform: translateY(-1px); }
        .back-link { padding: 16px; color: var(--chat-violet); background: #fff; }
        @media (max-width: 768px) {
          body { height: 100dvh; }
          .sidebar-header { padding: 19px 16px 15px; }
          .sidebar { border: 0; }
          #chatBox { padding: 18px 12px; }
          .chat-header { min-height: 64px; padding: 10px 12px; font-size: 14px; flex-wrap: wrap; }
          #conversationTools { order: 3; width: 100%; justify-content: space-between; padding-top: 6px; border-top: 1px solid #f1f5f9; }
          #chatMessageSearch { flex: 1; max-width: none !important; }
          .call-buttons { gap: 6px; }
          .call-buttons i { width: 36px; height: 36px; font-size: 15px; }
          .msg { max-width: 84%; font-size: 14px; }
          .input-area { gap: 4px; padding: 10px 8px 12px; }
          .input-area input { padding: 11px 12px; border-radius: 13px; }
          .btn-send { padding: 11px 13px; border-radius: 13px; font-size: 13px; }
        }    </style>
</head>
<body>

    <div class="sidebar">
        <div class="sidebar-header">
            <h3>Chats</h3>
            <small>Logged in as: <b><%= ub.getName() %></b></small>
        </div>

        <div class="search-container">
            <input type="text" id="userSearch" class="search-box" placeholder="Search friends..." onkeyup="filterUsers()">
        </div>
        
        <div style="display:flex;gap:6px;padding:8px 14px;">
            <button type="button" onclick="setConversationFilter('all')" class="conversation-filter-btn" data-filter="all">All</button>
            <button type="button" onclick="setConversationFilter('unread')" class="conversation-filter-btn" data-filter="unread">Unread</button>
            <button type="button" onclick="setConversationFilter('archived')" class="conversation-filter-btn" data-filter="archived">Archived</button>
        </div>
        <div id="friendListContainer">
            <c:choose>
                <c:when test="${empty pageScope.dbFriendList}">
                    <p id="noFriendsMsg" style="padding:20px; color:#999; text-align:center;">No friends found. Add friends to start chatting.</p>
                </c:when>
                <c:otherwise>
                    <c:forEach var="friend" items="${pageScope.dbFriendList}">
                        <div class="friend-item" id="friend-item-${friend.getName()}" data-username="${friend.getName()}" data-userid="${friend.getId()}" data-unread="${pageScope.unreadPartnerNames.contains(friend.getName())}" data-archived="${pageScope.archivedPartnerNames.contains(friend.getName())}" onclick="openChat('${friend.getName()}', this)">
                            <div class="avatar">
                                <img src="img/${not empty friend.getProfile_pic() ? friend.getProfile_pic() : 'default.png'}" alt="${friend.getName()}" style="width:100%; height:100%; border-radius:50%; object-fit:cover;" onerror="this.onerror=null; this.src='img/default.png';">
                                <div class="status-dot offline"></div>
                            </div>
                            <div class="friend-info" style="flex:1; min-width:0;">
                                <b style="font-size:15px; display:block; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"><c:out value="${friend.getName()}" /></b>
                                <span id="status-text-${friend.getName()}"><small style="color:#94a3b8;">Offline</small></span>
                            </div>
                            <div class="friend-call-actions">
                                <button type="button" class="friend-call-btn voice" onclick="event.stopPropagation(); quickCallFriend('${friend.getName()}', 'voice', this.closest('.friend-item'))" title="Voice Call ${friend.getName()}"><i class="fa-solid fa-phone"></i></button>
                                <button type="button" class="friend-call-btn video" onclick="event.stopPropagation(); quickCallFriend('${friend.getName()}', 'video', this.closest('.friend-item'))" title="Video Call ${friend.getName()}"><i class="fa-solid fa-video"></i></button>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <a href="UsersPostServlet" class="back-link">← Home</a>
    </div>

    <div class="main-chat">
        <div class="chat-header" style="position:relative">
            <div style="display: flex; align-items: center; min-width: 0; flex: 1;">
                <button class="mobile-back-btn" onclick="backToSidebar()"><i class="fa fa-arrow-left"></i></button>
                <div style="min-width: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                    <span style="font-size: 13px; color: #64748b;">Chat:</span> <span id="chattingWith">None</span>
                    <span id="chatHeaderStatus"></span>
                    <span id="typingIndicator" style="display:none; color:#16a34a; font-size:13px; font-weight:500; font-style:italic; margin-left:8px;"><i class="fa-solid fa-pen-nib"></i> typing...</span>
                    <input type="hidden" id="targetFriendName" value="None">
                </div>
            </div>
            <div id="conversationTools" style="display:none;align-items:center;gap:8px;">
                <input type="search" id="chatMessageSearch" placeholder="Search messages in this chat" oninput="filterChatMessages(this.value)" style="max-width:220px;padding:7px 10px;border:1px solid #ddd6fe;border-radius:10px;font-size:12px;">
                <select id="chatMessageTypeFilter" aria-label="Filter messages" onchange="filterChatMessages(document.getElementById('chatMessageSearch').value)" style="padding:7px;border:1px solid #ddd6fe;border-radius:9px;font-size:12px"><option value="all">All</option><option value="text">Text</option><option value="media">Media</option><option value="pinned">Pinned</option></select>
                <button type="button" onclick="togglePinnedMessagesPanel()" title="Pinned messages" aria-label="Show pinned messages" style="border:0;background:#f3e8ff;color:#7e22ce;border-radius:9px;padding:7px 10px;cursor:pointer"><i class="fa-solid fa-thumbtack"></i></button>
                <button type="button" id="archiveConversationBtn" onclick="toggleCurrentConversationArchive()" title="Archive conversation" style="border:0;background:#f3e8ff;color:#7e22ce;border-radius:9px;padding:7px 10px;cursor:pointer;"><i class="fa-solid fa-box-archive"></i></button>
            </div>
            <div id="pinnedMessagesPanel" hidden style="position:absolute;right:110px;top:66px;z-index:30;width:min(340px,calc(100vw - 40px));max-height:55vh;overflow:auto;padding:12px;background:white;border:1px solid #ddd6fe;border-radius:14px;box-shadow:0 12px 32px #0002"></div>
            <div style="display:flex;align-items:center;gap:10px;flex-shrink:0;">
                <a href="NotificationServlet" aria-label="Notifications" style="position:relative;color:#6d28d9;font-size:18px;"><i class="fa fa-bell"></i></a>
            <div class="call-buttons active" id="callButtons">
                <i class="fa-solid fa-wand-magic-sparkles" id="summarizeChatBtn" onclick="summarizeCurrentChat()" title="Summarize conversation with Gemini AI" style="color:#a855f7; cursor:pointer;"></i>
                <i class="fa-solid fa-phone" onclick="startVoiceCall()" title="Voice Call"></i>
                <i class="fa-solid fa-video" onclick="startVideoCall()" title="Video Call"></i>
                <i class="fa-solid fa-shield-halved" id="blockUserChatBtn" onclick="toggleBlockCurrentChatUser()" title="Block / Unblock this user" style="color:#e11d48; cursor:pointer; font-size:18px;"></i>
            </div>
            </div>
        </div>

        <!-- Blocked User Warning Banner -->
        <div id="chatBlockedBanner" style="display:none; padding:10px 16px; background:#fff1f2; border-bottom:1px solid #fecdd3; color:#be123c; font-size:13px; font-weight:600; align-items:center; justify-content:space-between;">
            <div style="display:flex; align-items:center; gap:8px;">
                <i class="fa-solid fa-ban" style="color:#e11d48; font-size:15px;"></i>
                <span>You have blocked this user or are blocked from messaging each other.</span>
            </div>
            <button type="button" onclick="unblockCurrentChatUser()" style="padding:4px 12px; background:#e11d48; color:white; border-radius:8px; font-size:11px; font-weight:bold; border:none; cursor:pointer;">Unblock</button>
        </div>

        <div id="chatBox">
            <div style="text-align:center; color:#999; margin-top:150px;">Select a user to chat</div>
            <div id="chatTypingBubble" class="typing-bubble" style="display:none;"><span class="dot"></span><span class="dot"></span><span class="dot"></span></div>
        </div>

        <!-- 笞｡ AI Smart Auto-Reply Bar -->
        <div id="smartRepliesBar" style="display:none; padding:7px 16px; background:#f8fafc; border-top:1px solid #e2e8f0; align-items:center; gap:8px; overflow-x:auto;">
            <span style="font-size:11px; font-weight:700; color:#9333ea; white-space:nowrap; display:flex; align-items:center; gap:4px;">
                <i class="fa-solid fa-bolt"></i> Smart Reply:
            </span>
            <div id="smartRepliesChips" style="display:flex; gap:6px; flex-wrap:nowrap; overflow-x:auto; flex:1;"></div>
            <button onclick="dismissSmartReplies()" style="background:none; border:none; color:#94a3b8; cursor:pointer; font-size:14px; padding:2px 6px;" title="Dismiss">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <!-- 町 Quote Reply Preview Bar -->
        <div id="replyPreviewBar" style="display:none; padding:8px 16px; background:#f8fafc; border-top:1px solid #e2e8f0; border-left:4px solid #9333ea; align-items:center; justify-content:space-between; z-index:10;">
            <div style="font-size:12px; color:#475569; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:85%;">
                <span style="font-weight:700; color:#9333ea;" id="replySenderLabel">Replying to:</span>
                <span id="replyTextSnippet" style="margin-left:6px; font-style:italic;"></span>
            </div>
            <button onclick="cancelReplyQuote()" style="background:none; border:none; color:#64748b; font-size:16px; cursor:pointer;" title="Cancel Reply"><i class="fa-solid fa-xmark"></i></button>
        </div>

        <!-- Floating Animated GIF Picker Popover in Chat -->
        <div id="chatGifPicker" style="display:none; position:absolute; bottom:65px; left:12px; width:330px; max-height:380px; background:white; border:1px solid #e2e8f0; border-radius:18px; box-shadow:0 20px 45px rgba(0,0,0,0.18); z-index:9999; flex-direction:column; overflow:hidden;">
            <div style="padding:10px 14px; border-bottom:1px solid #f1f5f9; display:flex; justify-content:space-between; align-items:center; background:#faf5ff;">
                <span style="font-weight:700; font-size:13px; color:#1e293b; display:flex; align-items:center; gap:6px;">
                    <span style="background:#db2777; color:white; font-size:10px; font-weight:900; padding:2px 5px; border-radius:4px;">GIF</span>
                    Animated Stickers & GIFs
                </span>
                <button type="button" onclick="toggleChatGifPicker()" style="background:none; border:none; color:#94a3b8; font-size:16px; cursor:pointer;"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div style="padding:8px 12px; background:#f8fafc; border-bottom:1px solid #f1f5f9;">
                <input type="text" id="chatGifSearchInput" placeholder="Search animated GIFs..." oninput="debounceChatGifSearch(this.value)" style="width:100%; box-sizing:border-box; padding:6px 10px; font-size:12px; border:1px solid #cbd5e1; border-radius:10px; outline:none;">
                <div style="display:flex; gap:6px; overflow-x:auto; margin-top:6px; padding-bottom:2px;">
                    <button type="button" onclick="loadChatGifs('')" style="font-size:10px; font-weight:700; padding:2px 8px; border-radius:10px; border:none; background:#db2777; color:white; cursor:pointer;">Trending</button>
                    <button type="button" onclick="loadChatGifs('happy')" style="font-size:10px; font-weight:700; padding:2px 8px; border-radius:10px; border:1px solid #e2e8f0; background:white; color:#475569; cursor:pointer;">Happy</button>
                    <button type="button" onclick="loadChatGifs('love')" style="font-size:10px; font-weight:700; padding:2px 8px; border-radius:10px; border:1px solid #e2e8f0; background:white; color:#475569; cursor:pointer;">Love</button>
                    <button type="button" onclick="loadChatGifs('dance')" style="font-size:10px; font-weight:700; padding:2px 8px; border-radius:10px; border:1px solid #e2e8f0; background:white; color:#475569; cursor:pointer;">Dance</button>
                    <button type="button" onclick="loadChatGifs('applause')" style="font-size:10px; font-weight:700; padding:2px 8px; border-radius:10px; border:1px solid #e2e8f0; background:white; color:#475569; cursor:pointer;">Clap</button>
                    <button type="button" onclick="loadChatGifs('laugh')" style="font-size:10px; font-weight:700; padding:2px 8px; border-radius:10px; border:1px solid #e2e8f0; background:white; color:#475569; cursor:pointer;">Haha</button>
                </div>
            </div>
            <div id="chatGifGrid" style="display:grid; grid-template-columns:1fr 1fr; gap:6px; padding:10px; max-height:240px; overflow-y:auto;">
                <!-- Populated by JS -->
            </div>
        </div>

        <div class="input-area" style="position:relative;">
            <button type="button" onclick="insertGeminiPrompt()" title="Ask Gemini AI in chat (@gemini)" style="background:none; border:none; color:#9333ea; font-size:18px; cursor:pointer; padding:0 6px;"><i class="fa-solid fa-wand-magic-sparkles"></i></button>
            <button type="button" id="voiceBtn" onclick="toggleVoiceRecording()" title="Record Voice Note" style="background:none; border:none; color:#a855f7; font-size:18px; cursor:pointer; padding:0 8px;"><i class="fa fa-microphone"></i></button>
            <input type="file" id="chatFileInput" style="display:none;" onchange="uploadChatAttachment(this)">
            <button type="button" onclick="document.getElementById('chatFileInput').click()" style="background:none; border:none; color:#64748b; font-size:18px; cursor:pointer; padding:0 8px;" title="Attach File / Image"><i class="fa fa-paperclip"></i></button>
                        <button type="button" onclick="toggleChatGifPicker()" style="background:#fce7f3; border:1px solid #fbcfe8; color:#db2777; font-size:11px; font-weight:900; border-radius:8px; padding:3px 7px; cursor:pointer; margin-right:4px;" title="Send animated GIF">GIF</button>
            <input type="text" id="messageText" placeholder="Type a message or @gemini to ask AI..." oninput="notifyTyping()" onkeypress="if(event.key==='Enter') sendToFriend()">
            <button class="btn-send" onclick="sendToFriend()">Send</button>
            <div id="recordingBadge" style="display:none; position:absolute; left:50px; top:-40px; background:#ef4444; color:white; padding:6px 14px; border-radius:20px; font-size:12px; font-weight:bold; align-items:center; gap:8px; shadow:0 4px 12px rgba(239,68,68,0.4);">
                <span style="width:8px; height:8px; background:white; border-radius:50%; animation:ping 1s infinite;"></span> Recording Voice Note... <span id="recordTimer">00:00</span>
            </div>
        </div>
    </div>

    <!-- ｪ・AI Conversation Summary Modal -->
    <div id="aiSummaryModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.55); backdrop-filter:blur(5px); z-index:99999; align-items:center; justify-content:center;">
        <div style="background:white; border-radius:20px; padding:24px; width:92%; max-width:520px; box-shadow:0 25px 50px rgba(0,0,0,0.3); display:flex; flex-direction:column; max-height:85vh;">
            <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px; border-bottom:1px solid #f1f5f9; padding-bottom:10px;">
                <div style="display:flex; align-items:center; gap:8px;">
                    <div style="width:34px; height:34px; border-radius:50%; background:linear-gradient(135deg, #9333ea, #ec4899); display:flex; align-items:center; justify-content:center; color:white; font-size:16px;">
                        <i class="fa-solid fa-wand-magic-sparkles"></i>
                    </div>
                    <div>
                        <h3 style="margin:0; font-size:17px; font-weight:700; color:#1e293b;">AI Conversation Summary</h3>
                        <small style="color:#94a3b8; font-size:11px;">Powered by Gemini AI</small>
                    </div>
                </div>
                <button onclick="closeSummaryModal()" style="background:none; border:none; color:#64748b; font-size:18px; cursor:pointer;"><i class="fa-solid fa-xmark"></i></button>
            </div>
            
            <div id="aiSummaryBody" style="flex:1; overflow-y:auto; font-size:14px; line-height:1.6; color:#334155; padding:8px 4px; white-space:pre-wrap;"></div>

            <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:16px; border-top:1px solid #f1f5f9; padding-top:12px;">
                <button id="copySummaryBtn" onclick="copySummaryText()" style="background:#f3e8ff; color:#7e22ce; border:none; padding:8px 16px; border-radius:20px; font-weight:600; cursor:pointer; font-size:13px; display:inline-flex; align-items:center; gap:6px;">
                    <i class="fa-regular fa-copy"></i> Copy Summary
                </button>
                <button onclick="closeSummaryModal()" style="background:#9333ea; color:white; border:none; padding:8px 18px; border-radius:20px; font-weight:700; cursor:pointer; font-size:13px;">
                    Close
                </button>
            </div>
        </div>
    </div>

    <!-- 笨擾ｸ・Message Edit Modal -->
    <div id="editMsgModal" style="display:none; position:fixed; inset:0; background:rgba(0,0,0,0.5); backdrop-filter:blur(4px); z-index:99999; align-items:center; justify-content:center;">
        <div style="background:white; border-radius:18px; padding:22px; width:90%; max-width:420px; box-shadow:0 20px 40px rgba(0,0,0,0.25);">
            <h3 style="margin-top:0; font-size:17px; font-weight:700; color:#1e293b; margin-bottom:12px;"><i class="fa-solid fa-pen-to-square" style="color:#9333ea;"></i> Edit Message</h3>
            <textarea id="editMsgInput" rows="3" style="width:100%; border:1px solid #cbd5e1; border-radius:12px; padding:10px 14px; font-size:14px; outline:none; resize:none; font-family:inherit; box-sizing:border-box;"></textarea>
            <input type="hidden" id="editMsgId">
            <div style="display:flex; justify-content:flex-end; gap:10px; margin-top:14px;">
                <button type="button" onclick="closeEditModal()" style="background:#f1f5f9; border:none; color:#475569; padding:8px 16px; border-radius:20px; font-weight:600; cursor:pointer;">Cancel</button>
                <button type="button" onclick="submitEditMessage()" style="background:#9333ea; border:none; color:white; padding:8px 20px; border-radius:20px; font-weight:700; cursor:pointer;">Save Changes</button>
            </div>
        </div>
    </div>

    <!-- 到 Calling System HTML Overlay -->
    <div id="callOverlay" class="call-overlay">
        <div class="call-container" id="callContainer">
            <!-- Top Header Bar for Video Call -->
            <div id="callTopBar" class="call-top-bar">
                <div class="call-top-info">
                    <span style="width: 10px; height: 10px; background: #22c55e; border-radius: 50%; box-shadow: 0 0 10px #22c55e; display: inline-block;"></span>
                    <span id="callTopUsername" style="color: white; font-weight: 700;">User</span>
                    <span id="callTopTimer" style="color: #cbd5e1; font-size: 13px; margin-left: 6px;">00:00</span>
                </div>
                <button class="call-top-btn" onclick="toggleCallFullscreen()" title="Toggle Fullscreen">
                    <i id="fullscreenIcon" class="fa-solid fa-expand"></i>
                </button>
            </div>

            <!-- Pulsing Rings (Only during Calling/Ringing) -->
            <div id="callingRings" class="pulsing-rings-wrap" style="position: absolute; width: 140px; height: 140px; top: 65px; display: none; z-index: 1;">
                <div class="pulsing-rings"></div>
                <div class="pulsing-rings"></div>
            </div>

            <!-- Call Info Display -->
            <div id="callInfoBox" style="position: relative; z-index: 2; margin-top: 10px;">
                <div class="call-avatar" id="callAvatar">Y</div>
                <h2 class="call-username" id="callUsername">Username</h2>
                <div class="call-status" id="callStatus">Calling...</div>
            </div>

            <!-- Voice Waves (Only active during voice call) -->
            <div class="voice-waves" id="voiceWaves" style="position: relative; z-index: 2;">
                <div class="voice-wave-bar"></div>
                <div class="voice-wave-bar"></div>
                <div class="voice-wave-bar"></div>
                <div class="voice-wave-bar"></div>
                <div class="voice-wave-bar"></div>
                <div class="voice-wave-bar"></div>
                <div class="voice-wave-bar"></div>
            </div>

            <!-- Call Action Controls (Accept/Decline) -->
            <div class="call-actions" id="callActions" style="position: relative; z-index: 2;">
                <button class="call-btn call-btn-decline" id="declineBtn" onclick="declineCall()" title="Decline Call"><i class="fa-solid fa-phone-slash"></i></button>
                <button class="call-btn call-btn-accept" id="acceptBtn" onclick="acceptCall()" title="Accept Call"><i class="fa-solid fa-phone"></i></button>
            </div>

            <!-- Video Session Grid -->
            <div class="video-grid" id="videoGrid">
                <div class="remote-video-container">
                    <video id="remoteVideo" autoplay playsinline></video>
                    <!-- Fallback simulated remote avatar/canvas if no feed -->
                    <div id="remoteAvatarFallback" style="display: none; position: absolute; font-size: 80px; font-weight: bold; color: rgba(255,255,255,0.2);">Remote</div>
                </div>
                <div class="local-video-container">
                    <video id="localVideo" autoplay playsinline muted></video>
                </div>
            </div>

            <!-- Dedicated Audio Receiver for Voice & Video Calls -->
            <audio id="remoteAudio" autoplay playsinline style="position:fixed;top:-9999px;left:-9999px;width:1px;height:1px;opacity:0.001;pointer-events:none;"></audio>

            <!-- Toast notification for Loudspeaker Toggle -->
            <div id="callSpeakerToast" class="call-speaker-toast"><i class="fa-solid fa-volume-high"></i> Loudspeaker ON</div>

            <!-- Active Call Controls (Visible for both Voice & Video) -->
            <div class="active-call-controls" id="activeCallControls" style="display: none;">
                <button class="call-btn call-btn-mute" id="muteMicBtn" onclick="toggleMuteMic()" title="Mute/Unmute Mic"><i class="fa-solid fa-microphone"></i></button>
                <button class="call-btn call-btn-mute" id="toggleCamBtn" onclick="toggleCamera()" title="Turn Camera On/Off"><i class="fa-solid fa-video"></i></button>
                <button class="call-btn call-btn-speaker" id="toggleSpeakerBtn" onclick="toggleLoudspeaker()" title="Loudspeaker: OFF (Click for Loudspeaker)"><i id="speakerIcon" class="fa-solid fa-volume-low"></i></button>
                <button class="call-btn call-btn-mute" id="dockFullscreenBtn" onclick="toggleCallFullscreen()" title="Fullscreen"><i class="fa-solid fa-expand"></i></button>
                <button class="call-btn call-btn-decline" onclick="endCall()" title="End Call"><i class="fa-solid fa-phone-slash"></i></button>
            </div>
        </div>
    </div>

    <script>
        var socket = null;
        var myName = "${ub.getName()}";
        var contextPath = "${pageContext.request.contextPath}";
        var cleanContextPath = contextPath || "";
        var typingTimeout = null;
        var isCurrentlyTyping = false;
        var reconnectTimer = null;

        // 七 Web Audio Notification Chime (Zero external dependencies)
        function playMessageChime() {
            try {
                var AudioCtx = window.AudioContext || window.webkitAudioContext;
                if (!AudioCtx) return;
                var ctx = new AudioCtx();
                var osc = ctx.createOscillator();
                var gain = ctx.createGain();
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.type = 'sine';
                osc.frequency.setValueAtTime(659.25, ctx.currentTime); // E5
                osc.frequency.exponentialRampToValueAtTime(880.00, ctx.currentTime + 0.12); // A5
                gain.gain.setValueAtTime(0.2, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.35);
                osc.start(ctx.currentTime);
                osc.stop(ctx.currentTime + 0.35);
            } catch (e) {
                console.log("Audio chime error:", e);
            }
        }

        // 粕 System / Browser Push Notification
        function requestNotificationPermission() {
            if ("Notification" in window && Notification.permission === "default") {
                Notification.requestPermission();
                document.addEventListener("visibilitychange", function() {
                    if (document.visibilityState === "visible") {
                        if (!socket || socket.readyState !== WebSocket.OPEN) {
                            initWebSocket();
                        }
                    }
                });
                window.addEventListener("pageshow", function() {
                    if (!socket || socket.readyState !== WebSocket.OPEN) {
                        initWebSocket();
                    }
                });
            }
        }

        function triggerNotification(sender, text) {
            playMessageChime();
            if ("Notification" in window && Notification.permission === "granted" && document.hidden) {
                try {
                    let cleanText = text;
                    if (cleanText && cleanText.startsWith("{") && cleanText.includes("\"message\":")) {
                        try { cleanText = JSON.parse(cleanText).message; } catch(e) {}
                    }
                    if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
                        navigator.serviceWorker.ready.then(reg => {
                            reg.showNotification("yChat: " + sender, {
                                body: cleanText,
                                icon: contextPath + "/icons/icon-192.png",
                                badge: contextPath + "/icons/icon-192.png"
                            });
                        });
                    } else {
                        new Notification("yChat: " + sender, {
                            body: cleanText,
                            icon: contextPath + "/icons/icon-192.png"
                        });
                    }
                } catch (e) {}
            }
        }

        // 竚ｨ・・Typing Indicator Dispatch
        function notifyTyping() {
            var friend = document.getElementById("targetFriendName").value;
            if (friend === "None" || !socket || socket.readyState !== WebSocket.OPEN) return;

            if (!isCurrentlyTyping) {
                isCurrentlyTyping = true;
                socket.send("TYPING|" + friend + "|typing");
            }
            clearTimeout(typingTimeout);
            typingTimeout = setTimeout(function() {
                isCurrentlyTyping = false;
                if (socket && socket.readyState === WebSocket.OPEN) {
                    socket.send("TYPING|" + friend + "|stopped");
                }
            }, 2000);
        }

        function initWebSocket() {
            if (socket && (socket.readyState === WebSocket.OPEN || socket.readyState === WebSocket.CONNECTING)) {
                return;
            }
            var protocol = window.location.protocol === "https:" ? "wss://" : "ws://";
            var host = window.location.host;
            var wsUrl = protocol + host + cleanContextPath + "/ws/user/" + encodeURIComponent(myName);

            try {
                socket = new WebSocket(wsUrl);
            } catch (e) {
                console.error("WebSocket create error:", e);
                scheduleReconnect();
                return;
            }

            socket.onopen = function(event) {
                console.log("WebSocket Connected successfully to: " + wsUrl);
                clearTimeout(reconnectTimer);
                if (window.messagesPingTimer) clearInterval(window.messagesPingTimer);
                window.messagesPingTimer = setInterval(function() {
                    if (socket && socket.readyState === WebSocket.OPEN) {
                        socket.send("PING|server|heartbeat");
                    }
                }, 25000);
            };

            socket.onerror = function(event) {
                console.error("WebSocket Error:", event);
            };

            socket.onclose = function(event) {
                if (window.messagesPingTimer) clearInterval(window.messagesPingTimer);
                console.log("WebSocket Closed. Attempting reconnect in 3s...");
                scheduleReconnect();
            };

            socket.onmessage = function(event) {
                var data = event.data;
                if (data.startsWith("ONLINE_USERS|")) {
                    updateFriendList(data.substring(13).split(","));
                } else if (data.startsWith("CHAT|")) {
                    var parts = data.split("|", 3);
                    var sender = parts[1];
                    var content = parts[2];
                    var currentFriend = document.getElementById("targetFriendName").value;
                    if (currentFriend === sender || sender === "Gemini AI") {
                        let parsed = null;
                        try {
                            if (content.startsWith("{") && content.includes("\"message\":")) {
                                parsed = JSON.parse(content);
                            }
                        } catch(e) {}
                        displayMessage(parsed || content, (parsed && parsed.sender === myName) ? 'sent' : 'received');
                        playMessageChime();
                        if (socket && socket.readyState === WebSocket.OPEN && sender !== "Gemini AI") {
                            socket.send("SEEN|" + sender);
                        }
                        // Smart auto-reply trigger when receiving message from friend
                        if (sender !== myName && sender !== "Gemini AI") {
                            let textForReplies = (parsed && parsed.message) ? parsed.message : content;
                            if (textForReplies && !textForReplies.startsWith("img/")) {
                                fetchSmartReplies(textForReplies);
                            }
                        }
                    } else {
                        triggerNotification(sender, content);
                        highlightUnreadFriend(sender);
                    }
                } else if (data.startsWith("CHAT_ACK|")) {
                    var parts = data.split("|", 3);
                    try {
                        var ackObj = JSON.parse(parts[2]);
                        if (ackObj && ackObj.id) {
                            var tempRows = document.querySelectorAll("#chatBox .msg-row[id^='msg-row-temp_']");
                            if (tempRows.length > 0) {
                                var lastTempRow = tempRows[tempRows.length - 1];
                                var oldId = lastTempRow.id.replace("msg-row-", "");
                                lastTempRow.id = "msg-row-" + ackObj.id;
                                var msgBubble = lastTempRow.querySelector("#msg-" + oldId);
                                if (msgBubble) msgBubble.id = "msg-" + ackObj.id;
                                var pill = lastTempRow.querySelector("#reaction-pill-" + oldId);
                                if (pill) pill.id = "reaction-pill-" + ackObj.id;
                                var picker = lastTempRow.querySelector("#reaction-picker-" + oldId);
                                if (picker) picker.id = "reaction-picker-" + ackObj.id;
                                var actions = lastTempRow.querySelector("#actions-" + oldId);
                                if (actions) actions.id = "actions-" + ackObj.id;
                            }
                        }
                    } catch(e) {}
                } else if (data.startsWith("EDIT_MSG|") || data.startsWith("EDIT_MSG_ACK|")) {
                    var parts = data.split("|", 3);
                    try {
                        var obj = JSON.parse(parts[2]);
                        applyEditedMessage(obj.id, obj.text);
                    } catch(e) {}
                } else if (data.startsWith("DELETE_MSG|") || data.startsWith("DELETE_MSG_ACK|")) {
                    var parts = data.split("|", 3);
                    try {
                        var obj = JSON.parse(parts[2]);
                        applyDeletedMessage(obj.id);
                    } catch(e) {}
                } else if (data.startsWith("REACTION|") || data.startsWith("REACTION_ACK|")) {
                    var parts = data.split("|", 3);
                    try {
                        var obj = JSON.parse(parts[2]);
                        applyReaction(obj.id, obj.reaction);
                    } catch(e) {}
                } else if (data.startsWith("SEEN|")) {
                    var parts = data.split("|", 2);
                    var seenFrom = parts[1];
                    var currentFriend = document.getElementById("targetFriendName").value;
                    if (currentFriend === seenFrom) {
                        document.querySelectorAll("#chatBox .msg-row.sent .msg-status, #chatBox .msg.sent .msg-status").forEach(el => {
                            el.innerHTML = " ✓ Seen";
                            el.style.color = "#38bdf8";
                            el.style.opacity = "1";
                        });
                    }
                } else if (data.startsWith("TYPING|")) {
                    var parts = data.split("|", 3);
                    var sender = parts[1];
                    var state = parts[2];
                    var currentFriend = document.getElementById("targetFriendName").value;
                    if (currentFriend === sender || sender === "Gemini AI") {
                        var ind = document.getElementById("typingIndicator");
                        if (ind) {
                            ind.style.display = (state === "typing") ? "inline-block" : "none";
                            if (sender === "Gemini AI") {
                                ind.innerHTML = '<i class="fa-solid fa-wand-magic-sparkles"></i> Gemini is thinking...';
                            } else {
                                ind.innerHTML = '<i class="fa-solid fa-pen-nib"></i> typing...';
                            }
                        }
                        var bubble = document.getElementById("chatTypingBubble");
                try { window.dispatchEvent(new CustomEvent('ychat:notification')); } catch(e){}
                        if (bubble) {
                            bubble.style.display = (state === "typing") ? "inline-flex" : "none";
                            if (state === "typing") {
                                var chatBox = document.getElementById("chatBox");
                                if (chatBox) chatBox.scrollTop = chatBox.scrollHeight;
                            }
                        }
                    }
                } else if (data.startsWith("NOTIF|")) {
                    window.dispatchEvent(new Event("ychat:notification"));
                } else if (data.startsWith("CALL_OFFER|")) {
                    var parts = data.split("|", 3);
                    handleCallOffer(parts[1], JSON.parse(parts[2]));
                } else if (data.startsWith("CALL_ANSWER|")) {
                    var parts = data.split("|", 3);
                    handleCallAnswer(parts[1], JSON.parse(parts[2]));
                } else if (data.startsWith("ICE_CANDIDATE|")) {
                    var parts = data.split("|", 3);
                    handleIceCandidate(parts[1], JSON.parse(parts[2]));
                } else if (data.startsWith("CALL_REJECT|")) {
                    var parts = data.split("|", 3);
                    handleCallReject(parts[1]);
                } else if (data.startsWith("CALL_END|")) {
                    var parts = data.split("|", 3);
                    handleCallEnd(parts[1]);
                } else if (data.startsWith("WEBRTC_ANSWER|")) {
                    var parts = data.split("|", 3);
                    handleWebRTCAnswer(parts[1], JSON.parse(parts[2]));
                }
            };
        }

        function scheduleReconnect() {
            clearTimeout(reconnectTimer);
            reconnectTimer = setTimeout(function() {
                initWebSocket();
            }, 3000);
        }

        function highlightUnreadFriend(friendName) {
            var items = document.getElementsByClassName('friend-item');
            for (var i = 0; i < items.length; i++) {
                var nameEl = items[i].getElementsByTagName('b')[0];
                if (nameEl && nameEl.innerText.trim() === friendName) {
                    items[i].dataset.unread = 'true';
                    items[i].style.backgroundColor = '#fae8ff';
                    var badge = items[i].querySelector('.unread-dot');
                    if (!badge) {
                        var dot = document.createElement('span');
                        dot.className = 'unread-dot';
                        dot.style.cssText = 'width:8px; height:8px; background:#a855f7; border-radius:50%; margin-left:auto; display:inline-block;';
                        items[i].appendChild(dot);
                    }
                    break;
                }
            }
        }

        var activeOnlineUsers = new Set();

        window.onload = function() {
            requestNotificationPermission();
            initWebSocket();

            // 櫨 Check for deep link (?userName=... or ?userId=...)
            const urlParams = new URLSearchParams(window.location.search);
            let targetUser = urlParams.get('userName');
            if (!targetUser || targetUser.trim() === "") {
                targetUser = "<%= (targetUserBean != null) ? targetUserBean.getName().replace("\"", "\\\"") : "" %>";
            }
            if (targetUser && targetUser.trim() !== "") {
                targetUser = targetUser.trim();
                window.targetToOpen = targetUser;
                let item = document.getElementById("friend-item-" + targetUser);
                if (item) {
                    openChat(targetUser, item);
                    window.targetToOpen = null;
                }
                const autoCallAction = urlParams.get('callAction');
                const autoCallType = urlParams.get('callType') || 'voice';
                if (autoCallAction === 'accept') {
                    let acceptAttempts = 0;
                    function triggerAutoAccept() {
                        if (socket && socket.readyState === WebSocket.OPEN) {
                            initAudio();
                            isCaller = false;
                            currentCallFriend = targetUser;
                            callType = autoCallType;

                            document.getElementById("callOverlay").style.display = "flex";
                            document.getElementById("callingRings").style.display = "block";
                            document.getElementById("callAvatar").innerText = targetUser.charAt(0).toUpperCase();
                            document.getElementById("callUsername").innerText = targetUser;
                            document.getElementById("callStatus").innerText = "Connecting...";
                            document.getElementById("acceptBtn").style.display = "none";
                            document.getElementById("declineBtn").style.display = "flex";
                            document.getElementById("videoGrid").style.display = "none";
                            document.getElementById("voiceWaves").style.display = "none";

                            socket.send("CALL_ANSWER|" + targetUser + "|" + JSON.stringify({ status: "accepted" }));
                            startPeerConnection();
                        } else if (acceptAttempts++ < 30) {
                            setTimeout(triggerAutoAccept, 150);
                        }
                    }
                    triggerAutoAccept();
                } else if (autoCallAction === 'call') {
                    let callAttempts = 0;
                    function triggerAutoCall() {
                        if (socket && socket.readyState === WebSocket.OPEN) {
                            initiateCall(autoCallType);
                        } else if (callAttempts++ < 30) {
                            setTimeout(triggerAutoCall, 150);
                        }
                    }
                    triggerAutoCall();
                }
            }
        };

        // 櫨 SEARCH FILTER LOGIC
        let conversationFilter = 'all';
        function setConversationFilter(filter) {
            conversationFilter = filter;
            document.querySelectorAll('.conversation-filter-btn').forEach(b => b.classList.toggle('active', b.dataset.filter === filter));
            filterUsers();
        }
        function filterChatMessages(query) {
            const needle = (query || '').trim().toLowerCase();
            const mode = document.getElementById('chatMessageTypeFilter')?.value || 'all';
            const friend = document.getElementById('targetFriendName')?.value || '';
            document.querySelectorAll('#chatBox .msg-row').forEach(row => {
                const queryMatch = !needle || row.innerText.toLowerCase().includes(needle);
                const pinned = isPinnedMessage(friend, row.id.replace('msg-row-', ''));
                const typeMatch = mode === 'all' || (mode === 'text' && row.dataset.messageType === 'text') || (mode === 'media' && row.dataset.messageType === 'media') || (mode === 'pinned' && pinned);
                row.style.display = queryMatch && typeMatch ? '' : 'none';
            });
        }

        function getPinnedMessageMap() { try { return JSON.parse(localStorage.getItem('ychat-pinned-messages') || '{}') || {}; } catch(e) { return {}; } }
        function isPinnedMessage(friend, id) { return (getPinnedMessageMap()[friend] || []).some(item => String(item.id) === String(id)); }
        function pinCurrentMessage(id) {
            const friend = document.getElementById('targetFriendName').value;
            if (!friend || friend === 'None') return;
            const row = document.getElementById('msg-row-' + id);
            const text = row ? (row.querySelector('.msg-text-content')?.innerText || row.innerText || 'Media message').trim().slice(0,180) : 'Message';
            const map = getPinnedMessageMap(); const list = map[friend] || []; const existing = list.findIndex(item => String(item.id) === String(id));
            if (existing >= 0) list.splice(existing,1); else list.push({id:String(id), text, sender:row?.classList.contains('sent')?myName:friend});
            map[friend] = list; localStorage.setItem('ychat-pinned-messages',JSON.stringify(map));
            const button = document.querySelector('#actions-' + CSS.escape(String(id)) + ' .pin-message-btn');
            if (button) { const pinned = isPinnedMessage(friend,id); button.title = pinned ? 'Unpin message' : 'Pin message'; button.innerHTML = pinned ? '<i class="fa-solid fa-thumbtack"></i>' : '<i class="fa-solid fa-thumbtack" style="opacity:.45"></i>'; }
            renderPinnedMessages(); filterChatMessages(document.getElementById('chatMessageSearch')?.value || '');
        }
        function togglePinnedMessagesPanel() { const panel=document.getElementById('pinnedMessagesPanel'); if(!panel)return; panel.hidden=!panel.hidden; renderPinnedMessages(); }
        function renderPinnedMessages() {
            const panel=document.getElementById('pinnedMessagesPanel'); if(!panel)return;
            const friend=document.getElementById('targetFriendName')?.value || ''; const list=getPinnedMessageMap()[friend] || [];
            panel.replaceChildren();
            const heading=document.createElement('strong'); heading.textContent='Pinned messages'; panel.append(heading);
            if(!list.length){const empty=document.createElement('p');empty.textContent='No pinned messages in this chat yet.';empty.style.color='#64748b';panel.append(empty);return;}
            list.forEach(item=>{const row=document.createElement('div');row.style.cssText='display:flex;gap:8px;align-items:flex-start;padding:8px 0;border-bottom:1px solid #eee';const jump=document.createElement('button');jump.type='button';jump.textContent=item.text;jump.style.cssText='flex:1;text-align:left;border:0;background:transparent;color:#334155;cursor:pointer';jump.onclick=()=>{panel.hidden=true;scrollToMessage(item.id);};const unpin=document.createElement('button');unpin.type='button';unpin.textContent='Unpin';unpin.style.cssText='border:0;background:transparent;color:#be123c;cursor:pointer';unpin.onclick=()=>pinCurrentMessage(item.id);row.append(jump,unpin);panel.append(row);});
        }

        function filterUsers() {
            var input = (document.getElementById('userSearch').value || "").toLowerCase().trim();
            var items = document.getElementsByClassName('friend-item');

            for (var i = 0; i < items.length; i++) {
                var usernameAttr = (items[i].getAttribute('data-username') || "").toLowerCase();
                var bName = (items[i].getElementsByTagName('b')[0] ? items[i].getElementsByTagName('b')[0].innerText : "").toLowerCase();
                var matchesName = usernameAttr.includes(input) || bName.includes(input);
                var archived = items[i].dataset.archived === 'true';
                var unread = items[i].dataset.unread === 'true';
                var matchesMode = conversationFilter === 'archived' ? archived : (conversationFilter === 'unread' ? unread && !archived : !archived);
                items[i].style.display = matchesName && matchesMode ? "flex" : "none";
            }
        }

        function toggleCurrentConversationArchive() {
            const partner = document.getElementById('targetFriendName').value;
            const row = document.getElementById('friend-item-' + partner);
            if (!partner || partner === 'None' || !row) return;
            const action = row.dataset.archived === 'true' ? 'restore' : 'archive';
            fetch('ConversationArchiveServlet', {method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({action,partner})})
            .then(r => r.json().then(data => ({ok:r.ok,data})))
            .then(({ok,data}) => { if (!ok || !data.success) throw new Error('Could not update conversation.'); row.dataset.archived = action === 'archive' ? 'true' : 'false'; document.getElementById('archiveConversationBtn').title = action === 'archive' ? 'Restore conversation' : 'Archive conversation'; setConversationFilter(conversationFilter); })
            .catch(err => alert(err.message));
        }

        function updateChatHeaderStatus() {
            var currentFriend = document.getElementById("targetFriendName").value;
            var headerStatus = document.getElementById("chatHeaderStatus");
            if (!headerStatus || !currentFriend || currentFriend === "None") {
                if (headerStatus) headerStatus.innerHTML = "";
                return;
            }

            if (currentFriend === "Gemini AI" || currentFriend === "gemini") {
                headerStatus.innerHTML = '<span style="color:#a855f7; font-size:12px; font-weight:600; display:inline-flex; align-items:center; gap:4px; margin-left:8px;"><i class="fa-solid fa-wand-magic-sparkles" style="font-size:10px;"></i> AI Assistant (Always Active)</span>';
                return;
            }

            var isOnline = activeOnlineUsers.has(currentFriend.toLowerCase());
            if (isOnline) {
                headerStatus.innerHTML = '<span style="color:#22c55e; font-size:12px; font-weight:600; display:inline-flex; align-items:center; gap:4px; margin-left:8px;"><i class="fa fa-circle" style="font-size:7px;"></i> Active now</span>';
            } else {
                headerStatus.innerHTML = '<span style="color:#94a3b8; font-size:12px; font-weight:500; display:inline-flex; align-items:center; gap:4px; margin-left:8px;"><i class="fa fa-circle" style="font-size:7px;"></i> Offline</span>';
            }
        }

        function updateFriendList(onlineUsersArray) {
            activeOnlineUsers = new Set(
                (onlineUsersArray || []).map(u => (u || "").trim().toLowerCase()).filter(Boolean)
            );

            // Ensure deep-link or opened friend exists in container
            if (window.targetToOpen && window.targetToOpen !== myName) {
                let existingItem = document.getElementById("friend-item-" + window.targetToOpen);
                if (!existingItem) {
                    addFriendToContainer(window.targetToOpen, "default.png");
                }
            }

            // Update status dots for each friend without wiping friend list
            document.querySelectorAll('.friend-item').forEach(function(item) {
                var uName = (item.getAttribute('data-username') || "").trim().toLowerCase();
                var dot = item.querySelector('.status-dot');
                var statusSpan = item.querySelector('[id^="status-text-"]');
                var isOnline = activeOnlineUsers.has(uName);

                if (dot) {
                    if (isOnline) {
                        dot.className = "status-dot online";
                    } else {
                        dot.className = "status-dot offline";
                    }
                }
                if (statusSpan) {
                    if (isOnline) {
                        statusSpan.innerHTML = '<small style="color:#22c55e; font-weight:600;">Active now</small>';
                    } else {
                        statusSpan.innerHTML = '<small style="color:#94a3b8;">Offline</small>';
                    }
                }
            });

            updateChatHeaderStatus();

            if (window.targetToOpen) {
                let item = document.getElementById("friend-item-" + window.targetToOpen);
                if (item) openChat(window.targetToOpen, item);
                window.targetToOpen = null; // Reset
            }

            filterUsers();
        }

        function addFriendToContainer(username, pic) {
            var container = document.getElementById("friendListContainer");
            var noFriends = document.getElementById("noFriendsMsg");
            if (noFriends) noFriends.remove();

            var isOnline = activeOnlineUsers.has(username.toLowerCase());
            var dotClass = isOnline ? "status-dot online" : "status-dot offline";
            var statusText = isOnline 
                ? '<small style="color:#22c55e; font-weight:600;">Active now</small>' 
                : '<small style="color:#94a3b8;">Offline</small>';

            var div = document.createElement("div");
            div.className = "friend-item";
            div.id = "friend-item-" + username;
            div.setAttribute("data-username", username.toLowerCase());
            div.onclick = function() { openChat(username, div); };
            div.innerHTML = `
                <div class="avatar">
                    <img src="img/\${pic || 'default.png'}" alt="\${username}" style="width:100%; height:100%; border-radius:50%; object-fit:cover;" onerror="this.onerror=null; this.src='img/default.png';">
                    <div class="\${dotClass}" id="dot-\${username}"></div>
                </div>
                <div class="friend-info" style="flex:1; min-width:0;">
                    <b style="font-size:15px; display:block; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">\${username}</b>
                    <span id="status-text-\${username}">\${statusText}</span>
                </div>
                <div class="friend-call-actions">
                    <button type="button" class="friend-call-btn voice" onclick="event.stopPropagation(); quickCallFriend('\${username}', 'voice', this.closest('.friend-item'))" title="Voice Call \${username}"><i class="fa-solid fa-phone"></i></button>
                    <button type="button" class="friend-call-btn video" onclick="event.stopPropagation(); quickCallFriend('\${username}', 'video', this.closest('.friend-item'))" title="Video Call \${username}"><i class="fa-solid fa-video"></i></button>
                </div>
            `;
            container.prepend(div);
        }

        function quickCallFriend(friend, type, element) {
            openChat(friend, element || document.getElementById("friend-item-" + friend));
            setTimeout(function() {
                initiateCall(type);
            }, 100);
        }

        function openChat(friend, element) {
            document.body.classList.add('chat-open');
            document.getElementById("chattingWith").innerText = friend;
            document.getElementById("conversationTools").style.display = friend === "Gemini AI" || friend === "gemini" ? "none" : "flex";
            const archiveRow = document.getElementById("friend-item-" + friend);
            document.getElementById("archiveConversationBtn").title = archiveRow && archiveRow.dataset.archived === "true" ? "Restore conversation" : "Archive conversation";
            document.getElementById("targetFriendName").value = friend;
            renderPinnedMessages();
            if (element && element.dataset && element.dataset.userid) {
                currentChatUserId = parseInt(element.dataset.userid);
            } else {
                const el = document.getElementById("friend-item-" + friend);
                if (el && el.dataset && el.dataset.userid) currentChatUserId = parseInt(el.dataset.userid);
            }
            updateBlockedStatusForActiveChat();
            updateChatHeaderStatus();
            cancelReplyQuote();
            dismissSmartReplies();

            document.getElementById("callButtons").classList.add("active");
            var voiceCallIcon = document.querySelector("#callButtons .fa-phone");
            var videoCallIcon = document.querySelector("#callButtons .fa-video");
            if (friend === "Gemini AI" || friend === "gemini") {
                if (voiceCallIcon) voiceCallIcon.style.display = "none";
                if (videoCallIcon) videoCallIcon.style.display = "none";
            } else {
                if (voiceCallIcon) voiceCallIcon.style.display = "inline-flex";
                if (videoCallIcon) videoCallIcon.style.display = "inline-flex";
            }

            document.getElementById("chatBox").innerHTML = "<p style='text-align:center; padding-top:50px; color:#999;'>Loading messages...</p>";
            document.querySelectorAll('.friend-item').forEach(i => i.classList.remove('active'));
            if(element) {
                element.classList.add('active');
                element.style.backgroundColor = '';
                var dot = element.querySelector('.unread-dot');
                if (dot) dot.remove();
                element.dataset.unread = "false";
            }

            fetch(cleanContextPath + '/loadMessages?user1=' + encodeURIComponent(myName) + '&user2=' + encodeURIComponent(friend))
            .then(res => res.json())
            .then(data => {
                window.dispatchEvent(new Event('ychat:notification'));
                const chatBox = document.getElementById("chatBox");
                chatBox.innerHTML = "";
                if (socket && socket.readyState === WebSocket.OPEN && friend !== "Gemini AI" && friend !== "gemini") {
                    socket.send("SEEN|" + friend);
                }
                if (data.length === 0) {
                    if (friend === "Gemini AI" || friend === "gemini") {
                        chatBox.innerHTML = `
                            <div style="text-align:center; padding-top:50px; color:#9333ea;">
                                <div style="width:58px; height:58px; border-radius:50%; background:linear-gradient(135deg, #9333ea, #ec4899); display:inline-flex; align-items:center; justify-content:center; color:white; font-size:24px; margin-bottom:12px; box-shadow:0 6px 18px rgba(147, 51, 234, 0.35);">
                                    <i class="fa-solid fa-wand-magic-sparkles"></i>
                                </div>
                                <h4 style="margin:0 0 6px; font-size:17px; font-weight:700; color:#1e293b;">Hello! I'm Gemini AI</h4>
                                <p style="color:#64748b; font-size:13px; max-width:320px; margin:0 auto;">Ask me anything, request summaries, or get answers in English, Bengali, or any language.</p>
                            </div>
                        `;
                    } else {
                        chatBox.innerHTML = "<p style='text-align:center; padding-top:50px; color:#999;'>No previous messages. Say hi!</p>";
                    }
                } else {
                    data.forEach(m => {
                        displayMessage(m, m.sender === myName ? 'sent' : 'received', m.isRead);
                    });

                    // Trigger smart auto-replies if last message was from the friend
                    let lastMsg = data[data.length - 1];
                    if (lastMsg && lastMsg.sender !== myName && lastMsg.sender !== "Gemini AI" && !lastMsg.isDeleted && lastMsg.message && !lastMsg.message.startsWith("img/")) {
                        fetchSmartReplies(lastMsg.message);
                    }
                }
                const bubble = document.createElement("div");
                bubble.id = "chatTypingBubble";
                bubble.className = "typing-bubble";
                bubble.style.display = "none";
                bubble.innerHTML = '<span class="dot"></span><span class="dot"></span><span class="dot"></span>';
                chatBox.appendChild(bubble);
                chatBox.scrollTop = chatBox.scrollHeight;
            })
            .catch(err => {
                console.error("Error loading messages:", err);
                document.getElementById("chatBox").innerHTML = "<p style='text-align:center; padding-top:50px; color:red;'>Failed to load history</p>";
            });
        }

        let currentReplyTo = null;

        function startReplyQuote(msgId, sender, textSnippet) {
            currentReplyTo = { id: msgId, sender: sender, text: textSnippet };
            const bar = document.getElementById("replyPreviewBar");
            const senderLabel = document.getElementById("replySenderLabel");
            const textSpan = document.getElementById("replyTextSnippet");
            if (bar && senderLabel && textSpan) {
                senderLabel.innerText = "Replying to " + sender + ":";
                textSpan.innerText = textSnippet.length > 50 ? textSnippet.substring(0, 50) + "..." : textSnippet;
                bar.style.display = "flex";
            }
            const input = document.getElementById("messageText");
            if (input) input.focus();
        }

        function cancelReplyQuote() {
            currentReplyTo = null;
            const bar = document.getElementById("replyPreviewBar");
            if (bar) bar.style.display = "none";
        }

        function sendToFriend() {
            var friend = document.getElementById("targetFriendName").value;
            var msgInput = document.getElementById("messageText");
            var content = msgInput.value.trim();
            if (friend !== "None" && content !== "") {
                if (socket && socket.readyState === WebSocket.OPEN) {
                    let payloadToSend;
                    let replyInfo = currentReplyTo;
                    if (replyInfo) {
                        payloadToSend = JSON.stringify({
                            text: content,
                            replyId: replyInfo.id,
                            replyText: replyInfo.text
                        });
                    } else {
                        payloadToSend = content;
                    }

                    socket.send("CHAT|" + friend + "|" + payloadToSend);
                    socket.send("TYPING|" + friend + "|stopped");

                    let tempId = "temp_" + Date.now();
                    displayMessage({
                        id: tempId,
                        sender: myName,
                        message: content,
                        isRead: false,
                        isEdited: false,
                        isDeleted: false,
                        replyToId: replyInfo ? replyInfo.id : null,
                        replyToText: replyInfo ? replyInfo.text : null
                    }, 'sent');

                    cancelReplyQuote();
                    dismissSmartReplies();
                    msgInput.value = "";
                } else {
                    alert("Connecting to chat server, please try again in a moment...");
                    initWebSocket();
                }
                isCurrentlyTyping = false;
                clearTimeout(typingTimeout);
            }
        }

        function backToSidebar() {
            document.body.classList.remove('chat-open');
            document.querySelectorAll('.friend-item').forEach(i => i.classList.remove('active'));
            document.getElementById("targetFriendName").value = "None";
            document.getElementById("chattingWith").innerText = "None";
            document.getElementById("callButtons").classList.remove("active");
        }

        let mediaRecorder = null;
        let audioChunks = [];
        let isRecording = false;
        let recordInterval = null;
        let recordSeconds = 0;

        function toggleVoiceRecording() {
            if (isRecording) {
                stopVoiceRecording();
            } else {
                startVoiceRecording();
            }
        }

        function startVoiceRecording() {
            if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                alert("Voice recording is not supported in this browser.");
                return;
            }

            navigator.mediaDevices.getUserMedia({ audio: true })
            .then(stream => {
                isRecording = true;
                audioChunks = [];
                mediaRecorder = new MediaRecorder(stream);
                
                mediaRecorder.ondataavailable = e => {
                    if (e.data.size > 0) audioChunks.push(e.data);
                };

                mediaRecorder.onstop = () => {
                    let audioBlob = new Blob(audioChunks, { type: 'audio/webm' });
                    let file = new File([audioBlob], "voice_" + Date.now() + ".webm", { type: "audio/webm" });
                    uploadAndSendVoice(file);
                    
                    stream.getTracks().forEach(track => track.stop());
                };

                mediaRecorder.start();
                
                document.getElementById("voiceBtn").style.color = "#ef4444";
                document.getElementById("recordingBadge").style.display = "flex";
                recordSeconds = 0;
                document.getElementById("recordTimer").innerText = "00:00";
                recordInterval = setInterval(() => {
                    recordSeconds++;
                    let m = String(Math.floor(recordSeconds / 60)).padStart(2, '0');
                    let s = String(recordSeconds % 60).padStart(2, '0');
                    document.getElementById("recordTimer").innerText = m + ":" + s;
                }, 1000);
            })
            .catch(err => {
                console.error("Microphone permission denied:", err);
                alert("Microphone access denied or not available.");
            });
        }

        function stopVoiceRecording() {
            if (mediaRecorder && isRecording) {
                isRecording = false;
                mediaRecorder.stop();
                clearInterval(recordInterval);
                document.getElementById("voiceBtn").style.color = "#a855f7";
                document.getElementById("recordingBadge").style.display = "none";
            }
        }

        function uploadAndSendVoice(file) {
            let formData = new FormData();
            formData.append("chatFile", file);

            fetch('ChatFileUploadServlet', { method: 'POST', body: formData })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    var friend = document.getElementById("targetFriendName").value;
                    if (friend !== "None") {
                        if (socket && socket.readyState === WebSocket.OPEN) {
                            socket.send("CHAT|" + friend + "|" + data.filePath);
                        }
                        displayMessage(data.filePath, 'sent', false);
                    }
                }
            })
            .catch(err => console.error("Voice upload error:", err));
        }

        function uploadChatAttachment(input) {
            if (input.files && input.files[0]) {
                let formData = new FormData();
                formData.append("chatFile", input.files[0]);

                fetch('ChatFileUploadServlet', { method: 'POST', body: formData })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        var friend = document.getElementById("targetFriendName").value;
                        if (friend !== "None") {
                            if (socket && socket.readyState === WebSocket.OPEN) {
                                socket.send("CHAT|" + friend + "|" + data.filePath);
                            }
                            displayMessage(data.filePath, 'sent', false);
                        }
                    }
                })
                .catch(err => console.error("File upload error:", err));
                input.value = "";
            }
        }

        function escapeHtml(text) {
            if (!text) return "";
            return String(text)
                .replace(/&/g, "&amp;")
                .replace(/</g, "&lt;")
                .replace(/>/g, "&gt;")
                .replace(/"/g, "&quot;")
                .replace(/'/g, "&#039;");
        }

        function displayMessage(msgItem, type, isRead = false) {
            var chatBox = document.getElementById("chatBox");
            if (!chatBox) return;

            // Normalize message data object
            let data = {};
            if (typeof msgItem === 'string') {
                data = {
                    id: "temp_" + Date.now() + "_" + Math.floor(Math.random() * 1000),
                    sender: type === 'sent' ? myName : (document.getElementById("targetFriendName").value || "Friend"),
                    message: msgItem,
                    isRead: isRead,
                    isEdited: false,
                    isDeleted: false,
                    reaction: null,
                    replyToId: currentReplyTo ? currentReplyTo.id : null,
                    replyToText: currentReplyTo ? currentReplyTo.text : null
                };
            } else {
                data = Object.assign({}, msgItem);
                if (!data.id) data.id = "temp_" + Date.now();
                if (data.isRead === undefined) data.isRead = isRead;
            }

            // Normalize [FILE:path] prefix if present
            if (data.message && data.message.startsWith("[FILE:") && data.message.endsWith("]")) {
                data.message = data.message.slice(6, -1);
            }
            const isAudio = data.message && (data.message.endsWith(".webm") || data.message.endsWith(".mp3") || data.message.endsWith(".wav") || data.message.endsWith(".ogg") || data.message.startsWith("img/voice_"));
            const isImg = data.message && (
                (data.message.startsWith("img/") && (data.message.endsWith(".png") || data.message.endsWith(".jpg") || data.message.endsWith(".jpeg") || data.message.endsWith(".gif") || data.message.endsWith(".webp") || data.message.endsWith(".avif") || data.message.endsWith(".bmp") || data.message.endsWith(".svg"))) ||
                ((data.message.startsWith("http://") || data.message.startsWith("https://")) && (data.message.includes(".gif") || data.message.endsWith(".png") || data.message.endsWith(".jpg") || data.message.endsWith(".avif") || data.message.includes("giphy.com") || data.message.includes("tenor.com")))
            );

            const row = document.createElement("div");
            row.className = "msg-row " + type;
            row.id = "msg-row-" + data.id;
            row.dataset.messageType = (isAudio || isImg) ? 'media' : 'text';

            // Action toolbar for reaction, quote, edit, delete
            let actionsHtml = "";
            if (!data.isDeleted) {
                const snippet = data.message ? (data.message.length > 50 ? data.message.substring(0, 50) + "..." : data.message) : "";
                const safeSnippet = escapeHtml(snippet);
                const safeSender = escapeHtml(data.sender || (type === 'sent' ? myName : 'Friend'));

                let translateBtn = (!isAudio && !isImg) ? 
                    ('<button type="button" class="msg-action-btn" onclick="translateMessage(\'' + data.id + '\')" title="Translate with Gemini AI"><i class="fa-solid fa-language"></i></button>') : '';
                let editBtn = (type === 'sent' && !isAudio && !isImg) ? 
                    ('<button type="button" class="msg-action-btn" onclick="openEditModal(\'' + data.id + '\')" title="Edit message"><i class="fa-solid fa-pen"></i></button>') : '';
                let deleteBtn = (type === 'sent') ? 
                    ('<button type="button" class="msg-action-btn" onclick="deleteMessage(\'' + data.id + '\')" title="Delete for everyone" style="color:#ef4444;"><i class="fa-solid fa-trash-can"></i></button>') : '';
                let pinBtn = '<button type="button" class="msg-action-btn pin-message-btn" onclick="pinCurrentMessage(\'' + data.id + '\')" title="' + (isPinnedMessage(document.getElementById("targetFriendName").value, data.id) ? 'Unpin message' : 'Pin message') + '"><i class="fa-solid fa-thumbtack"' + (isPinnedMessage(document.getElementById("targetFriendName").value, data.id) ? '' : ' style="opacity:.45"') + '></i></button>';

                actionsHtml = '<div class="msg-actions" id="actions-' + data.id + '">' +
                    '<div style="position:relative;">' +
                        '<button type="button" class="msg-action-btn" onclick="toggleReactionPicker(\'' + data.id + '\')" title="Add Reaction">' +
                            '<i class="fa-regular fa-face-smile"></i>' +
                        '</button>' +
                        '<div class="reaction-picker-menu" id="reaction-picker-' + data.id + '">' +
                            '<button type="button" class="reaction-emoji-btn" onclick="sendReaction(\'' + data.id + '\', \'&#x1F44D;\')">&#x1F44D;</button>' +
                            '<button type="button" class="reaction-emoji-btn" onclick="sendReaction(\'' + data.id + '\', \'&#x2764;&#xFE0F;\')">&#x2764;&#xFE0F;</button>' +
                            '<button type="button" class="reaction-emoji-btn" onclick="sendReaction(\'' + data.id + '\', \'&#x1F602;\')">&#x1F602;</button>' +
                            '<button type="button" class="reaction-emoji-btn" onclick="sendReaction(\'' + data.id + '\', \'&#x1F62E;\')">&#x1F62E;</button>' +
                            '<button type="button" class="reaction-emoji-btn" onclick="sendReaction(\'' + data.id + '\', \'&#x1F622;\')">&#x1F622;</button>' +
                            '<button type="button" class="reaction-emoji-btn" onclick="sendReaction(\'' + data.id + '\', \'&#x1F621;\')">&#x1F621;</button>' +
                            '<button type="button" class="reaction-close-btn" onclick="toggleReactionPicker(\'' + data.id + '\')" title="Close"><i class="fa-solid fa-xmark"></i></button>' +
                        '</div>' +
                    '</div>' +
                    '<button type="button" class="msg-action-btn" onclick="startReplyQuote(\'' + data.id + '\', \'' + safeSender + '\', \'' + safeSnippet + '\')" title="Quote reply">' +
                        '<i class="fa-solid fa-reply"></i>' +
                    '</button>' +
                    translateBtn +
                    pinBtn +
                    editBtn +
                    deleteBtn +
                '</div>';
            }

            // Message Bubble Inner HTML
            let bubbleHtml = "";

            // If sender is Gemini AI, show a bot badge header
            if (data.sender === "Gemini AI" || data.sender === "gemini") {
                bubbleHtml += '<div style="display:flex; align-items:center; gap:5px; font-size:11px; font-weight:700; color:#9333ea; margin-bottom:5px;">' +
                    '<i class="fa-solid fa-wand-magic-sparkles"></i> Gemini AI' +
                '</div>';
            }

            // Quoted message card if this message is a reply
            if (data.replyToText && !data.isDeleted) {
                bubbleHtml += '<div class="msg-quote-card" onclick="scrollToMessage(\'' + data.replyToId + '\')" title="Jump to original message">' +
                    '<span class="quote-author"><i class="fa-solid fa-reply"></i> Replying:</span>' +
                    '<span class="quote-snippet">' + escapeHtml(data.replyToText) + '</span>' +
                '</div>';
            }

            if (data.isDeleted) {
                bubbleHtml += '<span class="msg-deleted"><i class="fa-solid fa-ban"></i> This message was deleted</span>';
            } else if (isAudio) {
                bubbleHtml += '<div style="display:flex; align-items:center; gap:8px;">' +
                    '<i class="fa fa-microphone" style="color:#a855f7;"></i>' +
                    '<audio controls src="' + data.message + '" style="max-width:200px; height:32px; border-radius:16px;" onplay="this.volume=0.75;"></audio>' +
                '</div>';
            } else if (isImg) {
                bubbleHtml += '<img src="' + data.message + '" style="max-width:220px; max-height:220px; border-radius:12px; cursor:pointer;" onclick="window.open(\'' + data.message + '\', \'_blank\')">';
            } else {
                bubbleHtml += '<span class="msg-text-content" data-raw="' + escapeHtml(data.message) + '">' + escapeHtml(data.message) + '</span>';
                if (data.isEdited) {
                    bubbleHtml += '<small class="edited-tag">(edited)</small>';
                }
            }

            // Status Ticks for Sent Messages
            if (type === 'sent' && !data.isDeleted) {
                if (data.isRead) {
                    bubbleHtml += '<span class="msg-status" style="font-size:10px; margin-left:6px; float:right; display:inline-block; color:#38bdf8; opacity:1;"> ✓ Seen</span>';
                } else {
                    bubbleHtml += '<span class="msg-status" style="font-size:10px; margin-left:6px; float:right; display:inline-block; opacity:0.65;"> ✓ Sent</span>';
                }
            }

            // Reaction Pill Badge
            const reactionDisplay = (data.reaction && !data.isDeleted) ? "" : "display:none;";
            bubbleHtml += '<span class="msg-reaction-pill" id="reaction-pill-' + data.id + '" style="' + reactionDisplay + '" onclick="toggleReactionPicker(\'' + data.id + '\')">' + (data.reaction || '') + '</span>';

            // Row construction based on sent or received
            if (type === 'sent') {
                row.innerHTML = actionsHtml + '<div class="msg sent ' + (data.isDeleted ? 'msg-deleted' : '') + '" id="msg-' + data.id + '">' + bubbleHtml + '</div>';
            } else {
                row.innerHTML = '<div class="msg received ' + (data.isDeleted ? 'msg-deleted' : '') + '" id="msg-' + data.id + '">' + bubbleHtml + '</div>' + actionsHtml;
            }

            const typingBubble = document.getElementById("chatTypingBubble");
                try { window.dispatchEvent(new CustomEvent('ychat:notification')); } catch(e){}
            if (typingBubble && typingBubble.parentNode === chatBox) {
                chatBox.insertBefore(row, typingBubble);
            } else {
                chatBox.appendChild(row);
            }

            chatBox.scrollTop = chatBox.scrollHeight;
        }

        function scrollToMessage(targetId) {
            if (!targetId) return;
            const targetRow = document.getElementById("msg-row-" + targetId);
            if (targetRow) {
                targetRow.scrollIntoView({ behavior: 'smooth', block: 'center' });
                targetRow.style.transition = 'background 0.3s';
                targetRow.style.background = 'rgba(168, 85, 247, 0.25)';
                targetRow.style.borderRadius = '12px';
                setTimeout(() => { targetRow.style.background = ''; }, 1500);
            }
        }

        function toggleReactionPicker(msgId) {
            document.querySelectorAll(".reaction-picker-menu").forEach(el => {
                if (el.id !== "reaction-picker-" + msgId) el.classList.remove("active");
            });
            const picker = document.getElementById("reaction-picker-" + msgId);
            if (picker) picker.classList.toggle("active");
        }

        function sendReaction(msgId, emoji) {
            const friend = document.getElementById("targetFriendName").value;
            if (!msgId || friend === "None") return;

            const pill = document.getElementById("reaction-pill-" + msgId);
            let finalEmoji = emoji;
            if (pill && pill.innerText.trim() === emoji) {
                finalEmoji = null; // Unreact if same emoji clicked again
            }

            if (socket && socket.readyState === WebSocket.OPEN) {
                socket.send("REACTION|" + friend + "|" + JSON.stringify({ id: parseInt(msgId) || msgId, reaction: finalEmoji }));
                applyReaction(msgId, finalEmoji);
            }
            const picker = document.getElementById("reaction-picker-" + msgId);
            if (picker) picker.classList.remove("active");
        }

        function applyReaction(msgId, emoji) {
            const pill = document.getElementById("reaction-pill-" + msgId);
            if (!pill) return;
            if (emoji && emoji.trim() !== "") {
                pill.innerText = emoji;
                pill.style.display = "inline-flex";
            } else {
                pill.innerText = "";
                pill.style.display = "none";
            }
        }

        function openEditModal(msgId) {
            const row = document.getElementById("msg-row-" + msgId);
            if (!row) return;
            const textEl = row.querySelector(".msg-text-content");
            const curText = textEl ? (textEl.getAttribute("data-raw") || textEl.innerText) : "";
            document.getElementById("editMsgId").value = msgId;
            document.getElementById("editMsgInput").value = curText;
            document.getElementById("editMsgModal").style.display = "flex";
            document.getElementById("editMsgInput").focus();
        }

        function closeEditModal() {
            document.getElementById("editMsgModal").style.display = "none";
        }

        function submitEditMessage() {
            const msgId = document.getElementById("editMsgId").value;
            const newText = document.getElementById("editMsgInput").value.trim();
            const friend = document.getElementById("targetFriendName").value;
            if (!newText || !msgId || friend === "None") return;

            if (socket && socket.readyState === WebSocket.OPEN) {
                socket.send("EDIT_MSG|" + friend + "|" + JSON.stringify({ id: parseInt(msgId) || msgId, text: newText }));
                applyEditedMessage(msgId, newText);
            }
            closeEditModal();
        }

        function applyEditedMessage(msgId, newText) {
            const row = document.getElementById("msg-row-" + msgId);
            if (!row) return;
            const textEl = row.querySelector(".msg-text-content");
            if (textEl) {
                textEl.innerText = newText;
                textEl.setAttribute("data-raw", newText);
                let tag = row.querySelector(".edited-tag");
                if (!tag) {
                    tag = document.createElement("small");
                    tag.className = "edited-tag";
                    tag.innerText = "(edited)";
                    textEl.after(tag);
                }
            }
        }

        function deleteMessage(msgId) {
            if (!confirm("Are you sure you want to unsend this message for everyone?")) return;
            const friend = document.getElementById("targetFriendName").value;
            if (!msgId || friend === "None") return;

            if (socket && socket.readyState === WebSocket.OPEN) {
                socket.send("DELETE_MSG|" + friend + "|" + JSON.stringify({ id: parseInt(msgId) || msgId }));
                applyDeletedMessage(msgId);
            }
        }

        function applyDeletedMessage(msgId) {
            const row = document.getElementById("msg-row-" + msgId);
            if (!row) return;
            const msgBubble = row.querySelector(".msg");
            if (msgBubble) {
                msgBubble.classList.add("msg-deleted");
                msgBubble.innerHTML = '<i class="fa-solid fa-ban"></i> This message was deleted';
            }
            const actions = row.querySelector(".msg-actions");
            if (actions) actions.remove();
            const pill = row.querySelector(".msg-reaction-pill");
            if (pill) pill.remove();
        }

        document.addEventListener("click", function(e) {
            if (!e.target.closest(".reaction-picker-menu") && !e.target.closest(".msg-action-btn")) {
                document.querySelectorAll(".reaction-picker-menu.active").forEach(el => el.classList.remove("active"));
            }
        });

        // ==========================================
        // ､・CATEGORY 2: GEMINI AI POWERED FEATURES
        // ==========================================

        // 1. Quick @gemini helper
        function insertGeminiPrompt() {
            var input = document.getElementById("messageText");
            if (!input) return;
            var val = input.value.trim();
            if (!val.toLowerCase().startsWith("@gemini")) {
                input.value = "@gemini " + val;
            }
            input.focus();
        }

        // 2. Chat Summarizer
        function summarizeCurrentChat() {
            var currentFriend = document.getElementById("targetFriendName").value;
            if (!currentFriend || currentFriend === "None") {
                alert("Please select a chat conversation first.");
                return;
            }

            var rows = document.querySelectorAll("#chatBox .msg-row");
            var conversationLines = [];

            rows.forEach(function(row) {
                var textEl = row.querySelector(".msg-text-content");
                if (textEl) {
                    var isSent = row.classList.contains("sent");
                    var isAi = row.querySelector(".fa-wand-magic-sparkles") !== null;
                    var senderName = isAi ? "Gemini AI" : (isSent ? myName : currentFriend);
                    var cleanText = textEl.getAttribute("data-raw") || textEl.innerText.trim();
                    if (cleanText) {
                        conversationLines.push(senderName + ": " + cleanText);
                    }
                }
            });

            if (conversationLines.length === 0) {
                alert("No text messages found in this chat to summarize.");
                return;
            }

            var modal = document.getElementById("aiSummaryModal");
            var body = document.getElementById("aiSummaryBody");
            modal.style.display = "flex";
            body.innerHTML = `
                <div style="text-align:center; padding:45px 20px; color:#9333ea;">
                    <i class="fa-solid fa-spinner fa-spin" style="font-size:32px; margin-bottom:12px;"></i>
                    <p style="font-weight:700; font-size:16px; margin:0 0 4px; color:#1e293b;">Analyzing Conversation...</p>
                    <small style="color:#64748b;">Gemini AI is generating your key takeaways & summary</small>
                </div>
            `;

            var conversationText = conversationLines.slice(-30).join("\n");

            var formData = new URLSearchParams();
            formData.append("action", "summarize");
            formData.append("conversation", conversationText);

            fetch('aiChat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                body: formData.toString()
            })
            .then(res => res.json())
            .then(data => {
                if (data.success && data.summary) {
                    var formatted = escapeHtml(data.summary)
                        .replace(/\n/g, '<br>')
                        .replace(/\*\*(.*?)\*\*/g, '<b>$1</b>')
                        .replace(/窶｢\s*(.*?)(<br>|$)/g, '<div style="display:flex; gap:8px; margin-bottom:6px;"><span style="color:#9333ea; font-weight:bold;">窶｢</span><div>$1</div></div>');
                    body.innerHTML = formatted;
                } else {
                    body.innerHTML = "<p style=\"color:#ef4444; font-weight:600;\"><i class=\"fa-solid fa-triangle-exclamation\"></i> Failed to generate summary: " + escapeHtml(data.error || "Unknown error") + "</p>";
                }
            })
            .catch(err => {
                console.error("AI summary error:", err);
                body.innerHTML = `<p style="color:#ef4444;"><i class="fa-solid fa-triangle-exclamation"></i> Connection error while summarizing chat.</p>`;
            });
        }

        function closeSummaryModal() {
            var modal = document.getElementById("aiSummaryModal");
            if (modal) modal.style.display = "none";
        }

        function copySummaryText() {
            var body = document.getElementById("aiSummaryBody");
            if (!body) return;
            var text = body.innerText;
            navigator.clipboard.writeText(text).then(() => {
                var btn = document.getElementById("copySummaryBtn");
                if (btn) {
                    var originalHtml = btn.innerHTML;
                    btn.innerHTML = '<i class="fa-solid fa-check"></i> Copied!';
                    setTimeout(() => { btn.innerHTML = originalHtml; }, 2000);
                }
            }).catch(e => console.error("Copy failed", e));
        }

        // 3. Inline Message Translation
        function translateMessage(msgId) {
            var card = document.getElementById("trans-box-" + msgId);
            if (card) {
                card.style.display = (card.style.display === "none") ? "block" : "none";
                return;
            }

            var msgBubble = document.getElementById("msg-" + msgId);
            var textEl = msgBubble ? msgBubble.querySelector(".msg-text-content") : null;
            if (!textEl) return;

            var rawText = textEl.getAttribute("data-raw") || textEl.innerText;
            if (!rawText || rawText.trim() === "") return;

            var transBox = document.createElement("div");
            transBox.className = "msg-translation-card";
            transBox.id = "trans-box-" + msgId;
            transBox.innerHTML = `
                <div style="font-size:10px; font-weight:700; color:#0891b2; margin-bottom:2px; display:flex; align-items:center; gap:4px;">
                    <i class="fa-solid fa-language"></i> Translating...
                </div>
                <div style="font-size:12px; opacity:0.8;"><i class="fa-solid fa-spinner fa-spin"></i> Loading AI translation</div>
            `;
            msgBubble.appendChild(transBox);

            fetch('aiChat?action=translate&text=' + encodeURIComponent(rawText))
            .then(res => res.json())
            .then(data => {
                if (data.success && data.translated) {
                    transBox.innerHTML = '<div style="font-size:10px; font-weight:700; color:#0891b2; margin-bottom:2px; display:flex; align-items:center; gap:4px;"><i class="fa-solid fa-language"></i> Translated with Gemini:</div><div class="trans-text">' + escapeHtml(data.translated) + '</div>';
                } else {
                    transBox.innerHTML = `<span style="color:#ef4444; font-size:11px;">Translation failed.</span>`;
                    setTimeout(() => { transBox.remove(); }, 3000);
                }
            })
            .catch(err => {
                console.error("Translation error:", err);
                transBox.innerHTML = `<span style="color:#ef4444; font-size:11px;">Error translating message.</span>`;
                setTimeout(() => { transBox.remove(); }, 3000);
            });
        }

        // 4. Smart Auto-Reply Suggestions
        let smartRepliesDebounce = null;
        function fetchSmartReplies(messageText) {
            if (!messageText || messageText.trim() === "" || messageText.startsWith("img/")) {
                dismissSmartReplies();
                return;
            }

            clearTimeout(smartRepliesDebounce);
            smartRepliesDebounce = setTimeout(() => {
                fetch('aiChat?action=smart_replies&text=' + encodeURIComponent(messageText))
                .then(res => res.json())
                .then(data => {
                    if (data.success && Array.isArray(data.replies) && data.replies.length > 0) {
                        renderSmartReplies(data.replies);
                    } else {
                        dismissSmartReplies();
                    }
                })
                .catch(err => {
                    console.error("Smart replies error:", err);
                    dismissSmartReplies();
                });
            }, 300);
        }

        function renderSmartReplies(replies) {
            var bar = document.getElementById("smartRepliesBar");
            var container = document.getElementById("smartRepliesChips");
            if (!bar || !container) return;

            container.innerHTML = "";
            replies.forEach(function(reply) {
                var chip = document.createElement("button");
                chip.type = "button";
                chip.className = "smart-reply-chip";
                chip.innerHTML = "<i class=\"fa-solid fa-reply\" style=\"font-size:10px; opacity:0.8;\"></i> " + escapeHtml(reply);
                chip.onclick = function() {
                    applySmartReply(reply);
                };
                container.appendChild(chip);
            });

            bar.style.display = "flex";
        }

        function applySmartReply(replyText) {
            var input = document.getElementById("messageText");
            if (input) {
                input.value = replyText;
                sendToFriend();
            }
            dismissSmartReplies();
        }

        function dismissSmartReplies() {
            var bar = document.getElementById("smartRepliesBar");
            if (bar) bar.style.display = "none";
        }

        // ==========================================
        // 📞 PREMIUM CALLING & WEBRTC SIGNALING SYSTEM
        // ==========================================
        let isCaller = false;
        let peerConnection = null;
        let localStream = null;
        let callTimer = null;
        let currentCallFriend = null;
        let callType = 'voice';
        let ringInterval = null;
        let callStartTime = null;
        let toneOscillators = [];
        let audioCtx = null;
        let micMuted = false;
        let camOff = false;
        let loudspeakerOn = false;
        let speakerToastTimer = null;
        let pendingRemoteOffer = null;

        const rtcConfig = {
            iceServers: [
                { urls: 'stun:stun.l.google.com:19302' },
                { urls: 'stun:stun1.l.google.com:19302' },
                { urls: 'stun:stun2.l.google.com:19302' },
                { urls: 'stun:stun3.l.google.com:19302' },
                { urls: 'stun:stun4.l.google.com:19302' },
                { urls: 'stun:stun.services.mozilla.com:3478' },
                {
                    urls: [
                        'turn:3.26.151.171:3478?transport=udp',
                        'turn:3.26.151.171:3478?transport=tcp'
                    ],
                    username: 'ychat',
                    credential: 'pass2026'
                }
            ],
            iceCandidatePoolSize: 0
        };
        let iceCandidateQueue = [];

        function initAudio() {
            if (!audioCtx) {
                const AudioCtx = window.AudioContext || window.webkitAudioContext;
                if (AudioCtx) audioCtx = new AudioCtx();
            }
            if (audioCtx && audioCtx.state === 'suspended') {
                audioCtx.resume().catch(function() {});
            }
        }

        function unlockAudioElement() {
            const rAud = document.getElementById("remoteAudio");
            if (rAud) {
                rAud.muted = false;
                rAud.volume = 1.0;
                rAud.play().catch(function() {});
            }
        }

        function startOutgoingRingtone() {
            initAudio();
            stopRingtone();
            let playTone = () => {
                if (!audioCtx) return;
                let osc1 = audioCtx.createOscillator();
                let osc2 = audioCtx.createOscillator();
                let gain = audioCtx.createGain();
                
                osc1.type = 'sine';
                osc1.frequency.setValueAtTime(440, audioCtx.currentTime);
                osc2.type = 'sine';
                osc2.frequency.setValueAtTime(480, audioCtx.currentTime);
                
                gain.gain.setValueAtTime(0, audioCtx.currentTime);
                gain.gain.linearRampToValueAtTime(0.15, audioCtx.currentTime + 0.1);
                gain.gain.setValueAtTime(0.15, audioCtx.currentTime + 1.5);
                gain.gain.linearRampToValueAtTime(0, audioCtx.currentTime + 2.0);
                
                osc1.connect(gain);
                osc2.connect(gain);
                gain.connect(audioCtx.destination);
                
                osc1.start();
                osc2.start();
                
                toneOscillators.push(osc1, osc2);
                
                setTimeout(() => {
                    try { osc1.stop(); osc2.stop(); } catch(e) {}
                }, 2000);
            };
            
            playTone();
            ringInterval = setInterval(playTone, 4000);
        }

        function startIncomingRingtone() {
            initAudio();
            stopRingtone();
            let playRing = () => {
                if (!audioCtx) return;
                let osc = audioCtx.createOscillator();
                let gain = audioCtx.createGain();
                
                osc.type = 'triangle';
                let now = audioCtx.currentTime;
                osc.frequency.setValueAtTime(523.25, now); // C5
                osc.frequency.setValueAtTime(659.25, now + 0.15); // E5
                osc.frequency.setValueAtTime(783.99, now + 0.3); // G5
                osc.frequency.setValueAtTime(1046.50, now + 0.45); // C6
                
                gain.gain.setValueAtTime(0, now);
                gain.gain.linearRampToValueAtTime(0.2, now + 0.05);
                gain.gain.setValueAtTime(0.2, now + 0.5);
                gain.gain.linearRampToValueAtTime(0, now + 0.75);
                
                osc.connect(gain);
                gain.connect(audioCtx.destination);
                
                osc.start();
                toneOscillators.push(osc);
                
                setTimeout(() => {
                    try { osc.stop(); } catch(e) {}
                }, 800);
            };
            
            playRing();
            ringInterval = setInterval(playRing, 1200);
        }

        function stopRingtone() {
            if (ringInterval) {
                clearInterval(ringInterval);
                ringInterval = null;
            }
            toneOscillators.forEach(osc => {
                try { osc.stop(); } catch(e) {}
            });
            toneOscillators = [];
        }

        function playConnectedTone() {
            initAudio();
            if (!audioCtx) return;
            let osc = audioCtx.createOscillator();
            let gain = audioCtx.createGain();
            osc.frequency.setValueAtTime(660, audioCtx.currentTime);
            osc.frequency.setValueAtTime(880, audioCtx.currentTime + 0.15);
            gain.gain.setValueAtTime(0.12, audioCtx.currentTime);
            gain.gain.linearRampToValueAtTime(0, audioCtx.currentTime + 0.3);
            osc.connect(gain);
            gain.connect(audioCtx.destination);
            osc.start();
            setTimeout(() => {
                try { osc.stop(); } catch(e) {}
            }, 300);
        }

        async function getMediaStream(type) {
            try {
                return await navigator.mediaDevices.getUserMedia({
                    audio: { echoCancellation: true, noiseSuppression: true },
                    video: type === 'video' ? { facingMode: "user" } : false
                });
            } catch (err1) {
                console.warn("Primary getUserMedia failed, trying minimal constraints:", err1);
                try {
                    return await navigator.mediaDevices.getUserMedia({
                        audio: true,
                        video: type === 'video'
                    });
                } catch (err2) {
                    console.error("getUserMedia completely failed:", err2);
                    alert("Microphone/Camera permission is required. Please check your browser or iPhone settings.");
                    return null;
                }
            }
        }

        function createPeerConnection() {
            if (peerConnection) {
                try { peerConnection.close(); } catch(e) {}
                peerConnection = null;
            }

            peerConnection = new RTCPeerConnection(rtcConfig);

            peerConnection.ontrack = (event) => {
                console.log("Remote track received:", event.track.kind, event.streams);
                const stream = (event.streams && event.streams[0]) ? event.streams[0] : new MediaStream([event.track]);

                const rAud = document.getElementById("remoteAudio");
                if (rAud) {
                    rAud.srcObject = stream;
                    rAud.muted = false;
                    rAud.volume = 1.0;
                    const p = rAud.play();
                    if (p !== undefined) {
                        p.catch(function(err) {
                            console.warn("remoteAudio.play() caught:", err);
                            const resumeClick = function() {
                                rAud.play();
                                document.removeEventListener('click', resumeClick);
                                document.removeEventListener('touchend', resumeClick);
                            };
                            document.addEventListener('click', resumeClick, { once: true });
                            document.addEventListener('touchend', resumeClick, { once: true });
                        });
                    }
                }

                const rVid = document.getElementById("remoteVideo");
                if (rVid && callType === 'video') {
                    rVid.srcObject = stream;
                    rVid.muted = true; // Avoid duplicate audio echo
                    rVid.play().catch(function(e) { console.log("remoteVideo play:", e); });
                }

                switchToActiveCallUI();
            };

            peerConnection.onicecandidate = (event) => {
                if (event.candidate && currentCallFriend && socket && socket.readyState === WebSocket.OPEN) {
                    socket.send("ICE_CANDIDATE|" + currentCallFriend + "|" + JSON.stringify(event.candidate));
                }
            };

            peerConnection.oniceconnectionstatechange = () => {
                console.log("ICE Connection State:", peerConnection.iceConnectionState);
                if (peerConnection.iceConnectionState === "connected" || peerConnection.iceConnectionState === "completed") {
                    switchToActiveCallUI();
                } else if (peerConnection.iceConnectionState === "failed") {
                    console.warn("ICE connection failed, attempting restart...");
                    if (peerConnection.restartIce) peerConnection.restartIce();
                }
            };

            peerConnection.onconnectionstatechange = () => {
                console.log("Peer Connection State:", peerConnection.connectionState);
                if (peerConnection.connectionState === "connected") {
                    switchToActiveCallUI();
                }
            };
        }

        async function initiateCall(type) {
            var friend = document.getElementById("targetFriendName").value;
            if (!friend || friend === "None") {
                var firstItem = document.querySelector("#friendListContainer .friend-item");
                if (firstItem && firstItem.getAttribute("data-username")) {
                    friend = firstItem.getAttribute("data-username");
                    openChat(friend, firstItem);
                } else {
                    alert("Please select a friend to call.");
                    return;
                }
            }

            initAudio();
            unlockAudioElement();
            isCaller = true;
            currentCallFriend = friend;
            callType = type;
            pendingRemoteOffer = null;
            iceCandidateQueue = [];

            document.getElementById("callOverlay").style.display = "flex";
            document.getElementById("callingRings").style.display = "block";
            document.getElementById("callAvatar").innerText = friend.charAt(0).toUpperCase();
            document.getElementById("callUsername").innerText = friend;
            document.getElementById("callStatus").innerText = "Calling " + friend + "...";
            document.getElementById("acceptBtn").style.display = "none";
            document.getElementById("declineBtn").style.display = "flex";
            document.getElementById("videoGrid").style.display = "none";
            document.getElementById("voiceWaves").style.display = "none";

            startOutgoingRingtone();

            try {
                localStream = await getMediaStream(callType);
                if (!localStream) {
                    declineCall();
                    return;
                }
                const localVideo = document.getElementById("localVideo");
                if (localVideo && localStream) localVideo.srcObject = localStream;

                createPeerConnection();

                localStream.getTracks().forEach(track => {
                    peerConnection.addTrack(track, localStream);
                });

                const offer = await peerConnection.createOffer({
                    offerToReceiveAudio: true,
                    offerToReceiveVideo: (callType === 'video')
                });
                await peerConnection.setLocalDescription(offer);

                if (socket && socket.readyState === WebSocket.OPEN) {
                    socket.send("CALL_OFFER|" + friend + "|" + JSON.stringify({ type: callType, sdp: offer }));
                }
            } catch (err) {
                console.error("Initiate call error:", err);
                alert("Failed to start call: " + err.message);
                declineCall();
                return;
            }

            if (callTimer) clearTimeout(callTimer);
            callTimer = setTimeout(() => {
                if (currentCallFriend === friend && document.getElementById("activeCallControls").style.display === "none") {
                    stopRingtone();
                    document.getElementById("callStatus").innerText = "No Answer";
                    setTimeout(declineCall, 2000);
                }
            }, 45000);
        }

        function startVoiceCall() {
            initiateCall('voice');
        }

        function startVideoCall() {
            initiateCall('video');
        }

        window.showGlobalIncomingCall = function(caller, type) {
            if (currentCallFriend && currentCallFriend === caller) return;
            handleCallOffer(caller, { type: type || 'voice' });
        };

        async function handleCallOffer(sender, offerData) {
            if (currentCallFriend && currentCallFriend !== sender) {
                if (socket && socket.readyState === WebSocket.OPEN) {
                    socket.send("CALL_REJECT|" + sender + "|busy");
                }
                return;
            }

            initAudio();
            unlockAudioElement();
            isCaller = false;
            currentCallFriend = sender;
            callType = offerData.type || 'voice';
            pendingRemoteOffer = offerData.sdp || null;
            iceCandidateQueue = [];

            document.getElementById("callOverlay").style.display = "flex";
            document.getElementById("callingRings").style.display = "block";
            document.getElementById("callAvatar").innerText = sender.charAt(0).toUpperCase();
            document.getElementById("callUsername").innerText = sender;
            document.getElementById("callStatus").innerText = "Incoming " + (callType === 'video' ? 'Video' : 'Voice') + " Call...";
            document.getElementById("acceptBtn").style.display = "flex";
            document.getElementById("declineBtn").style.display = "flex";
            document.getElementById("videoGrid").style.display = "none";
            document.getElementById("voiceWaves").style.display = "none";

            startIncomingRingtone();

            if (callTimer) clearTimeout(callTimer);
            callTimer = setTimeout(() => {
                declineCall();
            }, 45000);
        }

        function declineCall() {
            stopRingtone();
            if (callTimer) clearTimeout(callTimer);

            if (currentCallFriend) {
                if (isCaller) {
                    if (socket && socket.readyState === WebSocket.OPEN) {
                        socket.send("CALL_END|" + currentCallFriend + "|cancelled");
                    }
                } else {
                    if (socket && socket.readyState === WebSocket.OPEN) {
                        socket.send("CALL_REJECT|" + currentCallFriend + "|declined");
                    }
                }
            }

            resetCallUI();
        }

        function handleCallReject(sender) {
            stopRingtone();
            if (callTimer) clearTimeout(callTimer);
            document.getElementById("callStatus").innerText = "Call Declined";
            setTimeout(() => {
                resetCallUI();
            }, 2000);
        }

        function handleCallEnd(sender) {
            stopRingtone();
            if (callTimer) clearTimeout(callTimer);
            endCall(true);
        }

        async function acceptCall() {
            stopRingtone();
            if (callTimer) clearTimeout(callTimer);

            unlockAudioElement();
            document.getElementById("acceptBtn").style.display = "none";
            document.getElementById("callingRings").style.display = "none";
            document.getElementById("callStatus").innerText = "Connecting...";

            try {
                localStream = await getMediaStream(callType);
                if (!localStream) {
                    declineCall();
                    return;
                }
                const localVideo = document.getElementById("localVideo");
                if (localVideo && localStream) localVideo.srcObject = localStream;

                createPeerConnection();

                localStream.getTracks().forEach(track => {
                    peerConnection.addTrack(track, localStream);
                });

                if (pendingRemoteOffer) {
                    await peerConnection.setRemoteDescription(new RTCSessionDescription(pendingRemoteOffer));
                    await flushIceCandidateQueue();
                    const answer = await peerConnection.createAnswer();
                    await peerConnection.setLocalDescription(answer);

                    if (socket && socket.readyState === WebSocket.OPEN) {
                        socket.send("CALL_ANSWER|" + currentCallFriend + "|" + JSON.stringify({ status: "accepted", sdp: answer }));
                    }
                    playConnectedTone();
                    switchToActiveCallUI();
                } else {
                    if (socket && socket.readyState === WebSocket.OPEN) {
                        socket.send("CALL_ANSWER|" + currentCallFriend + "|" + JSON.stringify({ status: "accepted" }));
                    }
                }
            } catch (err) {
                console.error("Accept call error:", err);
                alert("Failed to connect call: " + err.message);
                declineCall();
            }
        }

        async function handleCallAnswer(sender, answerData) {
            stopRingtone();
            if (callTimer) clearTimeout(callTimer);

            if (answerData.status === "accepted") {
                document.getElementById("callingRings").style.display = "none";
                document.getElementById("callStatus").innerText = "Connecting...";

                if (answerData.sdp && peerConnection) {
                    try {
                        await peerConnection.setRemoteDescription(new RTCSessionDescription(answerData.sdp));
                        await flushIceCandidateQueue();
                        playConnectedTone();
                        switchToActiveCallUI();
                    } catch (e) {
                        console.error("setRemoteDescription error:", e);
                    }
                }
            }
        }

        async function handleIceCandidate(sender, candidate) {
            if (!candidate) return;
            if (!peerConnection || !peerConnection.remoteDescription || !peerConnection.remoteDescription.type) {
                iceCandidateQueue.push(candidate);
                return;
            }
            try {
                await peerConnection.addIceCandidate(new RTCIceCandidate(candidate));
            } catch(e) {
                console.warn("ICE error:", e);
            }
        }

        async function flushIceCandidateQueue() {
            while (iceCandidateQueue.length > 0) {
                const cand = iceCandidateQueue.shift();
                try {
                    await peerConnection.addIceCandidate(new RTCIceCandidate(cand));
                } catch(e) {
                    console.warn("Queued ICE error:", e);
                }
            }
        }

        function switchToActiveCallUI(simulation = false) {
            const container = document.getElementById("callContainer");
            if (callType === 'video') {
                container.classList.add("video-mode");
                document.getElementById("callTopBar").style.display = "flex";
                document.getElementById("callTopUsername").innerText = currentCallFriend || "Video Call";
            } else {
                container.classList.remove("video-mode");
                document.getElementById("callTopBar").style.display = "none";
            }

            document.getElementById("callInfoBox").style.display = callType === 'voice' ? 'block' : 'none';
            document.getElementById("voiceWaves").style.display = callType === 'voice' ? 'flex' : 'none';
            document.getElementById("videoGrid").style.display = callType === 'video' ? 'block' : 'none';
            document.getElementById("acceptBtn").style.display = "none";
            document.getElementById("declineBtn").style.display = "none";
            document.getElementById("activeCallControls").style.display = "flex";
            document.getElementById("callStatus").innerText = "Active Call (00:00)";

            if (callTimer) clearInterval(callTimer);
            callStartTime = Date.now();
            callTimer = setInterval(() => {
                let elapsed = Math.floor((Date.now() - callStartTime) / 1000);
                let mins = String(Math.floor(elapsed / 60)).padStart(2, '0');
                let secs = String(elapsed % 60).padStart(2, '0');
                let timeStr = mins + ":" + secs;
                document.getElementById("callStatus").innerText = "Active Call (" + timeStr + ")";
                const topTimer = document.getElementById("callTopTimer");
                if (topTimer) topTimer.innerText = timeStr;
            }, 1000);

            if (callType === 'video') {
                setTimeout(() => {
                    const rVid = document.getElementById("remoteVideo");
                    const fallback = document.getElementById("remoteAvatarFallback");
                    if (rVid && (!rVid.srcObject || !rVid.videoWidth)) {
                        if (fallback) fallback.style.display = "block";
                    } else if (fallback) {
                        fallback.style.display = "none";
                    }
                }, 3000);
            }
        }

        function endCall(byRemote = false) {
            stopRingtone();
            if (callTimer) {
                clearInterval(callTimer);
                callTimer = null;
            }

            if (localStream) {
                localStream.getTracks().forEach(track => {
                    try { track.stop(); } catch(e) {}
                });
                localStream = null;
            }

            if (peerConnection) {
                try { peerConnection.close(); } catch(e) {}
                peerConnection = null;
            }

            const rVid = document.getElementById("remoteVideo");
            if (rVid) rVid.srcObject = null;
            const rAud = document.getElementById("remoteAudio");
            if (rAud) rAud.srcObject = null;
            const lVid = document.getElementById("localVideo");
            if (lVid) lVid.srcObject = null;

            if (currentCallFriend && !byRemote) {
                if (socket && socket.readyState === WebSocket.OPEN) {
                    socket.send("CALL_END|" + currentCallFriend + "|ended");
                }
            }

            resetCallUI();
        }

        function resetCallUI() {
            document.getElementById("callOverlay").style.display = "none";
            document.getElementById("callingRings").style.display = "none";
            document.getElementById("activeCallControls").style.display = "none";

            const container = document.getElementById("callContainer");
            if (container) container.classList.remove("video-mode");
            const topBar = document.getElementById("callTopBar");
            if (topBar) topBar.style.display = "none";
            if (document.fullscreenElement) {
                try { document.exitFullscreen(); } catch(e) {}
            }

            micMuted = false;
            camOff = false;
            loudspeakerOn = false;

            if (window.AndroidApp && typeof window.AndroidApp.setSpeakerphoneOn === 'function') {
                try { window.AndroidApp.setSpeakerphoneOn(false); } catch(e) {}
            }

            const speakerBtn = document.getElementById("toggleSpeakerBtn");
            const speakerIcon = document.getElementById("speakerIcon");
            if (speakerBtn) {
                speakerBtn.classList.remove("active");
                speakerBtn.title = "Loudspeaker: OFF";
            }
            if (speakerIcon) {
                speakerIcon.className = "fa-solid fa-volume-low";
            }

            const micBtn = document.getElementById("muteMicBtn");
            const camBtn = document.getElementById("toggleCamBtn");
            if (micBtn) {
                micBtn.classList.remove("active");
                micBtn.innerHTML = '<i class="fa-solid fa-microphone"></i>';
            }
            if (camBtn) {
                camBtn.classList.remove("active");
                camBtn.innerHTML = '<i class="fa-solid fa-video"></i>';
            }

            currentCallFriend = null;
            isCaller = false;
            pendingRemoteOffer = null;
            iceCandidateQueue = [];
        }

        function toggleMic() {
            if (!localStream) return;
            micMuted = !micMuted;
            localStream.getAudioTracks().forEach(track => {
                track.enabled = !micMuted;
            });
            const micBtn = document.getElementById("muteMicBtn");
            if (micBtn) {
                micBtn.classList.toggle("active", micMuted);
                micBtn.innerHTML = micMuted ? '<i class="fa-solid fa-microphone-slash"></i>' : '<i class="fa-solid fa-microphone"></i>';
            }
        }

        function toggleCam() {
            if (!localStream || callType !== 'video') return;
            camOff = !camOff;
            localStream.getVideoTracks().forEach(track => {
                track.enabled = !camOff;
            });
            const camBtn = document.getElementById("toggleCamBtn");
            if (camBtn) {
                camBtn.classList.toggle("active", camOff);
                camBtn.innerHTML = camOff ? '<i class="fa-solid fa-video-slash"></i>' : '<i class="fa-solid fa-video"></i>';
            }
        }

        function setLoudspeaker(enable) {
            loudspeakerOn = enable;
            const remoteAudio = document.getElementById("remoteAudio");
            if (remoteAudio) {
                remoteAudio.volume = 1.0;
                remoteAudio.muted = false;
            }
            if (window.AndroidApp && typeof window.AndroidApp.setSpeakerphoneOn === 'function') {
                try { window.AndroidApp.setSpeakerphoneOn(loudspeakerOn); } catch(e) {}
            }
            const btn = document.getElementById("toggleSpeakerBtn");
            const icon = document.getElementById("speakerIcon");
            if (btn) btn.classList.toggle("active", loudspeakerOn);
            if (icon) icon.className = loudspeakerOn ? "fa-solid fa-volume-high" : "fa-solid fa-volume-low";
            showSpeakerToast(loudspeakerOn ? "Loudspeaker ON" : "Normal Speaker ON", loudspeakerOn);
        }

        function toggleSpeakerphone() {
            setLoudspeaker(!loudspeakerOn);
        }

        function showSpeakerToast(text, isLoud) {
            const toast = document.getElementById("callSpeakerToast");
            if (!toast) return;
            toast.innerHTML = (isLoud ? '<i class="fa-solid fa-volume-high" style="color:#60a5fa;"></i> ' : '<i class="fa-solid fa-volume-low" style="color:#94a3b8;"></i> ') + text;
            toast.classList.add("show");
            if (speakerToastTimer) clearTimeout(speakerToastTimer);
            speakerToastTimer = setTimeout(() => {
                toast.classList.remove("show");
            }, 2000);
        }


        function toggleCallFullscreen() {
            const overlay = document.getElementById("callOverlay");
            const icon = document.getElementById("fullscreenIcon");
            const dockIcon = document.querySelector("#dockFullscreenBtn i");
            if (!document.fullscreenElement) {
                if (overlay.requestFullscreen) {
                    overlay.requestFullscreen();
                } else if (overlay.webkitRequestFullscreen) {
                    overlay.webkitRequestFullscreen();
                }
                if (icon) icon.className = "fa-solid fa-compress";
                if (dockIcon) dockIcon.className = "fa-solid fa-compress";
            } else {
                if (document.exitFullscreen) {
                    document.exitFullscreen();
                } else if (document.webkitExitFullscreen) {
                    document.webkitExitFullscreen();
                }
                if (icon) icon.className = "fa-solid fa-expand";
                if (dockIcon) dockIcon.className = "fa-solid fa-expand";
            }
        }

        function toggleMuteMic() {
            micMuted = !micMuted;
            if (localStream) {
                localStream.getAudioTracks().forEach(track => track.enabled = !micMuted);
            }
            const btn = document.getElementById("muteMicBtn");
            if (micMuted) {
                btn.classList.add("active");
                btn.innerHTML = '<i class="fa-solid fa-microphone-slash"></i>';
            } else {
                btn.classList.remove("active");
                btn.innerHTML = '<i class="fa-solid fa-microphone"></i>';
            }
        }

        function toggleCamera() {
            camOff = !camOff;
            if (localStream) {
                localStream.getVideoTracks().forEach(track => track.enabled = !camOff);
            }
            const btn = document.getElementById("toggleCamBtn");
            if (camOff) {
                btn.classList.add("active");
                btn.innerHTML = '<i class="fa-solid fa-video-slash"></i>';
            } else {
                btn.classList.remove("active");
                btn.innerHTML = '<i class="fa-solid fa-video"></i>';
            }
        }

        // 矧 Loudspeaker Control & Routing System
        function showSpeakerToast(text, isLoud) {
            const toast = document.getElementById("callSpeakerToast");
            if (!toast) return;
            toast.innerHTML = (isLoud ? '<i class="fa-solid fa-volume-high" style="color:#60a5fa;"></i> ' : '<i class="fa-solid fa-volume-low" style="color:#94a3b8;"></i> ') + text;
            toast.classList.add("show");
            if (speakerToastTimer) clearTimeout(speakerToastTimer);
            speakerToastTimer = setTimeout(() => {
                toast.classList.remove("show");
            }, 2000);
        }

        function initCallAudioRouting(stream) {
            try {
                if (!stream) return;
                const AudioCtx = window.AudioContext || window.webkitAudioContext;
                if (!AudioCtx) return;
                if (!callAudioCtx) {
                    callAudioCtx = new AudioCtx();
                }
                if (callAudioCtx.state === 'suspended') {
                    callAudioCtx.resume();
                }
                if (!callAudioSource) {
                    callAudioSource = callAudioCtx.createMediaStreamSource(stream);
                    callGainNode = callAudioCtx.createGain();
                    callGainNode.gain.setValueAtTime(loudspeakerOn ? 1.35 : 0.85, callAudioCtx.currentTime);
                    if (window.AndroidApp && typeof window.AndroidApp.setCallMode === 'function') {
                        try { window.AndroidApp.setCallMode(true); } catch(e) {}
                    }
                    if (window.AndroidApp && typeof window.AndroidApp.setSpeakerphoneOn === 'function') {
                        try { window.AndroidApp.setSpeakerphoneOn(loudspeakerOn); } catch(e) {}
                    }
                    callAudioSource.connect(callGainNode);
                    callGainNode.connect(callAudioCtx.destination);
                    
                    const remoteAudio = document.getElementById("remoteAudio");
                    if (remoteAudio) remoteAudio.muted = true;
                    const remoteVideo = document.getElementById("remoteVideo");
                    if (remoteVideo) remoteVideo.muted = true;
                }
            } catch(e) {
                console.warn("Audio routing error:", e);
                const remoteAudio = document.getElementById("remoteAudio");
                if (remoteAudio) remoteAudio.muted = false;
            }
        }

        async function setLoudspeaker(enable, showToast = true) {
            loudspeakerOn = enable;
            const btn = document.getElementById("toggleSpeakerBtn");
            const icon = document.getElementById("speakerIcon");
            const remoteAudio = document.getElementById("remoteAudio");
            const remoteVideo = document.getElementById("remoteVideo");

            // 1. Android Native App Bridge
            if (window.AndroidApp && typeof window.AndroidApp.setSpeakerphoneOn === 'function') {
                try {
                    window.AndroidApp.setSpeakerphoneOn(loudspeakerOn);
                } catch(e) {
                    console.warn("Android speakerphone call error:", e);
                }
            }

            // 2. Web Audio Gain Booster & Volume
            if (callGainNode && callAudioCtx) {
                if (callAudioCtx.state === 'suspended') {
                    callAudioCtx.resume();
                }
                const targetGain = loudspeakerOn ? 1.35 : 0.85;
                callGainNode.gain.cancelScheduledValues(callAudioCtx.currentTime);
                callGainNode.gain.setValueAtTime(callGainNode.gain.value, callAudioCtx.currentTime);
                callGainNode.gain.linearRampToValueAtTime(targetGain, callAudioCtx.currentTime + 0.1);
            } else {
                if (remoteAudio) {
                    remoteAudio.volume = loudspeakerOn ? 1.0 : 0.6;
                    remoteAudio.muted = false;
                }
                if (remoteVideo) {
                    remoteVideo.volume = loudspeakerOn ? 1.0 : 0.6;
                }
            }

            // 3. Audio Output Device Sink Selection (Chrome/Edge/Android supported)
            if (typeof remoteAudio?.setSinkId === 'function' && navigator.mediaDevices?.enumerateDevices) {
                try {
                    const devices = await navigator.mediaDevices.enumerateDevices();
                    const audioOutputs = devices.filter(d => d.kind === 'audiooutput');
                    if (audioOutputs.length > 0) {
                        if (loudspeakerOn) {
                            const speakerDev = audioOutputs.find(d => 
                                d.label.toLowerCase().includes('speaker') || 
                                d.label.toLowerCase().includes('loudspeaker') ||
                                d.label.toLowerCase().includes('default')
                            );
                            if (speakerDev) {
                                await remoteAudio.setSinkId(speakerDev.deviceId);
                                if (remoteVideo) await remoteVideo.setSinkId(speakerDev.deviceId);
                            }
                        } else {
                            const commDev = audioOutputs.find(d => 
                                d.label.toLowerCase().includes('earpiece') || 
                                d.label.toLowerCase().includes('headset') ||
                                d.label.toLowerCase().includes('communications')
                            ) || audioOutputs[0];
                            if (commDev) {
                                await remoteAudio.setSinkId(commDev.deviceId);
                                if (remoteVideo) await remoteVideo.setSinkId(commDev.deviceId);
                            }
                        }
                    }
                } catch(err) {
                    console.log("Device sink note:", err);
                }
            }

            // 4. Update UI Button and Toast
            if (loudspeakerOn) {
                if (btn) {
                    btn.classList.add("active");
                    btn.title = "Loudspeaker: ON (Click for Earpiece/Normal)";
                }
                if (icon) {
                    icon.className = "fa-solid fa-volume-high";
                }
                if (showToast) showSpeakerToast("Loudspeaker ON", true);
            } else {
                if (btn) {
                    btn.classList.remove("active");
                    btn.title = "Loudspeaker: OFF (Click for Loudspeaker)";
                }
                if (icon) {
                    icon.className = "fa-solid fa-volume-low";
                }
                if (showToast) showSpeakerToast("Loudspeaker OFF (Earpiece/Normal)", false);
            }
        }

        // ================= CHAT GIF INTEGRATION =================
        let chatGifSearchTimeout = null;

        function toggleChatGifPicker() {
            const picker = document.getElementById("chatGifPicker");
            if (!picker) return;
            const isHidden = picker.style.display === "none" || picker.style.display === "";
            picker.style.display = isHidden ? "flex" : "none";
            if (isHidden) {
                loadChatGifs("");
            }
        }

        function debounceChatGifSearch(query) {
            clearTimeout(chatGifSearchTimeout);
            chatGifSearchTimeout = setTimeout(() => {
                loadChatGifs(query);
            }, 300);
        }

        function loadChatGifs(query) {
            const grid = document.getElementById("chatGifGrid");
            if (!grid) return;
            grid.innerHTML = '<div style="grid-column:span 2; text-align:center; padding:20px; font-size:12px; color:#94a3b8;"><i class="fa fa-spinner fa-spin"></i> Loading GIFs...</div>';

            fetch("GifServlet?q=" + encodeURIComponent(query || ""))
                .then(res => res.json())
                .then(data => {
                    const list = data.results || [];
                    if (list.length === 0) {
                        grid.innerHTML = '<div style="grid-column:span 2; text-align:center; padding:20px; font-size:12px; color:#94a3b8;">No GIFs found</div>';
                        return;
                    }
                    let html = "";
                    list.forEach(g => {
                        html += '<div onclick="sendGifToFriend(\'' + g.url + '\')" style="border-radius:10px; overflow:hidden; cursor:pointer; background:#f1f5f9; height:85px; display:flex; align-items:center; justify-content:center; box-shadow:0 1px 3px rgba(0,0,0,0.1);">' +
                            '<img src="' + g.url + '" alt="' + (g.title || 'GIF') + '" style="width:100%; height:100%; object-fit:cover;" loading="lazy">' +
                        '</div>';
                    });
                    grid.innerHTML = html;
                })
                .catch(err => {
                    grid.innerHTML = '<div style="grid-column:span 2; text-align:center; padding:20px; font-size:12px; color:#ef4444;">Failed to load GIFs</div>';
                });
        }

        function sendGifToFriend(gifUrl) {
            var friend = document.getElementById("targetFriendName").value;
            if (friend === "None" || !friend) {
                alert("Please select a friend first to send GIF!");
                return;
            }
            if (socket && socket.readyState === WebSocket.OPEN) {
                socket.send("CHAT|" + friend + "|" + gifUrl);
                displayMessage({
                    id: "temp_" + Date.now(),
                    sender: myName,
                    message: gifUrl,
                    isRead: false,
                    isEdited: false,
                    isDeleted: false
                }, 'sent');
                toggleChatGifPicker();
            } else {
                alert("Chat server connecting, please retry in a moment...");
                initWebSocket();
            }
        }

        function toggleLoudspeaker() {
            setLoudspeaker(!loudspeakerOn, true);
        }

        // ================= SECURITY & BLOCK MANAGEMENT =================
        let blockedUserIds = new Set();
        let blockedUserNames = new Set();
        let currentChatUserId = null;

        function fetchBlockedUsers() {
            fetch('SecurityServlet?action=getBlockedUsers')
                .then(res => res.json())
                .then(data => {
                    if (data.success && data.users) {
                        blockedUserIds = new Set(data.users.map(u => u.id));
                        blockedUserNames = new Set(data.users.map(u => (u.name || '').toLowerCase()));
                        updateBlockedStatusForActiveChat();
                    }
                })
                .catch(e => console.log('Error fetching blocked users', e));
        }

        function updateBlockedStatusForActiveChat() {
            const friend = document.getElementById('targetFriendName').value;
            const banner = document.getElementById('chatBlockedBanner');
            const blockBtn = document.getElementById('blockUserChatBtn');
            const input = document.getElementById('messageText');
            const sendBtn = document.querySelector('.btn-send');

            if (!friend || friend === 'None' || friend === 'Gemini AI' || friend === 'gemini') {
                if (banner) banner.style.display = 'none';
                if (blockBtn) blockBtn.style.display = 'none';
                if (input) input.disabled = false;
                if (sendBtn) sendBtn.disabled = false;
                return;
            }

            if (blockBtn) blockBtn.style.display = 'inline-block';
            const isBlocked = (currentChatUserId && blockedUserIds.has(currentChatUserId)) ||
                              (friend && blockedUserNames.has(friend.toLowerCase()));

            if (isBlocked) {
                if (banner) banner.style.display = 'flex';
                if (blockBtn) {
                    blockBtn.title = 'Unblock ' + friend;
                    blockBtn.className = 'fa-solid fa-lock-open';
                    blockBtn.style.color = '#16a34a';
                }
                if (input) {
                    input.disabled = true;
                    input.placeholder = 'You cannot send messages to a blocked user.';
                }
                if (sendBtn) sendBtn.disabled = true;
            } else {
                if (banner) banner.style.display = 'none';
                if (blockBtn) {
                    blockBtn.title = 'Block ' + friend;
                    blockBtn.className = 'fa-solid fa-shield-halved';
                    blockBtn.style.color = '#e11d48';
                }
                if (input) {
                    input.disabled = false;
                    input.placeholder = 'Type a message or @gemini to ask AI...';
                }
                if (sendBtn) sendBtn.disabled = false;
            }
        }

        function toggleBlockCurrentChatUser() {
            const friend = document.getElementById('targetFriendName').value;
            if (!friend || friend === 'None' || friend === 'Gemini AI') return;

            const isBlocked = (currentChatUserId && blockedUserIds.has(currentChatUserId)) ||
                              (friend && blockedUserNames.has(friend.toLowerCase()));

            if (isBlocked) {
                unblockCurrentChatUser();
            } else {
                if (!confirm('Are you sure you want to block ' + friend + '? You will no longer receive calls or messages from them.')) return;
                let targetId = currentChatUserId;
                if (!targetId) {
                    const el = document.getElementById('friend-item-' + friend);
                    if (el && el.dataset && el.dataset.userid) targetId = parseInt(el.dataset.userid);
                }
                if (!targetId) {
                    alert('Unable to identify user ID to block.');
                    return;
                }
                fetch('SecurityServlet?action=block&userId=' + targetId, { method: 'POST' })
                    .then(res => res.json())
                    .then(data => {
                        if (data.success) {
                            blockedUserIds.add(targetId);
                            blockedUserNames.add(friend.toLowerCase());
                            updateBlockedStatusForActiveChat();
                            alert(friend + ' has been blocked.');
                        } else {
                            alert(data.message || 'Failed to block user.');
                        }
                    })
                    .catch(err => alert('Network error blocking user.'));
            }
        }

        function unblockCurrentChatUser() {
            const friend = document.getElementById('targetFriendName').value;
            if (!friend || friend === 'None') return;
            if (!confirm('Are you sure you want to unblock ' + friend + '?')) return;

            let targetId = currentChatUserId;
            if (!targetId) {
                const el = document.getElementById('friend-item-' + friend);
                if (el && el.dataset && el.dataset.userid) targetId = parseInt(el.dataset.userid);
            }
            if (!targetId) {
                alert('Unable to identify user ID to unblock.');
                return;
            }
            fetch('SecurityServlet?action=unblock&userId=' + targetId, { method: 'POST' })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        blockedUserIds.delete(targetId);
                        blockedUserNames.delete(friend.toLowerCase());
                        updateBlockedStatusForActiveChat();
                        alert(friend + ' has been unblocked.');
                    } else {
                        alert(data.message || 'Failed to unblock user.');
                    }
                })
                .catch(err => alert('Network error unblocking user.'));
        }

        // Initialize blocked users list & Service Worker on load
        document.addEventListener('DOMContentLoaded', () => {
            fetchBlockedUsers();
            if ('serviceWorker' in navigator) {
                navigator.serviceWorker.getRegistrations().then(regs => { for (let r of regs) r.unregister(); }); if ('caches' in window) { caches.keys().then(keys => { for (let k of keys) caches.delete(k); }); }
            }
            if ('Notification' in window && Notification.permission === 'default') {
                Notification.requestPermission();
                document.addEventListener("visibilitychange", function() {
                    if (document.visibilityState === "visible") {
                        if (!socket || socket.readyState !== WebSocket.OPEN) {
                            initWebSocket();
                        }
                    }
                });
                window.addEventListener("pageshow", function() {
                    if (!socket || socket.readyState !== WebSocket.OPEN) {
                        initWebSocket();
                    }
                });
            }
        });
    </script>

    <!-- Mobile Bottom Navigation Bar (Visible only on mobile/tablet) -->
    <nav id="mobileBottomNav" class="md:hidden fixed bottom-0 left-0 right-0 h-[65px] bg-white/95 backdrop-blur-md border-t border-gray-200 z-[99999] flex justify-around items-center px-4 rounded-t-3xl shadow-[0_-8px_30px_rgba(0,0,0,0.15)]">
        <a href="UsersPostServlet" class="flex flex-col items-center gap-1 text-gray-500 hover:text-blue-500 transition">
            <i class="fa fa-house text-xl"></i>
            <span class="text-[10px] font-bold">Home</span>
        </a>
        <a href="FriendServlet" class="flex flex-col items-center gap-1 text-gray-500 hover:text-blue-500 transition">
            <i class="fa fa-user-group text-xl"></i>
            <span class="text-[10px] font-bold">Friends</span>
        </a>
        <a href="messages.jsp" class="flex flex-col items-center gap-1 text-blue-500">
            <i class="fa-brands fa-facebook-messenger text-xl"></i>
            <span class="text-[10px] font-bold">Messenger</span>
        </a>
        <a href="UsersProfileServlet?userId=${sessionScope.userId}" class="flex flex-col items-center gap-1 text-gray-500 hover:text-blue-500 transition">
            <img src="img/<%= ub.getProfile_pic() != null ? ub.getProfile_pic() : "default.png" %>" class="w-6 h-6 rounded-full border border-gray-300">
            <span class="text-[10px] font-bold">Profile</span>
        </a>
    </nav>

    <script src="js/theme.js?v=20261029-safari-v7"></script><script src="js/ychat-pro-features.js?v=20261029-safari-v7"></script>
</body>
</html>
