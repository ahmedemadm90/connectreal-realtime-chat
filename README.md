# 💬 ConnectReal - Real-Time Chat Platform

A full-stack, high-performance real-time messaging application featuring a **Laravel WebSockets Backend** and a **Flutter Mobile Client**, built to handle live bidirectional communication with low latency.

---

## 🛠️ Architecture & Tech Stack

- **Backend**: Laravel 11, Laravel Reverb / WebSockets, Laravel Sanctum
- **Frontend / Mobile**: Flutter (Dart) with WebSocket channels integration
- **Database**: MySQL / SQLite with Eloquent real-time event broadcasting
- **Protocol**: WebSockets (WSS) & REST API fallback

---

## 📦 Core Features

1. **Real-Time Event Broadcasting**:
   - Instant message delivery across connected clients using Laravel event broadcasting.
2. **Secure Authentication**:
   - Token-based Sanctum authentication for private WebSocket channels.
3. **Cross-Platform Mobile Client**:
   - Smooth Flutter UI with automatic reconnection handling and live chat bubbles.
4. **Typing Indicators & Presence**:
   - Live presence channels to track online status and typing activity.

---

## 📂 Repository Structure

```tree
connectreal-realtime-chat/
├── backend/          # Laravel WebSocket & REST API server
├── frontend/         # Flutter mobile application
└── README.md
```

---

## ⚙️ Installation & Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/ahmedemadm90/connectreal-realtime-chat.git
   cd connectreal-realtime-chat
   ```

2. **Setup Backend**:
   ```bash
   cd backend
   composer install
   php artisan migrate
   php artisan serve
   ```

3. **Setup Frontend**:
   ```bash
   cd ../frontend
   flutter pub get
   flutter run
   ```

---

## 👨‍💻 Author

Developed with ❤️ by **Ahmed Emad** (Full-Stack & Mobile Developer).
