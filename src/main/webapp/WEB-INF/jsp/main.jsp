<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core"%>
<%@ taglib prefix="fn" uri="jakarta.tags.functions"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <script>
        if ('serviceWorker' in navigator) {
            navigator.serviceWorker.getRegistrations().then(function(regs) {
                for (var i = 0; i < regs.length; i++) regs[i].unregister();
            }).catch(function() {});
        }
        if ('caches' in window) {
            caches.keys().then(function(keys) {
                for (var i = 0; i < keys.length; i++) caches.delete(keys[i]);
            }).catch(function() {});
        }
    </script>
    <script src="<%=request.getContextPath()%>/js/notification-badge.js" data-context-path="<%=request.getContextPath()%>" defer></script>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover, shrink-to-fit=no">
<title>Y-ChatApp | Newsfeed</title>
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
<link rel="icon" type="image/png"
	href="<%=request.getContextPath()%>/icons/icon-192.png">

<script src="https://cdn.tailwindcss.com"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
<link
	href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;800&display=swap"
	rel="stylesheet">

<style>
* {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}

/* --- আপনার আসল বডি স্টাইল (শুধু width এবং overflow-x যোগ করা হয়েছে) --- */
body {
	background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
	background-size: 400% 400%;
	animation: gradient 15s ease infinite;
	font-family: 'Outfit', sans-serif;
	width: 100%;
	max-width: 100%;
	min-height: 100vh;
	overflow-x: hidden;
}

@keyframes gradient {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}
@media screen and (max-width: 768px) { input, textarea, select { font-size: 16px !important; } }
* { -webkit-tap-highlight-color: transparent; }
* { -webkit-tap-highlight-color: transparent !important; touch-action: pan-x pan-y !important; }
html, body { -webkit-text-size-adjust: 100% !important; touch-action: pan-x pan-y !important; }
input, textarea, select { font-size: 16px !important; }
.glass-card {
	touch-action: pan-x pan-y !important;
	-webkit-backdrop-filter: blur(12px) !important;
	background: rgba(255, 255, 255, 0.7) !important;
	backdrop-filter: blur(12px) !important;
	border: 1px solid rgba(255, 255, 255, 0.3) !important;
	box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.15) !important;
}

.glass-nav {
	background: rgba(255, 255, 255, 0.8) !important;
	backdrop-filter: blur(10px) !important;
	border-bottom: 1px solid rgba(255, 255, 255, 0.3) !important;
}

/* --- ২. এই নতুন ফিক্সটি যোগ করা হয়েছে (ইমেজ স্ক্রিনে ফিক্স করার জন্য) --- */
img {
	max-width: 100%;
	height: auto;
	display: block;
}

/* --- আপনার বাকি সব আসল কোড হুবহু নিচে রইলো (কিছুই বাদ দেওয়া হয়নি) --- */
.fb-shadow {
	box-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
}

.logo {
	display: flex;
	align-items: center;
	gap: 8px;
	color: #0866FF;
	font-size: 24px;
	font-weight: bold;
}

.react-container {
	position: relative;
	display: inline-block;
	touch-action: manipulation;
	-webkit-tap-highlight-color: transparent;
}

.react-box {
	display: none;
	position: absolute;
	bottom: 34px;
	left: -10px;
	background: white;
	padding: 6px 12px;
	border-radius: 50px;
	box-shadow: 0 4px 15px rgba(0, 0, 0, 0.25);
	z-index: 9999;
	gap: 10px;
	animation: pop 0.2s ease-out;
}

.react-box.react-box-open {
	display: flex !important;
}

.react-box::after {
	content: '';
	position: absolute;
	bottom: -15px;
	left: 0;
	width: 100%;
	height: 16px;
	pointer-events: none;
}

@media (hover: hover) and (pointer: fine) {
	.react-container:hover .react-box {
		display: flex;
	}
}

.react-box span {
	font-size: 26px;
	cursor: pointer;
	transition: transform 0.1s;
	user-select: none;
	-webkit-user-select: none;
	touch-action: manipulation;
}

.react-box span:hover {
	transform: scale(1.4);
}

@keyframes pop {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}
.comment-level-1 {
	margin-left: 0px;
}

.comment-level-2 {
	margin-left: 48px;
	border-left: 2px solid #ddd;
	padding-left: 10px;
}

.comment-level-3 {
	margin-left: 96px;
	border-left: 2px solid #ddd;
	padding-left: 10px;
}

.modal {
	display: none;
	position: fixed;
	inset: 0;
	background: rgba(0, 0, 0, 0.65);
	backdrop-filter: blur(5px);
	-webkit-backdrop-filter: blur(5px);
	z-index: 100000 !important;
	align-items: center;
	justify-content: center;
	padding: 12px;
	overflow-y: auto;
	-webkit-overflow-scrolling: touch;
}

.clickable {
	cursor: pointer;
}

.clickable:hover {
	text-decoration: underline;
}

.media-icon {
	color: #65676b;
	cursor: pointer;
	padding: 8px;
	border-radius: 50%;
	transition: 0.2s;
}

.media-icon:hover {
	background: #e4e6eb;
}

/* === ৩-কলামের লেআউট এবং পোস্ট ফিক্স করার সঠিক কোড === */
/* টপ নেভারকে স্ক্রিনের সাথে ফিট করা */
header, .navbar {
	width: 100% !important;
	max-width: 100% !important;
}

/* পোস্টের ভেতরের ইমেজের অতিরিক্ত স্পেস কমানো */
.post-media-img {
	object-fit: cover !important;
}

/* --- REELS STYLES --- */
.reels-container {
	display: flex;
	gap: 12px;
	overflow-x: auto;
	padding: 10px 0;
	scrollbar-width: none; /* Hide scrollbar for Firefox */
}
.reels-container::-webkit-scrollbar {
	display: none; /* Hide scrollbar for Chrome/Safari */
}
.reel-card {
	min-width: 140px;
	height: 230px;
	border-radius: 15px;
	position: relative;
	overflow: hidden;
	background: #000;
	cursor: pointer;
	flex-shrink: 0;
	transition: 0.3s;
	box-shadow: 0 4px 10px rgba(0,0,0,0.1);
}
.reel-card:hover {
	transform: scale(1.02);
}
.reel-video {
	width: 100%;
	height: 100%;
	object-fit: cover;
	opacity: 0.8;
}
.reel-user {
	position: absolute;
	top: 10px;
	left: 10px;
	z-index: 10;
}
.reel-user img {
	width: 32px;
	height: 32px;
	border-radius: 50%;
	border: 2px solid #0866FF;
}
.reel-info {
	position: absolute;
	bottom: 10px;
	left: 10px;
	color: white;
	font-size: 13px;
	font-weight: 600;
	z-index: 10;
}

@keyframes slideInUp {
    from { opacity: 0; transform: translateY(15px); }
    to { opacity: 1; transform: translateY(0); }
}
.animate-slide-in {
    animation: slideInUp 0.4s ease-out forwards;
}

.custom-scrollbar {
	scrollbar-width: thin;
	scrollbar-color: rgba(71, 85, 105, .62) rgba(255, 255, 255, .25);
}
.custom-scrollbar::-webkit-scrollbar { width: 8px; height: 8px; }
.custom-scrollbar::-webkit-scrollbar-track { background: rgba(255, 255, 255, .25); border-radius: 9999px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: rgba(71, 85, 105, .58); border: 2px solid transparent; background-clip: padding-box; border-radius: 9999px; }
.custom-scrollbar::-webkit-scrollbar-thumb:hover { background-color: #6B7280; }

@media (max-width: 1023px) {
	body {
		padding-bottom: 85px !important;
	}
	main {
		min-width: 0 !important;
		max-width: 100% !important;
	}
	#mobileBottomNav {
		position: fixed !important;
		bottom: 0 !important;
		left: 0 !important;
		right: 0 !important;
		width: 100% !important;
		height: 65px !important;
		z-index: 99999 !important;
		display: flex !important;
		transform: translateZ(0);
		-webkit-transform: translateZ(0);
	}
}
@media (max-width: 640px) {
	header.glass-nav {
		padding-left: 8px !important;
		padding-right: 8px !important;
	}
	header .logo span {
		font-size: 16px !important;
		white-space: nowrap !important;
	}
	header .logo img {
		width: 30px !important;
		height: 30px !important;
	}
	header .language-select-dropdown {
		padding: 4px 6px !important;
		font-size: 11px !important;
		max-width: 88px !important;
	}
	header a[href*="UsersProfileServlet"] span {
		display: none !important;
	}
}
</style>
</head>
<body class="bg-fixed">

	<header class="glass-nav h-[56px] sticky top-0 z-[5000] flex items-center justify-between px-4">
		<!-- LEFT SECTION (Logo and Search) -->
		<div class="flex items-center gap-2 flex-1">
			<div class="logo"
				style="display: flex; align-items: center; gap: 10px;">
				<img src="<%=request.getContextPath()%>/icons/icon-192.png"
					width="40" alt="Logo"> <span
					style="font-weight: bold; font-size: 20px;">Y-ChatApp</span>
			</div>

			<form action="SearchServlet" method="get"
				class="bg-white/50 backdrop-blur-md px-4 py-2 rounded-full hidden md:flex items-center gap-2 ml-4 border border-white/30 focus-within:w-[250px] transition-all duration-300 group">
				<i class="fa fa-search text-gray-400 group-focus-within:text-blue-500"></i> <input
					name="query" placeholder="Search Y-Chat"
					class="bg-transparent outline-none w-[150px] text-sm font-medium">
			</form>
		</div>

		<!-- CENTER SECTION (Navigation Links) -->
		<div
			class="hidden lg:flex flex-1 justify-center gap-12 text-[24px] text-gray-500">
			<a href="UsersPostServlet" title="Home"><i
				class="fa fa-house text-[#0866FF]"></i></a> <a href="GroupsServlet"
				title="Groups" class="text-gray-500 hover:text-blue-500 transition"><i
				class="fa fa-user-group clickable"></i></a> <a href="VideosServlet"
				title="Videos" class="text-gray-500 hover:text-blue-500 transition"><i
				class="fa fa-video clickable"></i></a> <a href="MarketServlet"
				title="Market" class="text-gray-500 hover:text-blue-500 transition"><i
				class="fa fa-shop clickable"></i></a>
		</div>

		<!-- RIGHT SECTION (Actions & Profile) -->
		<div class="flex items-center gap-3 flex-1 justify-end">

			<!-- Language Selector Dropdown -->
			<div class="relative flex items-center">
				<select class="language-select-dropdown bg-gray-200 text-gray-800 font-bold text-xs px-3 py-2 rounded-full cursor-pointer outline-none hover:bg-gray-300 transition shadow-sm border border-gray-300/50" onchange="changeAppLanguage(this.value)">
					<option value="en">English &#x1F1EC;&#x1F1E7;</option>
					<option value="bn">&#x09AC;&#x09BE;&#x0982;&#x09B2;&#x09BE; &#x1F1E7;&#x1F1E9;</option>
					<option value="ja">&#x65E5;&#x672C;&#x8A9E; &#x1F1EF;&#x1F1F5;</option>
					<option value="es">Espa&#xF1;ol &#x1F1EA;&#x1F1F8;</option>
					<option value="fr">Fran&#xE7;ais &#x1F1EB;&#x1F1F7;</option>
					<option value="de">Deutsch &#x1F1E9;&#x1F1EA;</option>
					<option value="zh">&#x4E2D;&#x6587; &#x1F1E8;&#x1F1F3;</option>
					<option value="ar">&#x0627;&#x0644;&#x0639;&#x0631;&#x0628;&#x064A;&#x0629; &#x1F1F8;&#x1F1E6;</option>
				</select>
			</div>
			<!-- Notification Link -->
			<button type="button" onclick="openNotificationPrefs()" title="Notification settings" class="w-9 h-9 rounded-full"><i class="fa fa-sliders"></i></button>
			<a href="NotificationServlet"
				class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center relative clickable hover:bg-gray-300 transition">
				<i class="fa fa-bell text-black"></i>
			</a>

			<!-- Profile Link -->
			<a href="UsersProfileServlet?userId=${sessionScope.userId}"
				class="flex items-center gap-2 p-1 hover:bg-gray-100 rounded-full clickable border border-transparent hover:border-gray-200 transition">
				<img src="img/${not empty ub.getProfile_pic() ? ub.getProfile_pic() : 'default.png'}" onerror="this.src='img/default.png'" class="w-9 h-9 rounded-full border object-cover"
				width="45Px"> <span>${ub.getName()}</span>
			</a>

			<!-- Logout Link -->
			<a href="UsersLogoutServlet" title="Logout"
				class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center hover:bg-red-100 hover:text-red-600 transition">
				<i class="fa fa-right-from-bracket"></i>
			</a>
		</div>
	</header>

	<!-- MOBILE TOP NAVIGATION BAR (Visible on mobile/tablet < 1024px) -->
	<div class="lg:hidden sticky top-[56px] z-[4990] glass-nav border-b border-white/30 px-3 py-2 space-y-2">
		<form action="SearchServlet" method="get"
			class="md:hidden flex items-center gap-2 bg-white/90 backdrop-blur-md px-3.5 py-2 rounded-full border border-gray-200/90 shadow-sm w-full">
			<i class="fa fa-search text-blue-500 text-sm"></i>
			<input name="query" placeholder="Search Y-Chat..."
				class="bg-transparent outline-none flex-1 min-w-0 text-sm font-medium text-gray-800 placeholder-gray-400">
			<button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-3 py-1 rounded-full transition shrink-0">Search</button>
		</form>
		<div class="flex items-center gap-2 overflow-x-auto custom-scrollbar pb-0.5">
			<a href="UsersPostServlet" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-blue-600 text-white text-xs font-bold shadow-sm shrink-0">
				<i class="fa fa-house"></i> <span>Home</span>
			</a>
			<button type="button" onclick="applyAppTheme(getAppTheme() === 'white' ? 'light' : 'white')" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white text-gray-800 text-xs font-bold border border-gray-300 shadow-sm shrink-0">
				<i class="fa fa-circle-half-stroke text-slate-700"></i> <span>White BG</span>
			</button>
			<a href="FriendServlet" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa fa-user-group text-blue-500"></i> <span>Friends</span>
			</a>
			<a href="messages.jsp" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa-brands fa-facebook-messenger text-purple-600"></i> <span>Messenger</span>
			</a>
			<a href="GroupsServlet" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa fa-users text-indigo-500"></i> <span>Groups</span>
			</a>
			<a href="VideosServlet" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa fa-video text-red-500"></i> <span>Videos</span>
			</a>
			<a href="MarketServlet" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa fa-shop text-emerald-500"></i> <span>Marketplace</span>
			</a>
			<button type="button" onclick="openReelModal()" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa fa-clapperboard text-orange-500"></i> <span>Create Reel</span>
			</button>
			<button type="button" onclick="showMemoriesModal()" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa fa-clock text-cyan-500"></i> <span>Memories</span>
			</button>
			<button type="button" onclick="showSavedPostsModal()" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa fa-bookmark text-pink-500"></i> <span>Saved</span>
			</button>
			<a href="aiDashboard" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa fa-wand-magic-sparkles text-purple-600"></i> <span>AI Assistant</span>
			</a>
			<a href="yads" class="flex items-center gap-1.5 px-3.5 py-1.5 rounded-full bg-white/80 hover:bg-white text-gray-700 text-xs font-bold border border-gray-200/80 shadow-sm shrink-0">
				<i class="fa fa-rectangle-ad text-blue-600"></i> <span>Y-Ads</span>
			</a>
		</div>
	</div>


		<!-- GLOBAL PRO UTILITY BANNER (Guaranteed visible on Desktop & Mobile/PWA/APK) -->
	<div id="ychatGlobalProBar" class="ychat-pro-bar">
		<button type="button" onclick="openStreakAndLevelModal()" class="ychat-pro-pill">
			<i class="fa-solid fa-fire text-orange-500" style="color:#f97316;"></i> <span id="ychatStreakText">3d Streak &middot; Lv.3</span>
		</button>
		<button type="button" onclick="openSendGiftModal('Creator', '')" class="ychat-pro-pill">
			<i class="fa-solid fa-coins text-amber-500" style="color:#f59e0b;"></i> <span id="ychatCoinsText">500 Coins &middot; Gift</span>
		</button>
		<button type="button" onclick="openStoryStudioModal()" class="ychat-pro-pill">
			<i class="fa-solid fa-music" style="color:#ec4899;"></i> <span>Story Music &amp; Poll</span>
		</button>
		<button type="button" onclick="openSavedCollectionsModal()" class="ychat-pro-pill">
			<i class="fa-solid fa-folder-open" style="color:#f59e0b;"></i> <span>Saved Folders</span>
		</button>
		<button type="button" onclick="recordAndOpenVisitorsModal()" class="ychat-pro-pill">
			<i class="fa-solid fa-eye" style="color:#06b6d4;"></i> <span>Profile Visitors</span>
		</button>
		<button type="button" onclick="openProfileQrModal()" class="ychat-pro-pill">
			<i class="fa-solid fa-qrcode" style="color:#7c3aed;"></i> <span>My QR Code</span>
		</button>
		<button type="button" onclick="toggleVerifiedBadge()" class="ychat-pro-pill">
			<i class="fa-solid fa-circle-check" style="color:#2563eb;"></i> <span>Verified Badge</span>
		</button>
		<button type="button" onclick="openRingtoneSelectorModal()" class="ychat-pro-pill">
			<i class="fa-solid fa-bell" style="color:#f59e0b;"></i> <span>Ringtones</span>
		</button>
		<button type="button" onclick="triggerInstallApp()" class="ychat-pro-pill">
			<i class="fa-solid fa-download" style="color:#10b981;"></i> <span>Install App</span>
		</button>
	</div>

	<div class="max-w-[1400px] mx-auto grid grid-cols-1 lg:grid-cols-[250px_1fr_280px] xl:grid-cols-[280px_1fr_320px] gap-6 mt-4 px-4">

		<!-- LEFT SIDEBAR -->
		<aside class="hidden lg:block sticky top-[70px] h-[calc(100vh-86px)] max-h-[calc(100vh-86px)] min-h-0 overflow-y-auto overscroll-y-contain custom-scrollbar">
			<div class="glass-card p-4 rounded-3xl space-y-2">
				<div onclick="location.href='UsersProfileServlet?userId=${sessionScope.userId}'"
					class="flex items-center gap-3 p-3 rounded-xl hover:bg-white hover:shadow-[0_10px_20px_rgba(0,0,0,0.1)] hover:-translate-y-1 transition-all duration-300 cursor-pointer group">
					<div class="relative">
						<img src="img/${not empty ub.getProfile_pic() ? ub.getProfile_pic() : 'default.png'}" onerror="this.src='img/default.png'" alt="${ub.getName()}" class="w-10 h-10 rounded-full border-2 border-blue-500 shadow-md object-cover">
						<div class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></div>
					</div>
					<span class="font-bold text-gray-700 group-hover:text-blue-600">${ub.getName()}</span>
				</div>

				<a href="FriendServlet" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-blue-400 to-blue-600 shadow-lg shadow-blue-200">
						<i class="fa fa-user-group text-white"></i>
					</div> <span class="font-bold text-gray-600 group-hover:text-blue-600">Friends</span>
				</a>

				<a href="messages.jsp" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-purple-400 to-purple-600 shadow-lg shadow-purple-200">
						<i class="fa fa-comment-dots text-white"></i>
					</div> <span class="font-bold text-gray-600 group-hover:text-purple-600">Messenger</span>
				</a>

				<div onclick="showMemoriesModal()" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group cursor-pointer">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-cyan-400 to-cyan-600 shadow-lg shadow-cyan-200">
						<i class="fa fa-clock text-white"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-cyan-600">Memories</span>
				</div>

				<div onclick="showSavedPostsModal()" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group cursor-pointer">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-pink-400 to-pink-600 shadow-lg shadow-pink-200">
						<i class="fa fa-bookmark text-white"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-pink-600">Saved</span>
				</div>

				<div onclick="openReelModal()" class="flex items-center gap-4 p-3 rounded-xl bg-orange-50/50 border border-orange-100 hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group cursor-pointer">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-orange-400 to-orange-600 shadow-lg shadow-orange-200">
						<i class="fa fa-clapperboard text-white"></i>
					</div>
					<span class="font-bold text-gray-700 group-hover:text-orange-600">Create Reel</span>
				</div>


				<a href="aiDashboard" class="flex items-center gap-4 p-3 rounded-xl bg-purple-50/50 border border-purple-100 hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-violet-500 to-purple-700 shadow-lg shadow-purple-200">
						<i class="fa fa-wand-magic-sparkles text-white"></i>
					</div>
					<span class="font-bold text-gray-700 group-hover:text-purple-600" data-i18n="ai_assistant">AI Assistant</span>
				</a>

				<a href="yads" class="flex items-center gap-4 p-3 rounded-xl bg-blue-50/50 border border-blue-100 hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 to-indigo-700 shadow-lg shadow-blue-200">
						<i class="fa fa-rectangle-ad text-white"></i>
					</div>
					<span class="font-bold text-gray-700 group-hover:text-blue-600" data-i18n="ads_manager">Y-Ads Manager</span>
				</a>

				<button type="button" onclick="openSecurityModal()" class="w-full flex items-center gap-4 p-3 rounded-xl bg-emerald-50/50 border border-emerald-100 hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group text-left">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-emerald-500 to-teal-600 shadow-lg shadow-emerald-200 shrink-0">
						<i class="fa fa-shield-halved text-white"></i>
					</div>
					<span class="font-bold text-gray-700 group-hover:text-emerald-700">Security &amp; Privacy</span>
				</button>

				<button type="button" onclick="openCreatorStatsModal()" class="w-full flex items-center gap-4 p-3 rounded-xl bg-amber-50/50 border border-amber-100 hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group text-left">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-amber-400 to-orange-500 shadow-lg shadow-amber-200 shrink-0">
						<i class="fa fa-coins text-white"></i>
					</div>
					<span class="font-bold text-gray-700 group-hover:text-orange-700">Creator Tips &amp; Perks</span>
				</button>

				<hr class="my-4 border-white/20">
				<p class="px-4 text-xs font-bold text-gray-400 uppercase tracking-widest mb-2" data-i18n="shortcuts">Shortcuts</p>

				<!-- Amazon -->
				<a href="https://www.amazon.com" target="_blank" rel="noopener noreferrer" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-amber-400 to-amber-600 shadow-lg shadow-amber-200">
						<i class="fa-brands fa-amazon text-white text-lg"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-amber-600">Amazon</span>
				</a>

				<!-- YouTube -->
				<a href="https://www.youtube.com" target="_blank" rel="noopener noreferrer" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-red-500 to-red-700 shadow-lg shadow-red-200">
						<i class="fa-brands fa-youtube text-white text-lg"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-red-600">YouTube</span>
				</a>

				<!-- Rakuten -->
				<a href="https://www.rakuten.co.jp" target="_blank" rel="noopener noreferrer" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-rose-500 to-rose-700 shadow-lg shadow-rose-200">
						<i class="fa-solid fa-bag-shopping text-white text-lg"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-rose-600">Rakuten</span>
				</a>

				<!-- Google -->
				<a href="https://www.google.com" target="_blank" rel="noopener noreferrer" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-blue-500 via-green-500 to-yellow-500 shadow-lg shadow-blue-200">
						<i class="fa-brands fa-google text-white text-lg"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-blue-600">Google</span>
				</a>

				<!-- Facebook / Meta -->
				<a href="https://www.facebook.com" target="_blank" rel="noopener noreferrer" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-blue-600 to-blue-800 shadow-lg shadow-blue-300">
						<i class="fa-brands fa-facebook text-white text-lg"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-blue-700">Facebook</span>
				</a>

				<!-- Instagram -->
				<a href="https://www.instagram.com" target="_blank" rel="noopener noreferrer" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-yellow-400 via-pink-500 to-purple-600 shadow-lg shadow-pink-200">
						<i class="fa-brands fa-instagram text-white text-lg"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-pink-600">Instagram</span>
				</a>

				<!-- Twitter / X -->
				<a href="https://x.com" target="_blank" rel="noopener noreferrer" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-gray-700 to-black shadow-lg shadow-gray-300">
						<i class="fa-brands fa-x-twitter text-white text-lg"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-gray-900">X (Twitter)</span>
				</a>

				<!-- TikTok -->
				<a href="https://www.tiktok.com" target="_blank" rel="noopener noreferrer" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-gray-900 via-cyan-500 to-pink-500 shadow-lg shadow-cyan-200">
						<i class="fa-brands fa-tiktok text-white text-lg"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-cyan-600">TikTok</span>
				</a>

				<!-- Groups -->
				<a href="GroupsServlet" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-indigo-400 to-indigo-600 shadow-lg shadow-indigo-200">
						<i class="fa fa-users text-white"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-indigo-600" data-i18n="groups">Groups</span>
				</a>

				<!-- Watch & Videos -->
				<a href="VideosServlet" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-red-400 to-red-600 shadow-lg shadow-red-200">
						<i class="fa fa-tv text-white"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-red-600" data-i18n="short_videos">Watch & Videos</span>
				</a>

				<!-- Marketplace -->
				<a href="MarketServlet" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-emerald-400 to-emerald-600 shadow-lg shadow-emerald-200">
						<i class="fa fa-store text-white"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-emerald-600" data-i18n="marketplace">Marketplace</span>
				</a>

				<!-- Privacy & Policy -->
				<a href="PolicyServlet" class="flex items-center gap-4 p-3 rounded-xl hover:bg-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 group">
					<div class="w-10 h-10 flex items-center justify-center rounded-xl bg-gradient-to-br from-slate-500 to-slate-700 shadow-lg shadow-slate-200">
						<i class="fa fa-shield-halved text-white"></i>
					</div>
					<span class="font-bold text-gray-600 group-hover:text-slate-700">Privacy & Policy</span>
				</a>
			</div>
		</aside>

		<!-- MAIN FEED -->
		<main class="space-y-6 min-w-0 max-w-full">
			<!-- STORIES SECTION -->
			<div class="flex gap-3 overflow-x-auto pb-2 custom-scrollbar">
				<!-- Create Story Card -->
				<div onclick="openStoryModal()" class="w-[120px] h-[190px] min-w-[120px] rounded-2xl glass-card relative overflow-hidden flex flex-col group cursor-pointer border border-white/30 shadow-md">
					<div class="h-[130px] overflow-hidden bg-gray-200">
						<img src="img/${not empty ub.getProfile_pic() ? ub.getProfile_pic() : 'default.png'}" alt="${ub.getName()}" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500" onerror="this.src='img/default.png'">
					</div>
					<div class="flex-1 bg-white relative flex flex-col items-center justify-end pb-3 pt-4">
						<div class="absolute -top-5 left-1/2 -translate-x-1/2 w-10 h-10 rounded-full bg-blue-600 border-4 border-white flex items-center justify-center shadow-md">
							<i class="fa fa-plus text-white text-sm"></i>
						</div>
						<span class="text-[11px] font-bold text-gray-700">Create Story</span>
					</div>
				</div>

				<!-- Story Cards -->
				<c:forEach var="story" items="${storyList}">
					<div onclick="handleStoryClick(this)" 
					     data-name="<c:out value='${story.getName()}' />"
					     data-pic="<c:out value='${not empty story.getProfilePic() ? story.getProfilePic() : \"default.png\"}' />"
					     data-media="<c:out value='${story.getMediaUrl()}' />"
					     data-text="<c:out value='${story.getText()}' />"
					     class="w-[120px] h-[190px] min-w-[120px] rounded-2xl relative overflow-hidden cursor-pointer shadow-md group border border-white/20 select-none">
						<c:choose>
							<c:when test="${not empty story.getMediaUrl()}">
								<c:set var="mUrl" value="${story.getMediaUrl().toLowerCase()}" />
								<c:choose>
									<c:when test="${mUrl.endsWith('.mp4') || mUrl.endsWith('.webm') || mUrl.endsWith('.mov')}">
										<video src="img/${story.getMediaUrl()}#t=0.1" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" muted playsinline preload="metadata"></video>
										<div class="absolute inset-0 flex items-center justify-center pointer-events-none">
											<div class="w-7 h-7 rounded-full bg-black/50 backdrop-blur-sm flex items-center justify-center text-white text-xs shadow">
												<i class="fa fa-play text-[10px] ml-0.5"></i>
											</div>
										</div>
									</c:when>
									<c:otherwise>
										<img src="img/${story.getMediaUrl()}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" onerror="this.src='img/default.png'">
									</c:otherwise>
								</c:choose>
								<div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent"></div>
							</c:when>
							<c:otherwise>
								<!-- Text Story default gradient background -->
								<div class="w-full h-full bg-gradient-to-br from-indigo-500 via-purple-500 to-pink-500 flex items-center justify-center p-3 text-center">
									<p class="text-white text-xs font-bold leading-tight line-clamp-4"><c:out value="${story.getText()}" /></p>
								</div>
							</c:otherwise>
						</c:choose>
						<!-- User avatar top left -->
						<div class="absolute top-2 left-2 w-8 h-8 rounded-full border-2 border-blue-500 overflow-hidden shadow-md bg-white">
							<img src="img/${not empty story.getProfilePic() ? story.getProfilePic() : 'default.png'}" class="w-full h-full object-cover" onerror="this.src='img/default.png'">
						</div>
						<!-- User Name bottom left -->
						<div class="absolute bottom-2 left-2 right-2">
							<p class="text-[11px] font-bold text-white truncate shadow-sm"><c:out value="${story.getName()}" /></p>
						</div>
					</div>
				</c:forEach>
			</div>

			<!-- REELS SECTION -->
			<div class="flex gap-3 overflow-x-auto py-2 custom-scrollbar">
				<div onclick="openReelModal()" class="w-[130px] min-w-[130px] max-w-[130px] h-[200px] rounded-2xl glass-card flex flex-col items-center justify-center border-2 border-dashed border-white/50 group cursor-pointer flex-shrink-0 shadow-md hover:scale-102 transition">
					<div class="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center mb-2 shadow-lg group-hover:scale-110 transition-transform">
						<i class="fa fa-plus text-white text-xl"></i>
					</div>
					<span class="text-gray-800 font-extrabold text-[11px] uppercase tracking-wider">Create Reel</span>
				</div>

				<c:forEach var="reel" items="${reelsList}">
					<div onclick="openReelViewer(${reel.getId()})" data-reel-id="${reel.getId()}" class="w-[130px] min-w-[130px] max-w-[130px] h-[200px] rounded-2xl relative overflow-hidden bg-black cursor-pointer shadow-md flex-shrink-0 group hover:scale-102 transition">
						<video class="w-full h-full object-cover opacity-80">
							<source src="img/${reel.getFile_name()}" type="video/mp4">
						</video>
						<div class="absolute top-2.5 left-2.5 z-10 w-8 h-8 rounded-full border-2 border-blue-500 overflow-hidden shadow">
							<img src="img/${not empty reel.getProfile_pic() ? reel.getProfile_pic() : 'default.png'}" alt="user" class="reel-owner-pic w-full h-full object-cover" onerror="this.src='img/default.png'">
						</div>
						<div class="reel-owner-name absolute bottom-2 left-2 right-2 text-white text-xs font-semibold truncate z-10">${reel.getName()}</div>
					</div>
				</c:forEach>
			</div>

			<!-- POST BOX -->
			<div class="glass-card p-5 rounded-3xl">
				<div class="flex gap-4">
					<a href="UsersProfileServlet?userId=${sessionScope.userId}" class="group relative"> 
                        <img src="img/${not empty ub.getProfile_pic() ? ub.getProfile_pic() : 'default.png'}" onerror="this.src='img/default.png'" alt="${ub.getName()}" class="w-12 h-12 rounded-2xl object-cover ring-2 ring-white shadow-md group-hover:scale-105 transition-transform">
                        <div class="absolute -bottom-1 -right-1 w-4 h-4 bg-green-500 border-2 border-white rounded-full"></div>
					</a>
					<button type="button" onclick="openModal()"
						class="flex-1 bg-white/40 hover:bg-white/60 backdrop-blur-md rounded-2xl text-left px-6 text-gray-600 text-[16px] font-medium transition-all border border-white/20 cursor-pointer" style="touch-action:manipulation;-webkit-tap-highlight-color:transparent;">
						What's on your mind, ${ub.getName()}?</button>
				</div>
				<div class="border-t border-white/20 mt-4 pt-3 flex justify-around">
					<button type="button" onclick="openLiveModal()"
						class="flex items-center gap-2 py-2 px-4 sm:px-6 hover:bg-red-500/10 rounded-xl transition-all clickable text-red-500 font-semibold cursor-pointer border-none bg-transparent" style="touch-action:manipulation;-webkit-tap-highlight-color:transparent;">
						<i class="fa fa-video text-lg"></i> Live
					</button>
					<button type="button" onclick="openModal(); setTimeout(function(){ var f=document.getElementById('modalFileInput'); if(f) f.click(); }, 150);"
						class="flex items-center gap-2 py-2 px-4 sm:px-6 hover:bg-green-500/10 rounded-xl transition-all clickable text-green-500 font-semibold cursor-pointer border-none bg-transparent" style="touch-action:manipulation;-webkit-tap-highlight-color:transparent;">
						<i class="fa fa-image text-lg"></i> Photo
					</button>
					<button type="button" onclick="openModal()"
						class="flex items-center gap-2 py-2 px-4 sm:px-6 hover:bg-yellow-500/10 rounded-xl transition-all clickable text-yellow-500 font-semibold cursor-pointer border-none bg-transparent" style="touch-action:manipulation;-webkit-tap-highlight-color:transparent;">
						<i class="fa fa-face-smile text-lg"></i> Feeling
					</button>
				</div>
			</div>

			<!-- MOBILE PEOPLE YOU MAY KNOW & CONTACTS SECTION (Visible on mobile/tablet < 1024px) -->
			<div class="lg:hidden space-y-4">
				<c:if test="${not empty suggestedFriends}">
					<div class="glass-card p-4 rounded-3xl">
						<div class="flex items-center justify-between mb-3">
							<h3 class="text-xs font-bold text-gray-600 uppercase tracking-wider flex items-center gap-2">
								<i class="fa fa-user-plus text-blue-500"></i> People You May Know
							</h3>
							<a href="FriendServlet" class="text-xs font-bold text-blue-600 hover:underline">See All</a>
						</div>
						<div class="flex gap-3 overflow-x-auto pb-2 custom-scrollbar">
							<c:forEach var="sug" items="${suggestedFriends}">
								<div class="min-w-[145px] max-w-[145px] bg-white/70 border border-gray-200/80 rounded-2xl p-3 flex flex-col items-center text-center shadow-sm shrink-0">
									<a href="UsersProfileServlet?userId=${sug.getId()}" class="flex flex-col items-center w-full">
										<img src="img/${not empty sug.getProfile_pic() ? sug.getProfile_pic() : 'default.png'}" class="w-14 h-14 rounded-full object-cover border-2 border-blue-500/40 mb-2 shadow-sm" onerror="this.src='img/default.png'">
										<p class="text-xs font-bold text-gray-800 truncate w-full">${sug.getName()}</p>
										<p class="text-[10px] text-gray-400 truncate w-full mb-2">${not empty sug.getCity() ? sug.getCity() : (not empty sug.getCountry() ? sug.getCountry() : 'Member')}</p>
									</a>
									<button onclick="addFriendFromSidebar(${sug.getId()}, this)" class="w-full py-1.5 bg-blue-500 hover:bg-blue-600 text-white text-xs font-bold rounded-xl shadow-sm transition flex items-center justify-center gap-1">
										<i class="fa fa-user-plus text-[10px]"></i> Add
									</button>
								</div>
							</c:forEach>
						</div>
					</div>
				</c:if>

				<div class="glass-card p-4 rounded-3xl">
					<div class="flex items-center justify-between mb-3">
						<h3 class="text-xs font-bold text-gray-600 uppercase tracking-wider flex items-center gap-2">
							<i class="fa-brands fa-facebook-messenger text-purple-600"></i> Contacts &amp; Friends
						</h3>
						<a href="messages.jsp" class="text-xs font-bold text-blue-600 hover:underline">Open Messenger</a>
					</div>
					<div class="flex gap-3 overflow-x-auto pb-1 custom-scrollbar">
						<c:forEach var="friend" items="${friendList}">
							<div onclick="location.href='messages.jsp?userName=${friend.getName()}'" class="flex flex-col items-center gap-1 min-w-[68px] max-w-[68px] cursor-pointer group shrink-0">
								<div class="relative w-12 h-12">
									<img src="img/${not empty friend.getProfile_pic() ? friend.getProfile_pic() : 'default.png'}" class="w-12 h-12 rounded-2xl object-cover border border-gray-200 shadow-sm" onerror="this.src='img/default.png'">
									<div data-contact-username="${friend.getName()}" class="contact-status-dot absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 bg-green-500 border-2 border-white rounded-full"></div>
								</div>
								<span class="text-[11px] font-semibold text-gray-700 truncate w-full text-center">${friend.getName()}</span>
							</div>
						</c:forEach>
						<c:if test="${empty friendList}">
							<a href="FriendServlet" class="text-xs text-blue-600 font-semibold py-2">Find Friends &rarr;</a>
						</c:if>
					</div>
				</div>
			</div>

			<div class="flex items-center justify-between glass-card rounded-2xl px-4 py-3 mb-4">
				<strong class="text-sm text-gray-700">Feed</strong>
				<form method="get" action="UsersPostServlet" class="flex items-center gap-2">
					<c:if test="${not empty filterTag}"><input type="hidden" name="tag" value="${filterTag}"></c:if>
					<label for="feedSort" class="text-xs font-semibold text-gray-500">Sort</label>
					<select id="feedSort" name="sort" onchange="this.form.submit()" class="rounded-lg border border-gray-200 bg-white px-3 py-2 text-xs font-bold text-gray-700">
						<option value="recent" ${feedSort != 'popular' ? 'selected' : ''}>Recent</option>
						<option value="popular" ${feedSort == 'popular' ? 'selected' : ''}>Popular</option>
					</select>
				</form>
			</div>

			<!-- POSTS LIST -->
			<c:forEach var="post" items="${postList}">
				<div class="glass-card rounded-3xl p-6 mb-6 md:hover:shadow-xl transition-shadow duration-300 group/post" data-post-id="${post.getId()}">
					<div class="flex justify-between">
						<div class="flex gap-3">
							<img onclick="location.href='UsersProfileServlet?userId=${post.getUserId()}'"
								src="img/${not empty post.getProfile_pic() ? post.getProfile_pic() : 'default.png'}" onerror="this.src='img/default.png'" class="w-10 h-10 rounded-full clickable object-cover" width="30Px">
							<div>
								<a href="UsersProfileServlet?userId=${post.getUserId()}" class="font-bold clickable group-hover/post:text-blue-600 transition-colors">${post.getName()}</a>
								<c:if test="${not empty post.getFeeling()}">
									<span class="text-gray-500 text-[14px]"> is feeling <span class="font-bold text-gray-700">${post.getFeeling()}</span></span>
								</c:if>
								<div class="text-[12px] text-gray-500 flex items-center gap-1">
									<span class="time-ago" data-time="${post.getTime()}">${post.getTime()}</span> • <i class="fa fa-earth-americas"></i>
								</div>
							</div>
						</div>
						<div class="relative">
	<button type="button" onclick="togglePostMenu(event, ${post.getId()})" aria-label="Post options" aria-expanded="false" aria-controls="post-menu-${post.getId()}" class="p-2 hover:bg-gray-100 rounded-full transition-colors"><i class="fa fa-ellipsis-h text-gray-500"></i></button>
	<div id="post-menu-${post.getId()}" class="hidden absolute right-0 top-10 bg-white border shadow-lg rounded-xl z-50 min-w-[190px] overflow-hidden">
		<div onclick="toggleSavePost(${post.getId()}, this)" class="px-4 py-3 hover:bg-blue-50 text-blue-600 cursor-pointer font-bold transition flex items-center gap-2">
			<i class="fa fa-bookmark"></i> Save Post
		</div>
		<div onclick="hidePost(${post.getId()})" class="px-4 py-3 hover:bg-slate-50 text-slate-700 cursor-pointer font-bold transition flex items-center gap-2">
			<i class="fa fa-eye-slash"></i> Hide Post
		</div>
		<div onclick="markNotInterested(${post.getId()})" class="px-4 py-3 hover:bg-amber-50 text-amber-700 cursor-pointer font-bold transition flex items-center gap-2">
			<i class="fa fa-thumbs-down"></i> Not interested
		</div>
		<div onclick="snoozePost(${post.getId()}, 7)" class="px-4 py-3 hover:bg-indigo-50 text-indigo-700 cursor-pointer font-bold transition flex items-center gap-2">
			<i class="fa fa-clock"></i> Snooze for 7 days
		</div>
		<c:if test="${post.getUserId() == sessionScope.ub.getId()}">
			<div onclick="deletePost(${post.getId()})" class="px-4 py-3 hover:bg-red-50 text-red-600 cursor-pointer font-bold transition flex items-center gap-2">
				<i class="fa fa-trash"></i> Delete Post
			</div>
		</c:if>
		<c:if test="${post.getUserId() != sessionScope.ub.getId()}">
			<div onclick="reportPost(${post.getId()})" class="px-4 py-3 hover:bg-amber-50 text-amber-700 cursor-pointer font-bold transition flex items-center gap-2">
				<i class="fa fa-flag"></i> Report Post
			</div>
		</c:if>
	</div>
</div>
					</div>

					<!-- Post Content -->
					<div class="mt-4">
						<p class="text-gray-800 leading-relaxed">${fn:escapeXml(post.getContent())}</p>
						<c:if test="${not empty post.getFile_name()}">
							<div class="mt-4 rounded-2xl overflow-hidden border border-white/20 shadow-lg bg-gray-100/30">
								<c:choose>
									<c:when test="${post.getPost_type() == 'video' || post.getFile_name().toLowerCase().endsWith('.webm') || post.getFile_name().toLowerCase().endsWith('.mp4')}">
										<video src="img/${post.getFile_name()}" controls class="w-full max-h-[500px] object-contain bg-black"></video>
									</c:when>
									<c:otherwise>
										<img src="img/${post.getFile_name()}" onerror="this.onerror=null;this.parentElement.style.display='none';" class="w-full max-h-[500px] object-cover md:hover:scale-[1.01] transition-transform duration-700">
									</c:otherwise>
								</c:choose>
							</div>
						</c:if>
					</div>

					<c:if test="${not empty post.getPollQuestion() and not empty post.getPollOptions()}"><div id="poll-${post.getId()}" data-question="${fn:escapeXml(post.getPollQuestion())}" class="mt-4 p-4 rounded-2xl bg-white/60 border border-indigo-100"><h3 class="font-bold text-gray-800 mb-3">${fn:escapeXml(post.getPollQuestion())}</h3><c:forEach var="option" items="${post.getPollOptions()}"><div class="mb-2"><c:choose><c:when test="${option.isVotedByCurrentUser()}"><div class="relative overflow-hidden rounded-xl border border-indigo-100 bg-white"><div class="absolute inset-y-0 left-0 bg-indigo-100" style="width:${option.getPercentage()}%"></div><div class="relative flex justify-between px-3 py-2 text-sm"><span>${fn:escapeXml(option.getOptionText())}</span><span class="font-bold">${option.getPercentage()}% · ${option.getVoteCount()}</span></div></div></c:when><c:otherwise><button type="button" onclick="submitPollVote(${post.getId()},${option.getId()},this)" class="w-full flex justify-between px-3 py-2 rounded-xl border border-indigo-200 bg-white hover:bg-indigo-50 text-sm text-left"><span>${fn:escapeXml(option.getOptionText())}</span><span class="text-gray-500">${option.getVoteCount()} votes</span></button></c:otherwise></c:choose></div></c:forEach><p class="text-xs text-gray-500 mt-2">Choose one option</p></div></c:if>
					<!-- Stats Section -->
					<div class="flex items-center justify-between mt-4 py-3 border-y border-white/10">
						<div class="flex items-center gap-1.5 text-gray-500 text-sm">
							<span id="react-count-${post.getId()}" class="font-bold ml-1">
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
						<div class="flex gap-4 text-gray-500 text-sm font-bold">
							<c:if test="${post.getUserId() == sessionScope.ub.getId()}"><button type="button" onclick="showPostInsights(${post.getId()})" title="See unique viewers today" class="text-xs text-blue-600 hover:underline">${post.getViewCount()} views · Insights</button></c:if>
							<span id="post-comment-count-text-${post.getId()}" class="hover:underline cursor-pointer" onclick="focusCmt(${post.getId()})">${post.getCommentCount()} Comments</span>
							<span id="post-share-count-text-${post.getId()}" class="hover:underline cursor-pointer" onclick="shareAJAX(${post.getId()})">${post.getShareCount()} Shares</span>
						</div>
					</div>

					<!-- Action Buttons -->
					<div class="flex justify-around py-1.5 border-t border-gray-100/60 mt-1">
						<div class="react-container flex-1 relative">
							<button type="button" id="post-action-btn-${post.getId()}" onclick="handleAJAXReact(${post.getId()}, 'Like', 'post', event)" class="w-full flex items-center justify-center gap-2 py-2 rounded-xl hover:bg-white/50 active:opacity-70 transition-opacity cursor-pointer font-bold text-gray-600 bg-transparent border-0" style="touch-action: manipulation; -webkit-tap-highlight-color: transparent;">
								<span id="post-action-btn-content-${post.getId()}" class="flex items-center justify-center gap-2 pointer-events-none">
									<i class="fa-regular fa-thumbs-up"></i> Like
								</span>
							</button>
							<div class="react-box glass-card !p-2 !rounded-full">
								<span title="Like" class="hover:scale-125 transition cursor-pointer select-none" onclick="handleAJAXReact(${post.getId()}, 'Like', 'post', event)">👍</span>
								<span title="Love" class="hover:scale-125 transition cursor-pointer select-none" onclick="handleAJAXReact(${post.getId()}, 'Love', 'post', event)">❤️</span>
								<span title="Care" class="hover:scale-125 transition cursor-pointer select-none" onclick="handleAJAXReact(${post.getId()}, 'Care', 'post', event)">🥰</span>
								<span title="Haha" class="hover:scale-125 transition cursor-pointer select-none" onclick="handleAJAXReact(${post.getId()}, 'Haha', 'post', event)">😆</span>
								<span title="Wow" class="hover:scale-125 transition cursor-pointer select-none" onclick="handleAJAXReact(${post.getId()}, 'Wow', 'post', event)">😮</span>
								<span title="Sad" class="hover:scale-125 transition cursor-pointer select-none" onclick="handleAJAXReact(${post.getId()}, 'Sad', 'post', event)">😢</span>
								<span title="Angry" class="hover:scale-125 transition cursor-pointer select-none" onclick="handleAJAXReact(${post.getId()}, 'Angry', 'post', event)">😡</span>
								<span title="Dislike" class="hover:scale-125 transition cursor-pointer select-none" onclick="handleAJAXReact(${post.getId()}, 'Dislike', 'post', event)">👎</span>
							</div>
						</div>
						<button type="button" onclick="focusCmt(${post.getId()})" class="flex-1 flex items-center justify-center gap-2 py-2 rounded-xl hover:bg-white/50 active:opacity-70 transition-opacity cursor-pointer font-bold text-gray-600 bg-transparent border-0" style="touch-action: manipulation; -webkit-tap-highlight-color: transparent;">
							<i class="fa-regular fa-comment"></i> Comment
						</button>
						<button type="button" onclick="shareAJAX(${post.getId()})" class="flex-1 flex items-center justify-center gap-2 py-2 rounded-xl hover:bg-white/50 active:opacity-70 transition-opacity cursor-pointer font-bold text-gray-600 bg-transparent border-0" style="touch-action: manipulation; -webkit-tap-highlight-color: transparent;">
							<i class="fa-solid fa-share"></i> Share
						</button>
					</div>

					<!-- Comment Section -->
					<div id="comment-section-${post.getId()}" class="mt-4 pt-4 border-t border-white/10">
						<div id="comment-list-${post.getId()}" class="space-y-4 mb-4">
							<c:forEach var="cmt" items="${post.getComments()}">
								<div class="flex flex-col gap-2 group/cmt mb-4">
									<div class="flex gap-2">
										<img src="img/${not empty cmt.getProfilePic() ? cmt.getProfilePic() : 'default.png'}" onerror="this.src='img/default.png'" class="w-8 h-8 rounded-full border shadow-sm cursor-pointer object-cover" onclick="location.href='UsersProfileServlet?userId=${cmt.getUserId()}'">
										<div class="flex flex-col flex-1">
											<div class="bg-white/50 px-4 py-2 rounded-2xl shadow-sm inline-block max-w-fit">
												<p class="font-bold text-[13px] hover:underline cursor-pointer" onclick="location.href='UsersProfileServlet?userId=${cmt.getUserId()}'">${cmt.getName()}</p>
												<p class="text-[14px] text-gray-700">${cmt.getComment_text()}</p>
												<c:if test="${not empty cmt.getFile_name()}">
													<img src="img/${cmt.getFile_name()}" class="mt-2 rounded-xl max-h-40 border shadow-sm">
												</c:if>
											</div>
											<div class="flex gap-4 ml-4 mt-1 text-[11px] font-bold text-gray-500 items-center">
												<div class="react-container clickable">
													<span class="hover:text-blue-600 transition" onclick="handleAJAXReact(${cmt.getId()}, 'Like', 'comment', event)">Like</span>
													<div class="react-box !p-1 !rounded-full">
														<span title="Like" onclick="handleAJAXReact(${cmt.getId()}, 'Like', 'comment', event)">👍</span>
														<span title="Love" onclick="handleAJAXReact(${cmt.getId()}, 'Love', 'comment', event)">❤️</span>
														<span title="Care" onclick="handleAJAXReact(${cmt.getId()}, 'Care', 'comment', event)">🥰</span>
														<span title="Haha" onclick="handleAJAXReact(${cmt.getId()}, 'Haha', 'comment', event)">😆</span>
														<span title="Wow" onclick="handleAJAXReact(${cmt.getId()}, 'Wow', 'comment', event)">😮</span>
														<span title="Sad" onclick="handleAJAXReact(${cmt.getId()}, 'Sad', 'comment', event)">😢</span>
														<span title="Angry" onclick="handleAJAXReact(${cmt.getId()}, 'Angry', 'comment', event)">😡</span>
														<span title="Dislike" onclick="handleAJAXReact(${cmt.getId()}, 'Dislike', 'comment', event)">👎</span>
													</div>
												</div>
												<span class="clickable hover:text-blue-600 transition" onclick="showReplyBox(${cmt.getId()}, '${cmt.getName()}')">Reply</span>
												<span class="clickable hover:text-blue-600 transition" onclick="shareCommentOrReply(this)">Share</span>
												<div id="comment-react-container-${cmt.getId()}" class="text-[10px] font-normal text-gray-400">
													<c:set var="tc" value="${cmt.getLikeCount() + cmt.getLoveCount() + cmt.getCareCount() + cmt.getHahaCount() + cmt.getWowCount() + cmt.getSadCount() + cmt.getAngryCount() + cmt.getDislikes()}"/>
													<c:if test="${tc > 0}">
														<c:if test="${cmt.getLikeCount() > 0}">👍 <span class="text-gray-600">${cmt.getLikeCount()}</span>&nbsp;&nbsp;</c:if>
														<c:if test="${cmt.getLoveCount() > 0}">❤️ <span class="text-gray-600">${cmt.getLoveCount()}</span>&nbsp;&nbsp;</c:if>
														<c:if test="${cmt.getCareCount() > 0}">🥰 <span class="text-gray-600">${cmt.getCareCount()}</span>&nbsp;&nbsp;</c:if>
														<c:if test="${cmt.getHahaCount() > 0}">😆 <span class="text-gray-600">${cmt.getHahaCount()}</span>&nbsp;&nbsp;</c:if>
														<c:if test="${cmt.getWowCount() > 0}">😮 <span class="text-gray-600">${cmt.getWowCount()}</span>&nbsp;&nbsp;</c:if>
														<c:if test="${cmt.getSadCount() > 0}">😢 <span class="text-gray-600">${cmt.getSadCount()}</span>&nbsp;&nbsp;</c:if>
														<c:if test="${cmt.getAngryCount() > 0}">😡 <span class="text-gray-600">${cmt.getAngryCount()}</span>&nbsp;&nbsp;</c:if>
														<c:if test="${cmt.getDislikes() > 0}">👎 <span class="text-gray-600">${cmt.getDislikes()}</span>&nbsp;&nbsp;</c:if>
													</c:if>
												</div>
											</div>

											<!-- Reply List -->
											<div id="reply-list-${cmt.getId()}" class="mt-2 space-y-2 ml-10">
												<c:forEach var="reply" items="${cmt.getReplies()}">
													<div class="comment-level-2 mb-2 flex gap-2">
														<a href="UsersProfileServlet?userId=${reply.getUserId()}">
															<img src="img/${not empty reply.getProfilePic() ? reply.getProfilePic() : 'default.png'}" onerror="this.src='img/default.png'" class="w-7 h-7 rounded-full border shadow-sm object-cover">
														</a>
														<div class="flex flex-col flex-1">
															<div class="bg-white/40 px-3 py-1.5 rounded-2xl inline-block max-w-fit shadow-sm">
																<p class="font-bold text-[12px]"><a href="UsersProfileServlet?userId=${reply.getUserId()}" class="hover:underline">${reply.getName()}</a></p>
																<p class="text-[13px] text-gray-700">${reply.getText()}</p>
																<c:if test="${not empty reply.getMedia()}">
																	<img src="img/${reply.getMedia()}" class="mt-1 rounded-lg max-h-32 border shadow-sm">
																</c:if>
															</div>
															<div class="flex gap-4 ml-3 mt-0.5 text-[10px] font-bold text-gray-500 items-center">
																<div class="react-container clickable">
																	<span class="hover:text-blue-600 transition" onclick="handleAJAXReact(${reply.getId()}, 'Like', 'reply', event)">Like</span>
																	<div class="react-box !p-1 !rounded-full">
																		<span title="Like" onclick="handleAJAXReact(${reply.getId()}, 'Like', 'reply', event)">👍</span>
																		<span title="Love" onclick="handleAJAXReact(${reply.getId()}, 'Love', 'reply', event)">❤️</span>
																		<span title="Care" onclick="handleAJAXReact(${reply.getId()}, 'Care', 'reply', event)">🥰</span>
																		<span title="Haha" onclick="handleAJAXReact(${reply.getId()}, 'Haha', 'reply', event)">😆</span>
																		<span title="Wow" onclick="handleAJAXReact(${reply.getId()}, 'Wow', 'reply', event)">😮</span>
																		<span title="Sad" onclick="handleAJAXReact(${reply.getId()}, 'Sad', 'reply', event)">😢</span>
																		<span title="Angry" onclick="handleAJAXReact(${reply.getId()}, 'Angry', 'reply', event)">😡</span>
																		<span title="Dislike" onclick="handleAJAXReact(${reply.getId()}, 'Dislike', 'reply', event)">👎</span>
																	</div>
																</div>
																<span class="clickable hover:text-blue-600 transition" onclick="showReplyBox(${cmt.getId()}, '${reply.getName()}')">Reply</span>
																<span class="clickable hover:text-blue-600 transition" onclick="shareCommentOrReply(this)">Share</span>
																<div id="reply-react-container-${reply.getId()}" class="text-[9px] font-normal text-gray-400">
																	<c:set var="trc" value="${reply.getLikeCount() + reply.getLoveCount() + reply.getCareCount() + reply.getHahaCount() + reply.getWowCount() + reply.getSadCount() + reply.getAngryCount() + reply.getDislikes()}"/>
																	<c:if test="${trc > 0}">
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
													</div>
												</c:forEach>
											</div>

											<!-- Reply Input Box -->
											<div id="replyInputContainer-${cmt.getId()}" class="hidden mt-2 ml-10 relative">
												<div class="flex gap-2">
													<img src="img/${not empty ub.getProfile_pic() ? ub.getProfile_pic() : 'default.png'}" onerror="this.src='img/default.png'" class="w-7 h-7 rounded-full border shadow-sm object-cover" width="28px">
													<div class="flex-1 bg-white/40 backdrop-blur-sm rounded-2xl px-3 py-1.5 flex items-center border border-white/20">
														<input type="text" id="input-reply-${cmt.getId()}" placeholder="Write a reply..." class="bg-transparent outline-none flex-1 text-[12px] font-medium"
															onkeydown="if(event.key === 'Enter') submitReplyAJAX('${cmt.getId()}')">
														<i class="fa-regular fa-face-smile text-yellow-500 cursor-pointer mx-2" onclick="toggleEmojiPicker('emoji-picker-reply-${cmt.getId()}')"></i>
                                                        <label for="replyMedia-${cmt.getId()}" class="cursor-pointer mx-2 text-gray-500 hover:text-blue-600 transition">
                                                            <i class="fa-solid fa-camera"></i>
                                                        </label>
                                                        <input type="file" id="replyMedia-${cmt.getId()}" class="hidden" accept="image/*,video/*" onchange="previewReplyMedia('${cmt.getId()}')">
														<button onclick="submitReplyAJAX('${cmt.getId()}')" class="text-blue-600"><i class="fa fa-paper-plane text-xs"></i></button>
													</div>
												</div>
                                                <div id="replyPreview-${cmt.getId()}" class="hidden ml-9 mt-2 relative inline-block">
                                                    <img id="replyImgPreview-${cmt.getId()}" src="" class="h-16 rounded-lg shadow-md border">
                                                    <button onclick="removeReplyMedia('${cmt.getId()}')" class="absolute -top-2 -right-2 bg-red-500 text-white rounded-full w-5 h-5 flex items-center justify-center text-xs shadow-md">×</button>
                                                </div>
												<div id="emoji-picker-reply-${cmt.getId()}" class="hidden absolute bottom-10 left-10 bg-white border rounded-xl p-2 shadow-xl z-[5000] w-40">
													<div class="grid grid-cols-4 gap-2 text-lg">
														<span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${cmt.getId()}', '😀')">😀</span>
														<span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${cmt.getId()}', '😂')">😂</span>
														<span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${cmt.getId()}', '❤️')">❤️</span>
														<span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${cmt.getId()}', '👍')">👍</span>
														<span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${cmt.getId()}', '🥰')">🥰</span>
														<span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${cmt.getId()}', '😮')">😮</span>
														<span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${cmt.getId()}', '😢')">😢</span>
														<span class="cursor-pointer hover:scale-125 transition" onclick="addEmoji('input-reply-${cmt.getId()}', '😡')">😡</span>
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
							</c:forEach>
						</div>
						<!-- Comment Input -->
						<form onsubmit="event.preventDefault(); submitCommentAJAX(${post.getId()});" class="flex gap-2 mt-4 items-center relative">
							<img src="img/${not empty ub.getProfile_pic() ? ub.getProfile_pic() : 'default.png'}" onerror="this.src='img/default.png'" class="w-8 h-8 rounded-full border shadow-sm object-cover" width="30Px">
							<div class="flex-1 bg-white/40 backdrop-blur-sm rounded-2xl px-4 py-2 flex items-center gap-2 border border-white/30 focus-within:ring-2 ring-blue-500/20 transition-all">
								<input id="input-post-${post.getId()}" class="bg-transparent outline-none flex-1 text-sm font-medium" placeholder="Write a comment...">
								<div class="flex items-center gap-1.5 text-gray-400">
									<i class="fa-regular fa-face-smile hover:text-yellow-500 cursor-pointer transition-colors" onclick="toggleEmojiPicker('emoji-picker-post-${post.getId()}')"></i>
									<i class="fa-regular fa-image hover:text-blue-500 cursor-pointer transition-colors" onclick="document.getElementById('commentMedia-${post.getId()}').click()"></i>
								</div>
								<input type="file" id="commentMedia-${post.getId()}" class="hidden" accept="image/*" onchange="previewCommentMedia(event, ${post.getId()})">
								<button type="submit" class="text-blue-600 hover:scale-110 transition-transform"><i class="fa fa-paper-plane"></i></button>
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
						</form>
					</div>
				</div>
			</c:forEach>
		</main>

		<!-- RIGHT SIDEBAR (Dynamic & Colorful) -->
		<aside class="hidden lg:block sticky top-[70px] max-h-[calc(100vh-85px)] overflow-y-auto custom-scrollbar">
			<div class="space-y-6">
				<!-- Sponsored Card (Dynamic Ad from DB with direct navigation to sponsor page) -->
				<c:set var="ad" value="${sponsoredAd}" />
				<c:set var="adDest" value="${not empty ad.linkUrl ? ad.linkUrl : 'yads'}" />
				<div class="glass-card p-5 rounded-3xl group transition-all hover:shadow-2xl">
					<div class="flex items-center justify-between mb-3">
						<span class="text-xs font-bold text-gray-500 uppercase tracking-widest flex items-center gap-1.5">
							<i class="fa fa-rectangle-ad text-blue-500"></i> Sponsored
						</span>
						<a href="${pageContext.request.contextPath}/yads" title="Manage Campaigns" class="text-gray-400 hover:text-blue-500 text-xs font-semibold flex items-center gap-1 transition">
							<span>Create Ad</span>
							<i class="fa fa-chevron-right text-[10px]"></i>
						</a>
					</div>
					
					<a href="${adDest}" ${adDest.startsWith('http://') || adDest.startsWith('https://') ? 'target="_blank" rel="noopener noreferrer"' : ''} class="block group/ad cursor-pointer">
						<div class="rounded-2xl overflow-hidden mb-3 relative aspect-video bg-gray-100 shadow-sm">
							<c:choose>
								<c:when test="${not empty ad.imageUrl and (fn:startsWith(ad.imageUrl, 'http://') or fn:startsWith(ad.imageUrl, 'https://'))}">
									<img src="${ad.imageUrl}" alt="${ad.title}" class="w-full h-full object-cover group-hover/ad:scale-105 transition-transform duration-500">
								</c:when>
								<c:when test="${not empty ad.imageUrl}">
									<img src="${ad.imageUrl.startsWith('img/') ? ad.imageUrl : 'img/'.concat(ad.imageUrl)}" alt="${ad.title}" class="w-full h-full object-cover group-hover/ad:scale-105 transition-transform duration-500" onerror="this.src='img/starbucks_coffee_ad.png'">
								</c:when>
								<c:otherwise>
									<img src="https://images.unsplash.com/photo-1611162617474-5b21e879e113?q=80&w=1000&auto=format&fit=crop" class="w-full h-full object-cover group-hover/ad:scale-105 transition-transform duration-500">
								</c:otherwise>
							</c:choose>
							<div class="absolute inset-0 bg-gradient-to-t from-black/50 via-transparent to-transparent"></div>
							<span class="absolute bottom-2 left-2.5 text-white text-[10px] font-bold bg-blue-600/90 backdrop-blur-sm px-2 py-0.5 rounded-md uppercase tracking-tight">Ad</span>
						</div>
						<div class="flex items-start justify-between gap-2">
							<div class="flex-1 min-w-0">
								<h4 class="text-sm font-bold text-gray-800 line-clamp-1 group-hover/ad:text-blue-600 transition">${not empty ad.title ? ad.title : 'Grow with Y-Ads'}</h4>
								<p class="text-[11px] text-gray-500 line-clamp-2 mt-0.5">${not empty ad.description ? ad.description : 'Reach thousands of active people on Y-ChatApp today!'}</p>
							</div>
							<div class="w-7 h-7 rounded-full bg-blue-50 flex items-center justify-center shrink-0 text-blue-600 group-hover/ad:bg-blue-600 group-hover/ad:text-white transition shadow-sm">
								<i class="fa ${adDest.startsWith('http') ? 'fa-arrow-up-right-from-square' : 'fa-arrow-right'} text-xs"></i>
							</div>
						</div>
					</a>
				</div>

								<!-- Top Trending Topics Card (#Hashtags) -->
				<c:if test="">
					<div class="glass-card p-5 rounded-3xl">
						<div class="flex items-center justify-between mb-4">
							<h3 class="text-xs font-bold text-gray-500 uppercase tracking-widest flex items-center gap-2">
								<i class="fa fa-arrow-trend-up text-indigo-500"></i> Trending Topics
							</h3>
							<c:if test="">
								<a href="UsersPostServlet" class="text-xs font-semibold text-indigo-500 hover:underline">Clear</a>
							</c:if>
						</div>
						<div class="space-y-2">
							<c:forEach var="trend" items="">
								<a href="UsersPostServlet?tag=" class="flex items-center justify-between p-2 rounded-2xl hover:bg-white/60 transition group">
									<div class="min-w-0">
										<p class="text-sm font-bold text-gray-800 group-hover:text-indigo-600 transition truncate">#</p>
										<p class="text-[11px] text-gray-400"> </p>
									</div>
									<div class="w-7 h-7 rounded-full bg-indigo-50 flex items-center justify-center shrink-0 text-indigo-600 group-hover:bg-indigo-600 group-hover:text-white transition">
										<i class="fa fa-hashtag text-xs"></i>
									</div>
								</a>
							</c:forEach>
						</div>
					</div>
				</c:if>

				<!-- People You May Know Section -->
				<c:if test="${not empty suggestedFriends}">
					<div class="glass-card p-5 rounded-3xl">
						<div class="flex items-center justify-between mb-4">
							<h3 class="text-xs font-bold text-gray-500 uppercase tracking-widest flex items-center gap-2">
								<i class="fa fa-user-plus text-blue-500"></i> People You May Know
							</h3>
							<a href="FriendServlet" class="text-xs font-semibold text-blue-500 hover:underline">See All</a>
						</div>
						<div class="space-y-3">
							<c:forEach var="sug" items="${suggestedFriends}">
								<div class="flex items-center justify-between gap-3 p-2 rounded-2xl hover:bg-white/50 transition">
									<a href="UsersProfileServlet?userId=${sug.getId()}" class="flex items-center gap-3 min-w-0">
										<img src="img/${not empty sug.getProfile_pic() ? sug.getProfile_pic() : 'default.png'}" class="w-10 h-10 rounded-full object-cover border" onerror="this.src='img/default.png'">
										<div class="min-w-0">
											<p class="text-sm font-bold text-gray-800 truncate hover:text-blue-600 transition">${sug.getName()}</p>
											<p class="text-[11px] text-gray-400 truncate">${not empty sug.getCity() ? sug.getCity() : (not empty sug.getCountry() ? sug.getCountry() : 'Member')}</p>
										</div>
									</a>
									<button onclick="addFriendFromSidebar(${sug.getId()}, this)" class="px-3 py-1.5 bg-blue-500 hover:bg-blue-600 text-white text-xs font-bold rounded-xl shadow-sm hover:shadow transition shrink-0 flex items-center gap-1">
										<i class="fa fa-user-plus text-[10px]"></i> Add
									</button>
								</div>
							</c:forEach>
						</div>
					</div>
				</c:if>

				<!-- Contacts Section -->
				<div class="glass-card p-5 rounded-3xl">
					<div class="flex items-center justify-between mb-4">
						<h3 class="text-xs font-bold text-gray-500 uppercase tracking-widest">Contacts</h3>
						<div class="flex gap-2 text-gray-400">
							<i class="fa fa-video hover:text-blue-500 transition cursor-pointer"></i>
							<i class="fa fa-search hover:text-blue-500 transition cursor-pointer"></i>
							<i class="fa fa-ellipsis-h hover:text-blue-500 transition cursor-pointer"></i>
						</div>
					</div>
					<div class="space-y-1">
						<c:forEach var="friend" items="${friendList}">
							<div onclick="location.href='messages.jsp?userName=${friend.getName()}'" class="flex items-center gap-3 p-2 rounded-xl hover:bg-white/40 dark:hover:bg-white/5 transition-all cursor-pointer group">
								<div class="relative shrink-0 w-10 h-10">
									<img src="img/${not empty friend.getProfile_pic() ? friend.getProfile_pic() : 'default.png'}" class="w-10 h-10 rounded-xl object-cover shadow-sm group-hover:rotate-6 transition-transform" onerror="this.src='img/default.png'">
									<div data-contact-username="${friend.getName()}" class="contact-status-dot absolute -bottom-1 -right-1 w-3.5 h-3.5 bg-gray-400 border-2 border-white dark:border-gray-800 rounded-full transition-all duration-300" title="Offline"></div>
								</div>
								<span class="text-sm font-semibold text-gray-700 dark:text-gray-300 group-hover:text-blue-600 transition-colors truncate whitespace-nowrap overflow-hidden">${friend.getName()}</span>
							</div>
						</c:forEach>
						<c:if test="${empty friendList}">
							<p class="text-xs text-gray-400 text-center py-4">No contacts online</p>
						</c:if>
					</div>
				</div>
			</div>
		</aside>
	</div>

	<!-- Features (Saved/Memories) Modal -->
	<div id="featuresModal" class="modal !bg-black/85 z-[9999]" style="display: none;">
		<div class="modal-content !max-w-[700px] !w-[95%] !bg-[#18191A] rounded-3xl shadow-2xl overflow-hidden border border-gray-700 p-0">
			<!-- Header -->
			<div class="flex items-center justify-between p-5 border-b border-gray-700">
				<h2 id="featuresModalTitle" class="text-xl font-bold text-white flex items-center gap-2"></h2>
				<button onclick="closeFeaturesModal()" class="w-8 h-8 rounded-full bg-gray-700 hover:bg-gray-600 flex items-center justify-center text-white transition">
                    <i class="fa fa-times"></i>
                </button>
			</div>
			<!-- Content Container -->
			<div id="featuresModalBody" class="p-6 max-h-[60vh] overflow-y-auto space-y-4 text-white">
				<!-- Content dynamically loaded via JS -->
			</div>
		</div>
	</div>

	<!-- Create Story Modal -->
	<div id="storyModal" class="modal" style="display: none;">
		<div class="modal-content !max-w-[450px] !w-[95%] bg-white rounded-2xl shadow-2xl p-0 overflow-hidden">
			<div class="flex items-center justify-between p-4 border-b">
				<h2 class="text-xl font-bold text-gray-800">Create Story</h2>
				<button onclick="closeStoryModal()" class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center hover:bg-red-100 hover:text-red-600 transition">
					<i class="fa fa-times"></i>
				</button>
			</div>
			<form id="storyForm" action="StoryServlet" method="post" enctype="multipart/form-data" class="p-6 space-y-4">
				<div>
					<label class="block text-sm font-bold text-gray-700 mb-1">Story Text (Optional)</label>
					<textarea name="text" placeholder="Write something in your story..." class="w-full p-3 border rounded-xl outline-none resize-none h-20 text-sm focus:ring-2 focus:ring-blue-500/20 transition-all"></textarea>
				</div>
				<div>
					<label class="block text-sm font-bold text-gray-700 mb-1">Story audience</label>
					<select name="audience" class="w-full p-3 border rounded-xl text-sm"><option value="PUBLIC">Public</option><option value="FRIENDS">Friends only</option><option value="PRIVATE">Only me</option></select>
				</div>
				<div>
					<label class="block text-sm font-bold text-gray-700 mb-1">Upload Photo/Video</label>
					<div class="border-2 border-dashed border-gray-200 rounded-xl p-6 text-center cursor-pointer hover:bg-gray-50 transition" onclick="document.getElementById('storyMediaInput').click()">
						<i class="fa fa-image text-3xl text-blue-500 mb-2"></i>
						<p class="text-gray-500 text-sm font-medium">Click to select photo or video</p>
					</div>
					<input type="file" name="media" id="storyMediaInput" class="hidden" accept="image/*,video/*" onchange="previewStoryMedia(this)">
				</div>
				<!-- Preview Container -->
				<div id="storyPreviewContainer" class="hidden mt-3 rounded-xl overflow-hidden bg-gray-100 border relative max-h-[200px]">
					<button type="button" onclick="removeStoryPreview()" class="absolute top-2 right-2 bg-black/60 text-white rounded-full w-6 h-6 flex items-center justify-center text-xs">×</button>
					<img id="storyImagePreview" src="#" class="w-full h-auto object-contain max-h-[200px] hidden">
					<video id="storyVideoPreview" src="#" class="w-full h-auto object-contain max-h-[200px] hidden" controls></video>
				</div>
				<button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded-xl shadow-lg transition">Share to Story</button>
			</form>
		</div>
	</div>

	<!-- Story Viewer Modal -->
	<div id="storyViewerModal" class="modal !bg-black/95" style="display: none;">
		<div class="relative w-full h-full flex items-center justify-center">
			<button onclick="closeStoryViewer()" class="absolute top-6 right-6 text-white text-3xl z-50 hover:scale-110 transition">
				<i class="fa fa-times"></i>
			</button>
			
			<div class="h-[80vh] w-[90%] max-w-[400px] bg-[#1c1c1e] rounded-2xl overflow-hidden relative shadow-2xl flex flex-col">
				<!-- Progress Bar -->
				<div class="absolute top-3 left-3 right-3 flex gap-1 z-50">
					<div class="h-1 flex-1 bg-white/30 rounded-full overflow-hidden">
						<div id="storyProgressBar" class="h-full bg-white w-0"></div>
					</div>
				</div>

				<!-- User Header -->
				<div class="absolute top-6 left-4 right-4 flex items-center gap-3 z-50 text-white">
					<img id="storyViewerUserPic" src="" class="w-9 h-9 rounded-full border-2 border-white object-cover">
					<div>
						<p id="storyViewerUserName" class="font-bold text-sm shadow-sm"></p>
					</div>
				</div>

				<!-- Story Content Body -->
				<div class="flex-1 flex items-center justify-center relative p-4">
					<img id="storyViewerImage" src="" class="w-full h-full object-contain hidden">
					<video id="storyViewerVideo" src="" class="w-full h-full object-contain hidden" autoplay controls></video>
					
					<!-- Text-only Story overlay -->
					<div id="storyViewerTextContainer" class="w-full h-full bg-gradient-to-br from-indigo-600 via-purple-600 to-pink-600 rounded-2xl flex items-center justify-center p-6 text-center text-white hidden">
						<p id="storyViewerText" class="text-xl font-bold leading-normal"></p>
					</div>

					<!-- Media Story Caption overlay -->
					<div id="storyViewerCaptionContainer" class="absolute bottom-4 left-4 right-4 bg-black/60 backdrop-blur-md rounded-xl p-3 text-center hidden">
						<p id="storyViewerCaption" class="text-white text-xs font-semibold leading-relaxed"></p>
					</div>
				</div>
			</div>
		</div>
	</div>

	<!-- Create Post Modal -->
	<div id="postModal" class="modal !z-[100000]" style="display: none;">
		<div
			class="modal-content !max-w-[540px] !w-[95%] max-h-[90vh] flex flex-col bg-white rounded-3xl shadow-2xl overflow-hidden my-auto transform transition-all border border-gray-100">

			<!-- Modal Header -->
			<div class="flex items-center justify-between p-4 border-b">
				<h2 class="text-xl font-bold text-center flex-1 text-gray-800">Create
					Post</h2>
				<button type="button" onclick="closeModal()"
					class="bg-gray-100 hover:bg-red-100 hover:text-red-600 rounded-full p-2 w-9 h-9 flex items-center justify-center transition-all cursor-pointer">
					<i class="fa fa-xmark text-lg"></i>
				</button>
			</div>

			<form id="postForm" action="UsersPostServlet" method="post"
				enctype="multipart/form-data"
				class="p-4 sm:p-5 flex flex-col flex-1 min-h-0 overflow-y-auto">

				<!-- User Info -->
				<div class="flex items-center gap-3 mb-4">
					<div class="relative">
						<img src="img/${ub.getProfile_pic()}"
							class="w-11 h-11 rounded-full border-2 border-blue-500 shadow-sm" onerror="this.src='img/default.png'">
					</div>
					<div>
						<p class="font-bold text-gray-800">${ub.getName()}</p>
						<div class="flex gap-2">
							<!-- Feeling Indicator -->
							<div
								class="flex items-center gap-1 bg-gray-100 px-2 py-0.5 rounded-md">
								<i class="fa fa-face-smile text-yellow-500 text-xs"></i> <select
									name="feeling"
									class="text-[11px] font-bold bg-transparent outline-none cursor-pointer text-gray-600">
									<option value="">Feeling</option>
									<option value="Happy">&#x1F60A; Happy</option>
									<option value="Loved">&#x2764;&#xFE0F; Loved</option>
									<option value="Haha">&#x1F602; Haha</option>
									<option value="Wow">&#x1F62E; Wow</option>
									<option value="Sad">&#x1F622; Sad!</option>
								</select>
							</div>
							<!-- Tag Indicator (New) -->
							<div id="tagBadge"
								class="hidden flex items-center gap-1 bg-blue-50 px-2 py-0.5 rounded-md">
								<i class="fa fa-user-tag text-blue-500 text-xs"></i> <span
									class="text-[11px] font-bold text-blue-600">Friends
									Tagged</span>
							</div>
						</div>
					</div>
				</div>

				<!-- Text Area -->
				<textarea name="content"
					placeholder="What's on your mind, ${ub.getName()}?"
					class="w-full text-base sm:text-lg outline-none resize-none placeholder-gray-400 text-gray-700 min-h-[90px] mb-3"></textarea>

				<div id="pollCreateSection" class="hidden mb-3 p-3 bg-indigo-50 rounded-xl border border-indigo-100"><label class="block text-xs font-bold text-indigo-700 mb-2">Poll question</label><input name="pollQuestion" maxlength="500" placeholder="Ask a question..." class="w-full bg-white border rounded-lg px-3 py-2 text-sm mb-2"><div id="pollOptionInputs" class="space-y-2"><input name="pollOption" maxlength="255" placeholder="Option 1" class="w-full bg-white border rounded-lg px-3 py-2 text-sm"><input name="pollOption" maxlength="255" placeholder="Option 2" class="w-full bg-white border rounded-lg px-3 py-2 text-sm"></div><button type="button" onclick="addPollOptionInput()" class="mt-2 text-xs font-bold text-indigo-700">+ Add option (up to 6)</button></div>
				<!-- 👥 Friends Tag Selection -->
				<div id="tagSection"
					class="hidden mb-3 p-3 bg-blue-50 rounded-xl border border-blue-100 shadow-inner">
					<p class="text-xs font-bold text-blue-600 mb-2">Tag Friends:</p>
					<select name="taggedFriends" multiple
						class="w-full bg-white border-none rounded-lg text-sm p-2 outline-none h-20 shadow-sm">
						<option value="1">Sakura</option>
						<option value="2">John Doe</option>
						<option value="3">Alex</option>
					</select>
				</div>

				<!-- Image/Video Preview -->
				<div id="modalPreviewContainer"
					class="hidden relative mt-2 mb-2 rounded-xl overflow-hidden border-2 border-blue-50 shadow-inner">
					<button type="button" onclick="removeModalPreview()"
						class="absolute top-2 right-2 bg-black/50 text-white hover:bg-red-500 rounded-full w-7 h-7 flex items-center justify-center z-10 transition-all cursor-pointer">×</button>
					<img id="modalImagePreview" src="#"
						class="w-full h-auto object-cover max-h-[180px]">
				</div>

				<!-- 🌈 কালারফুল ৩ডি "Add to Post" বক্স -->
				<div
					class="mt-auto p-3 border-2 border-gray-100 rounded-2xl flex items-center justify-between shadow-sm bg-gradient-to-r from-white to-gray-50">
					<span class="font-bold text-gray-700 text-sm pl-2">Add to
						your post</span>
					<div class="flex gap-2">
						<!-- Photo/Video Icon -->
						<div title="Photo/Video"
							onclick="document.getElementById('modalFileInput').click()"
							class="w-10 h-10 flex items-center justify-center rounded-xl bg-green-50 text-green-600 hover:bg-green-500 hover:text-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 cursor-pointer">
							<i class="fa fa-image text-xl"></i>
						</div>
						<!-- Tag Friends Icon -->
						<div title="Tag Friends" onclick="toggleTagSection()"
							class="w-10 h-10 flex items-center justify-center rounded-xl bg-blue-50 text-blue-600 hover:bg-blue-500 hover:text-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 cursor-pointer">
							<i class="fa fa-user-tag text-xl"></i>
						</div>
						<div title="Create Poll" onclick="togglePollCreate()" class="w-10 h-10 flex items-center justify-center rounded-xl bg-indigo-50 text-indigo-600 hover:bg-indigo-500 hover:text-white transition-all cursor-pointer"><i class="fa fa-square-poll-vertical text-xl"></i></div>
						<!-- Feeling/Activity Icon -->
						<div title="Feeling / Activity" onclick="focusFeelingSelector()"
							class="w-10 h-10 flex items-center justify-center rounded-xl bg-yellow-50 text-yellow-600 hover:bg-yellow-500 hover:text-white hover:shadow-lg hover:-translate-y-1 transition-all duration-300 cursor-pointer">
							<i class="fa fa-face-smile text-xl"></i>
						</div>
					</div>
				</div>

				<input type="file" name="media" id="modalFileInput" class="hidden"
					accept="image/*,video/*" onchange="previewModalImage(this)">

				<div class="flex gap-2 mt-4"><input type="datetime-local" name="scheduledAt" class="flex-1 border rounded-lg px-3 py-2 text-sm"><button type="button" onclick="savePostDraft()" class="px-3 py-2 rounded-lg bg-gray-100 font-bold text-xs cursor-pointer">Save Draft</button><button type="button" onclick="loadPostDraft()" class="px-3 py-2 rounded-lg bg-gray-100 font-bold text-xs cursor-pointer">Load Draft</button></div>

				<div class="pt-3 mt-2 border-t border-gray-100 sticky bottom-0 bg-white z-10">
					<button type="submit" id="mainPostSubmitBtn"
						class="w-full bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-black py-3.5 rounded-2xl shadow-lg active:scale-95 transition-all text-base cursor-pointer" style="touch-action:manipulation;-webkit-tap-highlight-color:transparent;">
						Post
					</button>
				</div>
			</form>
		</div>
	</div>

	<!-- Live Video Modal -->
	<div id="liveModal" class="modal z-[10000]" style="display: none;">
		<div class="modal-content !max-w-[800px] !w-[95%] bg-black text-white rounded-2xl shadow-2xl p-0 overflow-hidden flex flex-col md:flex-row h-[80vh]">
			<!-- Video Section -->
			<div id="liveVideoContainer" class="flex-1 relative bg-gray-900 flex flex-col justify-center items-center overflow-hidden">
				<video id="liveVideo" autoplay muted playsinline class="w-full h-full object-cover"></video>
				
				<!-- Floating Emoji Container -->
				<div id="floatingEmojiContainer" class="absolute inset-0 pointer-events-none z-10"></div>
				
				<!-- Floating Reaction Panel (Visible when live) -->
				<div id="liveReactionPanel" class="hidden absolute bottom-4 left-1/2 -translate-x-1/2 bg-black/60 backdrop-blur-md rounded-full px-4 py-2 flex gap-3 z-20 transition-all border border-white/10 hover:bg-black/80">
					<span class="cursor-pointer hover:scale-150 transition-transform text-lg" onclick="triggerLiveReaction('Like')">👍</span>
					<span class="cursor-pointer hover:scale-150 transition-transform text-lg" onclick="triggerLiveReaction('Love')">❤️</span>
					<span class="cursor-pointer hover:scale-150 transition-transform text-lg" onclick="triggerLiveReaction('Care')">🥰</span>
					<span class="cursor-pointer hover:scale-150 transition-transform text-lg" onclick="triggerLiveReaction('Haha')">😆</span>
					<span class="cursor-pointer hover:scale-150 transition-transform text-lg" onclick="triggerLiveReaction('Wow')">😮</span>
					<span class="cursor-pointer hover:scale-150 transition-transform text-lg" onclick="triggerLiveReaction('Sad')">😢</span>
					<span class="cursor-pointer hover:scale-150 transition-transform text-lg" onclick="triggerLiveReaction('Angry')">😡</span>
					<span class="cursor-pointer hover:scale-150 transition-transform text-lg" onclick="triggerLiveReaction('Dislike')">👎</span>
				</div>

				<!-- Live Badges (Hidden Initially) -->
				<div class="absolute top-4 left-4 flex gap-2 z-10">
					<div id="liveBadge" class="hidden bg-red-600 text-white font-bold text-xs px-3 py-1 rounded-md animate-pulse">LIVE</div>
					<div id="liveTimer" class="hidden bg-black/50 text-white text-xs px-3 py-1 rounded-md font-mono">00:00</div>
					<div id="liveViewers" class="hidden bg-black/50 text-white text-xs px-3 py-1 rounded-md flex items-center gap-1">
						<i class="fa fa-eye"></i> <span id="viewerCount">0</span>
					</div>
				</div>

				<button type="button" onclick="closeLiveModal()" class="absolute top-4 right-4 w-8 h-8 rounded-full bg-black/50 text-white flex items-center justify-center hover:bg-red-500 z-10 transition"><i class="fa fa-xmark"></i></button>
			</div>

			<!-- Sidebar / Chat Section -->
			<div class="w-full md:w-[300px] bg-[#242526] flex flex-col border-l border-white/10 relative">
				<div class="p-4 border-b border-white/10">
					<h3 class="font-bold text-lg mb-2">Live Broadcast Setup</h3>
					<input type="text" id="liveTitle" placeholder="Describe your live video..." class="w-full bg-[#3A3B3C] text-white rounded-lg p-2 text-sm outline-none">
				</div>

				<!-- Setup Overlay (Before going live) -->
				<div id="liveSetupOverlay" class="absolute inset-0 top-[100px] bg-[#242526] z-20 flex flex-col items-center justify-center p-6 text-center">
					<div class="w-16 h-16 rounded-full bg-blue-500/20 text-blue-500 flex items-center justify-center text-2xl mb-4 cursor-pointer hover:bg-blue-500 hover:text-white transition" onclick="requestCameraAccess()">
						<i class="fa fa-video"></i>
					</div>
					<h4 class="font-bold mb-2">Camera Access Required</h4>
					<p class="text-xs text-gray-400 mb-4">Click the camera icon to allow access and preview your video before going live.</p>
				</div>

				<!-- Chat Area -->
				<div class="flex-1 overflow-y-auto p-4 flex flex-col gap-3 relative">
					<div id="chatPlaceholder" class="absolute inset-0 flex items-center justify-center text-gray-500 text-sm">
						Chat will appear here once live
					</div>
					<div id="liveChatBox" class="hidden flex-col gap-3 flex-1 overflow-y-auto"></div>
				</div>

				<!-- Live Chat Input (Hidden initially, visible when live) -->
				<div id="liveChatInputArea" class="hidden p-3 border-t border-white/10 flex gap-2">
					<input type="text" id="liveChatInput" placeholder="Write a comment..." class="flex-1 bg-[#3A3B3C] text-white rounded-full px-4 py-1.5 text-xs outline-none border border-transparent focus:border-blue-500" onkeydown="if(event.key === 'Enter') sendLiveComment()">
					<button onclick="sendLiveComment()" class="bg-blue-600 hover:bg-blue-700 text-white w-7 h-7 rounded-full flex items-center justify-center transition">
						<i class="fa fa-paper-plane text-xs"></i>
					</button>
				</div>

				<!-- Bottom Actions -->
				<div class="p-4 border-t border-white/10">
					<button type="button" id="goLiveBtn" onclick="startLiveStream()" disabled class="w-full bg-blue-600 hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed text-white font-bold py-3 rounded-xl transition">Go Live</button>
					<button type="button" id="endLiveBtn" onclick="endLiveStream()" class="hidden w-full bg-red-600 hover:bg-red-700 text-white font-bold py-3 rounded-xl transition">End Live Video</button>
				</div>
			</div>
		</div>
	</div>

	<!-- Create Reel Modal -->
	<div id="reelModal" class="modal" style="display: none;">
		<div class="modal-content !max-w-[450px] !w-[95%] bg-white rounded-2xl shadow-2xl p-0 overflow-hidden">
			<div class="flex items-center justify-between p-4 border-b">
				<h2 class="text-xl font-bold">Create Reel</h2>
				<button onclick="closeReelModal()" class="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center">×</button>
			</div>
			<form id="reelForm" action="UsersPostServlet" method="post" enctype="multipart/form-data" class="p-6">
				<input type="hidden" name="type" value="REEL">
				<div class="border-2 border-dashed border-gray-200 rounded-xl p-8 text-center cursor-pointer hover:bg-gray-50 transition"
					 onclick="document.getElementById('reelVideoInput').click()">
					<i class="fa fa-clapperboard text-4xl text-blue-500 mb-2"></i>
					<p class="text-gray-500 font-medium">Click to select a video for your Reel</p>
					<p class="text-xs text-gray-400 mt-1">Short vertical videos work best!</p>
				</div>
				<input type="file" name="media" id="reelVideoInput" class="hidden" accept="video/*" onchange="previewReel(this)">
				<div id="reelPreview" class="hidden mt-4 rounded-xl overflow-hidden bg-black aspect-[9/16]">
					<video id="reelVideoPreview" class="w-full h-full object-contain" controls></video>
				</div>
				<textarea name="content" placeholder="Describe your reel..." class="w-full mt-4 p-3 border rounded-xl outline-none resize-none h-20 text-sm"></textarea>
				<button type="submit" class="w-full bg-blue-600 text-white font-bold py-3 rounded-xl mt-6 shadow-lg hover:bg-blue-700">Share Reel</button>
			</form>
		</div>
	</div>

	<!-- Reel Viewer Modal -->
	<div id="reelViewer" class="modal !bg-black/95" style="display: none;">
		<div class="relative w-full h-full flex items-center justify-center">
			<button onclick="closeReelViewer()" class="absolute top-6 right-6 text-white text-4xl z-50">×</button>
			<div class="h-[90vh] aspect-[9/16] bg-black rounded-2xl overflow-hidden relative shadow-2xl">
				<video id="viewerVideo" class="w-full h-full object-contain" loop autoplay controls></video>
				<div class="absolute bottom-0 left-0 right-0 p-6 bg-gradient-to-t from-black/80 to-transparent text-white">
					<div class="flex items-center gap-3 mb-2">
						<img id="viewerUserPic" src="" class="w-10 h-10 rounded-full border-2 border-white">
						<span id="viewerUserName" class="font-bold"></span>
					</div>
					<p id="viewerContent" class="text-sm"></p>
				</div>
			</div>
		</div>
	</div>

	<script>
    var contextPath = "${pageContext.request.contextPath}";

    // --- Live Stream Functions ---
    let liveStream = null;
    let liveInterval = null;
    let liveTimerSeconds = 0;
    let fakeViewers = 0;
    let fakeCommentsInterval = null;
    let mediaRecorder = null;
    let recordedChunks = [];    let liveSocket = null;
    let livePeers = new Map();
    const livePendingIce = new Map();
    let liveStatusInterval = null;
    const liveUsername = "${ub.getName()}";
    const liveRtcConfig = { iceServers: [{ urls: 'stun:stun.l.google.com:19302' }] };

    function sendLiveSignal(type, target, payload) {
        if (!liveSocket || liveSocket.readyState !== WebSocket.OPEN) return false;
        liveSocket.send(type + '|' + target + '|' + JSON.stringify(payload || {}));
        return true;
    }

    function connectLiveSocket() {
        if (liveSocket && liveSocket.readyState === WebSocket.OPEN) return Promise.resolve();
        if (liveSocket && liveSocket.readyState === WebSocket.CONNECTING) {
            return new Promise((resolve, reject) => {
                const timer = setTimeout(() => reject(new Error('Live connection timed out.')), 8000);
                liveSocket.addEventListener('open', () => { clearTimeout(timer); resolve(); }, { once: true });
                liveSocket.addEventListener('error', () => { clearTimeout(timer); reject(new Error('Live connection failed.')); }, { once: true });
            });
        }
        const protocol = location.protocol === 'https:' ? 'wss://' : 'ws://';
        liveSocket = new WebSocket(protocol + location.host + contextPath + '/ws/user/' + encodeURIComponent(liveUsername));
        return new Promise((resolve, reject) => {
            const timer = setTimeout(() => reject(new Error('Live connection timed out.')), 8000);
            liveSocket.onopen = () => { clearTimeout(timer); resolve(); };
            liveSocket.onerror = () => { clearTimeout(timer); reject(new Error('Live connection failed.')); };
            liveSocket.onmessage = handleHostLiveSignal;
        });
    }

    async function handleHostLiveSignal(event) {
        const parts = event.data.split('|');
        const type = parts[0];
        if (type === 'NOTIF') { window.dispatchEvent(new Event('ychat:notification')); return; }
        if (type === 'LIVE_VIEWER_COUNT') {
            if (parts[1] === liveUsername) { const count = document.getElementById('viewerCount'); if (count) count.innerText = parts[2] || '0'; }
            return;
        }
        if (type === 'POST_ACTIVITY') {
            window.dispatchEvent(new CustomEvent('ychat:post-activity', { detail: { postId: parts[1], activity: parts[2], actor: parts.slice(3).join('|') } }));
            clearTimeout(window.ychatFeedRefreshTimer);
            window.ychatFeedRefreshTimer = setTimeout(() => refreshFeed(), 350);
            return;
        }
        if (type === 'LIVE_CHAT' || type === 'LIVE_REACTION') {
            const room = parts[1], actor = parts[2], text = parts.slice(3).join('|');
            if (room !== liveUsername) return;
            let payload = {};
            try { payload = text ? JSON.parse(text) : {}; } catch (e) { return; }
            if (type === 'LIVE_CHAT' && payload.text) appendLiveComment(actor, payload.text, payload.profilePic || 'default-avatar.png', actor === liveUsername);
            if (type === 'LIVE_REACTION' && payload.emoji) {
                createFloatingEmoji(payload.emoji);
                appendLiveSystemMessage(actor + ' reacted with ' + payload.emoji);
            }
            return;
        }
        const viewer = parts[1], text = parts.slice(2).join('|');
        let payload = {};
        try { payload = text ? JSON.parse(text) : {}; } catch (e) { return; }
        if (type === 'LIVE_JOIN_REQUEST') await createLivePeerForViewer(viewer);
        else if (type === 'LIVE_ANSWER') {
            const peer = livePeers.get(viewer);
            if (peer && payload.sdp) {
                await peer.setRemoteDescription(new RTCSessionDescription(payload));
                const queued = livePendingIce.get(viewer) || [];
                for (const candidate of queued) await peer.addIceCandidate(new RTCIceCandidate(candidate));
                livePendingIce.delete(viewer);
            }
        } else if (type === 'LIVE_ICE') {
            const peer = livePeers.get(viewer);
            if (peer && payload.candidate) {
                if (!peer.remoteDescription) {
                    const queued = livePendingIce.get(viewer) || [];
                    queued.push(payload.candidate);
                    livePendingIce.set(viewer, queued);
                } else {
                    try { await peer.addIceCandidate(new RTCIceCandidate(payload.candidate)); }
                    catch (error) { console.warn('Could not add viewer ICE candidate:', error); }
                }
            }
        } else if (type === 'LIVE_VIEWER_LEFT') {
            const peer = livePeers.get(viewer);
            if (peer) peer.close();
            livePeers.delete(viewer);
        }
    }
    window.addEventListener('load', () => connectLiveSocket().catch(error => console.warn('Realtime feed connection unavailable:', error)));

    async function createLivePeerForViewer(viewer) {
        if (!liveStream || !liveSocket || liveSocket.readyState !== WebSocket.OPEN) return;
        const previous = livePeers.get(viewer);
        if (previous) previous.close();
        const peer = new RTCPeerConnection(liveRtcConfig);
        livePeers.set(viewer, peer);
        liveStream.getTracks().forEach(track => peer.addTrack(track, liveStream));
        peer.onicecandidate = event => { if (event.candidate) sendLiveSignal('LIVE_ICE', viewer, { candidate: event.candidate }); };
        peer.onconnectionstatechange = () => {
            if (['failed', 'closed', 'disconnected'].includes(peer.connectionState)) {
                peer.close();
                if (livePeers.get(viewer) === peer) livePeers.delete(viewer);
            }
        };
        const offer = await peer.createOffer();
        await peer.setLocalDescription(offer);
        sendLiveSignal('LIVE_OFFER', viewer, peer.localDescription);
    }

    async function refreshLiveViewerCount() {
        try {
            const response = await fetch(contextPath + '/LiveServlet?action=status', { cache: 'no-store' });
            const data = await response.json();
            const stream = (data.streams || []).find(item => item.streamer === liveUsername);
            if (stream) document.getElementById('viewerCount').innerText = stream.viewersCount;
        } catch (error) { console.warn('Could not refresh viewer count:', error); }
    }

    window.openLiveModal = function() { window.lastModalOpenedTime = Date.now();
        var m = document.getElementById('liveModal');
        if (m) {
            m.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
    };
    function openLiveModal() { window.openLiveModal(); }

    window.closeLiveModal = function() {
        var m = document.getElementById('liveModal');
        if (m) m.style.display = 'none';
        document.body.style.overflow = 'auto';
        window.liveCanvasAnimActive = false;
        var c = document.getElementById('liveFallbackCanvas');
        if (c) c.style.display = 'none';
        var v = document.getElementById('liveVideo');
        if (v) {
            v.style.display = 'block';
            if (v.srcObject) v.srcObject = null;
        }
        if (liveStream && !document.getElementById('endLiveBtn').classList.contains('hidden')) {
            endLiveStream();
            return;
        }
        
        if (liveStream && liveStream.getTracks) {
            liveStream.getTracks().forEach(track => track.stop());
        }
        resetLiveUI();
    };
    function closeLiveModal() { window.closeLiveModal(); }

    async function requestCameraAccess() {
        const overlay = document.getElementById('liveSetupOverlay');
        const goLive = document.getElementById('goLiveBtn');
        const video = document.getElementById('liveVideo');
        
        let streamAcquired = false;
        
        // 1. Try standard getUserMedia
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
            try {
                liveStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: true });
                streamAcquired = true;
            } catch (firstError) {
                try {
                    liveStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
                    streamAcquired = true;
                } catch (cameraError) {
                    console.warn('Direct mediaDevices error:', cameraError);
                }
            }
        }
        
        // 2. Legacy getUserMedia
        if (!streamAcquired) {
            const legacyGetUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;
            if (legacyGetUserMedia) {
                try {
                    liveStream = await new Promise((resolve, reject) => {
                        legacyGetUserMedia.call(navigator, { video: true, audio: false }, resolve, reject);
                    });
                    streamAcquired = true;
                } catch (e) {
                    console.warn('Legacy getUserMedia failed:', e);
                }
            }
        }
        
        // 3. Safari HTTP fallback: Safari disables getUserMedia on HTTP ip origins (http://3.26.151.171:8080)
        // Synthesize dynamic live canvas broadcast so Safari users are NEVER blocked from broadcasting live!
        if (!streamAcquired) {
            try {
                let canvas = document.getElementById('liveFallbackCanvas');
                if (!canvas) {
                    canvas = document.createElement('canvas');
                    canvas.id = 'liveFallbackCanvas';
                    canvas.className = 'w-full h-full object-cover absolute inset-0 z-0';
                    video.parentElement.insertBefore(canvas, video);
                }
                canvas.style.display = 'block';
                video.style.display = 'none';
                canvas.width = 640;
                canvas.height = 480;
                const ctx = canvas.getContext('2d');
                let frame = 0;
                window.liveCanvasAnimActive = true;
                function drawSimulatedCamera() {
                    if (!window.liveCanvasAnimActive) return;
                    frame++;
                    ctx.fillStyle = '#0f172a';
                    ctx.fillRect(0, 0, canvas.width, canvas.height);
                    
                    const grad = ctx.createLinearGradient(0, 0, canvas.width, canvas.height);
                    grad.addColorStop(0, '#2563eb');
                    grad.addColorStop(0.5, '#7c3aed');
                    grad.addColorStop(1, '#ec4899');
                    ctx.fillStyle = grad;
                    
                    const r = 70 + Math.sin(frame * 0.08) * 12;
                    ctx.beginPath();
                    ctx.arc(canvas.width / 2, canvas.height / 2 - 20, r, 0, Math.PI * 2);
                    ctx.fill();
                    
                    ctx.fillStyle = '#ffffff';
                    ctx.font = 'bold 24px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
                    ctx.textAlign = 'center';
                    ctx.fillText('${ub.getName()}', canvas.width / 2, canvas.height / 2 - 15);
                    
                    ctx.font = '14px -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif';
                    ctx.fillStyle = '#38bdf8';
                    ctx.fillText('🔴 Safari Live Broadcast Mode', canvas.width / 2, canvas.height / 2 + 20);
                    
                    requestAnimationFrame(drawSimulatedCamera);
                }
                drawSimulatedCamera();
                
                try {
                    if (canvas.captureStream) {
                        liveStream = canvas.captureStream(30);
                    } else if (canvas.webkitCaptureStream) {
                        liveStream = canvas.webkitCaptureStream(30);
                    }
                } catch(e) {}
            } catch (canvasErr) {
                console.warn('Canvas stream fallback error:', canvasErr);
            }
        } else {
            video.style.display = 'block';
            const c = document.getElementById('liveFallbackCanvas');
            if (c) c.style.display = 'none';
            if (liveStream && video) {
                video.srcObject = liveStream;
                video.muted = true;
                video.playsInline = true;
                video.setAttribute('playsinline', 'true');
                video.setAttribute('webkit-playsinline', 'true');
                try { await video.play(); } catch (playError) { console.warn('Preview playback was blocked:', playError); }
            }
        }
        
        if (overlay) overlay.classList.add('hidden');
        if (goLive) {
            goLive.disabled = false;
            goLive.classList.remove('opacity-50', 'cursor-not-allowed');
        }
    }

    async function startLiveStream() {
        const titleInput = document.getElementById('liveTitle');
        const title = titleInput ? titleInput.value.trim() : 'Live Broadcast';
        const goLive = document.getElementById('goLiveBtn');
        if (goLive) goLive.disabled = true;
        try {
            const response = await fetch(contextPath + '/LiveServlet?action=start&title=' + encodeURIComponent(title || 'Live Broadcast'), { method: 'POST' });
            const result = await response.json();
            if (!response.ok || !result.success) throw new Error(result.error || 'Could not start live session.');
            recordedChunks = [];
            let mimeType = '';
            if (typeof MediaRecorder !== 'undefined' && MediaRecorder.isTypeSupported) {
                const types = [
                    'video/mp4;codecs=avc1',
                    'video/mp4',
                    'video/webm;codecs=vp9,opus',
                    'video/webm;codecs=vp8,opus',
                    'video/webm'
                ];
                mimeType = types.find(t => MediaRecorder.isTypeSupported(t)) || '';
            }
            if (typeof MediaRecorder !== 'undefined' && liveStream) {
                try {
                    mediaRecorder = mimeType ? new MediaRecorder(liveStream, { mimeType }) : new MediaRecorder(liveStream);
                    mediaRecorder.ondataavailable = event => { if (event.data && event.data.size) recordedChunks.push(event.data); };
                    mediaRecorder.start(1000);
                } catch (recErr) {
                    console.warn('MediaRecorder init failed, continuing live broadcast:', recErr);
                    mediaRecorder = null;
                }
            }
        } catch (error) {
            console.error('Could not start live broadcast:', error);
            if (goLive) goLive.disabled = false;
            alert(error.message || 'Could not start live video. Please try again.');
            return;
        }
        goLive.classList.add('hidden');
        document.getElementById('endLiveBtn').classList.remove('hidden');
        titleInput.disabled = true;
        document.getElementById('liveBadge').classList.remove('hidden');
        document.getElementById('liveTimer').classList.remove('hidden');
        document.getElementById('liveViewers').classList.remove('hidden');
        document.getElementById('chatPlaceholder').classList.add('hidden');
        document.getElementById('liveChatBox').classList.remove('hidden');
        document.getElementById('liveReactionPanel').classList.remove('hidden');
        document.getElementById('liveChatInputArea').classList.remove('hidden');
        liveTimerSeconds = 0;
        fakeViewers = 0;
        document.getElementById('viewerCount').innerText = '0';
        refreshLiveViewerCount();
        liveStatusInterval = setInterval(refreshLiveViewerCount, 3000);
        liveInterval = setInterval(() => {
            liveTimerSeconds++;
            document.getElementById('liveTimer').innerText = String(Math.floor(liveTimerSeconds / 60)).padStart(2, '0') + ':' + String(liveTimerSeconds % 60).padStart(2, '0');
        }, 1000);
    }
    function sendLiveComment() {
        const input = document.getElementById('liveChatInput');
        if (!input || !input.value.trim()) return;
        if (!sendLiveSignal('LIVE_CHAT', liveUsername, { text: input.value.trim(), profilePic: "${ub.getProfile_pic()}" })) {
            alert('Live connection is unavailable. Please reconnect and try again.');
            return;
        }
        input.value = '';
    }

    function appendLiveComment(name, text, profilePic, isSelf) {
        const chatBox = document.getElementById('liveChatBox');
        if (!chatBox) return;
        const row = document.createElement('div');
        row.className = 'flex items-start gap-2 animate-slide-in';
        const image = document.createElement('img');
        image.src = 'img/' + (profilePic || 'default-avatar.png');
        image.onerror = () => { image.src = 'icons/icon-192.png'; };
        image.className = 'w-7 h-7 rounded-full border border-white/10 object-cover shadow-sm';
        const body = document.createElement('div');
        body.className = (isSelf ? 'bg-blue-900/40 border border-blue-500/20' : 'bg-[#3A3B3C]') + ' rounded-xl px-3 py-2 max-w-[85%] shadow-sm';
        const author = document.createElement('p');
        author.className = 'text-[11px] font-bold mb-0.5 ' + (isSelf ? 'text-blue-300' : 'text-gray-300');
        author.textContent = name;
        const message = document.createElement('p');
        message.className = 'text-[13px] text-white leading-tight';
        message.textContent = text;
        body.append(author, message);
        if (liveUsername && name !== liveUsername && !isSelf) {
            const controls=document.createElement('div'); controls.className='flex gap-2 mt-1';
            [['Mute','mute'],['Block','block']].forEach(([label,action])=>{const b=document.createElement('button');b.textContent=label;b.className='text-[10px] text-red-300 hover:text-white';b.onclick=()=>sendLiveSignal('LIVE_MODERATE',liveUsername,{target:name,action});controls.appendChild(b);});
            body.appendChild(controls);
        }
        row.append(image, body);
        chatBox.appendChild(row);
        chatBox.scrollTop = chatBox.scrollHeight;
    }

    function triggerLiveReaction(type) {
        const emojiMap = { Like:'👍', Love:'❤️', Care:'🥰', Haha:'😆', Wow:'😮', Sad:'😢', Angry:'😡', Dislike:'👎' };
        const emoji = emojiMap[type] || '👍';
        if (!sendLiveSignal('LIVE_REACTION', liveUsername, { emoji })) alert('Live connection is unavailable.');
    }

    function appendLiveSystemMessage(text) {
        const chatBox = document.getElementById('liveChatBox');
        if (!chatBox) return;
        const row = document.createElement('div');
        row.className = 'flex items-center justify-center py-1 animate-slide-in';
        const label = document.createElement('span');
        label.className = 'text-[10px] text-gray-400 bg-white/5 px-2.5 py-1 rounded-full border border-white/5';
        label.textContent = text;
        row.appendChild(label);
        chatBox.appendChild(row);
        chatBox.scrollTop = chatBox.scrollHeight;
    }
    function createFloatingEmoji(emoji) {
        let container = document.getElementById('floatingEmojiContainer');
        if (!container) return;
        
        let el = document.createElement('div');
        el.innerText = emoji;
        el.className = 'absolute text-2xl select-none pointer-events-none transition-all duration-1000 ease-out z-[99]';
        
        let startX = Math.random() * 60 + 20; 
        el.style.left = startX + '%';
        el.style.bottom = '10%';
        el.style.opacity = '1';
        el.style.transform = 'scale(0.5)';
        
        container.appendChild(el);
        
        // Force reflow
        el.offsetHeight;
        
        let endX = startX + (Math.random() * 40 - 20); 
        let endY = Math.random() * 40 + 50; 
        let scale = Math.random() * 1.5 + 0.8;
        
        el.style.left = endX + '%';
        el.style.bottom = endY + '%';
        el.style.opacity = '0';
        el.style.transform = 'scale(' + scale + ') rotate(' + (Math.random() * 40 - 20) + 'deg)';
        
        setTimeout(() => {
            el.remove();
        }, 1000);
    }

    function endLiveStream() {
        clearInterval(liveInterval);
        clearInterval(fakeCommentsInterval);
        clearInterval(liveStatusInterval);
        
        let btn = document.getElementById('endLiveBtn');
        btn.innerText = "Posting Live Video...";
        btn.disabled = true;
        fetch(contextPath + "/LiveServlet?action=end", { method: "POST" }).catch(error => console.warn("Could not end live session on server:", error));

        if (mediaRecorder && mediaRecorder.state !== "inactive") {
            mediaRecorder.onstop = function() {
                const recordingType = mediaRecorder.mimeType || "video/webm";
                const blob = new Blob(recordedChunks, { type: recordingType });
                if (!blob.size) {
                    alert("No live recording was captured, so there is nothing to save.");
                    document.getElementById('endLiveBtn').classList.add('hidden');
                    closeLiveModal();
                    return;
                }
                const title = document.getElementById('liveTitle').value.trim() || "Live Broadcast";
                const safeTitle = title.replace(/[^a-z0-9_-]+/gi, "_").replace(/^_+|_+$/g, "").slice(0, 60) || "live";
                const downloadName = "ychat-live-" + safeTitle + "-" + new Date().toISOString().replace(/[:.]/g, "-") + ".webm";
                const recordingUrl = URL.createObjectURL(blob);
                const downloadLink = document.createElement("a");
                downloadLink.href = recordingUrl;
                downloadLink.download = downloadName;
                document.body.appendChild(downloadLink);
                downloadLink.click();
                downloadLink.remove();
                setTimeout(() => URL.revokeObjectURL(recordingUrl), 60000);
                const file = new File([blob], downloadName, { type: recordingType });
                
                let formData = new FormData();
                formData.append("ajax", "true");
                formData.append("type", "video");
                formData.append("content", title);
                formData.append("media", file);

                fetch('UsersPostServlet?ajax=true', { method: 'POST', body: formData })
                .then(res => res.json())
                .then(data => {
                    if(data.success) {
                        alert("Live recording downloaded and posted to your Y-ChatApp feed.");
                        refreshFeed();
                    } else {
                        alert("Live recording was downloaded, but could not be posted to your Y-ChatApp feed.");
                    }
                })
                .catch(err => {
                    console.error("Upload error: ", err);
                    alert("Live recording was downloaded, but feed upload failed.");
                })
                .finally(() => {
                    document.getElementById('endLiveBtn').classList.add('hidden');
                    closeLiveModal();
                });
            };
            mediaRecorder.stop();
        } else {
            btn.classList.add('hidden');
            closeLiveModal();
        }
    }

    function resetLiveUI() {
        document.getElementById('liveSetupOverlay').classList.remove('hidden');
        document.getElementById('goLiveBtn').disabled = true;
        document.getElementById('goLiveBtn').classList.remove('hidden');
        document.getElementById('endLiveBtn').classList.add('hidden');
        document.getElementById('endLiveBtn').innerText = "End Live Video";
        document.getElementById('endLiveBtn').disabled = false;
        document.getElementById('liveTitle').disabled = false;
        document.getElementById('liveTitle').value = '';
        
        let fallback = document.getElementById("liveFallbackBox");
        if(fallback) fallback.remove();
        document.getElementById('liveVideo').style.display = 'block';
        
        document.getElementById('liveBadge').classList.add('hidden');
        document.getElementById('liveTimer').classList.add('hidden');
        document.getElementById('liveTimer').innerText = '00:00';
        document.getElementById('liveViewers').classList.add('hidden');
        document.getElementById('viewerCount').innerText = '0';
        
        document.getElementById('chatPlaceholder').classList.remove('hidden');
        document.getElementById('liveChatBox').classList.add('hidden');
        document.getElementById('liveChatBox').innerHTML = '';
        document.getElementById('liveReactionPanel').classList.add('hidden');
        document.getElementById('liveChatInputArea').classList.add('hidden');
        
        fakeViewers = 0;
        livePeers.forEach(peer => peer.close());
        livePeers.clear();
    }

    // --- Reels Functions ---
    function openReelModal() {
        const modal = document.getElementById('reelModal');
        if (modal) {
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
        }
    }

    function closeReelModal() {
        const modal = document.getElementById('reelModal');
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    }

    function previewReel(input) {
        const preview = document.getElementById('reelPreview');
        const video = document.getElementById('reelVideoPreview');
        if (input.files && input.files[0]) {
            const url = URL.createObjectURL(input.files[0]);
            video.src = url;
            preview.classList.remove('hidden');
        }
    }

    function openReelViewer(reelId) {
        const reel = document.querySelector(`[data-reel-id="${reelId}"]`);
        if (!reel) return;

        const source = reel.querySelector('source');
        const userName = reel.querySelector('.reel-owner-name');
        const userPic = reel.querySelector('.reel-owner-pic');
        if (!source || !userName || !userPic) return;

        const viewer = document.getElementById('reelViewer');
        const viewerVideo = document.getElementById('viewerVideo');
        viewerVideo.src = source.src;
        document.getElementById('viewerUserName').innerText = userName.innerText;
        document.getElementById('viewerUserPic').src = userPic.src;
        viewer.style.display = 'flex';
        viewerVideo.play().catch(() => {});
    }
    function closeReelViewer() {
        const viewer = document.getElementById('reelViewer');
        const viewerVideo = document.getElementById('viewerVideo');
        viewerVideo.pause();
        viewerVideo.src = "";
        viewer.style.display = 'none';
    }

    // ১. ৮টি রিঅ্যাকশন হ্যান্ডলার (পোস্ট, কমেন্ট, রিপ্লাই সবার জন্য)
    function handleAJAXReact(id, type, level, event) {
        // Prevent click bubbling to parent elements
        if (event && event.stopPropagation) {
            event.stopPropagation();
        }
        document.querySelectorAll('.react-box-open').forEach(b => b.classList.remove('react-box-open'));

        let targetUrl = (level === 'post') ? 'InteractionServlet' : 'CommentServlet';
        
        // FormData ব্যবহার করতে হবে কারণ উভয় Servlet-এ @MultipartConfig আছে
        // @MultipartConfig থাকলে URLSearchParams দিয়ে পাঠানো data getParameter() এ পাওয়া যায় না
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
            body: formData  // Content-Type header সেট করা উচিত নয়, browser নিজে সেট করবে multipart/form-data boundary সহ
        })
        .then(res => {
            const contentType = res.headers.get('content-type');
            if (contentType && contentType.includes('application/json')) {
                return res.json();
            }
            return res.text().then(txt => { throw new Error('Non-JSON response: ' + txt.substring(0, 200)); });
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
                    let countSpan = document.getElementById(`react-count-\${id}`);
                    if (countSpan) {
                        if (data.newCount > 0) {
                            countSpan.innerHTML = countsHtml;
                        } else {
                            countSpan.innerText = '0';
                        }
                    }
                    // Visual feedback for post reaction
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
                console.warn('Reaction server response:', data);
            }
        })
        .catch(err => console.error('Reaction Error:', err));
    }
    window.handleAJAXReact = handleAJAXReact;

    // Safari / Mobile Touch long-press & click support for reaction tray
    document.addEventListener('touchstart', function(e) {
        const btn = e.target.closest('[id^="post-action-btn-"]');
        if (btn) {
            btn._touchTimer = setTimeout(function() {
                const container = btn.closest('.react-container');
                const box = container ? container.querySelector('.react-box') : null;
                if (box) {
                    document.querySelectorAll('.react-box-open').forEach(b => b.classList.remove('react-box-open'));
                    box.classList.add('react-box-open');
                }
            }, 350);
        }
    }, { passive: true });
    document.addEventListener('touchend', function(e) {
        const btn = e.target.closest('[id^="post-action-btn-"]');
        if (btn && btn._touchTimer) {
            clearTimeout(btn._touchTimer);
            btn._touchTimer = null;
        }
    }, { passive: true });
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.react-container')) {
            document.querySelectorAll('.react-box-open').forEach(b => b.classList.remove('react-box-open'));
        }
    });

    function submitCommentAJAX(postId) {
        let input = document.getElementById('input-post-' + postId);
        let fileInput = document.getElementById('commentMedia-' + postId);
        let hasText = input && input.value.trim();
        let hasFile = fileInput && fileInput.files[0];
        if (!hasText && !hasFile) return;  // Need at least text OR media

        let formData = new FormData();
        formData.append("postId", postId);
        formData.append("comment_text", hasText ? input.value : "");
        formData.append("action", "ADD_COMMENT");
        if (hasFile) {
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
                        <div class="flex flex-col gap-2 group/cmt mb-4">
                            <div class="flex gap-2">
                                <img src="img/\${data.userPic}" class="w-8 h-8 rounded-full border shadow-sm cursor-pointer" onclick="location.href='UsersProfileServlet?userId=\${data.userId}'">
                                <div class="flex flex-col flex-1">
                                    <div class="bg-white/50 px-4 py-2 rounded-2xl shadow-sm inline-block max-w-fit">
                                        <p class="font-bold text-[13px] hover:underline cursor-pointer" onclick="location.href='UsersProfileServlet?userId=\${data.userId}'">\${data.userName}</p>
                                        <p class="text-[14px] text-gray-700">\${data.text}</p>
                                        \${data.fileName ? '<img src="img/' + data.fileName + '" class="mt-2 rounded-xl max-h-40 border shadow-sm">' : ''}
                                    </div>
                                    <div class="flex gap-4 ml-4 mt-1 text-[11px] font-bold text-gray-500 items-center">
                                        <div class="react-container clickable">
                                            <span class="hover:text-blue-600 transition" onclick="handleAJAXReact(\${data.commentId}, 'Like', 'comment', event)">Like</span>
                                            <div class="react-box !p-1 !rounded-full">
                                                <span title="Like" onclick="handleAJAXReact(\${data.commentId}, 'Like', 'comment', event)">👍</span>
                                                <span title="Love" onclick="handleAJAXReact(\${data.commentId}, 'Love', 'comment', event)">❤️</span>
                                                <span title="Care" onclick="handleAJAXReact(\${data.commentId}, 'Care', 'comment', event)">🥰</span>
                                                <span title="Haha" onclick="handleAJAXReact(\${data.commentId}, 'Haha', 'comment', event)">😆</span>
                                                <span title="Wow" onclick="handleAJAXReact(\${data.commentId}, 'Wow', 'comment', event)">😮</span>
                                                <span title="Sad" onclick="handleAJAXReact(\${data.commentId}, 'Sad', 'comment', event)">😢</span>
                                                <span title="Angry" onclick="handleAJAXReact(\${data.commentId}, 'Angry', 'comment', event)">😡</span>
                                                <span title="Dislike" onclick="handleAJAXReact(\${data.commentId}, 'Dislike', 'comment', event)">👎</span>
                                            </div>
                                        </div>
                                        <span class="clickable hover:text-blue-600 transition" onclick="showReplyBox(\${data.commentId}, '\${escapedName}')">Reply</span>
                                        <span class="clickable hover:text-blue-600 transition" onclick="shareCommentOrReply(this)">Share</span>
                                        <div id="comment-react-container-\${data.commentId}" class="text-[10px] font-normal text-gray-400"></div>
                                    </div>

                                    <!-- Reply List -->
                                    <div id="reply-list-\${data.commentId}" class="mt-2 space-y-2 ml-10"></div>

                                    <!-- Reply Input Box -->
                                    <div id="replyInputContainer-\${data.commentId}" class="hidden mt-2 ml-10 relative">
                                        <div class="flex gap-2">
                                            <img src="img/\${data.userPic}" class="w-7 h-7 rounded-full border shadow-sm" width="28px">
                                            <div class="flex-1 bg-white/40 backdrop-blur-sm rounded-2xl px-3 py-1.5 flex items-center border border-white/20">
                                                <input type="text" id="input-reply-\${data.commentId}" placeholder="Write a reply..." class="bg-transparent outline-none flex-1 text-[12px] font-medium"
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
                                </div>
                            </div>
                        </div>`;
                    list.insertAdjacentHTML('beforeend', html);
                }
                input.value = '';
                if (fileInput) fileInput.value = '';
                removeCommentMedia(postId); // Helper to hide preview
            }
        });
    }

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
                        <div class="comment-level-2 mb-2 flex gap-2">
                            <a href="UsersProfileServlet?userId=\${data.userId}">
                                <img src="img/\${data.userPic}" class="w-7 h-7 rounded-full border shadow-sm">
                            </a>
                            <div class="flex flex-col flex-1">
                                <div class="bg-white/40 px-3 py-1.5 rounded-2xl inline-block max-w-fit shadow-sm">
                                    <p class="font-bold text-[12px]"><a href="UsersProfileServlet?userId=\${data.userId}" class="hover:underline">\${data.userName}</a></p>
                                    <p class="text-[13px] text-gray-700">\${data.text}</p>
                                    \${data.fileName ? '<img src="img/' + data.fileName + '" class="mt-1 rounded-lg max-h-32 border shadow-sm">' : ''}
                                </div>
                                <div class="flex gap-4 ml-3 mt-0.5 text-[10px] font-bold text-gray-500 items-center">
                                    <div class="react-container clickable">
                                        <span class="hover:text-blue-600 transition" onclick="handleAJAXReact(\${data.replyId}, 'Like', 'reply', event)">Like</span>
                                        <div class="react-box !p-1 !rounded-full">
                                            <span title="Like" onclick="handleAJAXReact(\${data.replyId}, 'Like', 'reply', event)">👍</span>
                                            <span title="Love" onclick="handleAJAXReact(\${data.replyId}, 'Love', 'reply', event)">❤️</span>
                                            <span title="Care" onclick="handleAJAXReact(\${data.replyId}, 'Care', 'reply', event)">🥰</span>
                                            <span title="Haha" onclick="handleAJAXReact(\${data.replyId}, 'Haha', 'reply', event)">😆</span>
                                            <span title="Wow" onclick="handleAJAXReact(\${data.replyId}, 'Wow', 'reply', event)">😮</span>
                                            <span title="Sad" onclick="handleAJAXReact(\${data.replyId}, 'Sad', 'reply', event)">😢</span>
                                            <span title="Angry" onclick="handleAJAXReact(\${data.replyId}, 'Angry', 'reply', event)">😡</span>
                                            <span title="Dislike" onclick="handleAJAXReact(\${data.replyId}, 'Dislike', 'reply', event)">👎</span>
                                        </div>
                                    </div>
                                    <span class="clickable hover:text-blue-600 transition" onclick="showReplyBox(\${commentId}, '\${escapedName}')">Reply</span>
                                    <span class="clickable hover:text-blue-600 transition" onclick="shareCommentOrReply(this)">Share</span>
                                    <div id="reply-react-container-\${data.replyId}" class="text-[9px] font-normal text-gray-400"></div>
                                </div>
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

    function shareCommentOrReply(element) {
        let container = element.closest('.flex-1');
        if(container) {
            let textNode = container.querySelector('p.text-gray-700');
            if(textNode) {
                let text = textNode.innerText;
                if(!confirm("Share this comment/reply to your timeline?")) return;
                
                let formData = new FormData();
                formData.append("ajax", "true");
                formData.append("content", "Shared a comment: \"" + text + "\"");
                
                fetch('UsersPostServlet?ajax=true', { method: 'POST', body: formData })
                .then(res => res.json())
                .then(data => {
                    if(data.success) {
                        alert("Shared to your timeline successfully!");
                        refreshFeed();
                    } else {
                        alert("Failed to share.");
                    }
                })
                .catch(err => {
                    console.error("Share error: ", err);
                    alert("Error sharing comment.");
                });
            }
        }
    }

    // 4. Share logic
    function shareAJAX(postId) {
        if(!confirm("Share this post?")) return;
        fetch('InteractionServlet', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: "action=SHARE&postId=" + postId
        })
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
                alert("Share failed: " + data.error);
            }
        })
        .catch(err => console.error("Share error", err));
    }

    function draftKey(){return 'ychat-post-draft-'+'${ub.getId()}';}
    function togglePollCreate(){const box=document.getElementById('pollCreateSection');box.classList.toggle('hidden');if(!box.classList.contains('hidden'))box.querySelector('input[name="pollQuestion"]').focus();}
    function addPollOptionInput(){const list=document.getElementById('pollOptionInputs');if(list.querySelectorAll('input').length>=6){alert('A poll can have up to 6 options.');return;}const input=document.createElement('input');input.name='pollOption';input.maxLength=255;input.placeholder='Option '+(list.querySelectorAll('input').length+1);input.className='w-full bg-white border rounded-lg px-3 py-2 text-sm';list.appendChild(input);input.focus();}
    function escapePollText(value){const d=document.createElement('div');d.textContent=value==null?'':String(value);return d.innerHTML;}
    async function submitPollVote(postId,optionId,button){button.disabled=true;try{const body=new URLSearchParams({action:'vote',postId:String(postId),optionId:String(optionId)});const res=await fetch('PollServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded;charset=UTF-8'},body});const data=await res.json();if(data.status!=='success')throw new Error(data.message||'Could not vote');const card=document.getElementById('poll-'+postId);const options=data.options||[];card.innerHTML='<h3 class="font-bold text-gray-800 mb-3"></h3>'+options.map(o=>'<div class="relative overflow-hidden rounded-xl border border-indigo-100 bg-white mb-2"><div class="absolute inset-y-0 left-0 bg-indigo-100" style="width:'+Number(o.percentage||0)+'%"></div><div class="relative flex justify-between px-3 py-2 text-sm"><span>'+escapePollText(o.optionText)+'</span><span class="font-bold">'+Number(o.percentage||0)+'% · '+Number(o.voteCount||0)+'</span></div></div>').join('')+'<p class="text-xs text-gray-500 mt-2">Vote recorded</p>';card.querySelector('h3').textContent=card.dataset.question||'';}catch(e){alert(e.message);button.disabled=false;}}
    function savePostDraft(){const f=document.getElementById('postForm');localStorage.setItem(draftKey(),JSON.stringify({content:f.elements.content.value,feeling:f.elements.feeling.value}));alert('Draft saved on this device.');}
    function loadPostDraft(){const d=JSON.parse(localStorage.getItem(draftKey())||'null');if(!d){alert('No saved draft.');return;}const f=document.getElementById('postForm');f.elements.content.value=d.content||'';f.elements.feeling.value=d.feeling||'';openModal();}
    async function openNotificationPrefs(){
      for (const [category,label] of [['posts','Post activity'],['messages','Messenger'],['live','Live broadcasts'],['friends','Friend requests']]) {
        const enabled=confirm(label+' notifications: OK = enabled, Cancel = disabled');
        const body=new URLSearchParams({category,enabled:String(enabled)});
        try { const r=await fetch('NotificationPreferencesServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body}); if(!r.ok) throw new Error('Save failed'); }
        catch(e){ alert('Could not save '+label+' preference.'); return; }
      }
      alert('Notification preferences saved to your account.');
    }
    // 5. Submit new post (AJAX)
    var postFormEl = document.getElementById('postForm');
    if (postFormEl) postFormEl.addEventListener('submit', function(e) {
        e.preventDefault();
        let formData = new FormData(this);
        formData.append("ajax", "true");
        
        const btn = this.querySelector('button[type="submit"]');
        const originalText = btn.innerText;
        btn.innerText = "Posting...";
        btn.disabled = true;

        fetch('UsersPostServlet?ajax=true', { method: 'POST', body: formData })
        .then(res => {
            if (!res.ok) {
                throw new Error("HTTP error " + res.status);
            }
            return res.json();
        })
        .then(data => {
            if(data.success) {
                if(formData.get('scheduledAt')) alert('Post scheduled. It will appear after the selected time.');
                else localStorage.removeItem(draftKey());
                closeModal();
                this.reset();
                removeModalPreview();
                refreshFeed();
            } else {
                alert("Post failed!");
            }
        })
        .catch(err => {
            console.error("Post creation error:", err);
            alert("Post creation failed: " + err.message);
        })
        .finally(() => {
            btn.innerText = originalText;
            btn.disabled = false;
        });
    });

    // 6. Submit Reels (AJAX)
    var reelFormEl = document.getElementById('reelForm');
    if (reelFormEl) reelFormEl.addEventListener('submit', function(e) {
        e.preventDefault();
        let formData = new FormData(this);
        formData.append("ajax", "true");
        
        const btn = this.querySelector('button[type="submit"]');
        btn.innerText = "Uploading...";
        btn.disabled = true;

        fetch('UsersPostServlet?ajax=true', { method: 'POST', body: formData })
        .then(res => {
            if (!res.ok) throw new Error("HTTP error " + res.status);
            return res.json();
        })
        .then(data => {
            if(data.success) {
                closeReelModal();
                this.reset();
                refreshFeed();
            } else {
                alert("Reel failed!");
            }
        })
        .catch(err => {
            console.error("Reel upload error:", err);
            alert("Reel upload failed: " + err.message);
        })
        .finally(() => {
            btn.innerText = "Share Reel";
            btn.disabled = false;
        });
    });

    function togglePostMenu(event, postId) {
        if (event && event.stopPropagation) event.stopPropagation();
        const menu = document.getElementById('post-menu-' + postId);
        const shouldOpen = menu && menu.classList.contains('hidden');
        document.querySelectorAll('[id^="post-menu-"]').forEach(item => item.classList.add('hidden'));
        document.querySelectorAll('button[aria-controls^="post-menu-"]').forEach(button => button.setAttribute('aria-expanded', 'false'));
        if (shouldOpen) {
            menu.classList.remove('hidden');
            if (event && event.currentTarget && event.currentTarget.setAttribute) {
                event.currentTarget.setAttribute('aria-expanded', 'true');
            }
        }
    }
    window.togglePostMenu = togglePostMenu;
    window.toggleSavePost = toggleSavePost;
    window.deletePost = deletePost;
    window.hidePost = hidePost;
    window.reportPost = reportPost;
    window.focusCmt = focusCmt;
    window.shareAJAX = shareAJAX;

    document.addEventListener('click', function(event) {
        if (!event.target.closest('[id^="post-menu-"]') && !event.target.closest('button[aria-controls^="post-menu-"]')) {
            document.querySelectorAll('[id^="post-menu-"]').forEach(menu => menu.classList.add('hidden'));
            document.querySelectorAll('button[aria-controls^="post-menu-"]').forEach(button => button.setAttribute('aria-expanded', 'false'));
        }
    });

    function sendHideReport(action, postId, reason) {
        const params = new URLSearchParams();
        params.append('action', action);
        params.append('type', 'POST');
        params.append('id', String(postId));
        if (reason) params.append('reason', reason);
        params.append('details', '');
        return fetch('ReportHideServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
            body: params
        }).then(res => {
            if (!res.ok) throw new Error('HTTP error ' + res.status);
            return res.json();
        });
    }

    function hidePost(postId) {
        sendHideReport('hide', postId).then(data => {
            if (data.success) {
                const card = document.querySelector('[data-post-id="' + postId + '"]');
                if (card) card.style.display = 'none';
                refreshFeed();
            } else {
                alert(data.message || 'Could not hide this post.');
            }
        }).catch(err => {
            console.error('Hide post error:', err);
            alert('Could not hide this post. Please try again.');
        });
    }

    function markNotInterested(postId) {
        hidePost(postId);
    }

    function snoozePost(postId, days) {
        sendHideReport('hide', postId).then(data => {
            const card = document.querySelector('[data-post-id="' + postId + '"]');
            if (card) card.style.display = 'none';
            alert('Snoozed for ' + (days || 7) + ' days.');
        }).catch(() => {
            const card = document.querySelector('[data-post-id="' + postId + '"]');
            if (card) card.style.display = 'none';
        });
    }

    function reportPost(postId) {
        const reason = prompt('Why are you reporting this post?', 'Inappropriate content');
        if (reason === null || !reason.trim()) return;
        sendHideReport('report', postId, reason.trim()).then(data => {
            alert(data.success ? 'Report submitted. Thank you.' : (data.message || 'Could not submit the report.'));
        }).catch(err => {
            console.error('Report post error:', err);
            alert('Could not submit the report. Please try again.');
        });
    }
    // Delete Post Function
    function deletePost(postId) {
        if(!confirm("Are you sure you want to delete this post?")) return;
        
        let formData = new FormData();
        formData.append("action", "DELETE");
        formData.append("postId", postId);
        formData.append("ajax", "true");

        fetch('UsersPostServlet?ajax=true', { method: 'POST', body: formData })
        .then(res => {
            if (!res.ok) throw new Error("HTTP error " + res.status);
            return res.json();
        })
        .then(data => {
            if(data.success) {
                refreshFeed();
            } else {
                alert("Failed to delete post.");
            }
        })
        .catch(err => {
            console.error("Delete error: ", err);
            window.location.reload();
        });
    }

    // 7. Refresh feed function
    function refreshFeed() {
        fetch('UsersPostServlet')
        .then(res => res.text())
        .then(html => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');
            const newMain = doc.querySelector('main').innerHTML;
            document.querySelector('main').innerHTML = newMain;
            initTimeAgo();
            if (typeof window.enhanceNewsFeedPosts === 'function') {
                window.enhanceNewsFeedPosts();
            }
        });
    }

    function initTimeAgo() {
        console.log("Feed Refreshed!");
    }

    function showReplyBox(id, targetName) {
        let el = document.getElementById('replyInputContainer-' + id);
        if(el) {
            el.classList.remove('hidden');
            let input = document.getElementById('input-reply-' + id);
            if(input) {
                if (targetName) input.value = "@" + targetName + " ";
                if (input.scrollIntoView) input.scrollIntoView({ behavior: 'smooth', block: 'center' });
                input.focus();
            }
        }
    }
    function focusCmt(id) { 
        let input = document.getElementById('input-post-' + id);
        if(input) {
            input.focus();
            let wrap = input.parentElement;
            if (wrap) {
                wrap.style.boxShadow = '0 0 0 3px rgba(37, 99, 235, 0.45)';
                wrap.style.borderColor = '#2563eb';
                setTimeout(function() {
                    wrap.style.boxShadow = '';
                    wrap.style.borderColor = '';
                }, 1500);
            }
        }
    }
    function focusFeelingSelector() {
        const select = document.querySelector('#postForm select[name="feeling"]');
        if (!select) return;
        select.focus();
        if (typeof select.showPicker === 'function') {
            try { select.showPicker(); } catch (e) { /* Focus still allows keyboard selection. */ }
        }
    }

    function toggleTagSection() { 
        let tag = document.getElementById('tagSection');
        if(tag) tag.classList.toggle('hidden'); 
    }

    // --- Modal Functions ---
    window.openModal = function() { window.lastModalOpenedTime = Date.now();
        const modal = document.getElementById('postModal');
        if (modal) {
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden';
            setTimeout(function() {
                const ta = modal.querySelector('textarea[name="content"]');
                if (ta) ta.focus();
            }, 120);
        }
    };
    function openModal() { window.openModal(); }

    window.closeModal = function() {
        const modal = document.getElementById('postModal');
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    };
    function closeModal() { window.closeModal(); }

    // Close modal when clicking outside backdrop (guarded against iOS Safari 300ms synthetic ghost click)
    document.addEventListener('click', function(event) {
        if (typeof lastModalOpenedTime !== 'undefined' && (Date.now() - lastModalOpenedTime < 450)) return;
        const postModal = document.getElementById('postModal');
        if (event.target === postModal) {
            closeModal();
        }
        const liveModal = document.getElementById('liveModal');
        if (event.target === liveModal && (!liveStream || document.getElementById('endLiveBtn').classList.contains('hidden'))) {
            closeLiveModal();
        }
    });

    // --- Media Preview Functions ---
    function previewModalImage(input) {
        const preview = document.getElementById('modalImagePreview');
        const container = document.getElementById('modalPreviewContainer');
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            reader.onload = function(e) {
                if (preview) preview.src = e.target.result;
                if (container) container.classList.remove('hidden');
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    function removeModalPreview() {
        const input = document.getElementById('modalFileInput');
        const preview = document.getElementById('modalImagePreview');
        const container = document.getElementById('modalPreviewContainer');
        if (input) input.value = "";
        if (preview) preview.src = "#";
        if (container) container.classList.add('hidden');
    }

    function previewCommentMedia(event, postId) {
        const preview = document.getElementById('commentImgPreview-' + postId);
        const container = document.getElementById('commentPreview-' + postId);
        const file = event.target.files[0];
        if (file && preview && container) {
            const reader = new FileReader();
            reader.onload = function(e) {
                preview.src = e.target.result;
                preview.classList.remove('hidden');
                container.classList.remove('hidden');
            }
            reader.readAsDataURL(file);
        }
    }

    function removeCommentMedia(postId) {
        const input = document.getElementById('commentMedia-' + postId);
        const preview = document.getElementById('commentImgPreview-' + postId);
        const container = document.getElementById('commentPreview-' + postId);
        if (input) input.value = "";
        if (preview) {
            preview.src = "";
            preview.classList.add('hidden');
        }
        if (container) container.classList.add('hidden');
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

    // --- Other UI Functions ---
    function toggleEmojiPicker(id) {
        const picker = document.getElementById(id);
        if (picker) {
            // Close other pickers first
            document.querySelectorAll('[id^="emoji-picker-"]').forEach(p => {
                if (p.id !== id) p.classList.add('hidden');
            });
            picker.classList.toggle('hidden');
        }
    }

    function addEmoji(inputId, emoji) {
        const input = document.getElementById(inputId);
        if (input) {
            input.value += emoji;
            input.focus();
        }
    }
    
    function showReactionList(postId) {
        // Placeholder for reaction list
        console.log("Showing reactions for post: " + postId);
    }

    function previewMedia(event, type, id) {
        // Placeholder for other media previews
        console.log("Previewing media for " + type + " id: " + id);
    }

    // Close emoji pickers when clicking outside
    document.addEventListener('click', function(event) {
        if (!event.target.closest('.relative')) {
            document.querySelectorAll('[id^="emoji-picker-"]').forEach(p => p.classList.add('hidden'));
        }
    });

    // --- Saved Posts & Memories Features JS ---
    function toggleSavePost(postId, btn) {
        let isSaved = btn.innerText.includes("Unsave");
        let action = isSaved ? "UNSAVE" : "SAVE";
        
        fetch('FeaturesServlet?action=' + action + '&postId=' + postId, { method: 'POST' })
        .then(res => res.json())
        .then(data => {
            if(data.success) {
                if(action === "SAVE") {
                    btn.innerHTML = '<i class="fa fa-bookmark"></i> Unsave Post';
                    alert("Post Saved successfully!");
                } else {
                    btn.innerHTML = '<i class="fa fa-bookmark"></i> Save Post';
                    alert("Post Unsaved successfully!");
                }
            } else {
                alert("Action failed!");
            }
        })
        .catch(err => {
            console.error("Save error:", err);
            alert("Error processing request");
        });
    }

    function openFeaturesModal(title) {
        document.getElementById('featuresModalTitle').innerText = title;
        document.getElementById('featuresModalBody').innerHTML = '<div class="text-center py-8"><i class="fa fa-spinner animate-spin text-2xl text-blue-500"></i><p class="mt-2 text-gray-400">Loading...</p></div>';
        document.getElementById('featuresModal').style.display = 'flex';
    }

    function closeFeaturesModal() {
        document.getElementById('featuresModal').style.display = 'none';
    }

    function showSavedPostsModal() {
        openFeaturesModal("Saved Posts");
        fetch('FeaturesServlet?action=GET_SAVED')
        .then(res => res.json())
        .then(posts => {
            renderFeaturePosts(posts, "No saved posts yet. Bookmarked posts will appear here!");
        })
        .catch(err => {
            document.getElementById('featuresModalBody').innerHTML = '<p class="text-red-500 text-center">Error loading saved posts.</p>';
        });
    }

    function showMemoriesModal() {
        openFeaturesModal("Throwback Memories");
        fetch('FeaturesServlet?action=GET_MEMORIES')
        .then(res => res.json())
        .then(posts => {
            renderFeaturePosts(posts, "No memories yet. Create some posts to see throwbacks!");
        })
        .catch(err => {
            document.getElementById('featuresModalBody').innerHTML = '<p class="text-red-500 text-center">Error loading memories.</p>';
        });
    }

    function renderFeaturePosts(posts, emptyMessage) {
        const container = document.getElementById('featuresModalBody');
        if (!posts || posts.length === 0) {
            container.innerHTML = '<div class="text-center py-12 text-gray-400"><i class="fa fa-folder-open text-4xl mb-3 text-gray-500"></i><p>' + emptyMessage + '</p></div>';
            return;
        }
        
        let html = '';
        posts.forEach(p => {
            let mediaHtml = '';
            if (p.fileName) {
                if (p.postType === 'video' || p.fileName.endsWith('.webm') || p.fileName.endsWith('.mp4')) {
                    mediaHtml = '<video src="img/' + p.fileName + '" controls class="w-full max-h-[250px] object-contain bg-black rounded-lg mt-2"></video>';
                } else {
                    mediaHtml = '<img src="img/' + p.fileName + '" class="w-full max-h-[250px] object-cover rounded-lg mt-2">';
                }
            }
            
            let feelingHtml = p.feeling ? '<span class="text-xs bg-white/10 px-2 py-0.5 rounded-full text-blue-300">is feeling ' + p.feeling + '</span>' : '';
            
            html += `
                <div class="bg-[#242526] p-4 rounded-2xl border border-gray-700 space-y-3">
                    <div class="flex items-center gap-3">
                        <img src="img/\${p.profile_Pic}" class="w-10 h-10 rounded-full border border-gray-600 object-cover">
                        <div>
                            <div class="font-bold flex items-center gap-2">\${p.getName()} \${feelingHtml}</div>
                            <div class="text-xs text-gray-400">\${p.getTime()}</div>
                        </div>
                    </div>
                    <p class="text-gray-200 text-sm leading-relaxed">\${p.getContent()}</p>
                    \${mediaHtml}
                </div>
            `;
        });
        container.innerHTML = html;
    }

    // --- Stories Functions ---
    function openStoryModal() {
        document.getElementById('storyModal').style.display = 'flex';
        document.body.style.overflow = 'hidden';
    }
    
    function closeStoryModal() {
        document.getElementById('storyModal').style.display = 'none';
        document.body.style.overflow = 'auto';
        removeStoryPreview();
    }
    
    function previewStoryMedia(input) {
        const previewImg = document.getElementById('storyImagePreview');
        const previewVideo = document.getElementById('storyVideoPreview');
        const container = document.getElementById('storyPreviewContainer');
        
        if (input.files && input.files[0]) {
            const file = input.files[0];
            const url = URL.createObjectURL(file);
            
            container.classList.remove('hidden');
            if (file.type.startsWith('video/')) {
                previewVideo.src = url;
                previewVideo.classList.remove('hidden');
                previewImg.classList.add('hidden');
                previewImg.src = "";
            } else {
                previewImg.src = url;
                previewImg.classList.remove('hidden');
                previewVideo.classList.add('hidden');
                previewVideo.src = "";
            }
        }
    }
    
    function removeStoryPreview() {
        const input = document.getElementById('storyMediaInput');
        const previewImg = document.getElementById('storyImagePreview');
        const previewVideo = document.getElementById('storyVideoPreview');
        const container = document.getElementById('storyPreviewContainer');
        
        if (input) input.value = "";
        if (previewImg) {
            previewImg.src = "#";
            previewImg.classList.add('hidden');
        }
        if (previewVideo) {
            previewVideo.src = "";
            previewVideo.classList.add('hidden');
        }
        if (container) container.classList.add('hidden');
    }

    function handleStoryClick(el) {
        if (!el) return;
        const name = el.getAttribute('data-name') || '';
        const pic = el.getAttribute('data-pic') || 'default.png';
        const media = el.getAttribute('data-media') || '';
        const text = el.getAttribute('data-text') || '';
        openStoryViewer(name, pic, media, text);
    }

    let storyTimeout = null;
    function openStoryViewer(name, profilePic, mediaUrl, text) {
        document.getElementById('storyViewerUserName').innerText = name || 'User';
        const userPicEl = document.getElementById('storyViewerUserPic');
        if (!profilePic || profilePic === 'null' || profilePic.trim() === '') {
            userPicEl.src = 'img/default.png';
        } else {
            userPicEl.src = profilePic.startsWith('img/') ? profilePic : 'img/' + profilePic;
        }
        userPicEl.onerror = function() { this.src = 'img/default.png'; };
        
        const imgEl = document.getElementById('storyViewerImage');
        const videoEl = document.getElementById('storyViewerVideo');
        const textContainer = document.getElementById('storyViewerTextContainer');
        const textEl = document.getElementById('storyViewerText');
        const captionContainer = document.getElementById('storyViewerCaptionContainer');
        const captionEl = document.getElementById('storyViewerCaption');
        
        imgEl.classList.add('hidden');
        videoEl.classList.add('hidden');
        textContainer.classList.add('hidden');
        if (captionContainer) captionContainer.classList.add('hidden');
        
        if (mediaUrl && mediaUrl !== 'null' && mediaUrl.trim() !== '') {
            const lowerMedia = mediaUrl.toLowerCase();
            const mediaSrc = mediaUrl.startsWith('img/') ? mediaUrl : 'img/' + mediaUrl;
            if (lowerMedia.endsWith('.mp4') || lowerMedia.endsWith('.webm') || lowerMedia.endsWith('.mov')) {
                videoEl.src = mediaSrc;
                videoEl.classList.remove('hidden');
                videoEl.currentTime = 0;
                videoEl.play().catch(e => console.log('Autoplay prevented:', e));
            } else {
                imgEl.src = mediaSrc;
                imgEl.classList.remove('hidden');
            }
            if (text && text.trim() !== '' && text !== 'null' && captionContainer && captionEl) {
                captionEl.innerText = text;
                captionContainer.classList.remove('hidden');
            }
        } else {
            textEl.innerText = text || '';
            textContainer.classList.remove('hidden');
        }
        
        document.getElementById('storyViewerModal').style.display = 'flex';
        document.body.style.overflow = 'hidden';
        
        // Reset and trigger progress bar
        const progressBar = document.getElementById('storyProgressBar');
        progressBar.style.transition = 'none';
        progressBar.style.width = '0%';
        
        setTimeout(() => {
            progressBar.style.transition = 'width 5000ms linear';
            progressBar.style.width = '100%';
        }, 50);

        // Auto close after 5 seconds
        if (storyTimeout) clearTimeout(storyTimeout);
        storyTimeout = setTimeout(() => {
            closeStoryViewer();
        }, 5050);
    }
    
    function closeStoryViewer() {
        document.getElementById('storyViewerModal').style.display = 'none';
        document.body.style.overflow = 'auto';
        
        const videoEl = document.getElementById('storyViewerVideo');
        if (videoEl) {
            videoEl.pause();
            videoEl.src = "";
        }
        
        if (storyTimeout) clearTimeout(storyTimeout);
    }

    function addFriendFromSidebar(targetId, btn) {
        if (!targetId || !btn) return;
        btn.disabled = true;
        btn.innerHTML = '<i class="fa fa-spinner fa-spin text-[10px]"></i> Adding...';
        
        fetch('FriendServlet', {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'targetId=' + encodeURIComponent(targetId) + '&action=ADD&ajax=true'
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                btn.className = 'px-3 py-1.5 bg-gray-200 text-gray-700 text-xs font-bold rounded-xl shrink-0 cursor-default';
                btn.innerHTML = '<i class="fa fa-check text-[10px] text-green-600"></i> Sent';
            } else {
                btn.disabled = false;
                btn.innerHTML = '<i class="fa fa-user-plus text-[10px]"></i> Add';
                alert(data.message || 'Could not send friend request.');
            }
        })
        .catch(err => {
            btn.disabled = false;
            btn.innerHTML = '<i class="fa fa-user-plus text-[10px]"></i> Add';
            console.error('Add friend error:', err);
        });
    }
</script>



			<!-- Mobile Bottom Navigation Bar (Visible only on mobile/tablet) -->
			<nav id="mobileBottomNav"
				class="lg:hidden fixed bottom-0 left-0 right-0 h-[65px] bg-white/95 backdrop-blur-md border-t border-gray-200 z-[99999] flex justify-around items-center px-2 rounded-t-3xl shadow-[0_-8px_30px_rgba(0,0,0,0.15)]">
				<a href="UsersPostServlet"
					class="flex flex-col items-center gap-1 text-blue-600"> <i
					class="fa fa-house text-xl"></i> <span
					class="text-[10px] font-bold">Home</span>
				</a> <a href="FriendServlet"
					class="flex flex-col items-center gap-1 text-gray-600 hover:text-blue-600 transition">
					<i class="fa fa-user-group text-xl"></i> <span
					class="text-[10px] font-bold">Friends</span>
				</a> <a href="#" onclick="openLiveModal(); return false;"
					class="flex flex-col items-center gap-1 text-red-500 animate-pulse">
					<i class="fa fa-video text-xl"></i> <span
					class="text-[10px] font-bold">Go Live</span>
				</a> <a href="messages.jsp"
					class="flex flex-col items-center gap-1 text-gray-600 hover:text-blue-600 transition">
					<i class="fa-brands fa-facebook-messenger text-xl"></i> <span
					class="text-[10px] font-bold">Messenger</span>
				</a> <a href="UsersProfileServlet?userId=${sessionScope.userId}"
					class="flex flex-col items-center gap-1 text-gray-600 hover:text-blue-600 transition">
					<img src="img/${ub.getProfile_pic()}"
					class="w-6 h-6 rounded-full border border-gray-300" onerror="this.src='img/default.png'"> <span
					class="text-[10px] font-bold">Profile</span>
				</a>
				<c:if test="${sessionScope.isAdmin or ub.isAdmin()}">
					<a href="admin"
						class="flex flex-col items-center gap-1 text-rose-500 font-bold hover:scale-110 transition">
						<i class="fa-solid fa-user-shield text-xl"></i> <span
						class="text-[10px]">Admin</span>
					</a>
				</c:if>
			</nav>

			<script src="js/theme.js?v=20261030-safari-v12"></script><script src="js/ychat-pro-features.js?v=20261030-safari-v12"></script>
			<!-- Story Viewers Modal -->
			<div id="storyViewersListModal" class="modal !bg-black/80 z-[100000]" style="display: none;">
				<div
					class="modal-content !max-w-[420px] !w-[92%] !bg-white rounded-3xl shadow-2xl overflow-hidden p-0 border border-gray-200">
					<div
						class="flex items-center justify-between p-4 border-b border-gray-100">
						<h3
							class="font-bold text-base text-gray-800 flex items-center gap-2">
							<i class="fa fa-eye text-blue-500"></i> Story Viewers
						</h3>
						<button type="button" onclick="closeStoryViewersModal()"
							class="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 flex items-center justify-center transition">
							<i class="fa fa-times text-sm"></i>
						</button>
					</div>
					<div id="storyViewersListBody"
						class="p-4 max-h-[350px] overflow-y-auto space-y-3 custom-scrollbar">
						<!-- Dynamically filled with viewers -->
					</div>
				</div>
			</div>

			<!-- Repost / Quote Post Modal -->
			<div id="repostModal" class="modal !bg-black/75 z-[9999]" style="display: none;">
				<div
					class="modal-content !max-w-[500px] !w-[92%] !bg-white rounded-3xl shadow-2xl overflow-hidden p-0 border border-gray-200">
					<div
						class="flex items-center justify-between p-4 border-b border-gray-100">
						<h3
							class="font-bold text-base text-gray-800 flex items-center gap-2">
							<i class="fa-solid fa-repeat text-indigo-500"></i> Repost to your
							feed
						</h3>
						<button type="button" onclick="closeRepostModal()"
							class="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 flex items-center justify-center transition">
							<i class="fa fa-times text-sm"></i>
						</button>
					</div>
					<div class="p-5 space-y-4">
						<textarea id="repostCommentaryInput" rows="3"
							placeholder="Add your thoughts or commentary (optional)..."
							class="w-full p-3 bg-gray-50 rounded-2xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-indigo-500 transition resize-none text-gray-800"></textarea>

						<div
							class="p-3.5 rounded-2xl border border-gray-200 bg-gray-50/80">
							<div class="flex items-center gap-2 mb-1.5">
								<i class="fa fa-user-circle text-gray-400 text-base"></i> <span
									id="repostPreviewAuthor"
									class="text-xs font-bold text-gray-700"></span>
							</div>
							<p id="repostPreviewSnippet"
								class="text-xs text-gray-600 line-clamp-3"></p>
						</div>

						<input type="hidden" id="repostTargetPostId">

						<div class="flex gap-3 pt-2">
							<button type="button" onclick="submitDirectShare()"
								class="flex-1 py-2.5 rounded-xl border border-gray-300 font-bold text-xs text-gray-700 hover:bg-gray-100 transition flex items-center justify-center gap-1.5">
								<i class="fa-solid fa-share"></i> Repost Directly
							</button>
							<button type="button" onclick="submitQuoteRepost()"
								class="flex-1 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-xs shadow-md hover:shadow-lg transition flex items-center justify-center gap-1.5">
								<i class="fa-solid fa-quote-left"></i> Quote with Thoughts
							</button>
						</div>
					</div>
				</div>
			</div>

			<!-- Animated GIF Picker Modal -->
			<div id="gifPickerModal" class="modal !bg-black/70 z-[100000]" style="display: none;">
				<div
					class="modal-content !max-w-[460px] !w-[92%] !bg-white rounded-3xl shadow-2xl overflow-hidden p-0 border border-gray-200">
					<div
						class="p-4 border-b border-gray-100 flex items-center justify-between">
						<h3
							class="font-bold text-sm text-gray-800 flex items-center gap-2">
							<span
								class="px-1.5 py-0.5 rounded bg-pink-500 text-white text-[10px] font-black tracking-wider">GIF</span>
							Select Animated GIF
						</h3>
						<button type="button" onclick="closeGifPickerModal()"
							class="w-7 h-7 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-600 flex items-center justify-center transition">
							<i class="fa fa-times text-xs"></i>
						</button>
					</div>
					<div class="p-3 bg-gray-50 border-b border-gray-100 space-y-2">
						<div class="relative">
							<i
								class="fa fa-search absolute left-3 top-2.5 text-gray-400 text-xs"></i>
							<input type="text" id="gifSearchInput"
								placeholder="Search animated GIFs (love, dance, happy, haha)..."
								oninput="debounceGifSearch(this.value)"
								class="w-full pl-8 pr-3 py-1.5 text-xs bg-white rounded-xl border border-gray-200 outline-none text-gray-800">
						</div>
						<div
							class="flex gap-1.5 overflow-x-auto pb-1 text-[11px] font-semibold custom-scrollbar">
							<button type="button" onclick="filterGifCategory('')"
								class="px-2.5 py-1 rounded-lg bg-pink-500 text-white shrink-0">Trending</button>
							<button type="button" onclick="filterGifCategory('happy')"
								class="px-2.5 py-1 rounded-lg bg-gray-200 text-gray-700 hover:bg-pink-100 shrink-0">Happy</button>
							<button type="button" onclick="filterGifCategory('love')"
								class="px-2.5 py-1 rounded-lg bg-gray-200 text-gray-700 hover:bg-pink-100 shrink-0">Love</button>
							<button type="button" onclick="filterGifCategory('dance')"
								class="px-2.5 py-1 rounded-lg bg-gray-200 text-gray-700 hover:bg-pink-100 shrink-0">Dance</button>
							<button type="button" onclick="filterGifCategory('applause')"
								class="px-2.5 py-1 rounded-lg bg-gray-200 text-gray-700 hover:bg-pink-100 shrink-0">Clap</button>
							<button type="button" onclick="filterGifCategory('laugh')"
								class="px-2.5 py-1 rounded-lg bg-gray-200 text-gray-700 hover:bg-pink-100 shrink-0">Haha</button>
						</div>
					</div>
					<div id="gifGridContainer"
						class="p-3 grid grid-cols-2 gap-2.5 max-h-[300px] overflow-y-auto custom-scrollbar">
						<!-- Dynamically populated GIFs -->
					</div>
				</div>
			</div>

			<script>
	// ================= STORY VIEWER & TRACKING =================
	let currentStoryIdBeingViewed = null;
	const currentAppUserId = Number("${not empty sessionScope.ub ? sessionScope.ub.getId() : (not empty ub ? ub.getId() : 0)}") || 0;

	const originalHandleStoryClick = window.handleStoryClick;
	window.handleStoryClick = function(el) {
		if (!el) return;
		const sId = el.getAttribute('data-id');
		const sUserId = el.getAttribute('data-userid');
		const sViews = el.getAttribute('data-views') || '0';
		currentStoryIdBeingViewed = sId;

		// Record view in background
		if (sId) {
			fetch('StoryServlet?action=recordView&storyId=' + sId)
				.catch(err => console.log('Story view record err:', err));
		}

		// Configure owner bar
		const ownerBar = document.getElementById('storyViewerOwnerBar');
		const countLabel = document.getElementById('storyViewerCountLabel');
		if (ownerBar && countLabel) {
			if (parseInt(sUserId) === currentAppUserId) {
				countLabel.innerText = sViews;
				ownerBar.classList.remove('hidden');
			} else {
				ownerBar.classList.add('hidden');
			}
		}

		// Call original viewer logic
		const name = el.getAttribute('data-name') || '';
		const pic = el.getAttribute('data-pic') || 'default.png';
		const media = el.getAttribute('data-media') || '';
		const text = el.getAttribute('data-text') || '';
		openStoryViewer(name, pic, media, text);
	};

	function openStoryViewersModalFromViewer() {
		if (!currentStoryIdBeingViewed) return;
		openStoryViewersModal(currentStoryIdBeingViewed);
	}

	function openStoryViewersModal(storyId) {
		const modal = document.getElementById('storyViewersListModal');
		const body = document.getElementById('storyViewersListBody');
		if (!modal || !body) return;

		body.innerHTML = '<div class="text-center py-6 text-gray-400 text-xs"><i class="fa fa-spinner fa-spin text-lg mb-2"></i><br>Loading viewers...</div>';
		modal.style.display = 'flex';

		fetch('StoryServlet?action=getViewers&storyId=' + storyId)
			.then(res => res.json())
			.then(viewers => {
				if (!viewers || viewers.length === 0) {
					body.innerHTML = '<div class="text-center py-8 text-gray-400 text-xs">No viewers yet</div>';
					return;
				}
				let html = '';
				viewers.forEach(v => {
					html += '<div class="flex items-center justify-between p-2 rounded-2xl hover:bg-gray-50 transition">' +
						'<div class="flex items-center gap-3">' +
							'<img src="img/' + (v.profilePic || 'default.png') + '" class="w-9 h-9 rounded-full object-cover border" onerror="this.src=\'img/default.png\'">' +
							'<div>' +
								'<p class="text-sm font-bold text-gray-800">' + v.name + '</p>' +
								'<p class="text-[10px] text-gray-400">' + (v.viewedAt || 'Just now') + '</p>' +
							'</div>' +
						'</div>' +
						'<a href="UsersProfileServlet?userId=' + v.userId + '" class="text-xs font-semibold text-blue-500 hover:underline">Profile</a>' +
					'</div>';
				});
				body.innerHTML = html;
			})
			.catch(err => {
				body.innerHTML = '<div class="text-center py-6 text-red-500 text-xs">Failed to load viewers</div>';
			});
	}

	function closeStoryViewersModal() {
		const modal = document.getElementById('storyViewersListModal');
		if (modal) modal.style.display = 'none';
	}

	// ================= REPOST / QUOTE POST =================
	function openRepostModal(postId) {
		const modal = document.getElementById('repostModal');
		const authorEl = document.getElementById('repostPreviewAuthor');
		const snippetEl = document.getElementById('repostPreviewSnippet');
		const targetPostInput = document.getElementById('repostTargetPostId');
		const commentaryInput = document.getElementById('repostCommentaryInput');

		if (!modal) return;

		// Extract post data from DOM
		const actionBtnEl = document.getElementById('post-action-btn-' + postId);
		const postCard = document.getElementById('post-' + postId) || document.querySelector('[data-post-id="' + postId + '"]') || (actionBtnEl ? actionBtnEl.closest('.glass-card') : null);
		let author = 'Friend';
		let snippet = 'Post';

		if (postCard) {
			const authorNode = postCard.querySelector('a.font-bold');
			if (authorNode) author = authorNode.innerText.trim();
			const contentNode = postCard.querySelector('.leading-relaxed');
			if (contentNode) snippet = contentNode.innerText.trim();
		}

		if (authorEl) authorEl.innerText = author;
		if (snippetEl) snippetEl.innerText = snippet.length > 120 ? snippet.substring(0, 120) + '...' : snippet;
		if (targetPostInput) targetPostInput.value = postId;
		if (commentaryInput) commentaryInput.value = '';

		modal.style.display = 'flex';
	}

	function closeRepostModal() {
		const modal = document.getElementById('repostModal');
		if (modal) modal.style.display = 'none';
	}

	function submitDirectShare() {
		const targetEl = document.getElementById('repostTargetPostId');
		const postId = targetEl ? targetEl.value : '';
		if (!postId) return;
		sendShareRequest(postId, '');
	}

	function submitQuoteRepost() {
		const targetEl = document.getElementById('repostTargetPostId');
		const cmtEl = document.getElementById('repostCommentaryInput');
		const postId = targetEl ? targetEl.value : '';
		const commentary = cmtEl ? cmtEl.value : '';
		if (!postId) return;
		sendShareRequest(postId, commentary);
	}

	function sendShareRequest(postId, commentary) {
		const body = "action=REPOST&postId=" + encodeURIComponent(postId) + "&commentary=" + encodeURIComponent(commentary);
		fetch('InteractionServlet', {
			method: 'POST',
			headers: {'Content-Type': 'application/x-www-form-urlencoded'},
			body: body
		})
		.then(res => res.json())
		.then(data => {
			if (data.status === 'shared') {
				closeRepostModal();
				alert('Reposted successfully to your feed!');
				const shareEl = document.getElementById('post-share-count-text-' + postId);
				if (shareEl) {
					const count = parseInt(shareEl.innerText) || 0;
					shareEl.innerText = (count + 1) + " Shares";
				}
				location.reload();
			} else {
				alert('Repost failed: ' + (data.error || 'Server error'));
			}
		})
		.catch(err => {
			console.error('Repost error:', err);
			alert('Network error while reposting.');
		});
	}

	// ================= GIF PICKER FOR COMMENTS =================
	let activeCommentPostIdForGif = null;
	let gifSearchTimeout = null;

	function openCommentGifModal(postId) {
		activeCommentPostIdForGif = postId;
		const modal = document.getElementById('gifPickerModal');
		if (modal) {
			modal.style.display = 'flex';
			loadGifItems('');
		}
	}

	function closeGifPickerModal() {
		const modal = document.getElementById('gifPickerModal');
		if (modal) modal.style.display = 'none';
	}

	function debounceGifSearch(query) {
		clearTimeout(gifSearchTimeout);
		gifSearchTimeout = setTimeout(() => {
			loadGifItems(query);
		}, 350);
	}

	function filterGifCategory(cat) {
		const input = document.getElementById('gifSearchInput');
		if (input) input.value = cat;
		loadGifItems(cat);
	}

	function loadGifItems(query) {
		const grid = document.getElementById('gifGridContainer');
		if (!grid) return;
		grid.innerHTML = '<div class="col-span-2 text-center py-8 text-gray-400 text-xs"><i class="fa fa-spinner fa-spin text-lg mb-2"></i><br>Finding GIFs...</div>';

		fetch('GifServlet?q=' + encodeURIComponent(query || ''))
			.then(res => res.json())
			.then(data => {
				const list = data.results || [];
				if (list.length === 0) {
					grid.innerHTML = '<div class="col-span-2 text-center py-8 text-gray-400 text-xs">No animated GIFs found</div>';
					return;
				}
				let html = '';
				list.forEach(g => {
					html += '<div onclick="selectGifForComment(\'' + g.url + '\')" class="rounded-xl overflow-hidden cursor-pointer hover:scale-102 transition shadow-sm border border-gray-200 bg-gray-100 aspect-video flex items-center justify-center group">' +
						'<img src="' + g.url + '" alt="' + (g.title || 'GIF') + '" class="w-full h-full object-cover group-hover:brightness-105 transition" loading="lazy">' +
					'</div>';
				});
				grid.innerHTML = html;
			})
			.catch(err => {
				grid.innerHTML = '<div class="col-span-2 text-center py-8 text-red-400 text-xs">Failed to load GIFs</div>';
			});
	}

	function selectGifForComment(gifUrl) {
		if (!activeCommentPostIdForGif) return;
		const input = document.getElementById('input-post-' + activeCommentPostIdForGif);
		if (input) {
			input.value = (input.value ? input.value + ' ' : '') + gifUrl;
			input.focus();
		}
		closeGifPickerModal();
	}
	</script>

			<!-- ================= SECURITY & PRIVACY MODAL ================= -->
			<div id="securityModal"
				class="fixed inset-0 bg-slate-950/70 backdrop-blur-md z-[9999] hidden items-center justify-center p-4" style="display: none !important;">
				<div
					class="bg-white rounded-3xl max-w-2xl w-full shadow-2xl overflow-hidden flex flex-col max-h-[88vh] animate-in fade-in zoom-in-95 duration-200">
					<!-- Modal Header -->
					<div
						class="px-6 py-5 border-b border-gray-100 flex items-center justify-between bg-gradient-to-r from-emerald-50 via-teal-50 to-white">
						<div class="flex items-center gap-3">
							<div
								class="w-11 h-11 rounded-2xl bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center text-white shadow-md shadow-emerald-200">
								<i class="fa-solid fa-shield-halved text-xl"></i>
							</div>
							<div>
								<h3 class="font-extrabold text-lg text-gray-900 leading-tight">Security
									&amp; Privacy</h3>
								<p class="text-xs text-gray-500">Manage 2FA, Active
									Sessions, Blocked Users &amp; Notifications</p>
							</div>
						</div>
						<button type="button" onclick="closeSecurityModal()"
							class="w-9 h-9 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-500 hover:text-gray-800 flex items-center justify-center transition">
							<i class="fa-solid fa-xmark text-lg"></i>
						</button>
					</div>

					<!-- Navigation Tabs -->
					<div
						class="flex border-b border-gray-100 px-6 gap-2 bg-gray-50/70 overflow-x-auto">
						<button type="button" onclick="switchSecurityTab('2fa')"
							id="secTabBtn-2fa"
							class="py-3 px-4 text-xs font-bold border-b-2 border-emerald-600 text-emerald-600 flex items-center gap-2 whitespace-nowrap transition">
							<i class="fa-solid fa-key"></i> Two-Factor Auth
						</button>
						<button type="button" onclick="switchSecurityTab('sessions')"
							id="secTabBtn-sessions"
							class="py-3 px-4 text-xs font-bold border-b-2 border-transparent text-gray-500 hover:text-gray-800 flex items-center gap-2 whitespace-nowrap transition">
							<i class="fa-solid fa-laptop"></i> Active Sessions
						</button>
						<button type="button" onclick="switchSecurityTab('blocked')"
							id="secTabBtn-blocked"
							class="py-3 px-4 text-xs font-bold border-b-2 border-transparent text-gray-500 hover:text-gray-800 flex items-center gap-2 whitespace-nowrap transition">
							<i class="fa-solid fa-ban"></i> Blocked Accounts
						</button>
						<button type="button" onclick="switchSecurityTab('privacy')" id="secTabBtn-privacy" class="py-3 px-4 text-xs font-bold border-b-2 border-transparent text-gray-500 hover:text-gray-800 flex items-center gap-2 whitespace-nowrap transition"><i class="fa-solid fa-eye"></i> Profile Privacy</button>
					<button type="button" onclick="switchSecurityTab('push')"
							id="secTabBtn-push"
							class="py-3 px-4 text-xs font-bold border-b-2 border-transparent text-gray-500 hover:text-gray-800 flex items-center gap-2 whitespace-nowrap transition">
							<i class="fa-solid fa-bell"></i> Push Notifications
						</button>
					</div>

					<!-- Modal Body -->
					<div class="p-6 overflow-y-auto flex-1 custom-scrollbar space-y-4">
						<!-- Tab 1: 2FA -->
						<div id="secTab-2fa" class="space-y-5">
							<div
								class="p-5 rounded-2xl bg-emerald-50/60 border border-emerald-100 flex items-start gap-4">
								<div
									class="w-12 h-12 rounded-2xl bg-emerald-500 text-white flex items-center justify-center text-xl shrink-0 shadow-md">
									<i class="fa-solid fa-lock"></i>
								</div>
								<div class="flex-1">
									<div class="flex items-center justify-between">
										<h4 class="font-bold text-gray-900">Email Two-Factor
											Authentication (2FA)</h4>
										<span id="twoFactorStatusBadge"
											class="px-2.5 py-0.5 text-[11px] font-black rounded-full ${sessionScope.ub.isTwoFactorEnabled() ? 'bg-emerald-500 text-white' : 'bg-gray-200 text-gray-700'}">
											${sessionScope.ub.isTwoFactorEnabled() ? 'ENABLED' : 'DISABLED'}
										</span>
									</div>
									<p class="text-xs text-gray-600 mt-1 leading-relaxed">
										When 2FA is enabled, signing in will require a one-time
										6-digit security code sent to your registered email: <strong><c:out
												value="${sessionScope.ub.getEmail()}" /></strong>.
									</p>
								</div>
							</div>

							<div
								class="flex items-center justify-between p-4 bg-gray-50 rounded-2xl border border-gray-100">
								<div>
									<p class="text-sm font-bold text-gray-800">Require OTP on
										every login</p>
									<p class="text-xs text-gray-500">Helps stop unauthorized
										account access even if your password is compromised.</p>
								</div>
								<button type="button" id="toggle2FABtn"
									onclick="handleToggle2FA()"
									class="px-5 py-2.5 text-xs font-bold rounded-xl transition shadow-sm ${sessionScope.ub.isTwoFactorEnabled() ? 'bg-red-50 text-red-600 hover:bg-red-100 border border-red-200' : 'bg-emerald-600 text-white hover:bg-emerald-700'}">
									${sessionScope.ub.isTwoFactorEnabled() ? 'Disable 2FA' : 'Enable 2FA'}
								</button>
							</div>
						</div>

						<!-- Tab 2: Active Sessions -->
						<div id="secTab-sessions" class="hidden space-y-4">
							<div class="flex items-center justify-between">
								<div>
									<h4 class="font-bold text-sm text-gray-900">Where You're
										Logged In</h4>
									<p class="text-xs text-gray-500">Review devices currently
										signed in to your account.</p>
								</div>
								<button type="button" onclick="terminateAllOtherSessions()"
									class="px-3.5 py-1.5 text-xs font-bold text-red-600 bg-red-50 hover:bg-red-100 border border-red-200 rounded-xl transition flex items-center gap-1.5">
									<i class="fa-solid fa-right-from-bracket"></i> Log Out Other
									Devices
								</button>
							</div>

							<div id="securitySessionsList" class="space-y-3">
								<div class="text-center py-6 text-gray-400 text-xs">
									<i class="fa-solid fa-spinner fa-spin text-base mb-2"></i><br>Loading
									active sessions...
								</div>
							</div>
						</div>

						<!-- Tab 3: Blocked Users -->
						<div id="secTab-blocked" class="hidden space-y-4">
							<div>
								<h4 class="font-bold text-sm text-gray-900">Blocked People</h4>
								<p class="text-xs text-gray-500">Once you block someone,
									they can no longer message you, see your posts, or find your
									profile.</p>
							</div>

							<div id="securityBlockedList" class="space-y-2">
								<div class="text-center py-6 text-gray-400 text-xs">
									<i class="fa-solid fa-spinner fa-spin text-base mb-2"></i><br>Loading
									blocked users...
								</div>
							</div>
						</div>

						<!-- Tab 4: Web Push Notifications -->
						<div id="secTab-privacy" class="hidden space-y-4">
							<div class="p-5 rounded-2xl bg-sky-50 border border-sky-100 space-y-3">
								<h4 class="font-bold text-gray-900">Who can view your profile and posts?</h4>
								<p class="text-xs text-gray-600">Friends-only hides your profile posts and friends list from people who are not your accepted friends. Private makes those visible only to you.</p>
								<select id="profileVisibilitySelect" class="w-full rounded-xl border border-gray-200 bg-white p-3 text-sm"><option value="PUBLIC">Public</option><option value="FRIENDS">Friends only</option><option value="PRIVATE">Only me</option></select>
								<button type="button" onclick="saveProfileVisibility()" class="px-4 py-2 rounded-xl bg-blue-600 text-white text-xs font-bold">Save privacy</button>
							</div>
							<div class="p-5 rounded-2xl bg-white border border-gray-200 space-y-3">
								<h4 class="font-bold text-gray-900">Your account data</h4>
								<p class="text-xs text-gray-600">Download a JSON copy of your profile, posts, comments, replies, and messages.</p>
								<button type="button" onclick="downloadMyYChatData()" class="px-4 py-2 rounded-xl bg-blue-600 text-white text-xs font-bold"><i class="fa fa-download mr-1"></i> Download my data</button>
							</div>
							<div class="p-5 rounded-2xl bg-amber-50 border border-amber-200 space-y-3">
								<h4 class="font-bold text-gray-900">Deactivate or delete account</h4>
								<p class="text-xs text-gray-700">This sends an account-closure request for support review. It does not immediately erase account data.</p>
								<div class="flex flex-wrap gap-2"><button type="button" onclick="requestAccountClosure('DEACTIVATION')" class="px-4 py-2 rounded-xl bg-amber-600 text-white text-xs font-bold">Request deactivation</button><button type="button" onclick="requestAccountClosure('DELETION')" class="px-4 py-2 rounded-xl bg-red-600 text-white text-xs font-bold">Request permanent deletion</button></div>
							</div>
						</div>
						<div id="secTab-push" class="hidden space-y-4">
							<div
								class="p-5 rounded-2xl bg-blue-50/60 border border-blue-100 flex items-start gap-4">
								<div
									class="w-12 h-12 rounded-2xl bg-blue-500 text-white flex items-center justify-center text-xl shrink-0 shadow-md">
									<i class="fa-solid fa-bell"></i>
								</div>
								<div class="flex-1">
									<div class="flex items-center justify-between">
										<h4 class="font-bold text-gray-900">Browser &amp; Desktop
											Push Notifications</h4>
										<span id="pushPermissionBadge"
											class="px-2.5 py-0.5 text-[11px] font-black rounded-full bg-gray-200 text-gray-700">
											CHECKING... </span>
									</div>
									<p class="text-xs text-gray-600 mt-1 leading-relaxed">Get
										real-time alerts for new chat messages, calls, and
										notifications even when yChat is minimized in the background.
									</p>
								</div>
							</div>

							<div class="flex flex-col sm:flex-row items-center gap-3">
								<button type="button" onclick="enablePushNotifications()"
									class="w-full sm:w-auto px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-xl transition shadow-md shadow-blue-200 flex items-center justify-center gap-2">
									<i class="fa-solid fa-bell"></i> Enable Web Push Notifications
								</button>
								<button type="button" onclick="testPushNotification()"
									class="w-full sm:w-auto px-4 py-2.5 bg-gray-100 hover:bg-gray-200 text-gray-700 text-xs font-bold rounded-xl transition flex items-center justify-center gap-2">
									<i class="fa-solid fa-paper-plane"></i> Send Test Notification
								</button>
							</div>
						</div>
					</div>
				</div>
			</div>

			<!-- SECURITY & PRIVACY JAVASCRIPT -->
			<script>
	let current2FAEnabled = "${not empty sessionScope.ub && sessionScope.ub.isTwoFactorEnabled() ? 'true' : 'false'}" === 'true';

	function openSecurityModal(defaultTab) {
		const modal = document.getElementById('securityModal');
		if (modal) {
			modal.style.setProperty('display', 'flex', 'important');
			modal.classList.remove('hidden');
			switchSecurityTab(defaultTab || '2fa');
		}
	}

	function closeSecurityModal() {
		const modal = document.getElementById('securityModal');
		if (modal) {
			modal.style.setProperty('display', 'none', 'important');
			modal.classList.add('hidden');
		}
	}

	function switchSecurityTab(tab) {
		['2fa', 'sessions', 'blocked', 'push', 'privacy'].forEach(t => {
			const el = document.getElementById('secTab-' + t);
			const btn = document.getElementById('secTabBtn-' + t);
			if (el) el.classList.add('hidden');
			if (btn) {
				btn.classList.remove('border-emerald-600', 'text-emerald-600');
				btn.classList.add('border-transparent', 'text-gray-500');
			}
		});

		const target = document.getElementById('secTab-' + tab);
		const targetBtn = document.getElementById('secTabBtn-' + tab);
		if (target) target.classList.remove('hidden');
		if (targetBtn) {
			targetBtn.classList.remove('border-transparent', 'text-gray-500');
			targetBtn.classList.add('border-emerald-600', 'text-emerald-600');
		}

		if (tab === 'sessions') {
			loadActiveSessions();
		} else if (tab === 'blocked') {
			loadBlockedUsers();
		} else if (tab === 'push') {
			updatePushPermissionUI();
		} else if (tab === 'privacy') {
			loadProfileVisibility();
		}
	}

	function loadProfileVisibility() { fetch('SecurityServlet?action=getProfileVisibility').then(r=>r.json()).then(d=>{if(d.success)document.getElementById('profileVisibilitySelect').value=d.visibility;}).catch(()=>{}); }
	function saveProfileVisibility() { const visibility=document.getElementById('profileVisibilitySelect').value; fetch('SecurityServlet?action=setProfileVisibility&visibility='+encodeURIComponent(visibility),{method:'POST'}).then(r=>r.json()).then(d=>alert(d.success?'Profile privacy saved.':'Could not save profile privacy.')).catch(()=>alert('Could not save profile privacy.')); }
	function downloadMyYChatData() { fetch('SecurityServlet?action=exportMyData').then(async r=>{if(!r.ok)throw new Error('Export failed');const d=await r.json();if(d.success===false)throw new Error(d.message||'Export failed');return new Blob([JSON.stringify(d,null,2)],{type:'application/json'});}).then(blob=>{const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download='ychat-my-data.json';a.click();setTimeout(()=>URL.revokeObjectURL(a.href),1000);}).catch(e=>alert(e.message||'Could not download your data.')); }
	function requestAccountClosure(type) { const isDelete=type==='DELETION'; if(!confirm(isDelete?'Submit a permanent account deletion request for support review?':'Submit an account deactivation request for support review?'))return; if(isDelete && prompt('Type DELETE to confirm this request:')!=='DELETE')return; fetch('SecurityServlet?action=requestAccountClosure&type='+encodeURIComponent(type),{method:'POST'}).then(r=>r.json()).then(d=>alert(d.message||(d.success?'Request submitted.':'Could not submit request.'))).catch(()=>alert('Could not submit your request.')); }

	function handleToggle2FA() {
		const newStatus = !current2FAEnabled;
		const confirmMsg = newStatus 
			? "Are you sure you want to turn ON Two-Factor Authentication? You will need an email OTP on your next login."
			: "Are you sure you want to disable Two-Factor Authentication?";

		if (!confirm(confirmMsg)) return;

		fetch('SecurityServlet?action=toggle2FA&enabled=' + newStatus, { method: 'POST' })
			.then(res => res.json())
			.then(data => {
				if (data.success) {
					current2FAEnabled = newStatus;
					const badge = document.getElementById('twoFactorStatusBadge');
					const btn = document.getElementById('toggle2FABtn');
					if (badge) {
						badge.textContent = newStatus ? 'ENABLED' : 'DISABLED';
						badge.className = 'px-2.5 py-0.5 text-[11px] font-black rounded-full ' + (newStatus ? 'bg-emerald-500 text-white' : 'bg-gray-200 text-gray-700');
					}
					if (btn) {
						btn.textContent = newStatus ? 'Disable 2FA' : 'Enable 2FA';
						btn.className = 'px-5 py-2.5 text-xs font-bold rounded-xl transition shadow-sm ' + (newStatus ? 'bg-red-50 text-red-600 hover:bg-red-100 border border-red-200' : 'bg-emerald-600 text-white hover:bg-emerald-700');
					}
					alert("2FA status updated successfully.");
				} else {
					alert(data.message || "Failed to update 2FA status.");
				}
			})
			.catch(err => {
				alert("Error connecting to server.");
			});
	}

	function loadActiveSessions() {
		const container = document.getElementById('securitySessionsList');
		if (!container) return;
		container.innerHTML = '<div class="text-center py-6 text-gray-400 text-xs"><i class="fa-solid fa-spinner fa-spin text-base mb-2"></i><br>Loading active sessions...</div>';

		fetch('SecurityServlet?action=getActiveSessions')
			.then(res => res.json())
			.then(data => {
				if (!data.success || !data.sessions || data.sessions.length === 0) {
					container.innerHTML = '<div class="text-center py-6 text-gray-400 text-xs">No active sessions found.</div>';
					return;
				}
				let html = '';
				data.sessions.forEach(s => {
					let devIcon = 'fa-laptop';
					if (s.deviceType === 'Mobile') devIcon = 'fa-mobile-screen';
					else if (s.deviceType === 'Tablet') devIcon = 'fa-tablet-screen-button';

					html += '<div class="p-3.5 bg-gray-50 rounded-2xl border border-gray-100 flex items-center justify-between">';
					html += '  <div class="flex items-center gap-3">';
					html += '    <div class="w-10 h-10 rounded-xl bg-white shadow-sm flex items-center justify-center text-gray-600 text-lg border border-gray-100">';
					html += '      <i class="fa-solid ' + devIcon + '"></i>';
					html += '    </div>';
					html += '    <div>';
					html += '      <div class="flex items-center gap-2">';
					html += '        <span class="font-bold text-xs text-gray-800">' + s.browser + ' on ' + s.operatingSystem + '</span>';
					if (s.isCurrent) {
						html += '      <span class="px-2 py-0.5 text-[10px] bg-emerald-100 text-emerald-700 font-black rounded-md">CURRENT DEVICE</span>';
					}
					html += '      </div>';
					html += '      <p class="text-[11px] text-gray-500 mt-0.5">' + s.ipAddress + ' &bull; Last active: ' + s.lastActive + '</p>';
					html += '    </div>';
					html += '  </div>';

					if (!s.isCurrent) {
						html += '  <button type="button" onclick="terminateSession(' + s.id + ')" class="px-3 py-1.5 text-xs text-red-600 hover:bg-red-50 font-bold rounded-lg transition">';
						html += '    Log Out';
						html += '  </button>';
					}
					html += '</div>';
				});
				container.innerHTML = html;
			})
			.catch(err => {
				container.innerHTML = '<div class="text-center py-6 text-red-400 text-xs">Failed to load active sessions.</div>';
			});
	}

	function terminateSession(rowId) {
		if (!confirm("Are you sure you want to log out this device?")) return;
		fetch('SecurityServlet?action=terminateSession&sessionId=' + rowId, { method: 'POST' })
			.then(res => res.json())
			.then(data => {
				if (data.success) {
					loadActiveSessions();
				} else {
					alert(data.message || "Failed to log out device.");
				}
			});
	}

	function terminateAllOtherSessions() {
		if (!confirm("Log out from all other devices? You will remain signed in only on this device.")) return;
		fetch('SecurityServlet?action=terminateOtherSessions', { method: 'POST' })
			.then(res => res.json())
			.then(data => {
				if (data.success) {
					loadActiveSessions();
					alert("All other sessions have been logged out.");
				} else {
					alert(data.message || "Failed to log out other devices.");
				}
			});
	}

	function loadBlockedUsers() {
		const container = document.getElementById('securityBlockedList');
		if (!container) return;
		container.innerHTML = '<div class="text-center py-6 text-gray-400 text-xs"><i class="fa-solid fa-spinner fa-spin text-base mb-2"></i><br>Loading blocked users...</div>';

		fetch('SecurityServlet?action=getBlockedUsers')
			.then(res => res.json())
			.then(data => {
				if (!data.success || !data.users || data.users.length === 0) {
					container.innerHTML = '<div class="text-center py-8 text-gray-400 text-xs"><i class="fa-solid fa-user-check text-2xl text-emerald-400 mb-2"></i><br>You have not blocked any users.</div>';
					return;
				}
				let html = '';
				data.users.forEach(u => {
					const pic = u.profile_pic ? 'img/' + u.profile_pic : 'img/default.png';
					html += '<div class="p-3 bg-gray-50 rounded-2xl border border-gray-100 flex items-center justify-between">';
					html += '  <div class="flex items-center gap-3">';
					html += '    <img src="' + pic + '" class="w-10 h-10 rounded-full object-cover border border-gray-200" onerror="this.src=\'img/default.png\';">';
					html += '    <div>';
					html += '      <p class="font-bold text-xs text-gray-800">' + u.name + '</p>';
					html += '      <p class="text-[11px] text-gray-500">' + u.email + '</p>';
					html += '    </div>';
					html += '  </div>';
					html += '  <button type="button" onclick="unblockUser(' + u.id + ', \'' + (u.name || 'User').replace(/'/g, "\\'") + '\')" class="px-3.5 py-1.5 text-xs bg-emerald-50 hover:bg-emerald-100 text-emerald-700 border border-emerald-200 font-bold rounded-xl transition">';
					html += '    Unblock';
					html += '  </button>';
					html += '</div>';
				});
				container.innerHTML = html;
			})
			.catch(err => {
				container.innerHTML = '<div class="text-center py-6 text-red-400 text-xs">Failed to load blocked accounts.</div>';
			});
	}

	function blockUserFromPost(userId, userName) {
		if (!confirm("Are you sure you want to block " + (userName || "this user") + "? They will be unfriended, unfollowed, and removed from your feed.")) return;

		fetch('SecurityServlet?action=block&userId=' + userId, { method: 'POST' })
			.then(res => res.json())
			.then(data => {
				if (data.success) {
					alert(userName + " has been blocked.");
					location.reload();
				} else {
					alert(data.message || "Failed to block user.");
				}
			})
			.catch(err => alert("Error processing request."));
	}

	function unblockUser(userId, userName) {
		if (!confirm("Are you sure you want to unblock " + (userName || "this user") + "?")) return;

		fetch('SecurityServlet?action=unblock&userId=' + userId, { method: 'POST' })
			.then(res => res.json())
			.then(data => {
				if (data.success) {
					loadBlockedUsers();
					alert(userName + " has been unblocked.");
				} else {
					alert(data.message || "Failed to unblock user.");
				}
			})
			.catch(err => alert("Error processing request."));
	}

	function updatePushPermissionUI() {
		const badge = document.getElementById('pushPermissionBadge');
		if (!badge) return;
		if (!('Notification' in window)) {
			badge.textContent = 'UNSUPPORTED';
			badge.className = 'px-2.5 py-0.5 text-[11px] font-black rounded-full bg-red-100 text-red-700';
			return;
		}
		if (Notification.permission === 'granted') {
			badge.textContent = 'ENABLED';
			badge.className = 'px-2.5 py-0.5 text-[11px] font-black rounded-full bg-emerald-500 text-white';
		} else if (Notification.permission === 'denied') {
			badge.textContent = 'BLOCKED IN BROWSER';
			badge.className = 'px-2.5 py-0.5 text-[11px] font-black rounded-full bg-red-100 text-red-700';
		} else {
			badge.textContent = 'NOT CONFIGURED';
			badge.className = 'px-2.5 py-0.5 text-[11px] font-black rounded-full bg-amber-100 text-amber-700';
		}
	}

	function enablePushNotifications() {
		if (!('Notification' in window)) {
			alert('Web notifications are not supported by this browser.');
			return;
		}
		Notification.requestPermission().then(permission => {
			updatePushPermissionUI();
			if (permission === 'granted') {
				if ('serviceWorker' in navigator) {
					navigator.serviceWorker.register('sw.js').then(reg => {
						console.log('ServiceWorker registered:', reg);
					}).catch(err => console.log('SW registration error:', err));
				}
				alert('Push notifications enabled! You will now receive background alerts.');
			} else {
				alert('Notification permission was ' + permission + '.');
			}
		});
	}

	function testPushNotification() {
		if (!('Notification' in window) || Notification.permission !== 'granted') {
			enablePushNotifications();
			return;
		}
		if ('serviceWorker' in navigator && navigator.serviceWorker.controller) {
			navigator.serviceWorker.ready.then(reg => {
				reg.showNotification('yChat Notification', {
					body: 'Testing web push notifications! Everything is working smoothly.',
					icon: 'icons/icon-192.png',
					badge: 'icons/icon-192.png'
				});
			});
		} else {
			new Notification('yChat Notification', {
				body: 'Testing web push notifications! Everything is working smoothly.',
				icon: 'icons/icon-192.png'
			});
		}
	}

	// Service Worker cleaner & iOS Safari gesture auto-zoom suppressor
	if ('serviceWorker' in navigator) {
		navigator.serviceWorker.getRegistrations().then(regs => {
			for (let r of regs) r.unregister();
		}).catch(() => {});
	}
	if ('caches' in window) {
		caches.keys().then(keys => {
			for (let k of keys) caches.delete(k);
		}).catch(() => {});
	}
	(function() {
		var lastTouch = 0;
		document.addEventListener('touchend', function(e) {
			var now = Date.now();
			if (now - lastTouch <= 300) {
				e.preventDefault();
			}
			lastTouch = now;
		}, { passive: false });
		document.addEventListener('gesturestart', function(e) { e.preventDefault(); }, { passive: false });
		document.addEventListener('gesturechange', function(e) { e.preventDefault(); }, { passive: false });
		document.addEventListener('gestureend', function(e) { e.preventDefault(); }, { passive: false });
	})();

	// ================= CREATOR TIP & DONATION SYSTEM =================
	let currentTipMethod = 'WALLET';
	let selectedTipAmt = 5.0;

	function openTipModal(receiverId, creatorName, postId) {
		const modal = document.getElementById('tipModal');
		if (!modal) return;
		document.getElementById('tipReceiverId').value = receiverId;
		document.getElementById('tipPostId').value = postId || '';
		document.getElementById('tipCreatorName').textContent = creatorName || 'Creator';
		document.getElementById('tipCustomAmount').value = selectedTipAmt;
		selectTipMethod('WALLET');
		modal.style.setProperty('display', 'flex', 'important');
		modal.classList.remove('hidden');
	}

	function closeTipModal() {
		const modal = document.getElementById('tipModal');
		if (modal) {
			modal.style.setProperty('display', 'none', 'important');
			modal.classList.add('hidden');
		}
	}

	function selectTipAmount(amt) {
		selectedTipAmt = amt;
		document.getElementById('tipCustomAmount').value = amt;
		document.querySelectorAll('.tip-chip-btn').forEach(b => {
			b.classList.remove('bg-amber-500', 'text-white', 'border-amber-500');
			b.classList.add('bg-gray-100', 'text-gray-700', 'border-gray-200');
		});
		const target = document.getElementById('tipChip-' + amt);
		if (target) {
			target.classList.remove('bg-gray-100', 'text-gray-700', 'border-gray-200');
			target.classList.add('bg-amber-500', 'text-white', 'border-amber-500');
		}
	}

	function selectTipMethod(method) {
		currentTipMethod = method;
		['WALLET', 'BKASH', 'NAGAD', 'CARD'].forEach(m => {
			const btn = document.getElementById('tipMethodBtn-' + m);
			if (btn) {
				btn.classList.remove('border-amber-500', 'bg-amber-50', 'text-amber-700', 'shadow-sm');
				btn.classList.add('border-gray-200', 'text-gray-600');
			}
		});
		const active = document.getElementById('tipMethodBtn-' + method);
		if (active) {
			active.classList.remove('border-gray-200', 'text-gray-600');
			active.classList.add('border-amber-500', 'bg-amber-50', 'text-amber-700', 'shadow-sm');
		}
	}

	function submitCreatorTip() {
		const receiverId = document.getElementById('tipReceiverId').value;
		const postId = document.getElementById('tipPostId').value;
		const amt = parseFloat(document.getElementById('tipCustomAmount').value);
		const note = document.getElementById('tipNoteInput').value.trim();

		if (!receiverId || isNaN(amt) || amt <= 0) {
			alert('Please enter a valid tip amount.');
			return;
		}

		const btn = document.getElementById('submitTipBtn');
		if (btn) {
			btn.disabled = true;
			btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i> Processing...';
		}

		const params = new URLSearchParams();
		params.append('action', 'sendTip');
		params.append('receiverId', receiverId);
		if (postId) params.append('postId', postId);
		params.append('amount', amt);
		params.append('method', currentTipMethod);
		params.append('note', note);

		fetch('TipServlet', { method: 'POST', body: params })
			.then(res => res.json())
			.then(data => {
				if (btn) {
					btn.disabled = false;
					btn.innerHTML = '<span>Send Tip Now</span> <i class="fa-solid fa-paper-plane text-xs"></i>';
				}
				if (data.success) {
					alert(data.message);
					if (document.getElementById('tipUserBalance')) {
						document.getElementById('tipUserBalance').textContent = Number(data.newBalance).toFixed(2);
					}
					closeTipModal();
				} else {
					alert(data.message || 'Failed to send tip.');
				}
			})
			.catch(err => {
				if (btn) {
					btn.disabled = false;
					btn.innerHTML = '<span>Send Tip Now</span> <i class="fa-solid fa-paper-plane text-xs"></i>';
				}
				alert('Network error while processing tip.');
			});
	}

	// ================= CREATOR STATS & WALLET MODAL =================
	function openCreatorStatsModal() {
		const modal = document.getElementById('creatorStatsModal');
		if (modal) {
			modal.style.setProperty('display', 'flex', 'important');
			modal.classList.remove('hidden');
			loadCreatorStats();
		}
	}

	function closeCreatorStatsModal() {
		const modal = document.getElementById('creatorStatsModal');
		if (modal) {
			modal.style.setProperty('display', 'none', 'important');
			modal.classList.add('hidden');
		}
	}

	function loadCreatorStats() {
		fetch('TipServlet?action=getStats')
			.then(res => res.json())
			.then(data => {
				if (data.success) {
					const balEl = document.getElementById('creatorStatsBalance');
					const totalEl = document.getElementById('creatorStatsTotalTips');
					if (balEl) balEl.textContent = '$' + Number(data.balance).toFixed(2);
					if (totalEl) totalEl.textContent = '$' + Number(data.totalTipsReceived).toFixed(2);

					const listContainer = document.getElementById('creatorTipsReceivedList');
					if (listContainer) {
						if (!data.tips || data.tips.length === 0) {
							listContainer.innerHTML = '<div class="text-center py-6 text-gray-400 text-xs"><i class="fa-solid fa-coins text-2xl text-amber-300 mb-2"></i><br>No tips received yet. Great content attracts generous tips!</div>';
							return;
						}
						let html = '';
						data.tips.forEach(t => {
							const pic = t.senderPic ? 'img/' + t.senderPic : 'img/default.png';
							html += '<div class="p-3.5 bg-gray-50 rounded-2xl border border-gray-100 flex items-center justify-between">';
							html += '  <div class="flex items-center gap-3">';
							html += '    <img src="' + pic + '" class="w-10 h-10 rounded-full object-cover border border-gray-200" onerror="this.src=\'img/default.png\';">';
							html += '    <div>';
							html += '      <p class="font-bold text-xs text-gray-800">' + t.senderName + ' <span class="text-emerald-600 font-extrabold ml-1">+$' + Number(t.amount).toFixed(2) + '</span></p>';
							if (t.note) {
								html += '      <p class="text-[11px] text-gray-600 italic mt-0.5">"' + t.note + '"</p>';
							}
							html += '      <p class="text-[10px] text-gray-400 mt-0.5">' + t.formattedTime + ' &bull; via ' + t.paymentMethod + '</p>';
							html += '    </div>';
							html += '  </div>';
							html += '</div>';
						});
						listContainer.innerHTML = html;
					}
				}
			})
			.catch(err => console.log('Error loading creator stats:', err));
	}

	function observePostViews() {
		if (!('IntersectionObserver' in window)) return;
		const sent = new Set();
		const observer = new IntersectionObserver(entries => entries.forEach(entry => {
			if (entry.isIntersecting && entry.intersectionRatio >= 0.5) {
				const id = entry.target.dataset.postId;
				if (!id || sent.has(id)) return;
				sent.add(id); observer.unobserve(entry.target);
				fetch('PostViewServlet',{method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},body:new URLSearchParams({postId:id})}).catch(()=>{});
			}
		}),{threshold:0.5});
		document.querySelectorAll('[data-post-id]').forEach(card=>observer.observe(card));
	}
	document.addEventListener('DOMContentLoaded',observePostViews);

	function showPostInsights(postId) {
		fetch('PostInsightsServlet?postId=' + encodeURIComponent(postId))
			.then(r => r.json().then(data => ({ok:r.ok,data})))
			.then(({ok,data}) => { if (!ok || !data.success) throw new Error('Could not load insights.'); const viewers = data.viewers.length ? data.viewers.join(', ') : 'No viewers yet today.'; alert('Unique viewers today: ' + data.uniqueViewers + '\nViewers: ' + viewers); })
			.catch(err => alert(err.message || 'Could not load post insights.'));
	}

	function topUpWalletBalance() {
		const amount = prompt('Enter wallet top-up amount in USD ($5-$500):', '20');
		if (amount === null) return;
		const value = Number(amount);
		if (!Number.isFinite(value) || value < 5 || value > 500 || Math.round(value * 100) !== value * 100) { alert('Enter an amount from $5 to $500 with up to 2 decimal places.'); return; }
		beginStripeCheckout('WALLET_TOPUP', value.toFixed(2));
	}

	function beginStripeCheckout(purpose, amount) {
		const params = new URLSearchParams({ action: 'checkout', purpose });
		if (amount !== undefined && amount !== null) params.set('amount', String(amount));
		fetch('PaymentServlet', { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: params })
		.then(res => res.json().then(data => ({ ok: res.ok, data })))
		.then(({ok,data}) => { if (ok && data.checkoutUrl) window.location.assign(data.checkoutUrl); else alert(data.message || 'Secure checkout is unavailable.'); })
		.catch(err => { console.error('Stripe checkout error:', err); alert('Could not open secure checkout.'); });
	}

	function applyForBlueTick() { beginStripeCheckout('BLUE_TICK'); }
	</script>

			<!-- ================= CREATOR TIP MODAL ================= -->
			<div id="tipModal"
				class="fixed inset-0 bg-slate-950/70 backdrop-blur-md z-[9999] hidden items-center justify-center p-4" style="display: none !important;">
				<div
					class="bg-white rounded-3xl max-w-md w-full shadow-2xl overflow-hidden flex flex-col p-6 animate-in fade-in zoom-in-95 duration-200">
					<!-- Header -->
					<div
						class="flex items-center justify-between border-b border-gray-100 pb-4">
						<div class="flex items-center gap-3">
							<div
								class="w-11 h-11 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center text-white shadow-md shadow-amber-200 text-lg">
								<i class="fa-solid fa-coins"></i>
							</div>
							<div>
								<h3 class="font-extrabold text-base text-gray-900 leading-tight">Send
									a Tip</h3>
								<p class="text-xs text-gray-500">
									Support <strong id="tipCreatorName" class="text-amber-600">Creator</strong>
								</p>
							</div>
						</div>
						<button type="button" onclick="closeTipModal()"
							class="w-8 h-8 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-500 flex items-center justify-center transition">
							<i class="fa-solid fa-xmark text-sm"></i>
						</button>
					</div>

					<input type="hidden" id="tipReceiverId"> <input
						type="hidden" id="tipPostId">

					<div class="space-y-4 pt-4">
						<!-- Quick Preset Chips -->
						<div>
							<label
								class="block text-xs font-bold text-gray-500 uppercase tracking-wider mb-2">Select
								Amount</label>
							<div class="grid grid-cols-5 gap-2">
								<button type="button" onclick="selectTipAmount(1)"
									id="tipChip-1"
									class="tip-chip-btn py-2 rounded-xl text-xs font-bold border border-gray-200 bg-gray-100 text-gray-700 hover:border-amber-400 transition">$1</button>
								<button type="button" onclick="selectTipAmount(3)"
									id="tipChip-3"
									class="tip-chip-btn py-2 rounded-xl text-xs font-bold border border-gray-200 bg-gray-100 text-gray-700 hover:border-amber-400 transition">$3</button>
								<button type="button" onclick="selectTipAmount(5)"
									id="tipChip-5"
									class="tip-chip-btn py-2 rounded-xl text-xs font-bold border border-amber-500 bg-amber-500 text-white shadow-sm transition">$5</button>
								<button type="button" onclick="selectTipAmount(10)"
									id="tipChip-10"
									class="tip-chip-btn py-2 rounded-xl text-xs font-bold border border-gray-200 bg-gray-100 text-gray-700 hover:border-amber-400 transition">$10</button>
								<button type="button" onclick="selectTipAmount(20)"
									id="tipChip-20"
									class="tip-chip-btn py-2 rounded-xl text-xs font-bold border border-gray-200 bg-gray-100 text-gray-700 hover:border-amber-400 transition">$20</button>
							</div>
						</div>

						<!-- Custom Amount Box -->
						<div class="space-y-1">
							<label
								class="block text-xs font-bold text-gray-500 uppercase tracking-wider">Custom
								Amount ($)</label>
							<div class="relative">
								<span
									class="absolute left-4 top-1/2 -translate-y-1/2 font-extrabold text-gray-400 text-lg">$</span>
								<input type="number" id="tipCustomAmount" min="1" step="0.5"
									value="5.00"
									class="w-full pl-9 pr-4 py-3 bg-gray-50 border border-gray-200 rounded-2xl outline-none font-extrabold text-base text-gray-800 focus:border-amber-500 transition">
							</div>
						</div>

						<!-- Payment Method -->
						<div class="space-y-1.5">
							<div class="flex items-center justify-between">
								<label
									class="block text-xs font-bold text-gray-500 uppercase tracking-wider">Payment
									Method</label> <span class="text-[11px] font-bold text-emerald-600">Wallet
									Bal: $<span id="tipUserBalance">${sessionScope.ub.getBalance()}</span>
								</span>
							</div>
							<div class="grid grid-cols-4 gap-2">
								<button type="button" onclick="selectTipMethod('WALLET')"
									id="tipMethodBtn-WALLET"
									class="p-2.5 rounded-xl border-2 border-amber-500 bg-amber-50 text-amber-700 text-[11px] font-bold flex flex-col items-center gap-1 transition">
									<i class="fa-solid fa-wallet text-sm"></i> <span>Wallet</span>
								</button>
								<button type="button" onclick="selectTipMethod('BKASH')"
									id="tipMethodBtn-BKASH"
									class="p-2.5 rounded-xl border-2 border-gray-200 text-gray-600 text-[11px] font-bold flex flex-col items-center gap-1 transition">
									<span class="text-sm">猪</span> <span>bKash</span>
								</button>
								<button type="button" onclick="selectTipMethod('NAGAD')"
									id="tipMethodBtn-NAGAD"
									class="p-2.5 rounded-xl border-2 border-gray-200 text-gray-600 text-[11px] font-bold flex flex-col items-center gap-1 transition">
									<span class="text-sm">泛</span> <span>Nagad</span>
								</button>
								<button type="button" onclick="selectTipMethod('CARD')"
									id="tipMethodBtn-CARD"
									class="p-2.5 rounded-xl border-2 border-gray-200 text-gray-600 text-[11px] font-bold flex flex-col items-center gap-1 transition">
									<i class="fa-solid fa-credit-card text-sm"></i> <span>Card</span>
								</button>
							</div>
						</div>

						<!-- Encouraging Note -->
						<div class="space-y-1">
							<label
								class="block text-xs font-bold text-gray-500 uppercase tracking-wider">Personal
								Message / Note (Optional)</label> <input type="text" id="tipNoteInput"
								placeholder="Keep up the great work! 脂" maxlength="150"
								class="w-full px-4 py-2.5 bg-gray-50 border border-gray-200 rounded-2xl outline-none text-xs text-gray-700 focus:border-amber-500 transition">
						</div>

						<!-- Submit Button -->
						<button type="button" id="submitTipBtn"
							onclick="submitCreatorTip()"
							class="w-full py-3.5 bg-gradient-to-r from-amber-500 to-orange-500 hover:from-amber-600 hover:to-orange-600 text-white font-extrabold rounded-2xl shadow-lg shadow-amber-200 transition flex items-center justify-center gap-2">
							<span>Send Tip Now</span> <i
								class="fa-solid fa-paper-plane text-xs"></i>
						</button>
					</div>
				</div>
			</div>

			<!-- ================= CREATOR STATS & WALLET MODAL ================= -->
			<div id="creatorStatsModal"
				class="fixed inset-0 bg-slate-950/70 backdrop-blur-md z-[9999] hidden items-center justify-center p-4" style="display: none !important;">
				<div
					class="bg-white rounded-3xl max-w-xl w-full shadow-2xl overflow-hidden flex flex-col max-h-[85vh] animate-in fade-in zoom-in-95 duration-200">
					<!-- Header -->
					<div
						class="px-6 py-5 border-b border-gray-100 flex items-center justify-between bg-gradient-to-r from-amber-50 via-orange-50 to-white">
						<div class="flex items-center gap-3">
							<div
								class="w-11 h-11 rounded-2xl bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center text-white shadow-md shadow-amber-200 text-lg">
								<i class="fa-solid fa-crown"></i>
							</div>
							<div>
								<h3 class="font-extrabold text-lg text-gray-900 leading-tight">Creator
									Tips &amp; Perks</h3>
								<p class="text-xs text-gray-500">Wallet Balance, Received
									Donations &amp; Verified Blue Tick</p>
							</div>
						</div>
						<button type="button" onclick="closeCreatorStatsModal()"
							class="w-9 h-9 rounded-full bg-gray-100 hover:bg-gray-200 text-gray-500 flex items-center justify-center transition">
							<i class="fa-solid fa-xmark text-lg"></i>
						</button>
					</div>

					<!-- Body -->
					<div class="p-6 overflow-y-auto flex-1 custom-scrollbar space-y-5">
						<!-- Balance & Earnings Cards -->
						<div class="grid grid-cols-2 gap-4">
							<div
								class="p-4 bg-gradient-to-br from-amber-500/10 to-orange-500/10 border border-amber-200 rounded-3xl">
								<span
									class="text-xs font-bold text-amber-700 flex items-center gap-1.5 uppercase">
									<i class="fa-solid fa-wallet"></i> Wallet Balance
								</span>
								<p id="creatorStatsBalance"
									class="text-2xl font-black text-amber-900 mt-1">$${sessionScope.ub.getBalance()}</p>
								<button type="button" onclick="topUpWalletBalance()"
									class="mt-2 text-[11px] font-bold text-amber-600 hover:underline flex items-center gap-1">
									<i class="fa-solid fa-plus-circle"></i> Add Funds / Top Up
								</button>
							</div>

							<div
								class="p-4 bg-gradient-to-br from-emerald-500/10 to-teal-500/10 border border-emerald-200 rounded-3xl">
								<span
									class="text-xs font-bold text-emerald-700 flex items-center gap-1.5 uppercase">
									<i class="fa-solid fa-coins"></i> Total Tips Earned
								</span>
								<p id="creatorStatsTotalTips"
									class="text-2xl font-black text-emerald-900 mt-1">$0.00</p>
								<span class="text-[10px] text-gray-400 mt-2 block">Directly
									credited to your wallet</span>
							</div>
						</div>

						<!-- Blue Tick Verification Banner -->
						<div
							class="p-4 bg-blue-50/70 border border-blue-100 rounded-2xl flex items-center justify-between">
							<div class="flex items-center gap-3">
								<div
									class="w-10 h-10 rounded-xl bg-blue-500 text-white flex items-center justify-center text-lg shadow-md shadow-blue-200">
									<i class="fa-solid fa-circle-check"></i>
								</div>
								<div>
									<h4
										class="font-bold text-xs text-blue-900 flex items-center gap-1">
										Verified Creator Badge
										<c:if test="${sessionScope.ub.isVerified()}">
											<span
												class="px-2 py-0.5 text-[9px] bg-blue-600 text-white font-extrabold rounded-full">ACTIVE</span>
										</c:if>
									</h4>
									<p class="text-[11px] text-blue-700">Display a blue
										checkmark next to your name on all posts and comments.</p>
								</div>
							</div>
							<c:choose>
								<c:when test="${sessionScope.ub.isVerified()}">
									<span class="text-xs font-black text-blue-600"><i
										class="fa-solid fa-check mr-1"></i> Verified</span>
								</c:when>
								<c:otherwise>
									<button type="button" onclick="applyForBlueTick()"
										class="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold rounded-xl shadow-md shadow-blue-200 transition">
										Get Badge</button>
								</c:otherwise>
							</c:choose>
						</div>

						<!-- Received Tips History -->
						<div>
							<h4
								class="font-bold text-xs text-gray-700 uppercase tracking-wider mb-2">Recent
								Tips Received</h4>
							<div id="creatorTipsReceivedList" class="space-y-2">
								<div class="text-center py-6 text-gray-400 text-xs">
									<i class="fa-solid fa-spinner fa-spin text-base mb-2"></i><br>Loading
									tips history...
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			</body>
</html>
