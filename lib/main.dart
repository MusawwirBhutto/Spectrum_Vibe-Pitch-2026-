import 'package:baalkatwao/Business/MainBusinessPage.dart';
import 'package:baalkatwao/api_services/auth_notifier.dart';
import 'package:baalkatwao/pages/ChangePasswordPage.dart';
import 'package:baalkatwao/pages/EditProfilePage.dart';
import 'package:baalkatwao/pages/ForgotPasswordPage.dart';
import 'package:baalkatwao/pages/MainNavigationPage.dart';
import 'package:baalkatwao/pages/SettingPage.dart';
import 'package:baalkatwao/pages/SignupPage.dart';
import 'package:baalkatwao/pages/Spalsh_screen.dart';
import 'package:baalkatwao/routes/routes.dart';
import 'package:baalkatwao/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import the provider package

void main() {
  // wraping the entire app with a ChangeNotifierProvider
  // to make AuthNotifier available to all widgets.
  runApp(
    ChangeNotifierProvider(
      // This creates a single instance of AuthNotifier.
      // We call loadToken() immediately to check if a user is already logged in.
      create: (context) => AuthNotifier()..loadToken(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Groomin',
      theme: appTheme,
      routes: {
        '/': (context) => const SplashScreen(),
        Routes.signuppage: (context) => const SignupPage(),
        Routes.editprofilepage: (context) => const Editprofilepage(),
        Routes.loginpage: (context) =>
            const MainNavigationPage(initialindex: 2),
        Routes.appointmentpage: (context) =>
            const MainNavigationPage(initialindex: 1),
        Routes.settingspage: (context) => const SettingPage(),
        Routes.changepasspage: (context) => const Changepasswordpage(),
        Routes.forgotpasswordpage: (context) => const ForgotPasswordPage(),
        Routes.mainbusinesspage: (context) => const MainBusinessPage(),
      },
    );
  }
}
