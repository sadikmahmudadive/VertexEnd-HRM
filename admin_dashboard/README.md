# VertexHand HRM — Web Admin Dashboard

Enterprise Web Admin Dashboard for **VertexHand HRM**, built with **Next.js (App Router)**, **React 19**, **TypeScript**, and **Tailwind CSS**. It connects seamlessly to **Firebase** (Auth & Cloud Firestore) and **Cloudinary** (Media CDN).

---

## Features

1. **Executive Overview Dashboard (`/`)**
   - Real-time workforce KPIs: Total staff, Clocked-in today, Outdoor/Field duty active, Pending approvals.
   - 7-Day Attendance Trend chart (In-Office vs Field Outwork vs Leave).
   - Headcount distribution across Engineering, Design, Finance, People, and Sales.
   - Live stream of outdoor field duty punches and pending action center.

2. **Live Attendance & Outwork Monitor (`/attendance`)**
   - Real-time employee attendance log with shift durations.
   - Filter by: In-Office, Field Outwork, or All.
   - In-Office Geofence Verified vs Outwork Exemption badges.
   - 1-click **Export CSV Attendance Report**.

3. **Field Duty & Outwork Management (`/outwork`)**
   - Audit outdoor client visits (e.g. Apex Footwear, Grameenphone, BRAC Bank).
   - Inspect on-site photo proofs uploaded via **Cloudinary**.
   - 1-click Approve / Reject with automatic geofence exemption.

4. **Leave Management & Approvals (`/leaves`)**
   - Annual, Sick, Work From Home, and Comp-Off balance quotas.
   - Pending leave applications queue with team coverage impact analysis.
   - 1-click Approve / Reject.

5. **Employee Directory (`/employees`)**
   - Complete workforce roster with search and department filtering.
   - Modal to register new team members into the system.
   - Direct email and phone links.

6. **Expense Reimbursements (`/expenses`)**
   - Audit expense claims with attached receipts hosted on **Cloudinary CDN**.
   - Full HD receipt image preview modal.
   - Approve claims for disbursement with monthly payroll.

7. **Broadcast Announcements (`/announcements`)**
   - Publish company notices, policies, and holiday alerts directly to employee mobile apps.
   - High, Normal, and Low priority banner controls.

8. **Settings & Cloud Integration (`/settings`)**
   - Real-time status of Firebase Auth, Cloud Firestore, and Cloudinary.
   - Office geofence perimeter radius and company configuration.

---

## Getting Started

### 1. Install dependencies (already installed)
```bash
cd admin_dashboard
npm install
```

### 2. Run the development server
```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the dashboard.

### 3. Connect to Firebase (Optional)
Create an `.env.local` file inside `admin_dashboard/`:
```env
NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
```
*(If omitted, the dashboard automatically operates in realistic interactive Demo Mode).*
