<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Y-ChatApp</title>
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
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap');
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: #f8fafc; }
        .glass-card { background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(10px); border: 1px solid rgba(255, 255, 255, 0.2); }
        .btn-gradient { background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); transition: all 0.3s ease; }
        .btn-gradient:hover { transform: translateY(-2px); box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.4); }
        .input-focus:focus { ring: 2px; ring-color: #3b82f6; border-color: #3b82f6; outline: none; }
    </style>
</head>

<body class="min-h-screen flex items-center justify-center p-4 bg-slate-50">
    
    <div class="max-w-6xl w-full grid lg:grid-cols-2 gap-12 items-center">
        
        <!-- Left Side: Branding -->
        <div class="hidden lg:block space-y-6">
            <div class="inline-flex items-center gap-2 text-blue-600 mb-2">
                <div class="bg-blue-600 p-1 rounded-xl">
                    <img src="<%=request.getContextPath()%>/icons/icon-192.png" alt="Logo" class="w-10 h-10 object-contain">
                </div>
                <span class="text-3xl font-bold tracking-tight text-slate-900">Y-ChatApp</span>
            </div>
            <h1 class="text-6xl font-extrabold text-slate-900 leading-[1.1]">
                Connect with the <br> 
                <span class="text-transparent bg-clip-text bg-gradient-to-r from-blue-600 to-indigo-600">World Around You.</span>
            </h1>
            <p class="text-xl text-slate-600 max-w-lg leading-relaxed">
                Experience the next generation of social interaction. Share, chat, and connect in a faster, more secure environment.
            </p>
            <div class="flex items-center gap-8 pt-6">
                <div class="flex -space-x-3">
                    <img class="w-12 h-12 rounded-full border-4 border-white shadow-sm" src="https://i.pravatar.cc/150?u=1" alt="">
                    <img class="w-12 h-12 rounded-full border-4 border-white shadow-sm" src="https://i.pravatar.cc/150?u=2" alt="">
                    <img class="w-12 h-12 rounded-full border-4 border-white shadow-sm" src="https://i.pravatar.cc/150?u=3" alt="">
                    <div class="w-12 h-12 rounded-full border-4 border-white bg-slate-100 flex items-center justify-center text-slate-500 font-bold text-xs shadow-sm">+10k</div>
                </div>
                <p class="text-slate-500 font-medium">Join 10,000+ active users today!</p>
            </div>

            <!-- Native Mobile App Card (Left Branding) -->
            <div class="mt-8 p-6 bg-white/80 backdrop-blur-md rounded-3xl border border-slate-200/80 shadow-sm space-y-4">
                <div class="flex items-center justify-between">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-blue-600 to-indigo-600 flex items-center justify-center text-white shadow-md">
                            <i class="fa fa-mobile-screen text-lg"></i>
                        </div>
                        <div>
                            <h4 class="font-bold text-slate-900 text-sm">Download Native App</h4>
                            <p class="text-xs text-slate-500">Lock-screen incoming call ringing &amp; CallKit</p>
                        </div>
                    </div>
                    <span class="text-[11px] font-semibold text-emerald-600 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-200">v1.0.0</span>
                </div>
                <div class="grid grid-cols-2 gap-3 pt-1">
                    <a href="<%=request.getContextPath()%>/app-debug.apk" download="YChat.apk" class="flex items-center justify-center gap-2 px-4 py-3 bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold rounded-2xl shadow-sm transition-all hover:scale-[1.02]">
                        <i class="fab fa-android text-base text-emerald-400"></i>
                        <span>Android .APK</span>
                    </a>
                    <button type="button" onclick="openIosModal()" class="flex items-center justify-center gap-2 px-4 py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white text-xs font-semibold rounded-2xl shadow-sm transition-all hover:scale-[1.02]">
                        <i class="fab fa-apple text-base"></i>
                        <span>iOS / iPhone</span>
                    </button>
                </div>
            </div>
        </div>

        <!-- Right Side: Login Card -->
        <div class="w-full max-w-md mx-auto">
            <div class="glass-card p-10 rounded-[2.5rem] shadow-[0_20px_50px_rgba(0,0,0,0.05)] bg-white relative overflow-hidden">
                
                <div class="mb-8 text-center">
                    <h2 class="text-3xl font-bold text-slate-900 mb-2">Welcome Back</h2>
                    <p class="text-slate-500">Please enter your details to sign in</p>
                </div>

                <div id="errorBox" class="hidden mb-6 p-4 bg-red-50 border-l-4 border-red-500 text-red-700 text-sm rounded-r-lg flex items-center gap-3">
                    <i class="fa fa-circle-exclamation text-lg"></i>
                    <span id="errorMessage"></span>
                </div>

                <c:if test="${not empty logoutMsg or not empty successMsg}">
                    <div class="mb-6 p-4 bg-green-50 border-l-4 border-green-500 text-green-700 text-sm rounded-r-lg flex items-center gap-3">
                        <i class="fa fa-circle-check text-lg"></i>
                        <span>${logoutMsg}${successMsg}</span>
                    </div>
                </c:if>

                <form id="loginForm" class="space-y-5">
                    <div class="space-y-1">
                        <label class="text-sm font-semibold text-slate-700 ml-1">Email Address</label>
                        <div class="relative group">
                            <i class="fa fa-envelope absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-blue-500 transition-colors"></i>
                            <input type="email" name="email" id="email" placeholder="name@company.com" required
                                autocomplete="username email"
                                value="${not empty savedEmail ? savedEmail : ''}"
                                class="w-full pl-11 pr-4 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all text-slate-700">
                        </div>
                    </div>

                    <div class="space-y-1">
                        <label class="text-sm font-semibold text-slate-700 ml-1">Password</label>
                        <div class="relative group">
                            <i class="fa fa-lock absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-blue-500 transition-colors"></i>
                            <input type="password" name="pass" id="pass" placeholder="••••••••" required
                                autocomplete="current-password"
                                class="w-full pl-11 pr-4 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all text-slate-700">
                        </div>
                    </div>

                    <div class="flex items-center justify-between py-2">
                        <label class="flex items-center gap-2 cursor-pointer group">
                            <input type="checkbox" name="remember" id="remember" ${not empty savedEmail or not empty cookie.rem_token ? 'checked' : 'checked'} class="w-5 h-5 rounded-lg border-slate-300 text-blue-600 focus:ring-blue-500 transition-all cursor-pointer">
                            <span class="text-sm text-slate-600 group-hover:text-slate-900 transition-colors">Remember me</span>
                        </label>
                        <a href="ForgotPasswordServlet" class="text-sm font-semibold text-blue-600 hover:text-blue-700">Forgot password?</a>
                    </div>

                    <button type="submit" id="submitBtn" class="w-full btn-gradient py-4 text-white font-bold rounded-2xl shadow-lg shadow-blue-500/30 flex items-center justify-center gap-3">
                        <span>Sign In</span>
                        <i class="fa fa-arrow-right text-sm"></i>
                    </button>
                </form>

                <!-- Two-Factor Authentication (2FA) Modal Section -->
                <div id="twoFactorSection" class="hidden space-y-5">
                    <div class="text-center mb-4">
                        <div class="w-14 h-14 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center mx-auto mb-3 text-2xl">
                            <i class="fa fa-shield-halved"></i>
                        </div>
                        <h3 class="text-xl font-bold text-slate-900">Two-Factor Authentication</h3>
                        <p class="text-xs text-slate-500 mt-1">A 6-digit security code has been sent to your registered email address.</p>
                    </div>

                    <div class="space-y-1">
                        <label class="text-sm font-semibold text-slate-700 ml-1">Enter 6-Digit OTP</label>
                        <div class="relative group">
                            <i class="fa fa-key absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 group-focus-within:text-blue-500 transition-colors"></i>
                            <input type="text" id="twoFactorOtp" maxlength="6" placeholder="123456" autocomplete="one-time-code"
                                class="w-full pl-11 pr-4 py-3.5 bg-slate-50 border border-slate-200 rounded-2xl focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 outline-none transition-all text-slate-800 tracking-widest text-center text-xl font-bold">
                        </div>
                    </div>

                    <button type="button" id="verify2FABtn" class="w-full btn-gradient py-4 text-white font-bold rounded-2xl shadow-lg shadow-blue-500/30 flex items-center justify-center gap-3">
                        <span>Verify &amp; Continue</span>
                        <i class="fa fa-check text-sm"></i>
                    </button>

                    <div class="text-center">
                        <button type="button" id="cancel2FABtn" class="text-sm text-slate-500 hover:text-slate-800 font-medium">
                            <i class="fa fa-arrow-left mr-1"></i> Back to Login
                        </button>
                    </div>
                </div>

                <div class="mt-8 flex items-center gap-4">
                    <div class="flex-1 h-px bg-slate-100"></div>
                    <span class="text-sm text-slate-400 font-medium italic">OR</span>
                    <div class="flex-1 h-px bg-slate-100"></div>
                </div>

                <div class="mt-8 text-center space-y-3">
                    <p class="text-slate-600">Don't have an account? 
                        <a href="UsersRegistServlet" class="text-blue-600 font-bold hover:underline">Create an account</a>
                    </p>
                    <div>
                        <a href="PolicyServlet" class="text-xs text-slate-400 hover:text-blue-600 hover:underline transition-colors inline-flex items-center gap-1.5">
                            <i class="fa fa-shield-halved text-xs text-blue-500"></i> Privacy Policy &amp; Terms
                        </a>
                    </div>

                    <!-- Mobile App Download Banner (Visible on all devices) -->
                    <div class="pt-4 border-t border-slate-100 text-center">
                        <p class="text-xs font-bold text-slate-600 uppercase tracking-wider mb-2.5">
                            <i class="fa fa-mobile-screen text-blue-600 mr-1"></i> Get YChat Mobile App
                        </p>
                        <div class="flex items-center justify-center gap-2">
                            <a href="<%=request.getContextPath()%>/app-debug.apk" download="YChat.apk" class="inline-flex items-center gap-1.5 px-3 py-2 bg-slate-900 text-white text-xs font-semibold rounded-xl hover:bg-slate-800 transition-colors shadow-sm">
                                <i class="fab fa-android text-emerald-400"></i> Android APK
                            </a>
                            <button type="button" onclick="openIosModal()" class="inline-flex items-center gap-1.5 px-3 py-2 bg-blue-600 text-white text-xs font-semibold rounded-xl hover:bg-blue-700 transition-colors shadow-sm">
                                <i class="fab fa-apple"></i> iOS (iPhone)
                            </button>
                            <a href="https://github.com/shoabnewaj/ychatApp/releases/tag/mobile-latest" target="_blank" rel="noopener" class="inline-flex items-center gap-1 px-2.5 py-2 text-slate-500 hover:text-slate-800 text-xs font-medium rounded-xl border border-slate-200 hover:bg-slate-50 transition-colors" title="GitHub Releases">
                                <i class="fab fa-github"></i>
                            </a>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- Loading Overlay -->
    <div id="loadingOverlay" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[9999] flex flex-col items-center justify-center text-white">
        <div class="w-16 h-16 border-4 border-blue-500 border-t-transparent rounded-full animate-spin mb-4"></div>
        <p class="font-bold text-xl animate-pulse">Authenticating...</p>
    </div>

    <!-- iOS / iPhone Installation Modal -->
    <div id="iosModal" class="hidden fixed inset-0 bg-slate-900/60 backdrop-blur-sm z-[9999] flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-100 relative">
            <button type="button" onclick="closeIosModal()" class="absolute top-4 right-4 w-8 h-8 rounded-full bg-slate-100 text-slate-500 hover:bg-slate-200 flex items-center justify-center text-sm transition-colors">
                <i class="fa fa-xmark"></i>
            </button>
            <div class="flex items-center gap-3 mb-4">
                <div class="w-12 h-12 rounded-2xl bg-gradient-to-tr from-slate-900 to-slate-700 text-white flex items-center justify-center text-2xl shadow-md">
                    <i class="fab fa-apple"></i>
                </div>
                <div>
                    <h3 class="text-lg font-bold text-slate-900">YChat for iOS (iPhone)</h3>
                    <p class="text-xs text-slate-500">Native Apple CallKit &amp; Lock-Screen Ringing</p>
                </div>
            </div>

            <div class="space-y-3 text-xs text-slate-600 bg-slate-50 p-4 rounded-2xl border border-slate-200">
                <div class="flex items-start gap-2.5">
                    <span class="w-5 h-5 rounded-full bg-blue-600 text-white font-bold flex items-center justify-center shrink-0 text-[11px]">1</span>
                    <p><b>Download the IPA file:</b> Tap below to download <code class="bg-white px-1.5 py-0.5 rounded border border-slate-200 text-blue-600 font-semibold">YChat.ipa</code>.</p>
                </div>
                <div class="flex items-start gap-2.5">
                    <span class="w-5 h-5 rounded-full bg-blue-600 text-white font-bold flex items-center justify-center shrink-0 text-[11px]">2</span>
                    <p><b>Install via Sideloadly / AltStore / Scarlet:</b> Sideload the IPA onto your iPhone using your Apple ID (No jailbreak required).</p>
                </div>
                <div class="flex items-start gap-2.5">
                    <span class="w-5 h-5 rounded-full bg-blue-600 text-white font-bold flex items-center justify-center shrink-0 text-[11px]">3</span>
                    <p><b>Trust App:</b> Go to <i>Settings &rarr; General &rarr; VPN &amp; Device Management</i> and tap <b>Trust</b>.</p>
                </div>
            </div>

            <div class="mt-5 flex flex-col gap-2.5">
                <a href="<%=request.getContextPath()%>/YChat.ipa" download="YChat.ipa" class="w-full py-3 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-700 hover:to-indigo-700 text-white font-bold rounded-xl shadow-md shadow-blue-500/20 flex items-center justify-center gap-2 text-sm transition-all">
                    <i class="fa fa-download"></i>
                    <span>Download YChat.ipa (906 KB)</span>
                </a>
                <a href="https://github.com/shoabnewaj/ychatApp/releases/tag/mobile-latest" target="_blank" rel="noopener" class="w-full py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold rounded-xl flex items-center justify-center gap-2 text-xs transition-colors">
                    <i class="fab fa-github"></i>
                    <span>View Releases on GitHub</span>
                </a>
            </div>
        </div>
    </div>

    <script>
        const loginForm = document.getElementById('loginForm');
        const twoFactorSection = document.getElementById('twoFactorSection');
        const twoFactorOtp = document.getElementById('twoFactorOtp');
        const verify2FABtn = document.getElementById('verify2FABtn');
        const cancel2FABtn = document.getElementById('cancel2FABtn');
        const errorBox = document.getElementById('errorBox');
        const errorMessage = document.getElementById('errorMessage');
        const loadingOverlay = document.getElementById('loadingOverlay');

        loginForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            errorBox.classList.add('hidden');
            loadingOverlay.classList.remove('hidden');
            
            const formData = new FormData(this);
            formData.append('ajax', 'true');
            
            const params = new URLSearchParams(formData);

            fetch('UsersLoginServlet', {
                method: 'POST',
                body: params,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(response => response.json())
            .then(data => {
                loadingOverlay.classList.add('hidden');
                if (data.requires2FA) {
                    loginForm.classList.add('hidden');
                    twoFactorSection.classList.remove('hidden');
                    twoFactorOtp.value = '';
                    twoFactorOtp.focus();
                } else if (data.success) {
                    window.location.href = data.redirect;
                } else {
                    errorMessage.textContent = data.message;
                    errorBox.classList.remove('hidden');
                }
            })
            .catch(error => {
                loadingOverlay.classList.add('hidden');
                errorMessage.textContent = "An error occurred. Please try again.";
                errorBox.classList.remove('hidden');
            });
        });

        // Verify 2FA OTP
        verify2FABtn.addEventListener('click', function() {
            const otpVal = twoFactorOtp.value.trim();
            if (!otpVal || otpVal.length < 6) {
                errorMessage.textContent = "Please enter the valid 6-digit OTP.";
                errorBox.classList.remove('hidden');
                return;
            }

            errorBox.classList.add('hidden');
            loadingOverlay.classList.remove('hidden');

            const params = new URLSearchParams();
            params.append('action', 'verify2FA');
            params.append('otp', otpVal);

            fetch('UsersLoginServlet', {
                method: 'POST',
                body: params,
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
            })
            .then(response => response.json())
            .then(data => {
                loadingOverlay.classList.add('hidden');
                if (data.success) {
                    window.location.href = data.redirect || 'UsersPostServlet';
                } else {
                    errorMessage.textContent = data.message || "Invalid or expired OTP code.";
                    errorBox.classList.remove('hidden');
                }
            })
            .catch(error => {
                loadingOverlay.classList.add('hidden');
                errorMessage.textContent = "Error verifying 2FA OTP. Please try again.";
                errorBox.classList.remove('hidden');
            });
        });

        cancel2FABtn.addEventListener('click', function() {
            twoFactorSection.classList.add('hidden');
            loginForm.classList.remove('hidden');
            errorBox.classList.add('hidden');
        });

        function openIosModal() {
            document.getElementById('iosModal').classList.remove('hidden');
        }

        function closeIosModal() {
            document.getElementById('iosModal').classList.add('hidden');
        }
    </script>
    <script src="js/theme.js"></script>
</body>
</html>