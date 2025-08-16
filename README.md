# SocietySphere 🏙️

**A comprehensive Flutter application for modern housing society management.**

SocietySphere is a full-featured mobile application built with Flutter and Firebase, designed to streamline communication and operations within a residential society. It provides separate, feature-rich interfaces for both residents and administrators, covering everything from payments and complaints to notices and user management.

---

## ✨ Features

### 👨‍👩‍👧 For Residents

* **Secure Authentication:** Easy and secure sign-up and login.
* **Dashboard:** A quick overview of pending payments and recent notices.
* **Notice Board:** View all society notices with priority levels.
* **Complaint Management:** File new complaints with categories, priority, and photo attachments. Track the status and view admin responses.
* **Online Payments:** View all pending maintenance bills and pay securely using Razorpay.
* **Payment History:** Access a complete history of all past payments.

### 🔑 For Admins

* **Admin Dashboard:** Get a high-level overview of total residents, pending approvals, monthly collections, and active complaints.
* **User Management:**
    * Approve new resident sign-ups.
    * Grant or revoke admin privileges for other residents.
* **Notice Management:** Post, update, and delete society-wide notices.
* **Complaint Resolution:** View all resident complaints, update their status (Pending, In Progress, Resolved), and post response messages.
* **Maintenance & Billing:**
    * Set new monthly or one-time maintenance charges for all residents.
    * View, edit, and delete previously set maintenance charges.
* **Payment Tracking:**
    * View a complete history of all successful payments.
    * Access a detailed list of all pending payments with powerful filters (by resident name, month, etc.).

---

## 🛠️ Tech Stack

* **Frontend:** Flutter
* **Backend & Database:** Firebase (Firestore, Authentication, Cloud Functions, Storage)
* **State Management:** `StatefulWidget` & `setState`

---

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

* Flutter SDK installed
* A Firebase project created

### Installation

1.  **Clone the repo**
    ```sh
    git clone https://github.com/AbhishekGhume/SocietySphere.git
    ```
2.  **Install Flutter packages**
    ```sh
    flutter pub get
    ```
3.  **Set up Firebase**
    * Follow the instructions to add Firebase to your Flutter app for both Android (`google-services.json`) and iOS (`GoogleService-Info.plist`).
    * Enable **Authentication**, **Firestore**, **Storage**, and **Cloud Functions**.
      
4.  **Run the app**
    ```sh
    flutter run
    ```

---
