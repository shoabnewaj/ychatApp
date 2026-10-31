<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <script src="<%=request.getContextPath()%>/js/notification-badge.js" data-context-path="<%=request.getContextPath()%>" defer></script>
    <script src="<%=request.getContextPath()%>/js/global-call-presence.js" data-user="${sessionScope.ub.name}" data-context-path="<%=request.getContextPath()%>" defer></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Y-Chat Groups</title>
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

    <div class="max-w-[1200px] mx-auto p-6">
        <!-- Top bar with Title and Create Actions -->
        <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8 glass-card p-6 rounded-3xl">
            <div>
                <h1 class="text-3xl font-extrabold text-gray-800">👥 Y-Chat Groups</h1>
                <p class="text-gray-600">Connect with communities, share interests, and build networks</p>
            </div>
            <div>
                <button onclick="toggleModal(true)" class="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-full transition flex items-center gap-2 shadow-lg hover:shadow-blue-500/20">
                    <i class="fa fa-plus"></i> Create New Group
                </button>
            </div>
        </div>

        <!-- My Groups Section -->
        <div class="mb-10">
            <h2 class="text-2xl font-bold text-gray-800 mb-4">🏠 My Groups</h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                <c:set var="hasJoined" value="false" />
                <c:forEach var="group" items="${groups}">
                    <c:if test="${group.isJoined()}">
                        <c:set var="hasJoined" value="true" />
                        <div class="glass-card rounded-3xl overflow-hidden flex flex-col justify-between hover:scale-[1.02] transition-transform duration-300">
                            <div>
                                <div class="relative w-full h-32 bg-gray-200 overflow-hidden">
                                    <c:choose>
                                        <c:when test="${not empty group.getCoverPic()}">
                                            <img src="img/${group.getCoverPic()}" class="w-full h-full object-cover">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="w-full h-full flex items-center justify-center bg-blue-100 text-blue-500 font-bold text-lg">
                                                ${group.getName().substring(0,1)}
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="p-4">
                                    <h3 class="font-bold text-gray-800 line-clamp-1">${group.getName()}</h3>
                                    <p class="text-gray-500 text-xs mt-1 mb-2">${group.getMemberCount()} members</p>
                                    <p class="text-gray-600 text-xs line-clamp-2">${group.getDescription()}</p>
                                </div>
                            </div>
                            <div class="p-4 pt-0">
                                <a href="GroupsServlet?groupId=${group.getId()}" class="w-full text-center block bg-blue-50 hover:bg-blue-100 text-blue-600 font-semibold py-2 rounded-xl text-xs transition">
                                    Visit Group
                                </a>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
                <c:if test="${!hasJoined}">
                    <div class="col-span-full bg-white/30 backdrop-blur-md border border-white/20 p-8 rounded-3xl text-center text-gray-500 italic">
                        You haven't joined or created any groups yet.
                    </div>
                </c:if>
            </div>
        </div>

        <!-- Discover Groups Section -->
        <div>
            <h2 class="text-2xl font-bold text-gray-800 mb-4">🌍 Discover Groups</h2>
            <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
                <c:set var="hasDiscover" value="false" />
                <c:forEach var="group" items="${groups}">
                    <c:if test="${!group.isJoined()}">
                        <c:set var="hasDiscover" value="true" />
                        <div class="glass-card rounded-3xl overflow-hidden flex flex-col justify-between hover:scale-[1.02] transition-transform duration-300">
                            <div>
                                <div class="relative w-full h-32 bg-gray-200 overflow-hidden">
                                    <c:choose>
                                        <c:when test="${not empty group.getCoverPic()}">
                                            <img src="img/${group.getCoverPic()}" class="w-full h-full object-cover">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="w-full h-full flex items-center justify-center bg-purple-100 text-purple-500 font-bold text-lg">
                                                ${group.getName().substring(0,1)}
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="p-4">
                                    <h3 class="font-bold text-gray-800 line-clamp-1">${group.getName()}</h3>
                                    <p class="text-gray-500 text-xs mt-1 mb-2">${group.getMemberCount()} members</p>
                                    <p class="text-gray-600 text-xs line-clamp-2">${group.getDescription()}</p>
                                </div>
                            </div>
                            <div class="p-4 pt-0 flex gap-2">
                                <form action="GroupsServlet" method="post" class="flex-1">
                                    <input type="hidden" name="action" value="JOIN">
                                    <input type="hidden" name="groupId" value="${group.getId()}">
                                    <button type="submit" class="w-full text-center bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 rounded-xl text-xs transition shadow-sm">
                                        Join Group
                                    </button>
                                </form>
                                <a href="GroupsServlet?groupId=${group.getId()}" class="text-center bg-gray-100 hover:bg-gray-200 text-gray-700 font-semibold px-3 py-2 rounded-xl text-xs transition">
                                    View
                                </a>
                            </div>
                        </div>
                    </c:if>
                </c:forEach>
                <c:if test="${!hasDiscover}">
                    <div class="col-span-full bg-white/30 backdrop-blur-md border border-white/20 p-8 rounded-3xl text-center text-gray-500 italic">
                        No new groups to discover right now.
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <!-- Modal for Creating Group -->
    <div id="createModal" class="fixed inset-0 bg-black/50 z-[9999] flex items-center justify-center hidden p-4">
        <div class="glass-card max-w-lg w-full rounded-3xl p-6 relative">
            <button onclick="toggleModal(false)" class="absolute top-4 right-4 text-gray-500 hover:text-gray-800 text-xl font-bold">
                <i class="fa fa-times"></i>
            </button>
            <h2 class="text-2xl font-bold text-gray-800 mb-4">👥 Create Y-Chat Group</h2>
            <form action="GroupsServlet" method="post" enctype="multipart/form-data" class="space-y-4">
                <input type="hidden" name="action" value="CREATE">
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Group Name</label>
                    <input type="text" name="name" required placeholder="e.g. Java Developers Club" class="w-full px-4 py-2 rounded-xl bg-white/60 border border-gray-200 outline-none focus:border-blue-500 transition">
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Description</label>
                    <textarea name="description" rows="3" placeholder="What is this group about?" class="w-full px-4 py-2 rounded-xl bg-white/60 border border-gray-200 outline-none focus:border-blue-500 transition"></textarea>
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1">Cover Photo</label>
                    <input type="file" name="coverPic" accept="image/*" class="w-full text-sm text-gray-600 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100">
                </div>
                <div class="pt-2 flex justify-end gap-3">
                    <button type="button" onclick="toggleModal(false)" class="px-5 py-2.5 rounded-full border border-gray-300 font-semibold text-gray-700 hover:bg-white/50 transition">Cancel</button>
                    <button type="submit" class="px-6 py-2.5 rounded-full bg-blue-600 hover:bg-blue-700 font-semibold text-white shadow-md transition">Create Group</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function toggleModal(show) {
            const modal = document.getElementById('createModal');
            if (show) {
                modal.classList.remove('hidden');
            } else {
                modal.classList.add('hidden');
            }
        }
    </script>
</body>
</html>
