# Travelitin

A modern, visually stunning travel safety and itinerary management app built with **Flutter** and **Firebase**.

## ✨ Features

- **Beautiful, Responsive UI:** Modern glassmorphism, gradients, and animated effects.
- **Authentication:** Email/password and phone OTP login, with Firebase Auth.
- **Social Login:** Google, Facebook, and Apple sign-in options.
- **User Management:** Sign up, login, forgot password, and profile management.
- **Travel Tools:** Trip planning, expense tracking, scam reporting, and feedback.
- **Cloud Backend:** Uses Firebase Firestore for data storage and real-time updates.
- **Error Handling:** Centralized, user-friendly error messages.
- **Custom Theming:** Gold, white, and dark blue color palette for a premium look.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Dart SDK](https://dart.dev/get-dart)
- [Firebase Project](https://console.firebase.google.com/)
- (Optional) Android Studio or VS Code

### Installation

1. **Clone the repository:**
   ```bash
   https://github.com/travelitinservices/travelitin-services.git
   cd travelitin
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective directories.
   - Update `firebase_options.dart` if needed.

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🛠️ Project Structure

```
lib/
  features/
    auth/           # Authentication screens and widgets
    travel/         # Travel planning, expenses, etc.
  core/
    constants/      # App-wide constants and services
    services/       # Error handling, Firebase, etc.
  assets/           # Images, fonts, and other assets
  main.dart         # App entry point
```

## 🔑 Environment Variables

- Configure your Firebase project and APIs as needed.
- Store sensitive keys securely (do not commit them to version control).





**Made with using Flutter and Firebase by Raghuram Sekar.** 
