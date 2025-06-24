# Travelitin

A modern, feature-rich travel safety and itinerary management app built with **Flutter** and **Firebase**.

## Application Access
https://travelitindeployment-4qd34eysy-raghuram-s-projects.vercel.app

## ✨ Features

- **Enhanced UI/UX:**
  - Modern glassmorphism design with premium animations
  - Responsive layouts for all screen sizes
  - Custom animations using `flutter_animate` and `animate_do`
  - Carousel sliders, staggered grid views, and stylish loading animations
  - Custom fonts: Roboto, OliveVillage, CalSans

- **Authentication:**
  - Firebase Authentication (email/password, phone OTP, social login)
  - Secure session management

- **Travel Safety:**
  - Real-time location tracking with `geolocator`
  - Interactive maps (`google_maps_flutter`, `flutter_map`)
  - Scam reporting and travel alerts
  - Voice commands (`speech_to_text`), text-to-speech (`flutter_tts`)
  - Multi-language support (`translator`)

- **Travel Planning:**
  - Trip itinerary management
  - Expense tracking
  - Weather and local transportation info

- **Smart Features:**
  - Offline data persistence (`shared_preferences`)
  - Real-time sync with Firebase
  - Push notifications
  - Image caching (`cached_network_image`)
  - WebView integration

- **Technical:**
  - State management (`provider`, `get`)
  - Navigation (`go_router`)
  - Environment variable management (`flutter_dotenv`)
  - Comprehensive error handling
  - Unit, integration, and widget testing

- **Recent Improvements:**
  - Dynamic user greeting (name from Firestore)
  - Location badge with formatted address
  - Address formatting improvements
  - Quick Links navigation using `Navigator`
  - Vercel static web deployment

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.5.3)
- Dart SDK
- Firebase Project
- Android Studio or VS Code

### Installation
1. **Clone the repository:**
   ```bash
   git clone https://github.com/travelitinservices/travelitin-services.git
   cd travelitin
   ```
2. **Install dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure Firebase:**
   - Add your Firebase config files:
     - `google-services.json` (Android)
     - `GoogleService-Info.plist` (iOS)
   - Set up your `.env` file with required API keys
4. **Run the app:**
   ```bash
   flutter run
   ```

## 🛠️ Project Structure

```
lib/
  ├── features/
  │   ├── auth/         # Authentication
  │   ├── explore/      # Explore features
  │   ├── feed/         # Feed features
  │   ├── home/         # Home screen features
  │   ├── landing/      # Landing page features
  │   ├── language/     # Language support
  │   ├── location/     # Location services
  │   ├── map/          # Map features
  │   ├── revenue/      # Revenue features
  │   ├── scam_report/  # Scam reporting
  │   ├── translate/    # Translation features
  │   └── travel/       # Travel features
  ├── core/
  │   ├── constants/    # App constants
  │   └── services/     # Shared services
  ├── allfeedback.dart
  ├── chatwidgets.dart
  ├── editProf.dart
  ├── errorHandler.dart
  ├── firebase_options.dart
  ├── home_page.dart
  ├── home_page_new.dart
  ├── inputfields.dart
  ├── languages.dart
  ├── locationService.dart
  ├── loginScreen.dart
  ├── main.dart         # App entry point
  ├── placeholder_page.dart
  ├── report_scams.dart
  ├── server.py
  ├── storage_service.dart
```

## 🔧 Environment Setup
Create a `.env` file in the root directory with:
```
FIREBASE_API_KEY=your_api_key
MAPS_API_KEY=your_maps_key
```

## 📱 Platform Support
- Android
- iOS
- Web
- Windows
- macOS
- Linux

## 🧪 Testing
- Unit tests
- Integration tests
- Widget tests
- Mockito for mocking

Run tests using:
```bash
flutter test
```

**Made with Flutter, Firebase, React, and Node.js by Raghuram Sekar**





