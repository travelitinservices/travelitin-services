import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travelitin/core/constants/routes.dart';
import 'package:travelitin/core/constants/services/firebaseservice.dart';
import 'package:travelitin/core/constants/theme/appTheme.dart';
import 'package:travelitin/features/auth/screens/forgot_password_page.dart';
import 'package:travelitin/features/auth/screens/login_page.dart';
import 'package:travelitin/features/auth/screens/sign_up_page.dart';
import 'package:travelitin/features/explore/screens/explore.dart';
import 'package:travelitin/allfeedback.dart';
import 'package:travelitin/home_page.dart';
import 'package:travelitin/features/language/screens/language_suggestion_page.dart';
import 'package:travelitin/features/map/screens/map_view_page.dart';
import 'package:travelitin/features/revenue/screens/revenue.dart';
import 'package:travelitin/report_scams.dart';
import 'package:travelitin/features/travel/screens/Travelchat.dart';
import 'package:travelitin/features/travel/screens/travel_expense.dart';
import 'package:travelitin/features/travel/screens/TripPlanner.dart';
import 'package:travelitin/features/translate/screens/translate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travelitin/core/services/error_handling_service.dart';
import 'firebase_options.dart';

// AuthChangeNotifier listens for login/logout and refreshes GoRouter
class AuthChangeNotifier extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  
  AuthChangeNotifier() {
    _firebaseService.authStateChanges.listen((User? user) {
      notifyListeners();
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Load environment variables
    await dotenv.load(fileName: '.env');
    
    // Run the app
    runApp(const SafetyGuideApp());
  } catch (e, stack) {
    print('Initialization error: $e');
    print(stack);
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Initialization error: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    ));
  }
}

class SafetyGuideApp extends StatelessWidget {
  const SafetyGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: AppRoutes.login,
      debugLogDiagnostics: true,
      refreshListenable: AuthChangeNotifier(),
      redirect: (context, state) {
        final user = FirebaseService().currentUser;
        final isLoggedIn = user != null;
        final isOnPublicPage = [
          AppRoutes.login,
          AppRoutes.signup,
          AppRoutes.forgotPassword,
        ].contains(state.fullPath);

        if (isLoggedIn && state.fullPath == AppRoutes.login) {
          return AppRoutes.home;
        }

        if (!isLoggedIn && !isOnPublicPage) {
          return AppRoutes.login;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.feed,
          builder: (context, state) => const AllFeedback(),
        ),
        GoRoute(
          path: AppRoutes.planner,
          builder: (context, state) => const TripPlanner(),
        ),
        GoRoute(
          path: AppRoutes.travel,
          builder: (context, state) => const Travelchat(),
        ),
        GoRoute(
          path: AppRoutes.explore,
          builder: (context, state) => const ExplorePage(),
        ),
        GoRoute(
          path: AppRoutes.scamReport,
          builder: (context, state) => const ReportScams(),
        ),
        GoRoute(
          path: AppRoutes.travelExpense,
          builder: (context, state) => const TravelExpense(),
        ),
        GoRoute(
          path: AppRoutes.translate,
          builder: (context, state) => const TranslateScreen(),
        ),
        GoRoute(
          path: AppRoutes.language,
          builder: (context, state) => const LanguageSuggestionPage(),
        ),
        GoRoute(
          path: AppRoutes.map,
          builder: (context, state) => const MapViewPage(),
        ),
        GoRoute(
          path: AppRoutes.revenue,
          builder: (context, state) => const RevenuePage(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Safety Guide',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: AppTheme.cardTheme,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}