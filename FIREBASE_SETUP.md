# Firebase / FCM Setup — Tendapoa Flutter

Code yote ya Firebase Cloud Messaging tayari imeandikwa. Kinachobaki ni kuweka **configuration files** kutoka Firebase Console.

## 1. Android — `google-services.json`

Weka file kwenye:

```
android/app/google-services.json
```

> **Muhimu**: `applicationId` kwenye `android/app/build.gradle.kts` ni `com.tendapoa.app`. Hakikisha umeunda Android app kwenye Firebase Console kwa kutumia hii hii package name, vinginevyo build itashindwa.

### Verify build
```bash
cd tendapoa-back
flutter clean
flutter pub get
flutter run
```

Kama Gradle ikilalamika "File google-services.json is missing", hiyo ndio sababu.

---

## 2. iOS — `GoogleService-Info.plist`

1. Open `ios/Runner.xcworkspace` kwenye Xcode.
2. Drag `GoogleService-Info.plist` ndani ya target `Runner` (chagua "Copy items if needed").
3. Hakikisha bundle identifier kwenye Xcode = ile uliyoiweka kwenye Firebase Console iOS app.

---

## 3. Backend — Firebase Service Account

Backend (Laravel) inahitaji **service account JSON** (sio sawa na google-services.json):

1. Firebase Console → ⚙️ Project Settings → **Service accounts** → "Generate new private key".
2. Save file kama `storage/app/firebase/service-account.json` ndani ya Laravel project (sio mobile app).
3. Set ENV vars kwenye `.env` ya backend:
   ```
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_CREDENTIALS=storage/app/firebase/service-account.json
   ```

---

## 4. Test push notification

Baada ya configuration:

1. Login kwenye app → check Laravel logs (`storage/logs/laravel.log`) utaona:
   ```
   [FCM] token registered with backend
   ```
2. Endpoint za testing kupitia admin panel:
   - `/admin/broadcast` — tuma push kwa users wote au selected.
3. Au kwa command line (Tinker):
   ```php
   User::find(1)->notify(new \App\Notifications\TestPushNotification());
   ```

---

## Endpoints zinazohusika (mobile)

| Endpoint | Method | Maelezo |
|---|---|---|
| `/api/fcm/register` | POST | Register device token (called automatically on login) |
| `/api/fcm/unregister` | POST | Remove device token (called on logout) |
| `/api/fcm-token` | POST | Legacy single-device endpoint (backward compat) |
| `/api/notifications` | GET | In-app notifications list |
| `/api/notifications/read-all` | POST | Mark all as read |

---

## Troubleshooting

- **"Default FirebaseApp is not initialized"** — `google-services.json` haipo au package name halifaani.
- **Token haitokei kwenye backend** — angalia console logs za debug, hakikisha `Sanctum token` umewekwa kabla ya kuita FCM register.
- **Notifications haziji foreground** — `setForegroundNotificationPresentationOptions` tayari imewekwa; kama bado hazionekani angalia notification permission imekubaliwa.
