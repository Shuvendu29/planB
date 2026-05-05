// LOCAL VERSION - For testing without Firebase
// To use Firebase, replace with Firebase version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/local_auth_provider.dart';
import 'providers/local_user_provider.dart';
import 'providers/local_exam_provider.dart';
import 'providers/local_reward_provider.dart';
import 'screens/auth/local_login_screen.dart';
import 'screens/home/local_user_home_screen.dart';
import 'screens/sme/local_sme_dashboard_screen.dart';
import 'screens/admin/local_admin_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalAuthProvider()),
        ChangeNotifierProvider(create: (_) => LocalUserProvider()),
        ChangeNotifierProvider(create: (_) => LocalEntranceExamProvider()),
        ChangeNotifierProvider(create: (_) => LocalRewardProvider()),
      ],
      child: MaterialApp(
        title: 'PlanB - Exam Prep',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LocalAuthWrapper(),
          '/login': (context) => const LocalLoginScreen(),
          '/home': (context) => const LocalUserHomeScreen(),
          '/sme-dashboard': (context) => const LocalSMEDashboardScreen(),
          '/admin-dashboard': (context) => const LocalAdminDashboardScreen(),
        },
      ),
    );
  }
}

/// Auth Wrapper - Routes based on user role
class LocalAuthWrapper extends StatelessWidget {
  const LocalAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalAuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.currentUser != null) {
          final role = authProvider.currentUser!['role'] ?? 'user';
          switch (role) {
            case 'sme':
              return const LocalSMEDashboardScreen();
            case 'admin':
              return const LocalAdminDashboardScreen();
            default:
              return const LocalUserHomeScreen();
          }
        }

        return const LocalLoginScreen();
      },
    );
  }
}
