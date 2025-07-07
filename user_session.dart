import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserSession {
  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';
  static const String _loginTimeKey = 'login_time';

  static UserSession? _instance;
  static UserSession get instance {
    _instance ??= UserSession._internal();
    return _instance!;
  }

  UserSession._internal();

  Map<String, dynamic>? _userData;
  String? _token;

  // Update setUserData to accept token and save to storage
  Future<void> setUserData(
    Map<String, dynamic> userData, [
    String? token,
  ]) async {
    _userData = userData;
    _token = token;

    // Save to persistent storage
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(userData));
      await prefs.setString(_tokenKey, token);
      await prefs.setInt(_loginTimeKey, DateTime.now().millisecondsSinceEpoch);

      print('✅ Session saved - Token: ${token.substring(0, 20)}...');
    }
  }

  // Load user session on app start
  Future<bool> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final userStr = prefs.getString(_userKey);
      final token = prefs.getString(_tokenKey);
      final loginTime = prefs.getInt(_loginTimeKey) ?? 0;

      if (userStr != null && token != null) {
        _userData = jsonDecode(userStr);
        _token = token;

        print('✅ Session loaded - User: ${_userData!['email']}');
        print('✅ Token: ${token.substring(0, 20)}...');
        print(
          '✅ Login time: ${DateTime.fromMillisecondsSinceEpoch(loginTime)}',
        );

        // Check if session is too old (optional - 30 days)
        final daysSinceLogin = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(loginTime))
            .inDays;

        if (daysSinceLogin > 30) {
          print('⚠️ Session too old, clearing...');
          await clearUserData();
          return false;
        }

        return true;
      }

      print('❌ No saved session found');
      return false;
    } catch (e) {
      print('❌ Error loading session: $e');
      await clearUserData();
      return false;
    }
  }

  // Auto-refresh token if needed
  Future<bool> refreshTokenIfNeeded() async {
    if (_token == null) return false;

    try {
      // Check token expiration (decode without verification)
      final parts = _token!.split('.');
      if (parts.length != 3) return false;

      // Decode payload to check expiration
      String normalizedPayload = parts[1];
      switch (normalizedPayload.length % 4) {
        case 0:
          break;
        case 2:
          normalizedPayload += '==';
          break;
        case 3:
          normalizedPayload += '=';
          break;
        default:
          return false;
      }

      final payload = jsonDecode(
        utf8.decode(
          base64Decode(
            normalizedPayload.replaceAll('-', '+').replaceAll('_', '/'),
          ),
        ),
      );

      final exp = payload['exp'];
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Refresh if token expires in less than 1 day
      if (exp - now < 86400) {
        print('🔄 Token expiring soon, refreshing...');

        final response = await http.post(
          Uri.parse('http://192.168.1.4/sikap_api/php/refresh_token.php'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['success']) {
            await setUserData(result['user'], result['token']);
            print('✅ Token refreshed successfully');
            return true;
          }
        }
      }

      return true;
    } catch (e) {
      print('❌ Error refreshing token: $e');
      return false;
    }
  }

  // Add method to get auth headers
  Map<String, String> get authHeaders {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Get current user data
  Map<String, dynamic>? get userData => _userData;

  // Check if user is logged in
  bool get isLoggedIn => _userData != null && _token != null;

  // Get user ID
  int? get userId => _userData?['user_id'];

  // Get user role
  String? get userRole => _userData?['role'];

  // Get user name
  String get userName {
    if (_userData?['profile'] != null) {
      final profile = _userData!['profile'];
      final firstName = profile['first_name'] ?? '';
      final lastName = profile['last_name'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return 'User';
  }

  // Get jobseeker ID (for jobseekers only)
  int? get jobseekerId {
    if (_userData?['role'] == 'jobseeker' && _userData?['profile'] != null) {
      return _userData!['profile']['jobseeker_id'];
    }
    return null;
  }

  // Clear user data (logout) - updated to clear persistent storage
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
    await prefs.remove(_loginTimeKey);

    _userData = null;
    _token = null;

    print('✅ Session cleared');
  }

  // Get current token
  String? get token => _token;
}
