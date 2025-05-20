import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'features/auth/forgot_password_page.dart';
import 'features/auth/sign_up_page.dart';
import 'features/auth/login_page.dart';
import 'features/home/home_page.dart';
import 'features/feedback/displayfeed.dart';
import 'features/trip_planner/TripPlanner.dart';
import 'features/chat/Travelchat.dart';
import 'features/explore/explore.dart';
import 'features/scams/report_scams.dart';
import 'features/expenses/travel_expense.dart';
import 'features/translation/translate.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const SafetyGuideApp());
  } catch (e) {
    print("Firebase Initialization Error: $e");
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child:
              Text('Firebase Initialization Failed. Please restart the app.'),
        ),
      ),
    ));
  }
}
final GoRouter _router = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  refreshListenable:
      AuthChangeNotifier(), // Refresh router when auth state changes
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isOnLoginPage = state.fullPath == '/';

    if (isLoggedIn && isOnLoginPage) {
      return '/HomePage'; // Redirect logged-in users from login page to HomePage
    }

    if (!isLoggedIn &&
        !['/', '/SignUp', '/ForgotPassword'].contains(state.fullPath)) {
      return '/'; // Redirect non-logged-in users to login page
    }

    return null; // Allow navigation
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LoginPage(), // Public page
    ),
    GoRoute(
      path: '/SignUp',
      builder: (context, state) => SignUpPage(), // Public page
    ),
    GoRoute(
      path: '/ForgotPassword',
      builder: (context, state) => ForgotPasswordPage(), // Public page
    ),

    // 🔒 PROTECTED PAGES (Only accessible after login)
    GoRoute(
      path: '/HomePage',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/DisplayFeed',
      builder: (context, state) => DisplayFeedPage(),
    ),
    GoRoute(
      path: '/Planner',
      builder: (context, state) => TripPlanner(),
    ),
    GoRoute(
      path: '/Travel',
      builder: (context, state) => Travelchat(),
    ),
    GoRoute(
      path: '/Explore',
      builder: (context, state) => ExplorePage(),
    ),
    GoRoute(
      path: '/report_scam',
      builder: (context, state) => ScamReportPage(),
    ),
    GoRoute(
      path: '/travel_exp',
      builder: (context, state) => TravelExpensePage(),
    ),
    GoRoute(
      path: '/translate',
      builder: (context, state) => TranslatePage(),
    ),
  ],
);

// AuthChangeNotifier listens for login/logout and refreshes GoRouter
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      notifyListeners(); // This refreshes GoRouter when authentication changes
    });
  }
}
class SafetyGuideApp extends StatelessWidget {
  const SafetyGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Safety Guide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router, // ✅ This ensures deep linking works
    );
  }
}
