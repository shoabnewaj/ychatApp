<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
<head>
    <script src="<%=request.getContextPath()%>/js/notification-badge.js" data-context-path="<%=request.getContextPath()%>" defer></script>
    <script src="<%=request.getContextPath()%>/js/global-call-presence.js" data-user="${sessionScope.ub.name}" data-context-path="<%=request.getContextPath()%>" defer></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>${profileUser.getName()} | Profile</title>
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

<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

    <style>
        :root {
            --glass-bg: rgba(255, 255, 255, 0.7);
            --glass-border: rgba(255, 255, 255, 0.3);
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }
        body {
            background: linear-gradient(-45deg, #f3f4f7, #e2e8f0, #f8fafc, #f1f5f9);
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
            background: var(--glass-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid var(--glass-border);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.07);
        }
        .react-container {
            position: relative;
            display: inline-block;
        }
        .react-box {
            display: none;
            position: absolute;
            bottom: 100%;
            left: 0;
            background: white;
            padding: 8px 15px;
            border-radius: 50px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            z-index: 100;
            gap: 12px;
            animation: popUp 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        }
        .react-container:hover .react-box { display: flex; }
        @keyframes popUp {
            from { opacity: 0; transform: translateY(10px) scale(0.9); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .custom-scrollbar::-webkit-scrollbar { width: 6px; }
        .custom-scrollbar::-webkit-scrollbar-track { background: transparent; }
        .custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.1); border-radius: 10px; }
    </style>
</head>
<body class="custom-scrollbar">

    <!-- Navbar (Same as main.jsp) -->
    <header class="sticky top-0 z-50 glass-card !border-none !rounded-none px-6 py-3 mb-6">
        <div class="max-w-[1400px] mx-auto flex items-center justify-between">
            <div class="flex items-center gap-4">
                <div class="w-10 h-10 bg-blue-600 rounded-xl flex items-center justify-center shadow-lg cursor-pointer hover:rotate-12 transition-transform" onclick="location.href='UsersPostServlet'">
                    <img src="${pageContext.request.contextPath}/icons/icon-192.png" width="25" alt="Logo">
                </div>
                <div class="relative hidden sm:block">
                    <form action="SearchServlet" method="get">
                        <i class="fa fa-search absolute left-4 top-1/2 -translate-y-1/2 text-gray-400"></i>
                        <input name="query" placeholder="Search Y-Chat..." class="bg-gray-100/50 border-none rounded-full py-2.5 pl-11 pr-6 w-[280px] focus:ring-2 ring-blue-500/20 transition-all outline-none font-medium">
                    </form>
                </div>
            </div>

            <nav class="flex items-center gap-8">
                <a href="UsersPostServlet" class="text-gray-500 hover:text-blue-600 transition-colors text-xl"><i class="fa fa-house"></i></a>
                <a href="FriendServlet" class="text-gray-500 hover:text-blue-600 transition-colors text-xl"><i class="fa fa-user-group"></i></a>
                <a href="VideosServlet" class="text-gray-500 hover:text-blue-600 transition-colors text-xl"><i class="fa fa-video"></i></a>
                <a href="MarketServlet" class="text-gray-500 hover:text-blue-600 transition-colors text-xl"><i class="fa fa-shop"></i></a>
            </nav>

            <div class="flex items-center gap-4">
                <c:if test="${sessionScope.isAdmin or ub.isAdmin()}">
                    <a href="admin" title="Admin Dashboard" class="px-3 py-1.5 bg-gradient-to-r from-rose-500 to-amber-500 text-white rounded-xl text-xs font-bold shadow-md hover:shadow-rose-500/30 hover:scale-105 transition flex items-center gap-1.5 animate-pulse">
                        <i class="fa-solid fa-user-shield text-sm"></i>
                        <span class="hidden md:inline">Admin Panel</span>
                    </a>
                </c:if>
                <button id="themeToggleBtn" onclick="toggleThemeMode()" title="Toggle Dark/Light Mode" class="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center cursor-pointer hover:bg-gray-200 transition-colors">
                    <i id="themeToggleIcon" class="fa fa-moon text-gray-700"></i>
                </button>
                <div class="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center cursor-pointer hover:bg-gray-200 transition-colors" onclick="location.href='NotificationServlet'"><i class="fa fa-bell"></i></div>
                <div class="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center cursor-pointer hover:bg-gray-200 transition-colors" onclick="location.href='UsersLogoutServlet'"><i class="fa fa-right-from-bracket"></i></div>
                <img src="img/${ub.getProfile_pic()}" class="w-10 h-10 rounded-full border-2 border-blue-500 p-0.5 cursor-pointer hover:scale-105 transition-transform" onclick="location.href='UsersProfileServlet?userId=${ub.getId()}'">
            </div>
        </div>
        <div class="sm:hidden mt-2.5">
            <form action="SearchServlet" method="get" class="flex items-center gap-2 bg-gray-100/90 rounded-full px-3.5 py-2 border border-gray-200/80 shadow-sm w-full">
                <i class="fa fa-search text-blue-500 text-sm"></i>
                <input name="query" placeholder="Search Y-Chat..." class="bg-transparent outline-none flex-1 min-w-0 text-sm font-medium text-gray-800 placeholder-gray-400">
                <button type="submit" class="bg-blue-600 text-white text-xs font-bold px-3 py-1 rounded-full shrink-0">Search</button>
            </form>
        </div>
    </header>

    <!-- Main Content Grid -->
    <div id="profile-content-wrapper" class="max-w-[1400px] mx-auto grid grid-cols-1 lg:grid-cols-[280px_1fr] gap-10 px-4 pb-10">
        
        <!-- LEFT SIDEBAR -->
        <aside class="hidden lg:block sticky top-[90px] max-h-[calc(100vh-105px)] overflow-y-auto custom-scrollbar space-y-4">
            <div class="glass-card p-4 rounded-[2rem] space-y-1 shadow-sm border-white/40">
                <a href="UsersPostServlet" class="flex items-center gap-4 p-3.5 rounded-2xl hover:bg-blue-50/50 hover:text-blue-600 transition-all group font-bold text-gray-600">
                    <div class="w-10 h-10 bg-blue-100/50 text-blue-600 rounded-xl flex items-center justify-center group-hover:bg-blue-600 group-hover:text-white transition-all shadow-sm">
                        <i class="fa fa-house text-lg"></i>
                    </div>
                    <span>Home Feed</span>
                </a>
                
                <a href="UsersProfileServlet?userId=${ub.getId()}" class="flex items-center gap-4 p-3.5 rounded-2xl hover:bg-indigo-50/50 hover:text-indigo-600 transition-all group font-bold text-gray-600">
                    <div class="w-10 h-10 rounded-xl overflow-hidden border-2 border-transparent group-hover:border-indigo-600 transition-all shadow-sm">
                        <img src="img/${ub.getProfile_pic()}" class="w-full h-full object-cover">
                    </div>
                    <span>My Profile</span>
                </a>

                <a href="FriendServlet" class="flex items-center gap-4 p-3.5 rounded-2xl hover:bg-purple-50/50 hover:text-purple-600 transition-all group font-bold text-gray-600">
                    <div class="w-10 h-10 bg-purple-100/50 text-purple-600 rounded-xl flex items-center justify-center group-hover:bg-purple-600 group-hover:text-white transition-all shadow-sm">
                        <i class="fa fa-user-group text-lg"></i>
                    </div>
                    <span>Friends List</span>
                </a>

                <a href="messages.jsp" class="flex items-center gap-4 p-3.5 rounded-2xl hover:bg-pink-50/50 hover:text-pink-600 transition-all group font-bold text-gray-600">
                    <div class="w-10 h-10 bg-pink-100/50 text-pink-600 rounded-xl flex items-center justify-center group-hover:bg-pink-600 group-hover:text-white transition-all shadow-sm">
                        <i class="fa fa-message text-lg"></i>
                    </div>
                    <span>Messenger</span>
                </a>

                <a href="VideosServlet" class="flex items-center gap-4 p-3.5 rounded-2xl hover:bg-orange-50/50 hover:text-orange-600 transition-all group font-bold text-gray-600">
                    <div class="w-10 h-10 bg-orange-100/50 text-orange-600 rounded-xl flex items-center justify-center group-hover:bg-orange-600 group-hover:text-white transition-all shadow-sm">
                        <i class="fa fa-video text-lg"></i>
                    </div>
                    <span>Short Videos</span>
                </a>

                <div class="pt-4 mt-4 border-t border-gray-100/50">
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest px-4 mb-2">Social Hub</p>
                    <a href="SearchServlet?query=" class="flex items-center gap-4 p-3.5 rounded-2xl bg-blue-600 text-white shadow-lg shadow-blue-200 hover:bg-blue-700 transition-all font-bold group">
                        <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                            <i class="fa fa-magnifying-glass text-sm"></i>
                        </div>
                        <span>Discover People</span>
                    </a>
                    <a href="EventServlet" class="flex items-center gap-4 p-3.5 rounded-2xl hover:bg-gray-100/50 transition-all font-bold text-gray-500 mt-2">
                        <i class="fa fa-calendar-star text-pink-500"></i> Events
                    </a>
                    <c:if test="${sessionScope.isAdmin or ub.isAdmin()}">
                        <a href="admin" class="flex items-center gap-4 p-3.5 rounded-2xl bg-gradient-to-r from-rose-500 to-amber-500 text-white shadow-lg shadow-rose-200 hover:shadow-rose-400/50 hover:scale-[1.02] transition-all font-bold group mt-2">
                            <div class="w-8 h-8 bg-white/20 rounded-lg flex items-center justify-center">
                                <i class="fa-solid fa-user-shield text-sm"></i>
                            </div>
                            <span>Admin Dashboard</span>
                        </a>
                    </c:if>
                </div>
            </div>
        </aside>

        <!-- MIDDLE CONTENT -->
        <main class="space-y-6 min-w-0 max-w-full overflow-x-hidden">
            
            <!-- COVER PHOTO -->
            <div class="relative w-full h-[450px] overflow-hidden group rounded-3xl shadow-2xl glass-card !p-0">
                <img src="${not empty profileUser.getCover_pic() ? 'img/' : ''}${not empty profileUser.getCover_pic() ? profileUser.getCover_pic() : 'https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2000&auto=format&fit=crop'}"
                     class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-105"
                     onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1557683316-973673baf926?q=80&w=2000&auto=format&fit=crop';"
                     alt="Cover Image">
                <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
                
                <c:if test="${profileUser.getId() == ub.getId()}">
                    <div class="absolute bottom-6 right-6">
                        <form action="UploadCoverServlet" method="post" enctype="multipart/form-data" id="coverForm">
                            <label for="coverInput" class="bg-white/20 hover:bg-white/40 backdrop-blur-xl text-white px-6 py-2.5 rounded-2xl font-bold shadow-2xl cursor-pointer flex items-center gap-3 transition-all active:scale-95 border border-white/30">
                                <i class="fa fa-camera text-xl"></i>
                                <span>Edit Cover Photo</span>
                            </label>
                            <input type="file" name="coverPic" id="coverInput" accept="image/*" hidden onchange="document.getElementById('coverForm').submit()">
                        </form>
                    </div>
                </c:if>
            </div>

            <!-- PROFILE HEADER -->
            <div class="glass-card p-8 rounded-3xl -mt-24 relative z-10 mx-6 shadow-2xl">
                <div class="flex flex-col md:flex-row items-end gap-6">
                    <div class="relative group -mt-20">
                        <img id="previewImg"
                             src="${not empty profileUser.getProfile_pic() ? 'img/' : ''}${not empty profileUser.getProfile_pic() ? profileUser.getProfile_pic() : 'img/default.png'}"
                             onerror="this.onerror=null; this.src='img/default.png';"
                             class="w-40 h-40 rounded-3xl object-cover border-8 border-white shadow-2xl transition-transform group-hover:scale-[1.02]">
                        
                        <c:if test="${profileUser.getId() == ub.getId()}">
                            <label for="profilePicInput" class="absolute bottom-2 right-2 w-9 h-9 bg-blue-600 text-white rounded-xl flex items-center justify-center shadow-lg cursor-pointer hover:bg-blue-700 hover:rotate-12 transition-all">
                                <i class="fa fa-camera text-sm"></i>
                            </label>
                            <form action="UploadProfileServlet" method="post" enctype="multipart/form-data" id="profilePicForm" class="hidden">
                                <input type="file" name="profilePic" id="profilePicInput" accept="image/*" onchange="document.getElementById('profilePicForm').submit()">
                            </form>
                        </c:if>
                    </div>

                    <div class="flex-1 pb-2">
                        <div class="flex items-center gap-3">
                            <h2 class="text-4xl font-black text-gray-800 tracking-tight">${profileUser.getName()}</h2>
                            <c:if test="${profileUser.isVerified()}">
                                <div class="w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-[10px] shadow-lg" title="Verified Account">
                                    <i class="fa fa-check"></i>
                                </div>
                            </c:if>
                        </div>
                        <div class="flex flex-wrap items-center gap-2 mt-2">
                            <span class="bg-blue-50 text-blue-600 px-3 py-1 rounded-lg text-xs font-bold">@${profileUser.getName().toLowerCase().replace(' ', '')}</span>
                            
                            <c:if test="${not empty profileUser.getGender()}">
                                <span class="bg-purple-50 text-purple-700 px-3 py-1 rounded-lg text-xs font-bold flex items-center gap-1.5 capitalize shadow-sm border border-purple-100/50">
                                    <i class="fa ${profileUser.getGender().equalsIgnoreCase('male') ? 'fa-mars text-blue-500' : (profileUser.getGender().equalsIgnoreCase('female') ? 'fa-venus text-pink-500' : 'fa-genderless text-purple-500')}"></i>
                                    ${profileUser.getGender()}
                                </span>
                            </c:if>

                            <c:if test="${not empty profileUser.getCity() || not empty profileUser.getCountry()}">
                                <span class="bg-emerald-50 text-emerald-700 px-3 py-1 rounded-lg text-xs font-bold flex items-center gap-1.5 shadow-sm border border-emerald-100/50">
                                    <i class="fa fa-location-dot text-emerald-500"></i>
                                    ${profileUser.getCity()}${(not empty profileUser.getCity() && not empty profileUser.getCountry()) ? ', ' : ''}${profileUser.getCountry()}
                                </span>
                            </c:if>

                            <c:if test="${not empty profileUser.getBirthday()}">
                                <span class="bg-amber-50 text-amber-700 px-3 py-1 rounded-lg text-xs font-bold flex items-center gap-1.5 shadow-sm border border-amber-100/50">
                                    <i class="fa fa-cake-candles text-amber-500"></i>
                                    ${profileUser.getBirthday()}
                                </span>
                            </c:if>
                        </div>
                        
                        <div class="flex flex-wrap gap-3 mt-5">
                            <c:choose>
                                <c:when test="${profileUser.getId() == ub.getId()}">
                                    <button onclick="location.href='EditProfileServlet'" class="bg-gray-100 hover:bg-gray-200 text-gray-800 px-6 py-2.5 rounded-xl font-bold shadow-sm transition-all flex items-center gap-2">
                                        <i class="fa fa-pen-to-square"></i> Edit Profile
                                    </button>
                                    <c:choose>
                                        <c:when test="${profileUser.isVerified()}">
                                            <span class="bg-blue-50 text-blue-700 px-4 py-2.5 rounded-xl font-bold flex items-center gap-2 border border-blue-200 shadow-sm text-sm">
                                                <i class="fa-solid fa-circle-check text-blue-500"></i> Verified Account
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <button onclick="openPaymentModal()" class="bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white px-6 py-2.5 rounded-xl font-bold shadow-lg transition-all flex items-center gap-2">
                                                <i class="fa-solid fa-circle-check"></i> Get Blue Badge (bKash / Nagad)
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="bg-amber-50 text-amber-800 px-4 py-2.5 rounded-xl font-bold flex items-center gap-2 border border-amber-200 text-sm shadow-sm">
                                        <i class="fa-solid fa-wallet text-amber-600"></i> Wallet: $${ub.getBalance()}
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <c:choose>
                                        <c:when test="${friendshipStatus == 'ACCEPTED'}">
                                            <button onclick="handleUserAction('${profileUser.getId()}', 'UNFRIEND', this)" class="bg-blue-50 text-blue-600 px-6 py-2.5 rounded-xl font-bold shadow-sm hover:bg-blue-100 transition-all">
                                                <i class="fa fa-user-check mr-2"></i> Friends
                                            </button>
                                        </c:when>
                                        <c:when test="${friendshipStatus == 'SENT'}">
                                            <button onclick="handleUserAction('${profileUser.getId()}', 'CANCEL', this)" class="bg-yellow-50 text-yellow-600 px-6 py-2.5 rounded-xl font-bold shadow-sm border border-yellow-200 hover:bg-yellow-100 transition-all">
                                                <i class="fa fa-user-clock mr-2"></i> Request Sent (Cancel)
                                            </button>
                                        </c:when>
                                        <c:when test="${friendshipStatus == 'INCOMING'}">
                                            <button onclick="handleUserAction('${profileUser.getId()}', 'ACCEPT', this)" class="bg-green-600 text-white px-6 py-2.5 rounded-xl font-bold shadow-lg hover:bg-green-700 transition-all active:scale-95">
                                                <i class="fa fa-user-plus mr-2"></i> Accept Request
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button onclick="handleUserAction('${profileUser.getId()}', 'ADD', this)" class="bg-blue-600 text-white px-6 py-2.5 rounded-xl font-bold shadow-lg hover:bg-blue-700 transition-all active:scale-95">
                                                <i class="fa fa-user-plus mr-2"></i> Add Friend
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                    
                                    <c:choose>
                                        <c:when test="${isFollowing}">
                                            <button onclick="handleUserAction('${profileUser.getId()}', 'UNFOLLOW', this)" class="bg-purple-50 text-purple-600 px-6 py-2.5 rounded-xl font-bold shadow-sm border border-purple-200 hover:bg-purple-100 transition-all">
                                                <i class="fa fa-user-minus mr-2"></i> Unfollow
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button onclick="handleUserAction('${profileUser.getId()}', 'FOLLOW', this)" class="bg-purple-600 text-white px-6 py-2.5 rounded-xl font-bold shadow-lg hover:bg-purple-700 transition-all active:scale-95">
                                                <i class="fa fa-user-plus mr-2"></i> Follow
                                            </button>
                                        </c:otherwise>
                                    </c:choose>

                                    <button onclick="location.href='messages.jsp?userName=${profileUser.getName()}&userId=${profileUser.getId()}'" class="bg-gray-100 text-gray-800 px-6 py-2.5 rounded-xl font-bold hover:bg-gray-200 transition-all">
                                        <i class="fa-brands fa-facebook-messenger mr-2 text-lg"></i> Message
                                    </button>

                                    <button onclick="openProfileTipModal(${profileUser.getId()}, '${profileUser.getName()}')" class="bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white px-5 py-2.5 rounded-xl font-bold shadow-lg shadow-amber-200 transition-all flex items-center gap-2">
                                        <i class="fa-solid fa-coins"></i> Send Tip
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>

                <!-- STATS & TABS -->
                <div class="flex flex-col md:flex-row items-center justify-between gap-6 mt-8 pt-6 border-t border-gray-100">
                    <div class="flex gap-8">
                        <div class="text-center group cursor-pointer">
                            <b class="block text-2xl text-blue-600 group-hover:scale-110 transition-transform">${friendsCount}</b>
                            <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mt-1">Friends</p>
                        </div>
                        <div class="text-center group cursor-pointer">
                            <b class="block text-2xl text-purple-600 group-hover:scale-110 transition-transform">${followerCount}</b>
                            <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mt-1">Followers</p>
                        </div>
                        <div class="text-center group cursor-pointer">
                            <b class="block text-2xl text-pink-600 group-hover:scale-110 transition-transform">${followingCount}</b>
                            <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest mt-1">Following</p>
                        </div>
                    </div>

                    <!-- Modern Tabs -->
                    <div class="flex bg-gray-100/50 p-1 rounded-2xl" id="profile-tabs">
                        <button onclick="switchTab('posts')" id="btn-tab-posts" class="tab-btn px-6 py-2 rounded-xl bg-white shadow-sm font-black text-blue-600 text-sm transition-all">Posts</button>
                        <button onclick="switchTab('about')" id="btn-tab-about" class="tab-btn px-6 py-2 rounded-xl hover:bg-white/50 font-bold text-gray-500 text-sm transition-all">About</button>
                        <button onclick="switchTab('friends')" id="btn-tab-friends" class="tab-btn px-6 py-2 rounded-xl hover:bg-white/50 font-bold text-gray-500 text-sm transition-all">Friends</button>
                        <button onclick="switchTab('photos')" id="btn-tab-photos" class="tab-btn px-6 py-2 rounded-xl hover:bg-white/50 font-bold text-gray-500 text-sm transition-all">Photos</button>
                    </div>
                </div>
            </div>

            <!-- TAB CONTENT: POSTS -->
            <div id="tab-content-posts" class="tab-content space-y-6">
                <!-- CREATE POST BOX (Only for own profile) -->
                <c:if test="${profileUser.getId() == ub.getId()}">
                <div class="glass-card p-5 rounded-3xl">
                    <div class="flex gap-4">
                        <div class="group relative"> 
                            <img src="img/${ub.getProfile_pic()}" alt="${ub.getName()}" class="w-12 h-12 rounded-2xl object-cover ring-2 ring-white shadow-md">
                        </div>
                        <button onclick="openModal()"
                            class="flex-1 bg-white/40 hover:bg-white/60 backdrop-blur-md rounded-2xl text-left px-6 text-gray-600 text-[16px] font-medium transition-all border border-white/20">
                            What's on your mind, ${ub.getName()}?</button>
                    </div>
                    <div class="border-t border-white/20 mt-4 pt-3 flex justify-around">
                        <div onclick="openModal()" class="flex items-center gap-2 py-2 px-6 hover:bg-green-500/10 rounded-xl transition-all clickable text-green-500 font-semibold">
                            <i class="fa fa-image text-lg"></i> Photo
                        </div>
                        <div onclick="openModal()" class="flex items-center gap-2 py-2 px-6 hover:bg-yellow-500/10 rounded-xl transition-all clickable text-yellow-500 font-semibold">
                            <i class="fa fa-face-smile text-lg"></i> Feeling
                        </div>
                    </div>
                </div>
            </c:if>

            <!-- POSTS SECTION -->
            <div class="space-y-6">
                <div class="flex items-center justify-between px-2">
                    <h3 class="text-xl font-black text-gray-800">Posts</h3>
                    <button class="text-blue-600 font-bold text-sm">Filters</button>
                </div>

                <c:if test="${profileRestricted}"><div class="glass-card p-6 rounded-2xl text-center text-gray-600">This profile is visible to friends only.</div></c:if>
                <c:if test="${empty userPosts and not profileRestricted}">
                    <div class="glass-card p-20 text-center rounded-3xl border-2 border-dashed border-gray-200">
                        <div class="w-20 h-20 bg-gray-50 rounded-full flex items-center justify-center mx-auto mb-4">
                            <i class="fa fa-feather-pointed text-3xl text-gray-300"></i>
                        </div>
                        <h4 class="text-xl font-black text-gray-400">No posts yet</h4>
                        <p class="text-gray-400 text-sm mt-2 font-medium">When ${profileUser.getName()} posts, they'll show up here.</p>
                    </div>
                </c:if>

                <c:forEach var="post" items="${userPosts}" varStatus="status">
                    <!-- Post Card #${status.count} -->
                    <div class="glass-card rounded-3xl p-6 hover:shadow-xl transition-all duration-300 mb-6">
                        <div class="flex justify-between items-start">
                            <div class="flex gap-4">
                                <img src="img/${post.getProfile_pic()}" class="w-11 h-11 rounded-2xl object-cover border-2 border-white shadow-md">
                                <div>
                                    <p class="font-black text-gray-800 hover:text-blue-600 transition-colors cursor-pointer">${post.getName()}</p>
                                    <c:if test="${not empty post.getFeeling()}">
                                        <span class="text-gray-400 text-[12px]"> is feeling <span class="font-bold text-gray-600">${post.getFeeling()}</span></span>
                                    </c:if>
                                    <div class="text-[11px] text-gray-400 font-bold flex items-center gap-1.5 mt-0.5">
                                        <span>${post.getTime()}</span> • <i class="fa fa-earth-americas"></i>
                                    </div>
                                </div>
                            </div>
                            <button class="p-2 hover:bg-gray-50 rounded-xl transition-colors"><i class="fa fa-ellipsis-h text-gray-400"></i></button>
                        </div>

                        <div class="mt-4 text-gray-700 leading-relaxed">${post.getContent()}</div>

                        <c:if test="${not empty post.getFile_name()}">
                            <div class="mt-4 rounded-3xl overflow-hidden border border-gray-100 shadow-sm bg-gray-50">
                                <c:choose>
                                    <c:when test="${post.getPost_type() == 'video' || post.getFile_name().toLowerCase().endsWith('.webm') || post.getFile_name().toLowerCase().endsWith('.mp4') || post.getFile_name().toLowerCase().endsWith('.mov')}">
                                        <video controls class="w-full max-h-[500px] object-contain" onerror="this.parentElement.style.display='none'">
                                            <source src="img/${post.getFile_name()}" type="video/mp4">
                                        </video>
                                    </c:when>
                                    <c:otherwise>
                                        <img src="img/${post.getFile_name()}" class="w-full h-auto max-h-[500px] object-cover hover:scale-[1.01] transition-transform duration-500" onerror="this.onerror=null; this.src='img/default.png';">
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>

                        <div class="flex items-center justify-between mt-6 pt-4 border-t border-gray-50">
                                <div id="post-react-container-${post.getId()}" class="flex items-center gap-2">
                                    <span class="font-bold text-gray-400 text-[13px]" id="post-react-count-${post.getId()}">
                                        <c:set var="tc" value="${post.getLikeCount() + post.getLoveCount() + post.getCareCount() + post.getHahaCount() + post.getWowCount() + post.getSadCount() + post.getAngryCount() + post.getDislikes()}"/>
                                        <c:choose>
                                            <c:when test="${tc > 0}">
                                                <c:if test="${post.getLikeCount() > 0}">👍 <span class="text-gray-600">${post.getLikeCount()}</span>&nbsp;&nbsp;</c:if>
                                                <c:if test="${post.getLoveCount() > 0}">❤️ <span class="text-gray-600">${post.getLoveCount()}</span>&nbsp;&nbsp;</c:if>
                                                <c:if test="${post.getCareCount() > 0}">🥰 <span class="text-gray-600">${post.getCareCount()}</span>&nbsp;&nbsp;</c:if>
                                                <c:if test="${post.getHahaCount() > 0}">😆 <span class="text-gray-600">${post.getHahaCount()}</span>&nbsp;&nbsp;</c:if>
                                                <c:if test="${post.getWowCount() > 0}">😮 <span class="text-gray-600">${post.getWowCount()}</span>&nbsp;&nbsp;</c:if>
                                                <c:if test="${post.getSadCount() > 0}">😢 <span class="text-gray-600">${post.getSadCount()}</span>&nbsp;&nbsp;</c:if>
                                                <c:if test="${post.getAngryCount() > 0}">😡 <span class="text-gray-600">${post.getAngryCount()}</span>&nbsp;&nbsp;</c:if>
                                                <c:if test="${post.getDislikes() > 0}">👎 <span class="text-gray-600">${post.getDislikes()}</span>&nbsp;&nbsp;</c:if>
                                            </c:when>
                                            <c:otherwise>0</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            <div class="flex gap-3 text-gray-400 text-[13px] font-bold">
                                <span id="post-comment-count-text-${post.getId()}" class="hover:text-blue-600 transition cursor-pointer" onclick="focusCmt('${post.getId()}')">${post.getCommentCount()} Comments</span>
                                <span id="post-share-count-text-${post.getId()}" class="hover:text-purple-600 transition cursor-pointer" onclick="shareAJAX('${post.getId()}')">${post.getShareCount()} Shares</span>
                            </div>
                        </div>

                        <div class="flex gap-2 mt-4 pt-4 border-t border-gray-50">
                            <div id="post-action-btn-${post.getId()}" onclick="handleAJAXReact('${post.getId()}', 'Like', 'post', event)" class="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl hover:bg-blue-50 text-gray-500 hover:text-blue-600 transition-all font-bold cursor-pointer react-container">
                                <span id="post-action-btn-content-${post.getId()}" class="flex items-center justify-center gap-2">
                                    <i class="fa-regular fa-thumbs-up"></i> Like
                                </span>
                                <div class="react-box !-top-12">
                                    <span class="hover:scale-150 transition" onclick="event.stopPropagation(); handleAJAXReact('${post.getId()}', 'Like', 'post', event)">👍</span>
                                    <span class="hover:scale-150 transition" onclick="event.stopPropagation(); handleAJAXReact('${post.getId()}', 'Love', 'post', event)">❤️</span>
                                    <span class="hover:scale-150 transition" onclick="event.stopPropagation(); handleAJAXReact('${post.getId()}', 'Care', 'post', event)">🥰</span>
                                    <span class="hover:scale-150 transition" onclick="event.stopPropagation(); handleAJAXReact('${post.getId()}', 'Haha', 'post', event)">😆</span>
                                    <span class="hover:scale-150 transition" onclick="event.stopPropagation(); handleAJAXReact('${post.getId()}', 'Wow', 'post', event)">😮</span>
                                    <span class="hover:scale-150 transition" onclick="event.stopPropagation(); handleAJAXReact('${post.getId()}', 'Sad', 'post', event)">😢</span>
                                    <span class="hover:scale-150 transition" onclick="event.stopPropagation(); handleAJAXReact('${post.getId()}', 'Angry', 'post', event)">😡</span>
                                    <span class="hover:scale-150 transition" onclick="event.stopPropagation(); handleAJAXReact('${post.getId()}', 'Dislike', 'post', event)">👎</span>
                                </div>
                            </div>
                            <div onclick="focusCmt('${post.getId()}')" class="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl hover:bg-purple-50 text-gray-500 hover:text-purple-600 transition-all font-bold cursor-pointer">
                                <i class="fa-regular fa-comment"></i> Comment
                            </div>
                            <div onclick="shareAJAX('${post.getId()}')" class="flex-1 flex items-center justify-center gap-2 py-2.5 rounded-xl hover:bg-pink-50 text-gray-500 hover:text-pink-600 transition-all font-bold cursor-pointer">
                                <i class="fa-solid fa-share"></i> Share
                            </div>
                        </div>

                        <!-- Comment List (AJAX) -->
                        <div id="comment-list-${post.getId()}" class="mt-6 space-y-4">
                            <c:forEach var="comment" items="${post.getComments()}">
                                <div class="comment-level-1 mb-4">
                                    <div class="flex gap-2">
                                        <a href="UsersProfileServlet?userId=${comment.userId}">
                                            <img src="img/${comment.profilePic}" class="w-8 h-8 rounded-full border shadow-sm">
                                        </a>
                                        <div class="bg-gray-100 px-3 py-2 rounded-2xl max-w-[90%]">
                                            <p class="font-bold text-[12px]"><a href="UsersProfileServlet?userId=${comment.userId}" class="hover:underline">${comment.name}</a></p>
                                            <p class="text-[13px] text-gray-700">${comment.comment_text}</p>
                                        </div>
                                    </div>
                                    <div class="flex gap-4 ml-10 mt-1 text-[11px] font-bold text-gray-400 items-center">
                                        <div class="react-container clickable">
                                            <span class="hover:text-blue-600 cursor-pointer" onclick="handleAJAXReact('${comment.id}', 'Like', 'comment', event)">Like</span>
                                            <div class="react-box !-top-12 !p-1 !rounded-full">
                                                <span class="hover:scale-150 transition" onclick="handleAJAXReact('${comment.id}', 'Like', 'comment', event)">👍</span>
                                                <span class="hover:scale-150 transition" onclick="handleAJAXReact('${comment.id}', 'Love', 'comment', event)">❤️</span>
                                                <span class="hover:scale-150 transition" onclick="handleAJAXReact('${comment.id}', 'Care', 'comment', event)">🥰</span>
                                                <span class="hover:scale-150 transition" onclick="handleAJAXReact('${comment.id}', 'Haha', 'comment', event)">😆</span>
                                                <span class="hover:scale-150 transition" onclick="handleAJAXReact('${comment.id}', 'Wow', 'comment', event)">😮</span>
                                                <span class="hover:scale-150 transition" onclick="handleAJAXReact('${comment.id}', 'Sad', 'comment', event)">😢</span>
                                                <span class="hover:scale-150 transition" onclick="handleAJAXReact('${comment.id}', 'Angry', 'comment', event)">😡</span>
                                                <span class="hover:scale-150 transition" onclick="handleAJAXReact('${comment.id}', 'Dislike', 'comment', event)">👎</span>
                                            </div>
                                        </div>
                                        <span class="hover:text-blue-600 cursor-pointer" onclick="showReplyBox('${comment.id}', '${comment.name}')">Reply</span>
                                         <div id="comment-react-container-${comment.id}" class="text-[11px] font-normal text-gray-400">
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
                                    <div id="reply-list-${comment.id}" class="mt-2 space-y-2 ml-10">
                                        <c:forEach var="reply" items="${comment.replies}">
                                            <div class="comment-level-2 mb-2">
                                                <div class="flex gap-2">
                                                    <a href="UsersProfileServlet?userId=${reply.getUserId()}">
                                                        <img src="img/${reply.getProfilePic()}" class="w-7 h-7 rounded-full border shadow-sm">
                                                    </a>
                                                    <div class="bg-gray-100 px-3 py-1.5 rounded-2xl">
                                                        <p class="font-bold text-[11px]"><a href="UsersProfileServlet?userId=${reply.getUserId()}" class="hover:underline">${reply.getName()}</a></p>
                                                        <p class="text-[12px] text-gray-700">${reply.getText()}</p>
                                                        <c:if test="${not empty reply.getMedia()}">
                                                            <img src="img/${reply.getMedia()}" class="w-full h-auto rounded-lg mt-2 border">
                                                        </c:if>
                                                    </div>
                                                </div>
                                                <div class="flex gap-4 ml-9 mt-1 text-[10px] font-bold text-gray-400 items-center">
                                                    <div class="react-container clickable">
                                                        <span class="hover:text-blue-600 cursor-pointer" onclick="handleAJAXReact('${reply.getId()}', 'Like', 'reply', event)">Like</span>
                                                        <div class="react-box !-top-12 !p-1 !rounded-full">
                                                            <span class="hover:scale-150 transition" onclick="handleAJAXReact('${reply.getId()}', 'Like', 'reply', event)">👍</span>
                                                            <span class="hover:scale-150 transition" onclick="handleAJAXReact('${reply.getId()}', 'Love', 'reply', event)">❤️</span>
                                                            <span class="hover:scale-150 transition" onclick="handleAJAXReact('${reply.getId()}', 'Care', 'reply', event)">🥰</span>
                                                            <span class="hover:scale-150 transition" onclick="handleAJAXReact('${reply.getId()}', 'Haha', 'reply', event)">😆</span>
                                                            <span class="hover:scale-150 transition" onclick="handleAJAXReact('${reply.getId()}', 'Wow', 'reply', event)">😮</span>
                                                            <span class="hover:scale-150 transition" onclick="handleAJAXReact('${reply.getId()}', 'Sad', 'reply', event)">😢</span>
                                                            <span class="hover:scale-150 transition" onclick="handleAJAXReact('${reply.getId()}', 'Angry', 'reply', event)">😡</span>
                                                            <span class="hover:scale-150 transition" onclick="handleAJAXReact('${reply.getId()}', 'Dislike', 'reply', event)">👎</span>
                                                        </div>
                                                    </div>
                                                     <div id="reply-react-container-${reply.getId()}" class="text-[10px] font-normal text-gray-400">
                                                         <c:set var="rtc" value="${reply.getLikeCount() + reply.getLoveCount() + reply.getCareCount() + reply.getHahaCount() + reply.getWowCount() + reply.getSadCount() + reply.getAngryCount() + reply.getDislikes()}"/>
                                                         <c:if test="${rtc > 0}">
                                                             <c:if test="${reply.getLikeCount() > 0}">👍 <span class="text-gray-600">${reply.getLikeCount()}</span>&nbsp;&nbsp;</c:if>
                                                             <c:if test="${reply.getLoveCount() > 0}">❤️ <span class="text-gray-600">${reply.getLoveCount()}</span>&nbsp;&nbsp;</c:if>
                                                             <c:if test="${reply.getCareCount() > 0}">🥰 <span class="text-gray-600">${reply.getCareCount()}</span>&nbsp;&nbsp;</c:if>
                                                             <c:if test="${reply.getHahaCount() > 0}">😆 <span class="text-gray-600">${reply.getHahaCount()}</span>&nbsp;&nbsp;</c:if>
                                                             <c:if test="${reply.getWowCount() > 0}">😮 <span class="text-gray-600">${reply.getWowCount()}</span>&nbsp;&nbsp;</c:if>
                                                             <c:if test="${reply.getSadCount() > 0}">😢 <span class="text-gray-600">${reply.getSadCount()}</span>&nbsp;&nbsp;</c:if>
                                                             <c:if test="${reply.getAngryCount() > 0}">😡 <span class="text-gray-600">${reply.getAngryCount()}</span>&nbsp;&nbsp;</c:if>
                                                             <c:if test="${reply.getDislikes() > 0}">👎 <span class="text-gray-600">${reply.getDislikes()}</span>&nbsp;&nbsp;</c:if>
                                                         </c:if>
                                                     </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <!-- Reply Input Box -->
                                    <div id="replyInputContainer-${comment.id}" class="hidden mt-2 ml-10 relative">
                                        <div class="flex gap-2">
                                            <img src="img/${ub.getProfile_pic()}" class="w-7 h-7 rounded-full border" width="28px">
                                            <div class="flex-1 bg-[#f0f2f5] rounded-2xl px-3 py-1.5 flex items-center">
                                                <input type="text" id="input-reply-${comment.id}" placeholder="Write a reply..." class="bg-transparent outline-none flex-1 text-[12px]"
                                                    onkeydown="if(event.key === 'Enter') submitReplyAJAX('${comment.id}')">
                                                <i class="fa-regular fa-face-smile text-yellow-500 cursor-pointer mx-2" onclick="toggleEmojiPicker('emoji-picker-reply-${comment.id}')"></i>
                                                <label for="replyMedia-${comment.id}" class="cursor-pointer mx-2 text-gray-500 hover:text-blue-600 transition">
                                                    <i class="fa-solid fa-camera"></i>
                                                </label>
                                                <input type="file" id="replyMedia-${comment.id}" class="hidden" accept="image/*,video/*" onchange="previewReplyMedia('${comment.id}')">
                                                <button onclick="submitReplyAJAX('${comment.id}')" class="text-blue-600"><i class="fa fa-paper-plane text-xs"></i></button>
                                            </div>
                                        </div>
                                        <div id="replyPreview-${comment.id}" class="hidden ml-9 mt-2 relative inline-block">
                                            <img id="replyImgPreview-${comment.id}" src="" class="h-16 rounded-lg shadow-md border">
                                            <button onclick="removeReplyMedia('${comment.id}')" class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs shadow-md">×</button>
                                        </div>
                                        <div id="emoji-picker-reply-${comment.id}" class="hidden absolute bottom-10 left-10 bg-white border rounded-xl p-2 shadow-xl z-[5000] w-40">
                                            <div class="grid grid-cols-4 gap-2 text-lg">
                                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${comment.id}', '😀')">😀</span>
                                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${comment.id}', '😂')">😂</span>
                                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${comment.id}', '❤️')">❤️</span>
                                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${comment.id}', '👍')">👍</span>
                                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${comment.id}', '🥰')">🥰</span>
                                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${comment.id}', '😮')">😮</span>
                                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${comment.id}', '😢')">😢</span>
                                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${comment.id}', '😡')">😡</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>


                    <div class="flex gap-2 mt-4 relative">
                        <img src="img/${ub.getProfile_pic()}" class="w-8 h-8 rounded-full border" width="30px">
                        <div class="flex-1 bg-[#f0f2f5] rounded-2xl px-3 py-2 flex items-center">
                            <input type="text" id="input-post-${post.getId()}" placeholder="Write a comment..." class="bg-transparent outline-none flex-1 text-[14px]"
                                onkeydown="if(event.key === 'Enter') submitCommentAJAX('${post.getId()}')">
                            <i class="fa-regular fa-face-smile text-yellow-500 cursor-pointer mx-2" onclick="toggleEmojiPicker('emoji-picker-post-${post.getId()}')"></i>
                            <button onclick="submitCommentAJAX('${post.getId()}')" class="text-blue-600"><i class="fa fa-paper-plane"></i></button>
                        </div>
                        <div id="emoji-picker-post-${post.getId()}" class="hidden absolute bottom-12 right-0 bg-white border rounded-xl p-2 shadow-xl z-[5000] w-40">
                            <div class="grid grid-cols-4 gap-2 text-xl">
                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-post-${post.getId()}', '😀')">😀</span>
                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-post-${post.getId()}', '😂')">😂</span>
                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-post-${post.getId()}', '❤️')">❤️</span>
                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-post-${post.getId()}', '👍')">👍</span>
                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-post-${post.getId()}', '🥰')">🥰</span>
                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-post-${post.getId()}', '😮')">😮</span>
                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-post-${post.getId()}', '😢')">😢</span>
                                <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-post-${post.getId()}', '😡')">😡</span>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>
        </div> <!-- Close tab-content-posts -->

        <!-- TAB CONTENT: ABOUT -->
        <div id="tab-content-about" class="tab-content hidden space-y-6">
            <div class="glass-card p-8 rounded-3xl space-y-6">
                <h3 class="text-2xl font-black text-gray-800 flex items-center gap-3">
                    <i class="fa fa-circle-info text-blue-600"></i> About ${profileUser.getName()}
                </h3>
                
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- Contact Info -->
                    <div class="bg-white/40 p-6 rounded-2xl border border-white/30 space-y-4">
                        <h4 class="font-bold text-gray-700 uppercase tracking-widest text-xs">Contact & Basic Info</h4>
                        <div class="space-y-3 font-medium text-sm">
                            <div class="flex items-center gap-3 text-gray-600">
                                <i class="fa fa-envelope text-blue-500 w-5"></i>
                                <span>${profileUser.getEmail()}</span>
                            </div>
                            <div class="flex items-center gap-3 text-gray-600">
                                <i class="fa fa-user-tag text-purple-500 w-5"></i>
                                <span>@${profileUser.getName().toLowerCase().replace(' ', '')}</span>
                            </div>
                            <div class="flex items-center gap-3 text-gray-600">
                                <i class="fa fa-venus-mars text-pink-500 w-5"></i>
                                <span><strong class="text-gray-700">Gender:</strong> <span class="capitalize">${not empty profileUser.getGender() ? profileUser.getGender() : 'Not specified'}</span></span>
                            </div>
                            <div class="flex items-center gap-3 text-gray-600">
                                <i class="fa fa-cake-candles text-amber-500 w-5"></i>
                                <span><strong class="text-gray-700">Birthday:</strong> ${not empty profileUser.getBirthday() ? profileUser.getBirthday() : 'Not specified'}</span>
                            </div>
                            <div class="flex items-center gap-3 text-gray-600">
                                <i class="fa fa-city text-indigo-500 w-5"></i>
                                <span><strong class="text-gray-700">City:</strong> ${not empty profileUser.getCity() ? profileUser.getCity() : 'Not specified'}</span>
                            </div>
                            <div class="flex items-center gap-3 text-gray-600">
                                <i class="fa fa-earth-americas text-emerald-500 w-5"></i>
                                <span><strong class="text-gray-700">Country:</strong> ${not empty profileUser.getCountry() ? profileUser.getCountry() : 'Not specified'}</span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Biography/Bio -->
                    <div class="bg-white/40 p-6 rounded-2xl border border-white/30 space-y-4">
                        <h4 class="font-bold text-gray-700 uppercase tracking-widest text-xs">Biography</h4>
                        <p class="text-gray-600 font-medium leading-relaxed">
                            ${not empty profileUser.getBio() ? profileUser.getBio() : 'No bio available yet. Standard software engineer interested in building modern web systems, pair programming, and exploring new tech fields.'}
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- TAB CONTENT: FRIENDS -->
        <div id="tab-content-friends" class="tab-content hidden space-y-6">
            <div class="glass-card p-8 rounded-3xl">
                <div class="flex items-center justify-between mb-6">
                    <h3 class="text-2xl font-black text-gray-800 flex items-center gap-3">
                        <i class="fa fa-user-group text-purple-600"></i> Friends List
                    </h3>
                    <span class="bg-purple-100 text-purple-600 px-3.5 py-1 rounded-full text-sm font-black">${friendsCount} Friends</span>
                </div>
                
                <c:choose>
                    <c:when test="${empty friendsList}">
                        <div class="text-center py-12">
                            <div class="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center mx-auto mb-4">
                                <i class="fa fa-user-group text-2xl text-gray-300"></i>
                            </div>
                            <h4 class="text-lg font-black text-gray-400">No friends yet</h4>
                            <p class="text-gray-400 text-sm mt-1">When they accept or add friends, they'll show up here.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
                            <c:forEach var="friend" items="${friendsList}">
                                <div class="bg-white/40 p-4 rounded-2xl border border-white/30 flex items-center gap-4 hover:shadow-lg transition-all group cursor-pointer" onclick="location.href='UsersProfileServlet?userId=${friend.getId()}'">
                                    <img src="${not empty friend.getProfile_pic() ? 'img/' : ''}${not empty friend.getProfile_pic() ? friend.getProfile_pic() : 'https://via.placeholder.com/150'}" 
                                         class="w-16 h-16 rounded-xl object-cover border border-white/50 shadow-md group-hover:scale-105 transition-transform">
                                    <div class="overflow-hidden">
                                        <h4 class="font-black text-gray-800 group-hover:text-blue-600 transition-colors truncate">${friend.getName()}</h4>
                                        <p class="text-xs text-gray-400 truncate">@${friend.getName().toLowerCase().replace(' ', '')}</p>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- TAB CONTENT: PHOTOS -->
        <div id="tab-content-photos" class="tab-content hidden space-y-6">
            <div class="glass-card p-8 rounded-3xl">
                <h3 class="text-2xl font-black text-gray-800 flex items-center gap-3 mb-6">
                    <i class="fa fa-image text-pink-600"></i> Photos & Videos
                </h3>
                
                <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                    <c:set var="hasPhotos" value="false"/>
                    <c:forEach var="post" items="${userPosts}">
                        <c:if test="${not empty post.getFile_name()}">
                            <c:set var="hasPhotos" value="true"/>
                            <div class="relative group aspect-square rounded-2xl overflow-hidden border border-white/30 shadow-md bg-gray-50 cursor-pointer hover:shadow-lg transition-all">
                                <c:choose>
                                    <c:when test="${post.getPost_type() == 'video'}">
                                        <video class="w-full h-full object-cover">
                                            <source src="img/${post.getFile_name()}" type="video/mp4">
                                        </video>
                                        <div class="absolute inset-0 bg-black/30 flex items-center justify-center text-white opacity-90 group-hover:bg-black/45 transition-colors">
                                            <i class="fa fa-play text-2xl"></i>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <img src="img/${post.getFile_name()}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500">
                                        <div class="absolute inset-0 bg-gradient-to-t from-black/40 to-transparent opacity-0 group-hover:opacity-100 transition-opacity"></div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </c:forEach>
                    
                    <c:if test="${!hasPhotos}">
                        <div class="col-span-full text-center py-12">
                            <div class="w-16 h-16 bg-gray-50 rounded-full flex items-center justify-center mx-auto mb-4">
                                <i class="fa fa-images text-2xl text-gray-300"></i>
                            </div>
                            <h4 class="text-lg font-black text-gray-400">No photos yet</h4>
                            <p class="text-gray-400 text-sm mt-1">Photos and videos uploaded in posts will appear here.</p>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

    </div>

    <!-- Create Post Modal -->
    <div id="postModal" class="fixed inset-0 bg-white/80 backdrop-blur-sm z-[9999] hidden items-center justify-center p-4">
        <div class="bg-white w-full max-w-[550px] rounded-3xl shadow-2xl overflow-hidden transform transition-all border border-gray-100">
            <div class="flex items-center justify-between p-6 border-b">
                <h2 class="text-xl font-black text-gray-800">Create Post</h2>
                <button onclick="closeModal()" class="w-10 h-10 rounded-2xl bg-gray-50 hover:bg-red-50 text-gray-400 hover:text-red-500 transition-all flex items-center justify-center">
                    <i class="fa fa-xmark text-xl"></i>
                </button>
            </div>
            
            <form id="postForm" action="UsersPostServlet" method="post" enctype="multipart/form-data" class="p-6 space-y-6">
                <div class="flex items-center gap-4">
                    <img src="img/${ub.getProfile_pic()}" class="w-12 h-12 rounded-2xl border-2 border-white shadow-md">
                    <div>
                        <p class="font-black text-gray-800">${ub.getName()}</p>
                        <select name="feeling" class="text-[11px] font-black text-blue-600 bg-blue-50 px-2 py-1 rounded-lg outline-none cursor-pointer">
                            <option value="">Feeling?</option>
                            <option value="Happy">😊 Happy</option>
                            <option value="Loved">😍 Loved</option>
                            <option value="Haha">😆 Haha</option>
                            <option value="Wow">😮 Wow</option>
                            <option value="Sad">😢 Sad</option>
                            <option value="Angry">😡 Angry</option>
                        </select>
                    </div>
                </div>

                <textarea name="content" placeholder="Share something with your friends..." 
                          class="w-full h-40 text-xl font-medium outline-none resize-none placeholder-gray-300 text-gray-700"></textarea>

                <div id="previewContainer" class="hidden relative rounded-2xl overflow-hidden border border-gray-100">
                    <button type="button" onclick="removePreview()" class="absolute top-3 right-3 bg-black/50 text-white w-8 h-8 rounded-xl flex items-center justify-center z-10 hover:bg-red-500 transition-colors">×</button>
                    <img id="imagePreview" src="#" class="w-full h-auto max-h-[300px] object-cover">
                </div>

                <div class="p-4 border-2 border-dashed border-gray-100 rounded-2xl flex items-center justify-between">
                    <span class="text-gray-400 font-bold text-sm ml-2">Add to your post</span>
                    <label for="modalFileInput" class="w-11 h-11 bg-green-50 text-green-500 rounded-xl flex items-center justify-center cursor-pointer hover:bg-green-500 hover:text-white transition-all shadow-sm">
                        <i class="fa fa-image text-xl"></i>
                    </label>
                    <input type="file" name="media" id="modalFileInput" class="hidden" accept="image/*,video/*" onchange="previewImage(this)">
                </div>

                <button type="submit" class="w-full bg-blue-600 text-white font-black py-4 rounded-2xl shadow-lg shadow-blue-200 hover:bg-blue-700 active:scale-95 transition-all">
                    Post to Timeline
                </button>
            </form>
        </div>
    </div>

    <!-- JS -->
    <script>
        var contextPath = "${pageContext.request.contextPath}";
        // Tab Switching Logic
        function switchTab(tabName) {
            // Hide all tab content
            document.querySelectorAll('.tab-content').forEach(el => {
                el.classList.add('hidden');
            });
            
            // Show target tab content
            const targetTab = document.getElementById('tab-content-' + tabName);
            if (targetTab) {
                targetTab.classList.remove('hidden');
            }
            
            // Update tab buttons style
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.className = 'tab-btn px-6 py-2 rounded-xl hover:bg-white/50 font-bold text-gray-500 text-sm transition-all';
            });
            
            // Highlight active tab button
            const activeBtn = document.getElementById('btn-tab-' + tabName);
            if (activeBtn) {
                activeBtn.className = 'tab-btn px-6 py-2 rounded-xl bg-white shadow-sm font-black text-blue-600 text-sm transition-all';
            }
        }

        function openModal() {
            document.getElementById('postModal').classList.remove('hidden');
            document.getElementById('postModal').classList.add('flex');
            document.body.style.overflow = 'hidden';
        }
        function closeModal() {
            document.getElementById('postModal').classList.add('hidden');
            document.getElementById('postModal').classList.remove('flex');
            document.body.style.overflow = 'auto';
        }
        function previewImage(input) {
            const preview = document.getElementById('imagePreview');
            const container = document.getElementById('previewContainer');
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    container.classList.remove('hidden');
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
        function removePreview() {
            document.getElementById('modalFileInput').value = '';
            document.getElementById('previewContainer').classList.add('hidden');
        }


    function handleAJAXReact(id, type, level, event) {
        if (event) event.stopPropagation();
        let targetUrl = (level === 'post') ? ('${pageContext.request.contextPath}/InteractionServlet') : ('${pageContext.request.contextPath}/CommentServlet');
        // FormData ব্যবহার করতে হবে কারণ উভয় Servlet-এ @MultipartConfig আছে
        let formData = new FormData();
        if (level === 'post') {
            formData.append('id', id);
            formData.append('action', type);
        } else {
            formData.append('commentId', id);
            formData.append('action', type);
            formData.append('level', level);
        }

        let emojiMap = {
            'Like': '👍', 'Love': '❤️', 'Care': '🥰', 'Haha': '😆', 
            'Wow': '😮', 'Sad': '😢', 'Angry': '😡', 'Dislike': '👎', 'Dislikes': '👎'
        };
        let colorMap = {
            'Like': 'text-blue-600', 'Love': 'text-red-500', 'Care': 'text-yellow-500', 
            'Haha': 'text-yellow-500', 'Wow': 'text-yellow-500', 'Sad': 'text-yellow-500', 
            'Angry': 'text-red-600', 'Dislike': 'text-gray-800', 'Dislikes': 'text-gray-800'
        };
        let activeEmoji = emojiMap[type] || '👍';
        let activeColor = colorMap[type] || 'text-blue-600';

        fetch(targetUrl, { 
            method: 'POST', 
            body: formData  // Content-Type header সেট করা উচিত নয়, browser নিজে multipart boundary দেবে
        })
        .then(res => {
            const contentType = res.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                return res.json();
            }
            return res.text().then(txt => { throw new Error('Non-JSON: ' + txt.substring(0, 200)); });
        })
        .then(data => {
            if (data.status === 'ok' || data.success) {
                // Build granular count string
                let countsHtml = '';
                if (data.counts) {
                    for (let key in data.counts) {
                        if (data.counts[key] > 0) {
                            let mappedKey = key === 'Dislikes' ? 'Dislike' : key;
                            countsHtml += `\${emojiMap[mappedKey]} <span class="text-gray-600">\${data.counts[key]}</span>&nbsp;&nbsp;`;
                        }
                    }
                    countsHtml = countsHtml.trim();
                } else {
                    countsHtml = `\${activeEmoji} <span class="text-blue-500">\${data.newCount}</span>`;
                }

                if (level === 'post') {
                    let countSpan = document.getElementById(`post-react-count-\${id}`);
                    if (countSpan) {
                        if (data.newCount > 0) {
                            countSpan.innerHTML = countsHtml;
                        } else {
                            countSpan.innerText = '0';
                        }
                    }
                    // পোস্ট বাটনে visual feedback
                    let actionBtnContent = document.getElementById(`post-action-btn-content-\${id}`);
                    if (actionBtnContent && data.newCount > 0) {
                        actionBtnContent.innerHTML = `\${activeEmoji} <span class="\${activeColor}">\${type}</span>`;
                    } else if (actionBtnContent) {
                        actionBtnContent.innerHTML = `<i class="fa-regular fa-thumbs-up"></i> Like`;
                    }
                } else {
                    let containerId = level === 'comment' ? `comment-react-container-\${id}` : `reply-react-container-\${id}`;
                    let container = document.getElementById(containerId);
                    if (container) {
                        if (data.newCount > 0) {
                            container.innerHTML = countsHtml;
                        } else {
                            container.innerHTML = '';
                        }
                    }
                }
            } else {
                console.warn('Reaction response:', data);
            }
        })
        .catch(err => console.error("React error", err));
    }


    // ২. কমেন্ট সাবমিট
    function submitCommentAJAX(postId) {
        let input = document.getElementById('input-post-' + postId);
        let fileInput = document.getElementById('commentMedia-' + postId);
        if (!input || !input.value.trim()) return;

        let formData = new FormData();
        formData.append("postId", postId);
        formData.append("comment_text", input.value);
        formData.append("action", "ADD_COMMENT");
        if (fileInput && fileInput.files[0]) {
            formData.append("media", fileInput.files[0]);
        }

        fetch('CommentServlet', { method: 'POST', body: formData })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                let countText = document.getElementById(`post-comment-count-text-\${postId}`);
                if (countText) {
                    let currentCount = parseInt(countText.innerText) || 0;
                    countText.innerText = `\${currentCount + 1} Comments`;
                }
                
                let list = document.getElementById(`comment-list-\${postId}`);
                if (list) {
                    let escapedName = data.userName.replace(/'/g, "\\'");
                    let html = `
                        <div class="comment-level-1">
                            <div class="flex gap-2">
                                <a href="UsersProfileServlet?userId=\${data.userId}">
                                    <img src="img/\${data.userPic}" class="w-8 h-8 rounded-full border clickable" width="30px">
                                </a>
                                <div class="bg-[#f0f2f5] px-3 py-2 rounded-2xl max-w-[90%]">
                                    <p class="font-bold text-[13px]"><a href="UsersProfileServlet?userId=\${data.userId}" class="clickable hover:underline">\${data.userName}</a></p>
                                    <p class="text-[14px]">\${data.text}</p>
                                    \${data.fileName ? '<img src="img/' + data.fileName + '" class="w-full h-auto rounded-lg mt-2 border">' : ''}
                                </div>
                            </div>
                            <div class="flex gap-4 ml-10 mt-1 text-[12px] font-bold text-gray-500 items-center">
                                <div class="react-container clickable">
                                    <span class="hover:text-blue-600 transition" onclick="handleAJAXReact(\${data.commentId}, 'Like', 'comment', event)">Like</span>
                                    <div class="react-box !-top-12 !p-1 !rounded-full">
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.commentId}, 'Like', 'comment', event)">👍</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.commentId}, 'Love', 'comment', event)">❤️</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.commentId}, 'Care', 'comment', event)">🥰</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.commentId}, 'Haha', 'comment', event)">😆</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.commentId}, 'Wow', 'comment', event)">😮</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.commentId}, 'Sad', 'comment', event)">😢</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.commentId}, 'Angry', 'comment', event)">😡</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.commentId}, 'Dislike', 'comment', event)">👎</span>
                                    </div>
                                </div>
                                <span class="clickable hover:text-blue-600 transition" onclick="showReplyBox(\${data.commentId}, '\${escapedName}')">Reply</span>
                                <div class="text-[11px] font-normal text-gray-400" id="comment-react-container-\${data.commentId}"></div>
                            </div>
                            <div id="reply-list-\${data.commentId}" class="mt-2 space-y-2 ml-10"></div>
                            <div id="replyInputContainer-\${data.commentId}" class="hidden mt-2 ml-10 relative">
                                <div class="flex gap-2">
                                    <img src="img/\${data.userPic}" class="w-7 h-7 rounded-full border shadow-sm" width="28px">
                                    <div class="flex-1 bg-[#f0f2f5] rounded-2xl px-3 py-1.5 flex items-center">
                                        <input type="text" id="input-reply-\${data.commentId}" placeholder="Write a reply..." class="bg-transparent outline-none flex-1 text-[12px]"
                                            onkeydown="if(event.key === 'Enter') submitReplyAJAX('\${data.commentId}')">
                                        <i class="fa-regular fa-face-smile text-yellow-500 cursor-pointer mx-2" onclick="toggleEmojiPicker('emoji-picker-reply-\\${data.commentId}')"></i>
                                        <label for="replyMedia-\${data.commentId}" class="cursor-pointer mx-2 text-gray-500 hover:text-blue-600 transition">
                                            <i class="fa-solid fa-camera"></i>
                                        </label>
                                        <input type="file" id="replyMedia-\${data.commentId}" class="hidden" accept="image/*,video/*" onchange="previewReplyMedia('\${data.commentId}')">
                                        <button onclick="submitReplyAJAX('\${data.commentId}')" class="text-blue-600"><i class="fa fa-paper-plane text-xs"></i></button>
                                    </div>
                                </div>
                                <div id="emoji-picker-reply-\${data.commentId}" class="hidden absolute bottom-10 left-10 bg-white border rounded-xl p-2 shadow-xl z-[5000] w-40">
                                    <div class="grid grid-cols-4 gap-2 text-lg">
                                        <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-\${data.commentId}', '😀')">😀</span>
                                        <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-\${data.commentId}', '😂')">😂</span>
                                        <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-\${data.commentId}', '❤️')">❤️</span>
                                        <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-\${data.commentId}', '👍')">👍</span>
                                        <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-\${data.commentId}', '🥰')">🥰</span>
                                        <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-\${data.commentId}', '😮')">😮</span>
                                        <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-\${data.commentId}', '😢')">😢</span>
                                        <span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-\${data.commentId}', '😡')">😡</span>
                                    </div>
                                </div>
                                <div id="replyPreview-\${data.commentId}" class="hidden ml-9 mt-2 relative inline-block">
                                    <img id="replyImgPreview-\${data.commentId}" src="" class="h-16 rounded-lg shadow-md border">
                                    <button onclick="removeReplyMedia('\${data.commentId}')" class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs shadow-md">×</button>
                                </div>
                            </div>
                        </div>`;
                    list.insertAdjacentHTML('beforeend', html);
                }
                input.value = '';
                if (fileInput) fileInput.value = '';
                removeCommentMedia(postId); 
            }
        });
    }

    // ৩. রিপ্লাই সাবমিট
    function submitReplyAJAX(commentId) {
        let input = document.getElementById('input-reply-' + commentId);
        let fileInput = document.getElementById('replyMedia-' + commentId);
        if (!input || !input.value.trim()) return;

        let formData = new FormData();
        formData.append("commentId", commentId);
        formData.append("replyText", input.value);
        formData.append("action", "REPLY");
        if (fileInput && fileInput.files[0]) {
            formData.append("media", fileInput.files[0]);
        }

        fetch('CommentServlet', { method: 'POST', body: formData })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                let list = document.getElementById(`reply-list-\${commentId}`);
                if (list) {
                    let escapedName = data.userName.replace(/'/g, "\\'");
                    let html = `
                        <div class="comment-level-2">
                            <div class="flex gap-2">
                                <a href="UsersProfileServlet?userId=\${data.userId}">
                                    <img src="img/\${data.userPic}" class="w-7 h-7 rounded-full border clickable" width="28px">
                                </a>
                                <div class="bg-[#f0f2f5] px-3 py-1.5 rounded-2xl">
                                    <p class="font-bold text-[12px]"><a href="UsersProfileServlet?userId=\${data.userId}" class="clickable hover:underline">\${data.userName}</a></p>
                                    <p class="text-[13px]"><a href="UsersProfileServlet?userId=\${commentId}" class="text-blue-600 font-semibold hover:underline">@\${data.userName}</a> \${data.text}</p>
                                    \${data.fileName ? '<img src="img/' + data.fileName + '" class="w-full h-auto rounded-lg mt-2 border">' : ''}
                                </div>
                            </div>
                            <div class="flex gap-4 ml-10 mt-1 text-[11px] font-bold text-gray-500 items-center">
                                <div class="react-container clickable">
                                    <span class="hover:text-blue-600 transition" onclick="handleAJAXReact(\${data.replyId}, 'Like', 'reply', event)">Like</span>
                                    <div class="react-box !-top-12 !p-1 !rounded-full">
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.replyId}, 'Like', 'reply', event)">👍</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.replyId}, 'Love', 'reply', event)">❤️</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.replyId}, 'Care', 'reply', event)">🥰</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.replyId}, 'Haha', 'reply', event)">😆</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.replyId}, 'Wow', 'reply', event)">😮</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.replyId}, 'Sad', 'reply', event)">😢</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.replyId}, 'Angry', 'reply', event)">😡</span>
                                        <span class="hover:scale-150 transition" onclick="handleAJAXReact(\${data.replyId}, 'Dislike', 'reply', event)">👎</span>
                                    </div>
                                </div>
                                <div class="text-[10px] font-normal text-gray-400" id="reply-react-container-\${data.replyId}"></div>
                            </div>
                        </div>`;
                    list.insertAdjacentHTML('beforeend', html);
                }
                input.value = '';
                document.getElementById('replyInputContainer-' + commentId).classList.add('hidden');
                removeReplyMedia(commentId);
            }
        });
    }

    // ৪. শেয়ার লজিক
    function shareAJAX(postId) {
        if(!confirm("Share this post?")) return;
        let formData = new FormData();
        formData.append("action", "SHARE");
        formData.append("postId", postId);
        fetch('InteractionServlet', { method: 'POST', body: formData })
        .then(res => res.json())
        .then(data => {
            if(data.status === 'shared') {
                alert("Shared Successfully!");
                let shareEl = document.getElementById('post-share-count-text-' + postId);
                if (shareEl) {
                    let count = parseInt(shareEl.innerText) || 0;
                    shareEl.innerText = (count + 1) + " Shares";
                }
            } else {
                alert("Share failed!");
            }
        })
        .catch(err => {
            console.error("Share error", err);
            // Fallback
            let shareEl = document.getElementById('post-share-count-text-' + postId);
            if (shareEl) {
                let count = parseInt(shareEl.innerText) || 0;
                shareEl.innerText = (count + 1) + " Shares";
            }
            alert("Shared Successfully!");
        });
    }

    // ৫. ইউআই ফাংশন
    function showReplyBox(id, targetName) {
        let el = document.getElementById('replyInputContainer-' + id);
        if(el) {
            el.classList.remove('hidden');
            let input = document.getElementById('input-reply-' + id);
            if(input && targetName) { input.value = "@" + targetName + " "; input.focus(); }
        }
    }

    function previewReplyMedia(commentId) {
        let input = document.getElementById('replyMedia-' + commentId);
        let preview = document.getElementById('replyImgPreview-' + commentId);
        let container = document.getElementById('replyPreview-' + commentId);
        if (input && input.files && input.files[0] && preview && container) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                container.classList.remove('hidden');
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    function removeReplyMedia(commentId) {
        let input = document.getElementById('replyMedia-' + commentId);
        let preview = document.getElementById('replyImgPreview-' + commentId);
        let container = document.getElementById('replyPreview-' + commentId);
        if (input) input.value = "";
        if (preview) preview.src = "";
        if (container) container.classList.add('hidden');
    }
    function focusCmt(id) { 
        let input = document.getElementById('input-post-' + id);
        if(input) input.focus(); 
    }

    // ৬. ইউজার একশন (FOLLOW, UNFOLLOW, ADD FRIEND, etc.) - AJAX
    function handleUserAction(targetId, action, btn) {
        console.log("Friend Action:", action, "on Target:", targetId);
        let formData = new URLSearchParams();
        formData.append("targetId", targetId);
        formData.append("action", action);
        formData.append("ajax", "true");

        // UI Feedback
        if (btn) {
            btn.innerHTML = '<i class="fa fa-spinner fa-spin mr-2"></i> Processing...';
            btn.disabled = true;
        }

        fetch('FriendServlet', {
            method: 'POST',
            body: formData
        })
        .then(res => res.json())
        .then(data => {
            if(data.success) {
                // সাকসেস হলে ফুল রিলোড যাতে ডাটাবেজ থেকে ফ্রেশ ডাটা আসে
                location.reload();
            } else {
                alert("Action failed: " + (data.message || "Unknown error"));
                location.reload();
            }
        })
        .catch(err => {
            console.error("Action error", err);
            location.reload();
        });
    }

    function refreshProfile() {
        fetch(window.location.href)
        .then(res => res.text())
        .then(html => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');
            const wrapper = doc.querySelector('#profile-content-wrapper');
            if (wrapper) {
                document.querySelector('#profile-content-wrapper').innerHTML = wrapper.innerHTML;
                console.log("Profile Refreshed!");
            } else {
                location.reload(); // ফেইল করলে হার্ড রিলোড
            }
        })
        .catch(() => location.reload());
    }
    
    function toggleEmojiPicker(id) {
        const picker = document.getElementById(id);
        if (picker) {
            document.querySelectorAll('[id^="emoji-picker-"]').forEach(p => {
                if (p.id !== id) p.classList.add('hidden');
            });
            picker.classList.toggle('hidden');
        }
    }
    function addEmoji(inputId, emoji) {
        const input = document.getElementById(inputId);
        if (input) { input.value += emoji; input.focus(); }
    }

    document.addEventListener('click', function(event) {
        if (!event.target.closest('.relative')) {
            document.querySelectorAll('[id^="emoji-picker-"]').forEach(p => p.classList.add('hidden'));
        }
    });

    // প্রোফাইল ফটো প্রিভিউ
    const uploadArea = document.getElementById("uploadArea");
    const fileInput = document.getElementById("fileInput");
    const preview = document.getElementById("previewImg");
    if(uploadArea){
        uploadArea.addEventListener("click", () => fileInput.click());
        fileInput.addEventListener("change", () => {
            const file = fileInput.files[0];
            if (file) preview.src = URL.createObjectURL(file);
        });
    }
</script>


	<!-- Mobile Bottom Navigation Bar (Visible only on mobile/tablet) -->
	<nav id="mobileBottomNav" class="lg:hidden fixed bottom-0 left-0 right-0 h-[65px] bg-white/95 backdrop-blur-md border-t border-gray-200 z-[99999] flex justify-around items-center px-4 rounded-t-3xl shadow-[0_-8px_30px_rgba(0,0,0,0.15)]">
		<a href="UsersPostServlet" class="flex flex-col items-center gap-1 text-gray-500 hover:text-blue-500 transition">
			<i class="fa fa-house text-xl"></i>
			<span class="text-[10px] font-bold">Home</span>
		</a>
		<a href="FriendServlet" class="flex flex-col items-center gap-1 text-gray-500 hover:text-blue-500 transition">
			<i class="fa fa-user-group text-xl"></i>
			<span class="text-[10px] font-bold">Friends</span>
		</a>
		<a href="messages.jsp" class="flex flex-col items-center gap-1 text-gray-500 hover:text-blue-500 transition">
			<i class="fa-brands fa-facebook-messenger text-xl"></i>
			<span class="text-[10px] font-bold">Messenger</span>
		</a>
		<a href="UsersProfileServlet?userId=${sessionScope.userId}" class="flex flex-col items-center gap-1 text-blue-500">
			<img src="img/${ub.getProfile_pic()}" class="w-6 h-6 rounded-full border-2 border-blue-500">
			<span class="text-[10px] font-bold">Profile</span>
		</a>
	</nav>

    <!-- Secure Stripe Checkout -->
    <div id="paymentModal" class="hidden fixed inset-0 bg-black/60 backdrop-blur-md z-[99999] flex items-center justify-center p-4">
        <div class="glass-card bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl space-y-5 animate-slide-in text-gray-800">
            <div class="flex items-center justify-between border-b pb-3">
                <h3 class="text-lg font-extrabold flex items-center gap-2 text-blue-600">
                    <i class="fa-solid fa-circle-check text-blue-500 text-xl"></i> Get Verified Blue Badge
                </h3>
                <button onclick="closePaymentModal()" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 flex items-center justify-center text-gray-500 font-bold transition">笨・/button>
            </div>

            <div class="bg-blue-50/70 border border-blue-100 p-4 rounded-2xl flex items-center justify-between">
                <div>
                    <p class="font-bold text-blue-900 text-sm">Y-Chat Verified Badge</p>
                    <p class="text-xs text-blue-600 mt-0.5">Lifetime Blue Checkmark Badge</p>
                </div>
                <span class="text-xl font-extrabold text-blue-700">$4.99 USD</span>
            </div>

            <div class="rounded-2xl border border-emerald-200 bg-emerald-50 p-4 text-sm text-emerald-900">Payment is processed securely by Stripe Checkout. Card details are entered on Stripe and never stored by Y-ChatApp.</div>

            <div class="flex items-center gap-3 pt-2">
                <button type="button" onclick="closePaymentModal()" class="flex-1 py-3 rounded-2xl bg-gray-100 hover:bg-gray-200 font-bold text-gray-700 text-sm transition">Cancel</button>
                <button type="button" onclick="submitPayment()" class="flex-1 py-3 rounded-2xl bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-bold text-sm shadow-lg transition">Continue to Secure Payment</button>
            </div>
        </div>
    </div>

    <script>
        let selectedPaymentMethod = 'bKash';

        function openPaymentModal() {
            document.getElementById('paymentModal').classList.remove('hidden');
        }

        function closePaymentModal() {
            document.getElementById('paymentModal').classList.add('hidden');
        }

        function selectPayMethod(method) {
            selectedPaymentMethod = method;
            document.querySelectorAll('.pay-method-btn').forEach(btn => {
                btn.classList.remove('border-pink-500', 'bg-pink-50', 'text-pink-700', 'border-orange-500', 'bg-orange-50', 'text-orange-700', 'border-blue-500', 'bg-blue-50', 'text-blue-700');
                btn.classList.add('border-gray-200', 'text-gray-700');
            });
            const selectedBtn = document.getElementById('payBtn' + method);
            if (selectedBtn) {
                selectedBtn.classList.remove('border-gray-200', 'text-gray-700');
                selectedBtn.classList.add('border-blue-500', 'bg-blue-50', 'text-blue-700');
            }
        }

        function submitPayment() {
            const params = new URLSearchParams({action:'checkout',purpose:'BLUE_TICK'});
            fetch('PaymentServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:params})
            .then(async res => { const data=await res.json(); if(!res.ok) throw new Error(data.message || 'Secure checkout is unavailable.'); return data; })
            .then(data => { if(data.checkoutUrl) window.location.assign(data.checkoutUrl); else throw new Error(data.message || 'Could not start checkout.'); })
            .catch(err => alert(err.message || 'Could not start secure checkout.'));
        }

        // --- Profile Creator Tip Handlers ---
        let activeProfileTipMethod = 'WALLET';

        function openProfileTipModal(receiverId, creatorName) {
            document.getElementById('profileTipReceiverId').value = receiverId;
            document.getElementById('profileTipCreatorName').innerText = creatorName || 'Creator';
            document.getElementById('profileTipModal').classList.remove('hidden');
        }

        function closeProfileTipModal() {
            document.getElementById('profileTipModal').classList.add('hidden');
        }

        function selectProfileTipAmount(amt) {
            document.getElementById('profileTipCustomAmount').value = amt.toFixed(2);
            document.querySelectorAll('.ptip-chip-btn').forEach(b => {
                b.classList.remove('border-amber-500', 'bg-amber-500', 'text-white', 'shadow-sm');
                b.classList.add('border-gray-200', 'bg-gray-100', 'text-gray-700');
            });
            const activeBtn = document.getElementById('pTipChip-' + amt);
            if (activeBtn) {
                activeBtn.classList.remove('border-gray-200', 'bg-gray-100', 'text-gray-700');
                activeBtn.classList.add('border-amber-500', 'bg-amber-500', 'text-white', 'shadow-sm');
            }
        }

        function selectProfileTipMethod(method) {
            activeProfileTipMethod = method;
            ['WALLET', 'BKASH', 'NAGAD', 'CARD'].forEach(m => {
                const b = document.getElementById('pTipMethodBtn-' + m);
                if (b) {
                    if (m === method) {
                        b.classList.add('border-amber-500', 'bg-amber-50', 'text-amber-700');
                        b.classList.remove('border-gray-200', 'text-gray-600');
                    } else {
                        b.classList.remove('border-amber-500', 'bg-amber-50', 'text-amber-700');
                        b.classList.add('border-gray-200', 'text-gray-600');
                    }
                }
            });
        }

        function submitProfileCreatorTip() {
            const receiverId = document.getElementById('profileTipReceiverId').value;
            const amount = parseFloat(document.getElementById('profileTipCustomAmount').value);
            const note = document.getElementById('profileTipNoteInput').value.trim();

            if (!amount || isNaN(amount) || amount <= 0) {
                alert('Please enter a valid tip amount.');
                return;
            }

            const btn = document.getElementById('submitProfileTipBtn');
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-2"></i> Sending...';

            const params = new URLSearchParams();
            params.append('action', 'sendTip');
            params.append('receiverId', receiverId);
            params.append('postId', '0');
            params.append('amount', amount);
            params.append('paymentMethod', activeProfileTipMethod);
            params.append('note', note);

            fetch('TipServlet', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params
            })
            .then(res => res.json())
            .then(data => {
                btn.disabled = false;
                btn.innerHTML = '<span>Send Tip Now</span> <i class="fa-solid fa-paper-plane text-xs"></i>';

                if (data.status === 'success') {
                    alert(data.message || 'Tip sent successfully!');
                    closeProfileTipModal();
                    if (data.newBalance !== undefined) {
                        const balEl = document.getElementById('profileTipUserBalance');
                        if (balEl) balEl.innerText = parseFloat(data.newBalance).toFixed(2);
                    }
                } else {
                    alert(data.message || 'Failed to send tip.');
                }
            })
            .catch(err => {
                btn.disabled = false;
                btn.innerHTML = '<span>Send Tip Now</span> <i class="fa-solid fa-paper-plane text-xs"></i>';
                console.error('Error sending tip:', err);
                alert('An error occurred while sending tip.');
            });
        }
    </script>

    <!-- ================= PROFILE CREATOR TIP MODAL ================= -->
    <div id="profileTipModal" class="fixed inset-0 bg-slate-950/70 backdrop-blur-md z-[9999] hidden flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-md w-full shadow-2xl overflow-hidden flex flex-col p-6 animate-in fade-in zoom-in-95 duration-200">
            <!-- Header -->
            <div class="flex items-center justify-between border-b border-gray-100 pb-4">
                <div class="flex items-center gap-3">
                    <div class="w-11 h-11 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center text-white shadow-md shadow-amber-200 text-lg">
                        <i class="fa-solid fa-coins"></i>
                    </div>
                    <div>
                        <h3 class="font-extrabold text-base text-gray-900 leading-tight">Send a Tip</h3>
                        <p class="text-xs text-gray-500">Support <strong id="profileTipCreatorName" class="text-amber-600">Creator</strong></p>
                    </div>
                </div>
                <button type="button" onclick="closeProfileTipModal()" class="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-500 flex items-center justify-center transition">
                    <i class="fa-solid fa-xmark text-sm"></i>
                </button>
            </div>

            <input type="hidden" id="profileTipReceiverId">

            <div class="space-y-4 pt-4">
                <!-- Quick Preset Chips -->
                <div>
                    <label class="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Select Amount</label>
                    <div class="grid grid-cols-5 gap-2">
                        <button type="button" onclick="selectProfileTipAmount(1)" id="pTipChip-1" class="ptip-chip-btn py-2 rounded-xl text-xs font-bold border border-gray-200 bg-gray-100 text-gray-700 hover:border-amber-400 transition">$1</button>
                        <button type="button" onclick="selectProfileTipAmount(3)" id="pTipChip-3" class="ptip-chip-btn py-2 rounded-xl text-xs font-bold border border-gray-200 bg-gray-100 text-gray-700 hover:border-amber-400 transition">$3</button>
                        <button type="button" onclick="selectProfileTipAmount(5)" id="pTipChip-5" class="ptip-chip-btn py-2 rounded-xl text-xs font-bold border border-amber-500 bg-amber-500 text-white shadow-sm transition">$5</button>
                        <button type="button" onclick="selectProfileTipAmount(10)" id="pTipChip-10" class="ptip-chip-btn py-2 rounded-xl text-xs font-bold border border-gray-200 bg-gray-100 text-gray-700 hover:border-amber-400 transition">$10</button>
                        <button type="button" onclick="selectProfileTipAmount(20)" id="pTipChip-20" class="ptip-chip-btn py-2 rounded-xl text-xs font-bold border border-gray-200 bg-gray-100 text-gray-700 hover:border-amber-400 transition">$20</button>
                    </div>
                </div>

                <!-- Custom Amount Box -->
                <div class="space-y-1">
                    <label class="block text-xs font-bold text-gray-500 uppercase tracking-wider">Custom Amount ($)</label>
                    <div class="relative">
                        <span class="absolute left-4 top-1/2 -translate-y-1/2 font-extrabold text-gray-400 text-lg">$</span>
                        <input type="number" id="profileTipCustomAmount" min="1" step="0.5" value="5.00" class="w-full pl-9 pr-4 py-3 bg-gray-50 border border-gray-200 rounded-2xl outline-none font-extrabold text-base text-gray-800 focus:border-amber-500 transition">
                    </div>
                </div>

                <!-- Payment Method -->
                <div class="space-y-1.5">
                    <div class="flex items-center justify-between">
                        <label class="block text-xs font-bold text-gray-500 uppercase tracking-wider">Payment Method</label>
                        <span class="text-[11px] font-bold text-emerald-600">Wallet Bal: $<span id="profileTipUserBalance">${sessionScope.ub.getBalance()}</span></span>
                    </div>
                    <div class="grid grid-cols-4 gap-2">
                        <button type="button" onclick="selectProfileTipMethod('WALLET')" id="pTipMethodBtn-WALLET" class="p-2.5 rounded-xl border-2 border-amber-500 bg-amber-50 text-amber-700 text-[11px] font-bold flex flex-col items-center gap-1 transition">
                            <i class="fa-solid fa-wallet text-sm"></i>
                            <span>Wallet</span>
                        </button>
                        <button type="button" disabled aria-hidden="true" class="hidden" onclick="selectProfileTipMethod('BKASH')" id="pTipMethodBtn-BKASH" class="p-2.5 rounded-xl border-2 border-gray-200 text-gray-600 text-[11px] font-bold flex flex-col items-center gap-1 transition">
                            <span class="text-sm">猪</span>
                            <span>bKash</span>
                        </button>
                        <button type="button" disabled aria-hidden="true" class="hidden" onclick="selectProfileTipMethod('NAGAD')" id="pTipMethodBtn-NAGAD" class="p-2.5 rounded-xl border-2 border-gray-200 text-gray-600 text-[11px] font-bold flex flex-col items-center gap-1 transition">
                            <span class="text-sm">泛</span>
                            <span>Nagad</span>
                        </button>
                        <button type="button" disabled aria-hidden="true" class="hidden" onclick="selectProfileTipMethod('CARD')" id="pTipMethodBtn-CARD" class="p-2.5 rounded-xl border-2 border-gray-200 text-gray-600 text-[11px] font-bold flex flex-col items-center gap-1 transition">
                            <i class="fa-solid fa-credit-card text-sm"></i>
                            <span>Card</span>
                        </button>
                    </div>
                </div>

                <!-- Encouraging Note -->
                <div class="space-y-1">
                    <label class="block text-xs font-bold text-gray-500 uppercase tracking-wider">Personal Message / Note (Optional)</label>
                    <input type="text" id="profileTipNoteInput" placeholder="Keep up the great work! 脂" maxlength="150" class="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-2xl outline-none text-xs text-gray-700 focus:border-amber-500 transition">
                </div>

                <!-- Submit Button -->
                <button type="button" id="submitProfileTipBtn" onclick="submitProfileCreatorTip()" class="w-full py-3.5 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white font-extrabold rounded-2xl shadow-lg shadow-amber-200 transition flex items-center justify-center gap-2">
                    <span>Send Tip Now</span>
                    <i class="fa-solid fa-paper-plane text-xs"></i>
                </button>
            </div>
        </div>
    </div>
	<script src="js/theme.js?v=20261029-safari-v7"></script><script src="js/ychat-pro-features.js?v=20261029-safari-v7"></script>
</body>
</html>
