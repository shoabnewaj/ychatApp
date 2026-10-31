<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
<head>
    <script src="<%=request.getContextPath()%>/js/notification-badge.js" data-context-path="<%=request.getContextPath()%>" defer></script>
    <script src="<%=request.getContextPath()%>/js/global-call-presence.js" data-user="${sessionScope.ub.name}" data-context-path="<%=request.getContextPath()%>" defer></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications | Y-ChatApp</title>
    <link rel="icon" type="image/png" href="<%=request.getContextPath()%>/icons/icon-192.png">
    <style>
        * { margin:0; padding:0; box-sizing:border-box; }
        body { font-family: 'Segoe UI', sans-serif; display: flex; background: #f0f2f5; height: 100vh; overflow: hidden; }
        .sidebar { width: 260px; height: 100vh; background: white; padding: 20px; border-right: 1px solid #ddd; position: fixed; display: flex; flex-direction: column; justify-content: space-between; }
        .logo { font-size: 22px; font-weight: bold; color: purple; margin-bottom: 25px; }
        .menu a { display: block; padding: 12px; text-decoration: none; color: #555; border-radius: 10px; margin-bottom: 5px; }
        .menu a:hover, .active-menu { background: #f3e8ff; color: purple !important; }
        .main { flex: 1; margin-left: 260px; padding: 40px; overflow-y: auto; display: flex; flex-direction: column; align-items: center; }
        .notif-container { width: 100%; max-width: 600px; background: white; padding: 25px; border-radius: 15px; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        .notif-item { display: flex; justify-content: space-between; align-items: center; padding: 15px; border-bottom: 1px solid #eee; }
        .notif-left { display: flex; align-items: center; gap: 15px; }
        .notif-icon { font-size: 20px; width: 45px; height: 45px; background: #f3e8ff; border-radius: 50%; display: flex; align-items: center; justify-content: center; }
        .delete-btn { color: #ff3b30; text-decoration: none; font-size: 20px; padding: 5px; cursor: pointer; }
        @media (max-width: 768px) {
            body { flex-direction: column; height: auto; min-height: 100vh; overflow-y: auto; }
            .sidebar { width: 100%; height: auto; position: relative; border-right: none; border-bottom: 1px solid #ddd; padding: 15px; }
            .sidebar .menu { display: flex; flex-wrap: wrap; gap: 6px; }
            .sidebar .menu a { margin-bottom: 0; padding: 8px 12px; font-size: 14px; }
            .main { margin-left: 0; padding: 15px; width: 100%; }
            .notif-container { padding: 15px; }
        }
    </style>
</head>
<body>

<div class="sidebar">
    <div>
        <div class="logo">💬 Y-ChatApp</div>
        <div class="menu">
            <a href="UsersPostServlet">🏠 Home</a>
            <a href="NotificationServlet" class="active-menu">🔔 Notifications</a>
            <a href="FriendServlet">👥 Friends</a>
            <a href="UsersProfileServlet?userId=${sessionScope.userId}">👤 Profile</a>
            <a href="UsersLogoutServlet">🚪 Logout</a>
        </div>
    </div>
    <div style="background: #f3f4f6; padding: 15px; border-radius: 12px;">
        <b>${ub.getName()}</b><br><small>${ub.getEmail()}</small>
    </div>
</div>

<div class="main">
    <div class="notif-container">
        <h2 style="color: purple; margin-bottom: 20px; border-bottom: 2px solid #f3e8ff; padding-bottom: 10px;">🔔 Notifications</h2>
        
        <c:choose>
            <c:when test="${empty notifications}">
                <p style="text-align:center; padding: 20px; color:#888;">📭 No new notifications.</p>
            </c:when>
            <c:otherwise>
                <c:forEach var="message" items="${notifications}">
                    <div class="notif-item">
                        <a class="notif-left" href="${message.type eq 'LIVE' and message.senderId gt 0 ? 'VideosServlet?watchId=' : 'NotificationServlet'}${message.type eq 'LIVE' and message.senderId gt 0 ? message.senderId : ''}" style="color:inherit;text-decoration:none;flex:1;">
                            <div class="notif-icon">
                                <c:choose>
                                    <c:when test="${message.type eq 'LIVE'}">🔴</c:when>
                                    <c:otherwise>
                                    <c:choose>
                                    <c:when test="${message.message.contains('reacted')}">❤️</c:when>
                                    <c:when test="${message.message.contains('liked')}">👍</c:when>
                                    <c:when test="${message.message.contains('friend request')}">👥</c:when>
                                    <c:when test="${message.message.contains('accepted')}">🤝</c:when>
                                    <c:when test="${message.message.contains('message')}">💬</c:when>
                                    <c:when test="${message.message.contains('commented')}">📝</c:when>
                                    <c:when test="${message.message.contains('replied')}">↩️</c:when>
                                    <c:when test="${message.message.contains('shared')}">🔄</c:when>
                                    <c:otherwise>🔔</c:otherwise>
                                </c:choose>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div>
                                <p style="color: #333; font-size: 15px;">${message.message}</p>
                                <small style="color: #999;" title="${message.createdAt}">${message.timeAgo}</small>
                            </div>
                        </a>
                        <a href="NotificationServlet?action=delete&amp;msg=${message.id}" class="delete-btn" onclick="return confirm('Delete this notification?')">×</a>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </div>
</div>

</body>
</html>