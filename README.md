# 📚 Student Notes Management App (Flutter + Supabase)

A production-level mobile application built using **Flutter** and **Supabase**, designed for engineering students to access notes, MCQs, and study materials with a role-based system.

---

## 🚀 Features

### 🔐 Authentication

* Email/Password login & signup
* Role-based access:

    * 👨‍🎓 Student
    * 👨‍🏫 Teacher
    * 👑 Admin

---

### 📚 Notes Feed

* Scrollable feed (like social media)
* Mixed content:

    * 📄 PDF Notes
    * 🖼️ Images
    * 📘 Documents
    * 🎥 Video lectures
* Latest + Most Viewed algorithm

---

### 🏷️ Categories (Engineering Branches)

* Computer Engineering
* Mechanical Engineering
* Civil Engineering
* Electrical Engineering
* Electronics
* IT

---

### 🔍 Search & Filter

* Search by title or subject
* Category-based filtering

---

### ⭐ Bookmark System

* Save important notes
* Quick access

---

### 📡 Offline Support

* Cached notes using SharedPreferences
* Works without internet (basic level)

---

### 👨‍🏫 Teacher System

* Only teachers/admin can upload notes
* Teachers must be **verified by admin**

---

### 👑 Admin Panel

* Approve/reject teachers
* Control content visibility

---

### 🧠 MCQ Quiz System

* Timer-based quiz
* Score tracking
* Engineering-related questions

---

### 📱 UI Features

* Bottom Navigation:

    * 🏠 Feed
    * 📂 Categories
    * 👤 Profile
* Clean Material Design
* Thumbnail-based content display

---

## 🏗️ Tech Stack

| Technology        | Usage                         |
| ----------------- | ----------------------------- |
| Flutter 3.x       | UI Development                |
| Dart              | Programming Language          |
| Supabase          | Backend (Auth + DB + Storage) |
| Provider          | State Management              |
| SharedPreferences | Offline caching               |

---

## 📁 Project Structure

```
lib/
│
├── core/
│   ├── constants/
│   └── navigation/
│
├── features/
│   ├── auth/
│   ├── notes/
│   ├── quiz/
│   ├── admin/
│   ├── category/
│   └── profile/
│
└── main.dart
```

---

## 🔐 Role-Based Access

| Role    | Permissions                   |
| ------- | ----------------------------- |
| Student | View notes, take quiz         |
| Teacher | Upload notes (if verified)    |
| Admin   | Verify teachers, manage users |

---

## ⚙️ Setup Instructions

### 1️⃣ Clone Repository

```bash
git clone https://github.com/your-username/notes-app.git
cd notes-app
```

---

### 2️⃣ Install Dependencies

```bash
flutter pub get
```

---

### 3️⃣ Setup Supabase

* Create project in Supabase
* Enable Auth (Email/Password)
* Create tables:

    * `users`
    * `notes`

---

### 4️⃣ Run App

```bash
flutter run
```

---

## 📊 Database Design

### 🔹 Users Table

* id
* email
* role (student / teacher / admin)
* is_verified

---

### 🔹 Notes Table

* id
* title
* subject
* file_url
* thumbnail_url
* type
* views_count
* created_at

---

## 🧠 Key Concepts Used

* State Management using Provider
* Role-Based Access Control (RBAC)
* RESTful backend integration (Supabase)
* Offline caching strategy
* Scalable architecture

---

## 🎯 Future Improvements

* Push Notifications
* Video streaming optimization
* Dark Mode
* Advanced search (tags, filters)
* Cloud sync for bookmarks

---

## 👨‍💻 Author

**Vaibhav Kadu**
Final Year Engineering Student
of SND College of Engineering, Yeola

---

## 📌 Project Purpose

This project demonstrates:

* Full-stack mobile app development
* Real-world architecture
* Scalable backend integration
* Production-ready features

---
