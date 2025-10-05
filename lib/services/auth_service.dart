import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static User? _currentUser;

  // Get current user
  static User? get currentUser => _currentUser;

  // Initialize auth state
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      _currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  // Login user
  static Future<User> login(String username, String password) async {
    try {
      // TODO: Implement actual API login
      // For development, use mock data based on username prefix
      if (username.isEmpty || password.isEmpty) {
        throw Exception('Username and password are required');
      }

      // Mock authentication logic
      String userId;
      UserRole role;
      String? substationId;

      if (username.toLowerCase().startsWith('control')) {
        userId = 'control-${DateTime.now().millisecondsSinceEpoch}';
        role = UserRole.controlRoom;
      } else if (username.toLowerCase().startsWith('sub')) {
        userId = 'sub-${DateTime.now().millisecondsSinceEpoch}';
        role = UserRole.substation;
        substationId = 'station-${username.toLowerCase().replaceAll(RegExp(r'[^0-9]'), '')}';
      } else if (username.toLowerCase().startsWith('admin')) {
        userId = 'admin-${DateTime.now().millisecondsSinceEpoch}';
        role = UserRole.admin;
      } else {
        throw Exception('Invalid username format. Use prefix: control_, sub_, or admin_');
      }

      final user = User(
        id: userId,
        username: username,
        email: '$username@safedesk.com',
        role: role,
        substationId: substationId,
      );

      await _saveUser(user);
      _currentUser = user;
      return user;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    _currentUser = null;
  }

  // Save user data
  static Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    _currentUser = user;
  }

  // Mock role assignment for development
  static UserRole _getMockRole(String username) {
    if (username.startsWith('admin')) return UserRole.admin;
    if (username.startsWith('control')) return UserRole.controlRoom;
    return UserRole.substation;
  }

  // Check if user is authenticated
  static bool get isAuthenticated => _currentUser != null;

  // Check user role
  static bool hasRole(UserRole role) => _currentUser?.role == role;
}