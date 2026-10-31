<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <script src="<%=request.getContextPath()%>/js/notification-badge.js" data-context-path="<%=request.getContextPath()%>" defer></script>
    <script src="<%=request.getContextPath()%>/js/global-call-presence.js" data-user="${sessionScope.ub.name}" data-context-path="<%=request.getContextPath()%>" defer></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Y-Chat Watch</title>
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
            <a href="GroupsServlet" title="Groups" class="text-gray-500 hover:text-blue-500 transition"><i class="fa fa-user-group"></i></a>
            <a href="VideosServlet" title="Videos" class="text-blue-500"><i class="fa fa-video"></i></a>
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

    <div class="max-w-[1400px] mx-auto grid grid-cols-1 lg:grid-cols-[380px_1fr] gap-6 p-6">
        
        <!-- Left Side: Upload Video -->
        <div>
            <div class="glass-card p-6 rounded-3xl sticky top-[80px]">
                <h2 class="text-xl font-bold text-gray-800 mb-4">🎥 Share a Short Video</h2>
                <form action="VideosServlet" method="post" enctype="multipart/form-data" class="space-y-4">
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Description / Caption</label>
                        <textarea name="content" rows="3" required placeholder="What is this video about?" class="w-full px-4 py-2 rounded-xl bg-white/60 border border-gray-200 outline-none focus:border-blue-500 transition"></textarea>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-700 mb-1">Video File</label>
                        <div class="border-2 border-dashed border-gray-300 rounded-xl p-6 text-center hover:border-blue-500 transition cursor-pointer relative bg-white/40">
                            <input type="file" name="videoFile" accept="video/*" required class="absolute inset-0 opacity-0 cursor-pointer" onchange="previewFile(event)">
                            <div id="uploadPlaceholder">
                                <i class="fa fa-cloud-arrow-up text-4xl text-gray-400 mb-2"></i>
                                <p class="text-sm font-medium text-gray-600">Select video file (.mp4, .mov, etc.)</p>
                                <p class="text-xs text-gray-400 mt-1">Short vertical videos work best!</p>
                            </div>
                            <div id="filePreview" class="hidden">
                                <i class="fa-solid fa-circle-check text-4xl text-green-500 mb-2"></i>
                                <p id="fileNameSpan" class="text-sm font-medium text-gray-700 truncate"></p>
                            </div>
                        </div>
                    </div>
                    <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 rounded-full transition shadow-lg hover:shadow-blue-500/20">
                        Upload Video
                    </button>
                </form>
            </div>
        </div>

        <!-- Right Side: Video Feed -->
        <div class="space-y-6">
            <section class="glass-card rounded-3xl p-5" aria-labelledby="liveBroadcastHeading">
                <div class="flex items-center justify-between mb-3">
                    <h2 id="liveBroadcastHeading" class="text-lg font-bold text-gray-800">🔴 Live now</h2>
                    <span id="liveBroadcastStatus" class="text-xs text-gray-500">Checking live broadcasts…</span>
                </div>
                <div id="liveBroadcastList" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <p class="text-sm text-gray-500">Loading live broadcasts…</p>
                </div>
            </section>            <section class="glass-card rounded-3xl p-5">
                <h2 class="text-lg font-bold text-gray-800 mb-3">🔖 Saved lives</h2>
                <div id="savedLiveList" class="space-y-3"><p class="text-sm text-gray-500">Loading saved lives…</p></div>
            </section>            <c:choose>
                <c:when test="${empty videos}">
                    <div class="glass-card text-center p-16 rounded-3xl">
                        <div class="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4 text-3xl">
                            🎬
                        </div>
                        <h2 class="text-xl font-bold text-gray-800">No videos posted yet</h2>
                        <p class="text-gray-500 mt-2">Start sharing videos to see them here!</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="post" items="${videos}">
                        <div class="glass-card rounded-3xl overflow-hidden shadow-sm flex flex-col md:flex-row">
                            <!-- Video Player Section -->
                            <div class="bg-black flex-1 flex items-center justify-center relative min-h-[350px] md:min-h-0 md:w-3/5">
                                <video class="w-full h-full max-h-[500px]" controls preload="metadata">
                                    <source src="img/${post.getFile_name()}">
                                    Your browser does not support the video tag.
                                </video>
                            </div>

                            <!-- Post & Comments Sidebar -->
                            <div class="md:w-2/5 flex flex-col justify-between p-6 border-t md:border-t-0 md:border-l border-white/20 bg-white/10">
                                <div>
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

                                    <!-- Interaction Bar -->
                                    <div class="flex items-center justify-between border-t border-b border-white/25 py-2.5 mb-4">
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
                                    <div id="comment-list-${post.getId()}" class="space-y-3 max-h-[220px] overflow-y-auto pr-1">
                                        <c:forEach var="comment" items="${post.getComments()}">
                                            <div class="flex gap-2.5 items-start">
                                                <img src="img/${comment.profilePic}" class="w-7 h-7 rounded-full border">
                                                <div class="flex flex-col flex-1">
                                                    <div class="bg-white/40 px-3 py-1.5 rounded-2xl text-xs inline-block max-w-fit">
                                                        <span class="font-bold text-gray-800">${comment.name}</span>
                                                        <p class="text-gray-700 mt-0.5">${comment.text}</p>
                                                        <c:if test="${not empty comment.fileName}">
                                                            <img src="img/${comment.fileName}" class="mt-1 rounded-lg max-h-32">
                                                        </c:if>
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
                                </div>

                                <!-- Add Comment Form -->
                                <div class="mt-4 flex gap-2">
                                    <input type="text" id="commentInput-${post.getId()}" placeholder="Write a comment..." class="flex-1 px-4 py-2 rounded-full bg-white/60 border border-gray-200 outline-none focus:border-blue-500 text-xs transition" onkeydown="if(event.key === 'Enter') submitCommentAJAX(${post.getId()})">
                                    <button onclick="submitCommentAJAX(${post.getId()})" class="bg-blue-600 hover:bg-blue-700 text-white w-8 h-8 rounded-full flex items-center justify-center transition">
                                        <i class="fa fa-paper-plane text-xs"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

    </div>

    <script>
        function previewFile(e) {
            const file = e.target.files[0];
            if (file) {
                document.getElementById('uploadPlaceholder').classList.add('hidden');
                document.getElementById('filePreview').classList.remove('hidden');
                document.getElementById('fileNameSpan').innerText = file.name;
            }
        }

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
                            <div class="flex gap-2.5 items-start">
                                <img src="img/${data.userPic}" class="w-7 h-7 rounded-full border">
                                <div class="flex flex-col flex-1">
                                    <div class="bg-white/40 px-3 py-1.5 rounded-2xl text-xs inline-block max-w-fit">
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

        const liveContextPath = '${pageContext.request.contextPath}';
        const liveViewerUsername = "${ub.getName()}";
        const liveViewerRtcConfig = { iceServers: [{ urls: 'stun:stun.l.google.com:19302' }] };
        let liveViewerSocket = null;
        const liveViewerPeers = new Map();
        const liveViewerPendingIce = new Map();
        const liveViewerCards = new Map();
        let autoWatchTargetId = Number(new URLSearchParams(location.search).get('watchId')) || 0;
        let autoWatchTriggered = false;
        const liveViewerProfilePic = "${ub.getProfile_pic()}";

        function connectViewerSocket() {
            if (liveViewerSocket && liveViewerSocket.readyState === WebSocket.OPEN) return Promise.resolve();
            if (liveViewerSocket && liveViewerSocket.readyState === WebSocket.CONNECTING) {
                return new Promise((resolve, reject) => {
                    const timer = setTimeout(() => reject(new Error('Live socket timed out.')), 8000);
                    liveViewerSocket.addEventListener('open', () => { clearTimeout(timer); resolve(); }, { once: true });
                    liveViewerSocket.addEventListener('error', () => { clearTimeout(timer); reject(new Error('Live socket failed.')); }, { once: true });
                });
            }
            const protocol = location.protocol === 'https:' ? 'wss://' : 'ws://';
            liveViewerSocket = new WebSocket(protocol + location.host + liveContextPath + '/ws/user/' + encodeURIComponent(liveViewerUsername));
            liveViewerSocket.onmessage = handleViewerSignal;
            return new Promise((resolve, reject) => {
                const timer = setTimeout(() => reject(new Error('Live socket timed out.')), 8000);
                liveViewerSocket.onopen = () => { clearTimeout(timer); resolve(); };
                liveViewerSocket.onerror = () => { clearTimeout(timer); reject(new Error('Live socket failed.')); };
            });
        }

        function sendViewerSignal(type, target, payload) {
            if (liveViewerSocket && liveViewerSocket.readyState === WebSocket.OPEN) {
                liveViewerSocket.send(type + '|' + target + '|' + JSON.stringify(payload || {}));
                return true;
            }
            return false;
        }

        async function handleViewerSignal(event) {
            const parts = event.data.split('|');
            const type = parts[0];
            if (type === 'LIVE_CHAT' || type === 'LIVE_REACTION') {
                const room = parts[1], actor = parts[2], text = parts.slice(3).join('|');
                let payload = {};
                try { payload = text ? JSON.parse(text) : {}; } catch (e) { return; }
                appendLiveViewerActivity(room, type, actor, payload);
                return;
            }
            const streamer = parts[1], text = parts.slice(2).join('|');
            let payload = {};
            try { payload = text ? JSON.parse(text) : {}; } catch (e) { return; }
            const peer = liveViewerPeers.get(streamer);
            if (type === 'LIVE_OFFER' && peer && payload.sdp) {
                await peer.setRemoteDescription(new RTCSessionDescription(payload));
                const queued = liveViewerPendingIce.get(streamer) || [];
                for (const candidate of queued) await peer.addIceCandidate(new RTCIceCandidate(candidate));
                liveViewerPendingIce.delete(streamer);
                const answer = await peer.createAnswer();
                await peer.setLocalDescription(answer);
                sendViewerSignal('LIVE_ANSWER', streamer, peer.localDescription);
            } else if (type === 'LIVE_ICE' && peer && payload.candidate) {
                if (!peer.remoteDescription) {
                    const queued = liveViewerPendingIce.get(streamer) || [];
                    queued.push(payload.candidate);
                    liveViewerPendingIce.set(streamer, queued);
                } else {
                    try { await peer.addIceCandidate(new RTCIceCandidate(payload.candidate)); }
                    catch (error) { console.warn('Could not add broadcaster ICE candidate:', error); }
                }
            } else if (type === 'LIVE_ENDED') closeLiveViewer(streamer, 'This live broadcast has ended.');
            else if (type === 'LIVE_BLOCKED') closeLiveViewer(streamer, 'The host removed you from this live broadcast.');
        }

        function appendLiveViewerActivity(streamer, type, actor, payload) {
            const card = liveViewerCards.get(streamer);
            const box = card && card.querySelector('[data-live-chat]');
            if (!box) return;
            const line = document.createElement('p');
            line.className = 'text-xs text-gray-700 py-1';
            line.textContent = type === 'LIVE_CHAT' ? actor + ': ' + (payload.text || '') : actor + ' reacted with ' + (payload.emoji || '👍');
            box.appendChild(line);
            box.scrollTop = box.scrollHeight;
        }

        function sendViewerLiveComment(streamer, input) {
            const text = input.value.trim();
            if (!text) return;
            if (!sendViewerSignal('LIVE_CHAT', streamer, { text, profilePic: liveViewerProfilePic })) {
                alert('Live connection is unavailable. Please reconnect.');
                return;
            }
            input.value = '';
        }

        async function toggleLiveBookmark(stream, button) {
            button.disabled = true;
            try {
                const action = stream.saved ? 'unsave' : 'save';
                const response = await fetch(liveContextPath + '/LiveServlet?action=' + action + '&streamerId=' + encodeURIComponent(stream.streamerId), { method: 'POST' });
                const result = await response.json();
                if (!response.ok || !result.success) throw new Error(result.error || 'Could not save live.');
                stream.saved = result.saved;
                button.textContent = stream.saved ? 'Unsave' : 'Save';
                await refreshSavedLives();
            } catch (error) {
                alert(error.message || 'Could not save live.');
            } finally { button.disabled = false; }
        }

        async function shareLiveBroadcast(stream) {
            const url = new URL('VideosServlet', location.href);
            url.searchParams.set('watchId', stream.streamerId);
            const shareData = { title: stream.title || 'Live on Y-ChatApp', text: stream.streamer + ' is live now', url: url.href };
            try {
                if (navigator.share) await navigator.share(shareData);
                else { await navigator.clipboard.writeText(url.href); alert('Live link copied. Send it to a friend.'); }
            } catch (error) { if (error.name !== 'AbortError') alert('Could not share the live link.'); }
        }

        async function refreshSavedLives() {
            const container = document.getElementById('savedLiveList');
            try {
                const response = await fetch(liveContextPath + '/LiveServlet?action=saved', { cache: 'no-store' });
                const data = await response.json();
                const entries = data.savedLives || [];
                container.replaceChildren();
                if (!entries.length) {
                    const empty = document.createElement('p');
                    empty.className = 'text-sm text-gray-500';
                    empty.textContent = 'No saved live broadcasters yet.';
                    container.appendChild(empty);
                    return;
                }
                entries.forEach(entry => {
                    const row = document.createElement('div');
                    row.className = 'flex items-center justify-between gap-3 rounded-xl bg-white/50 p-3';
                    const text = document.createElement('div');
                    const name = document.createElement('p');
                    name.className = 'font-bold text-gray-800';
                    name.textContent = entry.streamer;
                    const title = document.createElement('p');
                    title.className = 'text-xs text-gray-600';
                    title.textContent = entry.title;
                    text.append(name, title);
                    row.appendChild(text);
                    if (entry.isLive) {
                        const watch = document.createElement('button');
                        watch.className = 'rounded-full bg-blue-600 text-white px-4 py-2 text-xs font-bold';
                        watch.textContent = 'Watch live';
                        watch.addEventListener('click', () => watchLiveBroadcast(entry.streamer));
                        row.appendChild(watch);
                    } else {
                        const offline = document.createElement('span');
                        offline.className = 'text-xs text-gray-500';
                        offline.textContent = 'Offline';
                        row.appendChild(offline);
                    }
                    container.appendChild(row);
                });
            } catch (error) {
                container.textContent = 'Saved live streams could not be loaded.';
            }
        }

        async function watchLiveBroadcast(streamer) {
            const card = liveViewerCards.get(streamer);
            if (!card) return;
            const status = card.querySelector('[data-live-status]');
            const watchButton = card.querySelector('[data-watch-live]');
            if (liveViewerPeers.has(streamer)) return;
            watchButton.disabled = true;
            status.textContent = 'Connecting…';
            try {
                await connectViewerSocket();
                const peer = new RTCPeerConnection(liveViewerRtcConfig);
                liveViewerPeers.set(streamer, peer);
                peer.ontrack = event => {
                    const video = card.querySelector('video');
                    video.srcObject = event.streams[0];
                    video.classList.remove('hidden');
                    video.play().catch(() => {});
                    status.textContent = 'Live';
                };
                peer.onicecandidate = event => { if (event.candidate) sendViewerSignal('LIVE_ICE', streamer, { candidate: event.candidate }); };
                peer.onconnectionstatechange = () => { if (peer.connectionState === 'failed') closeLiveViewer(streamer, 'Connection failed. Try again.'); };
                sendViewerSignal('LIVE_JOIN_REQUEST', streamer, {});
            } catch (error) {
                console.error('Could not join live broadcast:', error);
                status.textContent = error.message || 'Could not connect.';
                watchButton.disabled = false;
            }
        }
        function closeLiveViewer(streamer, message) {
            const peer = liveViewerPeers.get(streamer);
            if (peer) peer.close();
            liveViewerPeers.delete(streamer);
            const card = liveViewerCards.get(streamer);
            if (card) {
                const video = card.querySelector('video');
                if (video.srcObject) video.srcObject.getTracks().forEach(track => track.stop());
                video.srcObject = null;
                video.classList.add('hidden');
                card.querySelector('[data-live-status]').textContent = message || 'Disconnected';
                const button = card.querySelector('[data-watch-live]');
                button.disabled = false;
                button.textContent = 'Watch live';
            }
            if (liveViewerSocket && liveViewerSocket.readyState === WebSocket.OPEN) sendViewerSignal('LIVE_LEAVE', streamer, {});
        }

        function renderLiveBroadcasts(streams) {
            const container = document.getElementById('liveBroadcastList');
            const status = document.getElementById('liveBroadcastStatus');
            streams = streams.filter(stream => stream.streamer !== liveViewerUsername);
            const current = new Set(streams.map(stream => stream.streamer));
            for (const [name, card] of liveViewerCards.entries()) {
                if (!current.has(name)) {
                    closeLiveViewer(name, 'This live broadcast has ended.');
                    card.remove();
                    liveViewerCards.delete(name);
                }
            }
            if (!streams.length) {
                container.innerHTML = '<p class="text-sm text-gray-500">There are no live broadcasts right now.</p>';
                status.textContent = 'No active broadcasts';
                return;
            }
            status.textContent = streams.length + (streams.length === 1 ? ' broadcast' : ' broadcasts');
            if (!liveViewerCards.size) container.innerHTML = '';
            streams.forEach(stream => {
                const existingCard = liveViewerCards.get(stream.streamer);
                if (existingCard) {
                    const countLabel = existingCard.querySelector('[data-live-viewer-count]');
                    if (countLabel) countLabel.textContent = (Number(stream.viewersCount) || 0) + ' watching';
                    return;
                }
                const card = document.createElement('article');
                card.className = 'rounded-2xl overflow-hidden bg-black text-white';
                const video = document.createElement('video');
                video.className = 'hidden w-full aspect-video object-contain bg-black';
                video.autoplay = true;
                video.muted = true;
                video.controls = true;
                video.playsInline = true;
                const activity = document.createElement('div');
                activity.className = 'max-h-28 overflow-y-auto bg-white p-3';
                activity.dataset.liveChat = 'true';
                const commentRow = document.createElement('div');
                commentRow.className = 'flex gap-2 p-3 bg-white';
                const commentInput = document.createElement('input');
                commentInput.type = 'text';
                commentInput.maxLength = 500;
                commentInput.placeholder = 'Write a live comment…';
                commentInput.className = 'min-w-0 flex-1 rounded-full border px-3 py-2 text-xs text-gray-800';
                commentInput.addEventListener('keydown', event => { if (event.key === 'Enter') sendViewerLiveComment(stream.streamer, commentInput); });
                const commentButton = document.createElement('button');
                commentButton.type = 'button';
                commentButton.className = 'rounded-full bg-blue-600 text-white px-3 py-2 text-xs font-bold';
                commentButton.textContent = 'Comment';
                commentButton.addEventListener('click', () => sendViewerLiveComment(stream.streamer, commentInput));
                commentRow.append(commentInput, commentButton);
                const details = document.createElement('div');
                details.className = 'flex items-center justify-between gap-3 p-4';
                const info = document.createElement('div');
                const name = document.createElement('p');
                name.className = 'font-bold';
                name.textContent = stream.streamer;
                const title = document.createElement('p');
                title.className = 'text-sm text-gray-300';
                title.textContent = stream.title || 'Live Broadcast';
                const countLabel = document.createElement('p');
                countLabel.className = 'text-xs text-gray-300 mt-1';
                countLabel.dataset.liveViewerCount = 'true';
                countLabel.textContent = (Number(stream.viewersCount) || 0) + ' watching';
                const viewerStatus = document.createElement('p');
                viewerStatus.className = 'text-xs text-gray-400';
                viewerStatus.dataset.liveStatus = 'true';
                viewerStatus.textContent = 'Ready to watch';
                info.append(name, title, countLabel, viewerStatus);
                const button = document.createElement('button');
                button.type = 'button';
                button.className = 'shrink-0 rounded-full bg-blue-600 hover:bg-blue-700 px-4 py-2 text-sm font-bold disabled:opacity-50';
                button.textContent = 'Watch live';
                button.dataset.watchLive = 'true';
                button.addEventListener('click', () => watchLiveBroadcast(stream.streamer));
                const actions = document.createElement('div');
                actions.className = 'flex flex-wrap gap-2 px-4 pb-3';
                const share = document.createElement('button');
                share.type = 'button'; share.className = 'rounded-full bg-gray-200 text-gray-800 px-3 py-2 text-xs font-bold'; share.textContent = 'Share';
                share.addEventListener('click', () => shareLiveBroadcast(stream));
                const save = document.createElement('button');
                save.type = 'button'; save.className = 'rounded-full bg-amber-400 text-gray-900 px-3 py-2 text-xs font-bold'; save.textContent = stream.saved ? 'Unsave' : 'Save';
                save.addEventListener('click', () => toggleLiveBookmark(stream, save));
                actions.append(share, save);
                const reactions = document.createElement('div');
                reactions.className = 'flex flex-wrap gap-2 px-4 pb-3';
                [['Like','👍'],['Love','❤️'],['Care','🥰'],['Haha','😆'],['Wow','😮'],['Sad','😢'],['Angry','😡'],['Dislike','👎']].forEach(([name, emoji]) => {
                    const reaction = document.createElement('button');
                    reaction.type = 'button'; reaction.className = 'rounded-full bg-white/20 px-2 py-1 text-sm hover:bg-white/35'; reaction.title = name; reaction.textContent = emoji;
                    reaction.addEventListener('click', () => sendViewerSignal('LIVE_REACTION', stream.streamer, { emoji }));
                    reactions.appendChild(reaction);
                });
                details.append(info, button);
                card.append(video, details, actions, reactions, activity, commentRow);
                container.appendChild(card);
                liveViewerCards.set(stream.streamer, card);
            });
        }

        async function refreshLiveBroadcasts() {
            try {
                const response = await fetch(liveContextPath + '/LiveServlet?action=list', { cache: 'no-store' });
                if (!response.ok) throw new Error('Could not load live broadcasts.');
                const data = await response.json();
                renderLiveBroadcasts(data.streams || []);
                const target = (data.streams || []).find(stream => Number(stream.streamerId) === autoWatchTargetId);
                if (target && !autoWatchTriggered) { autoWatchTriggered = true; setTimeout(() => watchLiveBroadcast(target.streamer), 150); }
            } catch (error) {
                document.getElementById('liveBroadcastStatus').textContent = 'Unable to check broadcasts';
                console.warn(error);
            }
        }
        refreshLiveBroadcasts();
        refreshSavedLives();
        setInterval(refreshLiveBroadcasts, 5000);
        window.addEventListener('pagehide', () => {
            liveViewerPeers.forEach((peer, streamer) => {
                peer.close();
                sendViewerSignal('LIVE_LEAVE', streamer, {});
            });
        });
        </script>
</body>
</html>
