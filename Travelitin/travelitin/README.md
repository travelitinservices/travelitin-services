# Travelitin

A modern, feature-rich travel safety and itinerary management app built with **Flutter** and **Firebase**.

## ✨ Features

- **Enhanced UI/UX:**
  - Modern glassmorphism design with premium animations
  - Responsive layouts for all screen sizes
  - Custom animations using `flutter_animate` and `animate_do`
  - Beautiful carousel sliders and staggered grid views
  - Loading animations with `flutter_spinkit` and `shimmer` effects
  - Custom fonts including Roboto, OliveVillage, and CalSans

- **Advanced Authentication:**
  - Firebase Authentication integration
  - Email/password and phone OTP login
  - Social login options
  - Secure session management

- **Travel Safety Features:**
  - Real-time location tracking with `geolocator`
  - Interactive maps using `google_maps_flutter` and `flutter_map`
  - Voice commands with `speech_to_text`
  - Text-to-speech capabilities with `flutter_tts`
  - Multi-language support with `translator`

- **Travel Planning Tools:**
  - Trip itinerary management
  - Expense tracking
  - Interactive maps and location services
  - Weather information
  - Local transportation options

- **Smart Features:**
  - Offline data persistence with `shared_preferences`
  - Real-time data sync with Firebase
  - Push notifications
  - Image caching with `cached_network_image`
  - WebView integration for external content

- **Technical Features:**
  - State management with `provider` and `get`
  - Navigation using `go_router`
  - Environment variable management with `flutter_dotenv`
  - Comprehensive error handling
  - Unit and integration testing setup

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
   - Add your Firebase configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Set up your `.env` file with required API keys

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🛠️ Project Structure

```
lib/
  ├── features/          # Feature-based modules
  │   ├── auth/         # Authentication
  │   ├── travel/       # Travel features
  │   └── safety/       # Safety features
  ├── core/             # Core functionality
  │   ├── constants/    # App constants
  │   ├── services/     # Shared services
  │   └── utils/        # Utility functions
  ├── shared/           # Shared widgets and components
  └── main.dart         # App entry point
```

## 🔧 Environment Setup

Create a `.env` file in the root directory with the following variables:
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

The project includes:
- Unit tests
- Integration tests
- Widget tests
- Mockito for mocking

Run tests using:
```bash
flutter test
```

## 📄 License

This project is licensed under the MIT License.

**Made with ❤️ using Flutter and Firebase by Raghuram Sekar** 