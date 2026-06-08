// lib/services/auth_notifier.dart
import 'package:baalkatwao/api_services/auth_services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthNotifier with ChangeNotifier {
  String? _authToken;
  String? _userRole;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  String? get authToken => _authToken;
  String? get userRole => _userRole;
  bool get isAuthenticated => _authToken != null;
  bool get isLoading => _isLoading;
  bool get isBusiness => _userRole == 'BUSINESS';
  bool get isCustomer => _userRole == 'CUSTOMER';
  Map<String, dynamic>? get userData => _userData;

  static const String _tokenKey = 'authToken';
  static const String _roleKey = 'userRole';
  static const String _userDataKey = 'userData';

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_tokenKey);
    _userRole = prefs.getString(_roleKey);

    // Load and decode the user data
    final userDataString = prefs.getString(_userDataKey);
    if (userDataString != null) {
      try {
        _userData = json.decode(userDataString);
      } catch (e) {
        // Handle corrupted JSON gracefully

        await prefs.remove(_userDataKey);
        _userData = null;
      }
    }

    if (_authToken != null && _userData == null) {
      try {
        // Call the API service to get the user data
        final userDataResponse = await getLoggedInUser(_authToken!);

        // Assuming getLoggedInUser returns {"user": {...}}
        final user = userDataResponse['user'];

        // Update state and persistence with the fresh data
        await prefs.setString(_userDataKey, json.encode(user));
        _userData = user;
        _userRole = user['role']; // Ensure role is also updated
      } catch (e) {
        // If fetching fails (e.g., old expired token, network error)

        // Clear the potentially expired/invalid token and force logout
        await clearAuthData(); // This calls notifyListeners()
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Called after successful login
  Future<void> setAuthData(
    String token,
    String role,
    Map<String, dynamic> userData,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    // Save all three pieces of data
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    await prefs.setString(
      _userDataKey,
      json.encode(userData),
    ); // Encode to JSON string

    _authToken = token;
    _userRole = role;
    _userData = userData;
    notifyListeners();
  }

  // Clear all auth data on logout
  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userDataKey);

    _authToken = null;
    _userRole = null;
    _userData = null;
    notifyListeners();
  }

  Future<void> refreshUserData({String? newToken}) async {
    // 1. If a new token is provided (e.g., from an email verification API response),
    //    update the in-memory state so the subsequent API call uses the new token.
    if (newToken != null) {
      _authToken = newToken;
    }

    if (_authToken == null) return;

    try {
      // 2. Use the current (or newly provided) token to fetch fresh user data
      final userDataResponse = await getLoggedInUser(_authToken!);

      // FIX: Correctly extract the inner 'user' map
      final user = userDataResponse['user'];
      // Determine the role from the new data, falling back to the current role
      final newRole = user?['role'] ?? _userRole;

      if (user != null && newRole != null) {
        // 3. Use the robust setAuthData to update the token (if it changed),
        //    the role, and the user data, and persist all three to SharedPreferences.
        await setAuthData(_authToken!, newRole, user);
      } else {
        // If the server didn't return valid data, force logout
        await clearAuthData();
      }

      if (kDebugMode) {
        print('User data refreshed successfully.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing user data: $e');
      }
      // Optional: Clear data if the token is likely invalid
      // await clearAuthData();
    }
  }

  //-------------------------------------------------------For Business Salon data----------------------------------------------------
}
