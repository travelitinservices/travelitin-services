import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thingqbator/core/constants/routes.dart';
import 'package:thingqbator/core/services/firebase_service.dart';
import 'package:thingqbator/core/theme/app_theme.dart';
import 'package:thingqbator/features/auth/screens/forgot_password_screen.dart';
import 'package:thingqbator/features/auth/screens/login_screen.dart';
import 'package:thingqbator/features/auth/screens/sign_up_screen.dart';
import 'package:thingqbator/features/explore/screens/explore_screen.dart';
import 'package:thingqbator/features/feed/screens/display_feed_screen.dart';
import 'package:thingqbator/features/home/screens/home_screen.dart';
import 'package:thingqbator/features/language/screens/language_suggestion_screen.dart';
import 'package:thingqbator/features/map/screens/map_view_screen.dart';
import 'package:thingqbator/features/revenue/screens/revenue_page.dart';
import 'package:thingqbator/features/scam_report/screens/scam_report_screen.dart';
import 'package:thingqbator/features/travel/screens/travel_chat_screen.dart';
import 'package:thingqbator/features/travel/screens/travel_expense_screen.dart';
import 'package:thingqbator/features/travel/screens/trip_planner_screen.dart';
import 'package:thingqbator/features/translate/screens/translate_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// AuthChangeNotifier listens for login/logout and refreshes GoRouter
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await FirebaseService.initializeFirebase();
    await dotenv.load(fileName: '.env');
    runApp(const SafetyGuideApp());
  } catch (e) {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Firebase Initialization Failed. Please restart the app.'),
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
        final user = FirebaseAuth.instance.currentUser;
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
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.signup,
          builder: (context, state) => const SignUpScreen(),
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.feed,
          builder: (context, state) => const DisplayFeedScreen.DisplayFeedScreen(),
        ),
        GoRoute(
          path: AppRoutes.planner,
          builder: (context, state) => const TripPlannerScreen.TripPlannerScreen(),
        ),
        GoRoute(
          path: AppRoutes.travel,
          builder: (context, state) => const TravelChatScreen.TravelChatScreen(),
        ),
        GoRoute(
          path: AppRoutes.explore,
          builder: (context, state) => const ExploreScreen.ExploreScreen(),
        ),
        GoRoute(
          path: AppRoutes.scamReport,
          builder: (context, state) => const ScamReportScreen(),
        ),
        GoRoute(
          path: AppRoutes.travelExpense,
          builder: (context, state) => const TravelExpenseScreen.TravelExpenseScreen(),
        ),
        GoRoute(
          path: AppRoutes.translate,
          builder: (context, state) => const TranslateScreen.TranslateScreen(),
        ),
        GoRoute(
          path: AppRoutes.language,
          builder: (context, state) => const LanguageSuggestionScreen(),
        ),
        GoRoute(
          path: AppRoutes.map,
          builder: (context, state) => const MapViewScreen(),
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
        inputDecorationTheme: AppTheme.inputDecorationTheme,
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}