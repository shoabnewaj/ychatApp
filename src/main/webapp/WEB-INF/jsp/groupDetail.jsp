<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <script src="<%=request.getContextPath()%>/js/notification-badge.js" data-context-path="<%=request.getContextPath()%>" defer></script>
    <script src="<%=request.getContextPath()%>/js/global-call-presence.js" data-user="${sessionScope.ub.name}" data-context-path="<%=request.getContextPath()%>" defer></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${group.getName()} | Y-Chat Group</title>
    <link rel="icon" type="image/png" href="<%=request.getContextPath()%>/icons/icon-192.png">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
            background-size: 400% 400%;
            animation: gradient 15s ease infinite;
            font-family: 'Outfit', sans-serif;
            min-height: 100vh;
        }
        @keyframes gradient {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        .glass-card {
            background: rgba(255, 255, 255, 0.75) !important;
            backdrop-filter: blur(12px) !important;
            border: 1px solid rgba(255, 255, 255, 0.3) !important;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.15) !important;
        }
        .glass-nav {
            background: rgba(255, 255, 255, 0.8) !important;
            backdrop-filter: blur(12px) !important;
            border-bottom: 1px solid rgba(255, 255, 255, 0.3) !important;
        }
        .react-box {
            display: none;
            position: absolute;
            bottom: 100%;
            left: 0;
            background: white;
            border-radius: 9999px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            padding: 8px;
            gap: 8px;
            animation: popUp 0.2s cubic-bezier(0.18, 0.89, 0.32, 1.28);
            z-index: 100;
        }
        .react-container:hover .react-box {
            display: flex;
        }
        @keyframes popUp {
            from { opacity: 0; transform: translateY(10px) scale(0.9); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
    </style>
</head>
<body class="bg-fixed">

    <!-- Header Navigation -->
    <header class="glass-nav h-[56px] sticky top-0 z-[5000] flex items-center justify-between px-4">
        <div class="flex items-center gap-2 flex-1">
            <div class="logo flex items-center gap-2">
                <img src="<%=request.getContextPath()%>/icons/icon-192.png" width="40" alt="Logo">
                <span class="font-bold text-xl">Y-ChatApp</span>
            </div>
        </div>

        <!-- Center Section (Navigation) -->
        <div class="hidden lg:flex flex-1 justify-center gap-12 text-[24px]">
            <a href="UsersPostServlet" title="Home" class="text-gray-500 hover:text-blue-500 transition"><i class="fa fa-house"></i></a>
            <a href="GroupsServlet" title="Groups" class="text-blue-500"><i class="fa fa-user-group"></i></a>
            <a href="VideosServlet" title="Videos" class="text-gray-500 hover:text-blue-500 transition"><i class="fa fa-video"></i></a>
            <a href="MarketServlet" title="Market" class="text-gray-500 hover:text-blue-500 transition"><i class="fa fa-shop"></i></a>
        </div>

        <!-- Right Section (Actions) -->
        <div class="flex items-center gap-3 flex-1 justify-end">
            <a href="NotificationServlet" class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center hover:bg-gray-300 transition">
                <i class="fa fa-bell text-black"></i>
            </a>
            <a href="UsersProfileServlet?userId=${sessionScope.userId}" class="flex items-center gap-2 p-1 hover:bg-gray-100 rounded-full border border-transparent transition">
                <img src="img/${ub.getProfile_pic()}" class="w-9 h-9 rounded-full border">
                <span class="hidden md:inline">${ub.getName()}</span>
            </a>
            <a href="UsersLogoutServlet" title="Logout" class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center hover:bg-red-100 hover:text-red-600 transition">
                <i class="fa fa-right-from-bracket"></i>
            </a>
        </div>
    </header>

    <div class="max-w-[1000px] mx-auto p-6">
        
        <!-- Group Hero Header -->
        <div class="glass-card rounded-3xl overflow-hidden mb-8 shadow-md">
            <!-- Cover photo -->
            <div class="h-64 w-full bg-gradient-to-r from-blue-400 to-purple-500 relative">
                <c:if test="${not empty group.getCoverPic()}">
                    <img src="img/${group.getCoverPic()}" class="w-full h-full object-cover">
                </c:if>
            </div>
            <!-- Details -->
            <div class="p-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div>
                    <h1 class="text-3xl font-extrabold text-gray-800">${group.getName()}</h1>
                    <p class="text-gray-600 text-sm mt-1">${group.getMemberCount()} members • Created by ${group.getCreatorName()}</p>
                    <p class="text-gray-700 text-sm mt-3 max-w-2xl">${group.getDescription()}</p>
                </div>
                <div class="flex gap-3">
                    <c:choose>
                        <c:when test="${group.isJoined()}">
                            <form action="GroupsServlet" method="post">
                                <input type="hidden" name="action" value="LEAVE">
                                <input type="hidden" name="groupId" value="${group.getId()}">
                                <button type="submit" class="bg-red-50 hover:bg-red-100 text-red-600 font-semibold px-6 py-3 rounded-full transition shadow-sm">
                                    Leave Group
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <form action="GroupsServlet" method="post">
                                <input type="hidden" name="action" value="JOIN">
                                <input type="hidden" name="groupId" value="${group.getId()}">
                                <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-full transition shadow-md">
                                    Join Group
                                </button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-[1fr_350px] gap-6">
            <!-- Feed / Post Section -->
            <div class="space-y-6">
                <!-- Create Post (if joined) -->
                <c:choose>
                    <c:when test="${group.isJoined()}">
                        <div class="glass-card p-6 rounded-3xl">
                            <h3 class="text-lg font-bold text-gray-800 mb-3">✍️ Write something in the group</h3>
                            <form action="GroupsServlet" method="post" enctype="multipart/form-data" class="space-y-3">
                                <input type="hidden" name="action" value="ADD_POST">
                                <input type="hidden" name="groupId" value="${group.getId()}">
                                <textarea name="content" rows="3" required placeholder="What's on your mind, ${ub.getName()}?" class="w-full px-4 py-2 rounded-xl bg-white/60 border border-gray-200 outline-none focus:border-blue-500 transition text-sm"></textarea>
                                <div class="flex items-center justify-between">
                                    <input type="file" name="image" accept="image/*,video/*" class="text-xs text-gray-500 file:mr-3 file:py-1.5 file:px-3 file:rounded-full file:border-0 file:text-xs file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100">
                                    <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-5 py-2 rounded-full text-sm transition shadow-sm">
                                        Post
                                    </button>
                                </div>
                            </form>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="glass-card p-6 rounded-3xl text-center text-gray-500 italic">
                            🔒 Join the group to view discussion and publish posts.
                        </div>
                    </c:otherwise>
                </c:choose>

                <!-- Posts List -->
                <c:if test="${group.isJoined()}">
                    <c:choose>
                        <c:when test="${empty posts}">
                            <div class="glass-card text-center p-12 rounded-3xl text-gray-500 italic">
                                No posts in this group yet. Be the first to start a conversation!
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="post" items="${posts}">
                                <div class="glass-card p-6 rounded-3xl">
                                    <!-- User Header -->
                                    <div class="flex items-center gap-3 mb-4">
                                        <img src="img/${post.getProfile_pic()}" class="w-10 h-10 rounded-full border">
                                        <div>
                                            <div class="font-bold text-gray-800">${post.getName()}</div>
                                            <div class="text-xs text-gray-500">${post.getTime()}</div>
                                        </div>
                                    </div>

                                    <!-- Content -->
                                    <p class="text-gray-700 text-sm mb-4">${post.getContent()}</p>

                                    <!-- Attachment -->
                                    <c:if test="${not empty post.getFile_name()}">
                                        <div class="rounded-2xl overflow-hidden mb-4 border max-h-[400px] flex items-center justify-center bg-black/5">
                                            <c:choose>
                                                <c:when test="${post.getPost_type() == 'video'}">
                                                    <video class="w-full h-full max-h-[400px]" controls preload="metadata">
                                                        <source src="img/${post.getFile_name()}" type="video/mp4">
                                                    </video>
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="img/${post.getFile_name()}" class="w-full h-full object-cover">
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </c:if>

                                    <!-- Interaction Bar -->
                                    <div class="flex items-center justify-between border-t border-b border-white/20 py-2 mb-3">
                                        <div class="relative react-container">
                                            <button class="flex items-center gap-1.5 text-gray-600 hover:text-blue-600 font-semibold text-xs transition">
                                                <i class="fa-regular fa-thumbs-up"></i> React
                                            </button>
                                            <div class="react-box">
                                                <span class="cursor-pointer hover:scale-125 transition text-lg" onclick="reactPost(${post.getId()}, 'LIKE')">👍</span>
                                                <span class="cursor-pointer hover:scale-125 transition text-lg" onclick="reactPost(${post.getId()}, 'LOVE')">❤️</span>
                                                <span class="cursor-pointer hover:scale-125 transition text-lg" onclick="reactPost(${post.getId()}, 'CARE')">🥰</span>
                                                <span class="cursor-pointer hover:scale-125 transition text-lg" onclick="reactPost(${post.getId()}, 'HAHA')">😆</span>
                                                <span class="cursor-pointer hover:scale-125 transition text-lg" onclick="reactPost(${post.getId()}, 'WOW')">😮</span>
                                                <span class="cursor-pointer hover:scale-125 transition text-lg" onclick="reactPost(${post.getId()}, 'SAD')">😢</span>
                                                <span class="cursor-pointer hover:scale-125 transition text-lg" onclick="reactPost(${post.getId()}, 'ANGRY')">😡</span>
                                                <span class="cursor-pointer hover:scale-125 transition text-lg" onclick="reactPost(${post.getId()}, 'DISLIKE')">👎</span>
                                            </div>
                                        </div>

                                        <button class="flex items-center gap-1.5 text-gray-600 hover:text-blue-600 font-semibold text-xs transition">
                                            <i class="fa-regular fa-message"></i> Comment
                                        </button>

                                        <button onclick="sharePost(${post.getId()})" class="flex items-center gap-1.5 text-gray-600 hover:text-blue-600 font-semibold text-xs transition">
                                            <i class="fa-solid fa-share-nodes"></i> Share
                                        </button>
                                    </div>

                                    <!-- Counts -->
                                    <div class="flex items-center gap-2 mb-4 text-xs font-semibold text-gray-500">
                                        <span id="reactCount-${post.getId()}">
                                            ${post.getLikeCount() + post.getLoveCount() + post.getCareCount() + post.getHahaCount() + post.getWowCount() + post.getSadCount() + post.getAngryCount() + post.getDislikes()} reactions
                                        </span>
                                        <span>•</span>
                                        <span id="commentCountText-${post.getId()}">${post.getCommentCount()} comments</span>
                                    </div>

                                    <!-- Comments list -->
                                    <div id="comment-list-${post.getId()}" class="space-y-2 mb-4 max-h-[220px] overflow-y-auto pr-1">
                                        <c:forEach var="comment" items="${post.getComments()}">
                                            <div class="flex gap-2 items-start text-xs">
                                                <img src="img/${comment.profilePic}" class="w-6 h-6 rounded-full border">
                                                <div class="flex flex-col flex-1">
                                                    <div class="bg-white/40 px-3 py-1.5 rounded-2xl inline-block max-w-fit">
                                                        <span class="font-bold text-gray-800">${comment.name}</span>
                                                        <p class="text-gray-700 mt-0.5">${comment.text}</p>
                                                    </div>
                                                    <!-- Reaction & Reply Links -->
                                                    <div class="flex gap-4 ml-3 mt-0.5 text-[10px] font-bold text-gray-500 items-center">
                                                        <div class="react-container clickable relative">
                                                            <span class="hover:text-blue-600 cursor-pointer transition" onclick="handleAJAXReact(${comment.id}, 'Like', 'comment', event)">Like</span>
                                                            <div class="react-box !p-1 !rounded-full">
                                                                <span class="cursor-pointer" title="Like" onclick="handleAJAXReact(${comment.id}, 'Like', 'comment', event)">👍</span>
                                                                <span class="cursor-pointer" title="Love" onclick="handleAJAXReact(${comment.id}, 'Love', 'comment', event)">❤️</span>
                                                                <span class="cursor-pointer" title="Care" onclick="handleAJAXReact(${comment.id}, 'Care', 'comment', event)">🥰</span>
                                                                <span class="cursor-pointer" title="Haha" onclick="handleAJAXReact(${comment.id}, 'Haha', 'comment', event)">😆</span>
                                                                <span class="cursor-pointer" title="Wow" onclick="handleAJAXReact(${comment.id}, 'Wow', 'comment', event)">😮</span>
                                                                <span class="cursor-pointer" title="Sad" onclick="handleAJAXReact(${comment.id}, 'Sad', 'comment', event)">😢</span>
                                                                <span class="cursor-pointer" title="Angry" onclick="handleAJAXReact(${comment.id}, 'Angry', 'comment', event)">😡</span>
                                                                <span class="cursor-pointer" title="Dislike" onclick="handleAJAXReact(${comment.id}, 'Dislike', 'comment', event)">👎</span>
                                                            </div>
                                                        </div>
                                                        <div id="comment-react-container-${comment.id}" class="text-[9px] font-normal text-gray-400">
                                                            <c:set var="tc" value="${comment.likeCount + comment.loveCount + comment.careCount + comment.hahaCount + comment.wowCount + comment.sadCount + comment.angryCount + comment.dislikes}"/>
                                                            <c:if test="${tc > 0}">
                                                                <c:if test="${comment.likeCount > 0}">👍 <span class="text-gray-600">${comment.likeCount}</span>&nbsp;&nbsp;</c:if>
                                                                <c:if test="${comment.loveCount > 0}">❤️ <span class="text-gray-600">${comment.loveCount}</span>&nbsp;&nbsp;</c:if>
                                                                <c:if test="${comment.careCount > 0}">🥰 <span class="text-gray-600">${comment.careCount}</span>&nbsp;&nbsp;</c:if>
                                                                <c:if test="${comment.hahaCount > 0}">😆 <span class="text-gray-600">${comment.hahaCount}</span>&nbsp;&nbsp;</c:if>
                                                                <c:if test="${comment.wowCount > 0}">😮 <span class="text-gray-600">${comment.wowCount}</span>&nbsp;&nbsp;</c:if>
                                                                <c:if test="${comment.sadCount > 0}">😢 <span class="text-gray-600">${comment.sadCount}</span>&nbsp;&nbsp;</c:if>
                                                                <c:if test="${comment.angryCount > 0}">😡 <span class="text-gray-600">${comment.angryCount}</span>&nbsp;&nbsp;</c:if>
                                                                <c:if test="${comment.dislikes > 0}">👎 <span class="text-gray-600">${comment.dislikes}</span>&nbsp;&nbsp;</c:if>
                                                            </c:if>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <!-- Add Comment Form -->
                                    <div class="flex gap-2">
                                        <input type="text" id="commentInput-${post.getId()}" placeholder="Write a comment..." class="flex-1 px-4 py-1.5 rounded-full bg-white/60 border border-gray-200 outline-none focus:border-blue-500 text-xs transition" onkeydown="if(event.key === 'Enter') submitCommentAJAX(${post.getId()})">
                                        <button onclick="submitCommentAJAX(${post.getId()})" class="bg-blue-600 hover:bg-blue-700 text-white w-7 h-7 rounded-full flex items-center justify-center transition">
                                            <i class="fa fa-paper-plane text-xs"></i>
                                        </button>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </c:if>
            </div>

            <!-- About Section / Creator Details -->
            <div>
                <div class="glass-card p-6 rounded-3xl sticky top-[80px]">
                    <h3 class="font-bold text-gray-800 text-lg mb-3">ℹ️ About this group</h3>
                    <div class="space-y-4 text-sm text-gray-700">
                        <div>
                            <span class="font-semibold block text-gray-800">Creator</span>
                            <span>${group.getCreatorName()}</span>
                        </div>
                        <div>
                            <span class="font-semibold block text-gray-800">Created On</span>
                            <span>${group.createdAt}</span>
                        </div>
                        <div>
                            <span class="font-semibold block text-gray-800">Privacy</span>
                            <span>Public Group</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script>
        function reactPost(postId, reactionType) {
            const formData = new FormData();
            formData.append("postId", postId);
            formData.append("action", reactionType);

            fetch('InteractionServlet', {
                method: 'POST',
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                if (data.status === 'ok') {
                    document.getElementById(`reactCount-${postId}`).innerText = `${data.newCount} reactions`;
                }
            })
            .catch(err => console.error(err));
        }

        function sharePost(postId) {
            const formData = new FormData();
            formData.append("postId", postId);
            formData.append("action", "SHARE");

            fetch('InteractionServlet', {
                method: 'POST',
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                if (data.status === 'shared') {
                    alert("Post shared successfully to your feed!");
                    window.location.reload();
                }
            })
            .catch(err => console.error(err));
        }

        function handleAJAXReact(id, type, level, event) {
            if (event) event.stopPropagation();
            let targetUrl = '${pageContext.request.contextPath}/CommentServlet';
            let formData = new FormData();
            formData.append('commentId', id);
            formData.append('action', type);
            formData.append('level', level);

            let emojiMap = {
                'Like': '👍', 'Love': '❤️', 'Care': '🥰', 'Haha': '😆', 
                'Wow': '😮', 'Sad': '😢', 'Angry': '😡', 'Dislike': '👎'
            };

            fetch(targetUrl, { 
                method: 'POST', 
                body: formData
            })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    let countsHtml = '';
                    if (data.counts) {
                        for (let key in data.counts) {
                            if (data.counts[key] > 0) {
                                let mappedKey = key === 'Dislikes' ? 'Dislike' : key;
                                countsHtml += `${emojiMap[mappedKey]} <span class="text-gray-600">${data.counts[key]}</span>&nbsp;&nbsp;`;
                            }
                        }
                        countsHtml = countsHtml.trim();
                    }
                    let container = document.getElementById(`comment-react-container-${id}`);
                    if (container) {
                        container.innerHTML = countsHtml || '';
                    }
                }
            })
            .catch(err => console.error(err));
        }

        function submitCommentAJAX(postId) {
            let input = document.getElementById('commentInput-' + postId);
            if (!input || !input.value.trim()) return;

            let formData = new FormData();
            formData.append("postId", postId);
            formData.append("commentText", input.value);
            formData.append("action", "ADD_COMMENT");

            fetch('CommentServlet', { method: 'POST', body: formData })
            .then(res => res.json())
            .then(data => {
                if (data.success) {
                    // Update comment count UI
                    let countText = document.getElementById(`commentCountText-${postId}`);
                    if (countText) {
                        let currentCount = parseInt(countText.innerText) || 0;
                        countText.innerText = `${currentCount + 1} comments`;
                    }
                    
                    // Append new comment HTML
                    let list = document.getElementById(`comment-list-${postId}`);
                    if (list) {
                        let html = `
                            <div class="flex gap-2 items-start text-xs">
                                <img src="img/${data.userPic}" class="w-6 h-6 rounded-full border">
                                <div class="flex flex-col flex-1">
                                    <div class="bg-white/40 px-3 py-1.5 rounded-2xl inline-block max-w-fit">
                                        <span class="font-bold text-gray-800">${data.userName}</span>
                                        <p class="text-gray-700 mt-0.5">${data.text}</p>
                                    </div>
                                    <!-- Reaction & Reply Links -->
                                    <div class="flex gap-4 ml-3 mt-0.5 text-[10px] font-bold text-gray-500 items-center">
                                        <div class="react-container clickable relative">
                                            <span class="hover:text-blue-600 cursor-pointer transition" onclick="handleAJAXReact(${data.commentId}, 'Like', 'comment', event)">Like</span>
                                            <div class="react-box !p-1 !rounded-full">
                                                <span class="cursor-pointer" title="Like" onclick="handleAJAXReact(${data.commentId}, 'Like', 'comment', event)">👍</span>
                                                <span class="cursor-pointer" title="Love" onclick="handleAJAXReact(${data.commentId}, 'Love', 'comment', event)">❤️</span>
                                                <span class="cursor-pointer" title="Care" onclick="handleAJAXReact(${data.commentId}, 'Care', 'comment', event)">🥰</span>
                                                <span class="cursor-pointer" title="Haha" onclick="handleAJAXReact(${data.commentId}, 'Haha', 'comment', event)">😆</span>
                                                <span class="cursor-pointer" title="Wow" onclick="handleAJAXReact(${data.commentId}, 'Wow', 'comment', event)">😮</span>
                                                <span class="cursor-pointer" title="Sad" onclick="handleAJAXReact(${data.commentId}, 'Sad', 'comment', event)">😢</span>
                                                <span class="cursor-pointer" title="Angry" onclick="handleAJAXReact(${data.commentId}, 'Angry', 'comment', event)">😡</span>
                                                <span class="cursor-pointer" title="Dislike" onclick="handleAJAXReact(${data.commentId}, 'Dislike', 'comment', event)">👎</span>
                                            </div>
                                        </div>
                                        <div id="comment-react-container-${data.commentId}" class="text-[9px] font-normal text-gray-400"></div>
                                    </div>
                                </div>
                            </div>`;
                        list.insertAdjacentHTML('beforeend', html);
                        list.scrollTop = list.scrollHeight;
                    }
                    input.value = '';
                }
            })
            .catch(err => console.error(err));
        }
    </script>
</body>
</html>
