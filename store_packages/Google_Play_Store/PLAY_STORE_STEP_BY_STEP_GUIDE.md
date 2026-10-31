# Google Play Store Release Guide (গুগল প্লে স্টোর পাবলিশ গাইড)

এই ফোল্ডারে আপনার অ্যাপ গুগল প্লে স্টোরে জমা দেওয়ার জন্য সবকিছু প্রস্তুত করা হয়েছে।

### 📁 ফোল্ডারের ফাইলসমূহ:
1. `build_outputs/Y-ChatApp-release.aab`: গুগল প্লে স্টোরে আপলোড করার জন্য অফিশিয়াল Android App Bundle (.aab)।
2. `build_outputs/Y-ChatApp.apk`: সরাসরি টেস্ট করার জন্য রেডিমেড APK।
3. `store_graphics/icon-512x512.png`: প্লে স্টোরের জন্য নির্ধারিত 512x512 হাই-রেজোলিউশন অ্যাপ আইকন।
4. `store_graphics/feature_graphic-1024x500.png`: প্লে স্টোরের হোমপেজ ও ব্যানারের জন্য 1024x500 ফিচার গ্রাফিক্স ব্যানার।
5. `store_listing/`: অ্যাপ টাইটেল, শর্ট ডেসক্রিপশন এবং ফুল ডেসক্রিপশন টেক্সট ফাইল।
6. `screenshots/`: আপনার ফোনের স্ক্রিনশট রাখার ফোল্ডার।

---

### 🚀 গুগল প্লে স্টোরে আপলোড করার সহজ ধাপসমূহ:
1. **Google Play Console**-এ লগইন করুন: https://play.google.com/console
2. **"Create App"** বাটনে ক্লিক করুন:
   - App Name: `Y-ChatApp - Social & Messenger`
   - Default Language: English (United States)
   - App or Game: App
   - Free or Paid: Free
3. **Store Presence -> Main store listing**:
   - `store_listing/app_title.txt` থেকে নাম পেস্ট করুন।
   - `store_listing/short_description.txt` থেকে শর্ট ডেসক্রিপশন পেস্ট করুন।
   - `store_listing/full_description.txt` থেকে ফুল ডেসক্রিপশন পেস্ট করুন।
   - **App Icon**: `store_graphics/icon-512x512.png` আপলোড করুন।
   - **Feature Graphic**: `store_graphics/feature_graphic-1024x500.png` আপলোড করুন।
   - **Phone Screenshots**: আপনার ফোনের ২ থেকে ৮ টি স্ক্রিনশট আপলোড করুন।
4. **App Content & Data Safety**:
   - Privacy Policy URL: `http://3.26.151.171:8080/privacy_policy.jsp` দিন।
   - Ads: No (বা যদি অ্যাড রাখেন Yes দিন)।
   - Content Rating: Questionnaire পূরণ করুন (Social Network ক্যাটাগরি)।
5. **Production Release**:
   - **Releases -> Production -> Create new release**-এ যান।
   - **App Bundles**: `build_outputs/Y-ChatApp-release.aab` ফাইলটি ড্র্যাগ করে ড্রপ করুন।
   - Release Name: `1.0 (Initial Release)` দিন।
   - **Next -> Save -> Review Release -> Start rollout to Production** ক্লিক করুন।
