# Real-Time Chat App

A modern, feature-rich chat application built with Flutter and Firebase, enabling seamless real-time communication between users.

## 🚀 Features

- **Real-time Messaging**: Instant message delivery using Firebase Firestore
- **One-on-One Conversations**: Private chat between users
- **User Authentication**: Secure login and registration with Firebase Auth
- **Message History**: Persistent chat history stored in Firestore
- **Responsive UI**: Clean and intuitive Material Design interface
- **Offline Support**: View message history even without internet connection
- **Typing Indicators**: See when someone is typing (optional if implemented)
- **Read Receipts**: Track message delivery and read status (optional if implemented)

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Backend**: Firebase
- **Database**: Cloud Firestore
- **Authentication**: Firebase Authentication
- **State Management**: Riverpod
- **Language**: Dart

## 📱 Screenshots

(Add screenshots of your app here)

## 🔧 Installation

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Firebase account
- Android Studio / VS Code
- Android emulator or physical device

### Setup

1. **Clone the repository**
```bash
   git clone https://github.com/MuhammadAwaisGill/realtime-chat-app.git
   cd realtime-chat-app
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Firebase Configuration**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Firebase Authentication and Cloud Firestore
   - Download `google-services.json` (Android) and place it in `android/app/`
   - Download `GoogleService-Info.plist` (iOS) and place it in `ios/Runner/`

4. **Run the app**
```bash
   flutter run
```

## 📂 Project Structure
```
lib/
├── main.dart
├── models/          # Data models
├── providers/       # Riverpod providers
├── screens/         # UI screens
├── services/        # Firebase services
└── widgets/         # Reusable widgets
```

## 🔐 Firebase Security Rules

Make sure to configure Firestore security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
    }
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Muhammad Awais**
- GitHub: [@MuhammadAwaisGill](https://github.com/MuhammadAwaisGill)
- LinkedIn: [muhammad--awais](https://linkedin.com/in/muhammad--awais)
- Email: muhammadawaisgill18@gmail.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Riverpod for state management solutions
