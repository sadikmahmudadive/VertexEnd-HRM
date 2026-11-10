# Backend Integration Guide: Firebase & Cloudinary

VertexHand HRM is now fully architected to use **Firebase** for backend services (Authentication, Cloud Firestore database) and **Cloudinary** for media storage (profile avatars, expense receipt scans, on-site outwork proof photos).

---

## 1. Firebase Backend (Auth & Firestore)

### Step 1: Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project (e.g., `vertexhand-hrm`).
3. Under **Build > Authentication**:
   - Enable **Email/Password** sign-in method.
4. Under **Build > Firestore Database**:
   - Click **Create database** (start in test mode or production mode).

### Step 2: Configure FlutterFire
You can configure Firebase in two ways:

#### Option A: Run FlutterFire CLI (Fastest & Automated)
```bash
# Install FlutterFire CLI if you haven't:
dart pub global activate flutterfire_cli

# Run configuration in your project root:
flutterfire configure
```
Select your Firebase project. This will automatically update [`lib/core/firebase/firebase_options.dart`](file:///f:/Code/Flutter%20Projects/VertexHand%20HRM/lib/core/firebase/firebase_options.dart).

#### Option B: Manual Setup
Open [`lib/core/firebase/firebase_options.dart`](file:///f:/Code/Flutter%20Projects/VertexHand%20HRM/lib/core/firebase/firebase_options.dart) and paste your Web and Android keys:
- `apiKey`
- `appId`
- `messagingSenderId`
- `projectId`
- `storageBucket`

> **Note:** The app has a built-in safety net (`DefaultFirebaseOptions.isConfigured`). If keys are not yet configured or you are offline, it gracefully falls back to local demo mode without throwing unhandled exceptions.

### Firestore Collections Structure
- **`users`**: Employee profiles (`id`, `name`, `email`, `role`, `dept`, `avatarUrl`, `phone`, `companyCode`).
- **`attendance`**: Daily clock-in & out logs (`userId`, `date`, `clockInTime`, `clockOutTime`, `isOutwork`, `location`, `clientName`, `seconds`).
- **`outwork_requests`**: Field duty requests (`userId`, `userName`, `category`, `clientName`, `location`, `schedule`, `reason`, `status`, `proofImageUrl`).
- **`leave_requests`**: Leave applications (`userId`, `userName`, `leaveType`, `dates`, `length`, `reason`, `status`).
- **`expenses`**: Expense claims with Cloudinary receipt image CDN URLs (`userId`, `title`, `category`, `amount`, `date`, `status`, `receiptImageUrl`).
- **`tasks`**: Assigned task checklist (`userId`, `title`, `sub`, `done`, `due`).
- **`notifications`**: Push & in-app alerts.

---

## 2. Cloudinary Media Storage

Cloudinary handles media uploads via high-speed, direct unsigned HTTPS endpoints, with zero native build dependencies.

### Step 1: Get Cloudinary Credentials
1. Sign up or log into [Cloudinary](https://cloudinary.com/) (Free tier includes generous storage and bandwidth).
2. From your Cloudinary Dashboard:
   - Copy your **Cloud name** (e.g. `my_cloud_name`).
3. In **Settings > Upload > Upload presets**:
   - Click **Add upload preset**.
   - Set **Signing mode** to **Unsigned**.
   - Name your preset (e.g. `hrm_unsigned`).
   - Click **Save**.

### Step 2: Set Credentials in VertexHand HRM
Open [`lib/core/services/cloudinary_service.dart`](file:///f:/Code/Flutter%20Projects/VertexHand%20HRM/lib/core/services/cloudinary_service.dart) and set:
```dart
static const String _defaultCloudName = 'YOUR_CLOUD_NAME';
static const String _defaultUploadPreset = 'YOUR_UPLOAD_PRESET';
```

### Where Cloudinary is Integrated in the App
1. **Profile Photos** ([`ProfileScreen`](file:///f:/Code/Flutter%20Projects/VertexHand%20HRM/lib/features/profile/profile_screen.dart)):
   - Tap the avatar to snap a photo or choose from gallery.
   - Uploads to `vertexhand_hrm/avatars/`.
   - Saves the secure HTTPS CDN URL to Firestore `users/{uid}/avatarUrl` and renders on [`HrmAvatar`](file:///f:/Code/Flutter%20Projects/VertexHand%20HRM/lib/core/widgets/components.dart).
2. **Expense Receipts** ([`ExpensesScreen`](file:///f:/Code/Flutter%20Projects/VertexHand%20HRM/lib/features/expenses/expenses_screen.dart)):
   - Snap a receipt with camera or select from gallery.
   - Uploads to `vertexhand_hrm/receipts/`.
   - Attaches `receiptImageUrl` to the claim in Firestore. Tap recent claims to view full receipt photos.
3. **Outwork Field Duty Proofs** ([`OutworkRequestSheet`](file:///f:/Code/Flutter%20Projects/VertexHand%20HRM/lib/features/attendance/outwork_request_sheet.dart)):
   - Snap on-site client photo (e.g., client office signboard/premises).
   - Uploads to `vertexhand_hrm/outwork/`.
   - Saves `proofImageUrl` into the Firestore outwork document.

---

## 3. Running & Testing

Press **`R`** (hot restart) or run:
```bash
flutter run
```
All smoke tests and static analysis pass cleanly with 0 warnings:
```bash
flutter analyze
flutter test
```

