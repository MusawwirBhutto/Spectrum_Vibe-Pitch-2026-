// lib/pages/MainNavigationPage.dart

import 'package:baalkatwao/Business/OnBoardingPage.dart';
import 'package:baalkatwao/api_services/auth_notifier.dart';
import 'package:baalkatwao/pages/AppointmentPage.dart';
import 'package:baalkatwao/pages/HomePage.dart';
import 'package:baalkatwao/pages/ProfilePage.dart';
import 'package:baalkatwao/pages/HairstyleAIStudio.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialindex;
  const MainNavigationPage({super.key, required this.initialindex});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  bool _redirected = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialindex;
  }

  // --- ADDED AI STUDIO WIDGET HERE ---
  static final List<Widget> _widgetOptions = <Widget>[
    const Homepage(),
    const AppointmentPage(),
    const HairstyleAIStudio(), // New AI Studio Feature
    const ProfilePage(),
  ];

  // Logic to handle user redirection (Business Logic preserved 100%)
  void _maybeRedirectIfBusiness(AuthNotifier authNotifier) {
    if (_redirected) return;

    if (!authNotifier.isLoading && authNotifier.isBusiness) {
      _redirected = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Onboardingpage()),
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);

    if (authNotifier.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _maybeRedirectIfBusiness(authNotifier);

    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),

      // --- MODERN NAVIGATION BAR (GNav) ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.1)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: Theme.of(context).primaryColor,
              color: Colors.grey[600],

              tabs: const [
                GButton(icon: LineIcons.home, text: 'Home'),
                GButton(icon: LineIcons.calendar, text: 'Bookings'),
                // --- ADDED AI STUDIO BUTTON ---
                GButton(
                  icon: LineIcons.magic, // Perfect LineIcon for AI magic
                  text: 'AI Studio',
                ),
                GButton(icon: LineIcons.user, text: 'Profile'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
