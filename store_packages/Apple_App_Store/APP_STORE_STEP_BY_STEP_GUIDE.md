# Apple App Store Submission Guide (অ্যাপল অ্যাপ স্টোর সাবমিশন গাইড)

এই ফোল্ডারে অ্যাপল অ্যাপ স্টোরে সাবমিট করার জন্য সম্পূর্ণ Xcode সুইফট প্রজেক্ট ও গ্রাফিক্স রেডি করা হয়েছে।

### 📁 ফোল্ডারের ফাইলসমূহ:
1. `ios_xcode_project/`: সম্পূর্ণ iOS Xcode প্রজেক্ট (SwiftUI + WKWebView)।
   - `YChatAppApp.swift`: অ্যাপ এন্ট্রি পয়েন্ট।
   - `ContentView.swift`: অটো-কুকি সিঙ্ক ও ক্যামেরা/মাইক্রোফোন হ্যান্ডলার সহ নেটিভ ওয়েবভিউ।
   - `Info.plist`: ক্যামেরা, মাইক্রোফোন এবং ফটো গ্যালারির সকল Apple Privacy Permission রিকোয়ারমেন্ট সহ।
2. `store_graphics/AppIcon-1024x1024.png`: অ্যাপ স্টোরের স্ট্যান্ডার্ড ১০২৪x১০২৪ আইকন (Apple-এর নিয়ম অনুযায়ী নো-আলফা/স্বচ্ছতাহীন RGB)।
3. `store_listing/`: অ্যাপ স্টোর নেম, সাবটাইটেল, কি-ওয়ার্ড এবং ডেসক্রিপশন ফাইল।

---

### 🚀 অ্যাপল অ্যাপ স্টোরে সাবমিট করার ধাপসমূহ:
1. **Apple Developer Account** প্রয়োজন (developer.apple.com - $99/বছর)।
2. **Mac / Xcode-এ প্রজেক্ট ওপেন করা:**
   - ম্যাক কম্পিউটারে (বা MacinCloud ক্লাউড ম্যাকে) এই `ios_xcode_project` ফোল্ডারটি ওপেন করুন।
   - Signing & Capabilities ট্যাবে আপনার Developer Team সিলেক্ট করুন।
3. **Archive & Upload:**
   - Product -> Archive সিলেক্ট করুন।
   - বিল্ড সম্পন্ন হলে "Distribute App" -> "App Store Connect" -> "Upload" চাপুন।
4. **App Store Connect-এ লিস্টিং তৈরি:**
   - https://appstoreconnect.apple.com এ গিয়ে নতুন অ্যাপ তৈরি করুন।
   - `store_listing/app_name.txt` ও `store_listing/subtitle.txt` পেস্ট করুন।
   - স্ক্রিনশট আপলোড করুন (iPhone 6.7" ও 6.5")।
   - আপলোড করা বিল্ডটি সিলেক্ট করুন এবং "Submit for Review" বাটনে ক্লিক করুন।
