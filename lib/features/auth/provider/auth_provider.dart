import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _service = AuthService();

  User? user;
  bool isLoading = false;
  String? error;
  String? role;
  bool isVerified = false;

  bool get canUploadNotes => role == "admin" || role == "teacher";

  bool get canManageNotes => role == "admin" || role == "teacher";

  String _roleKey(String userId) => 'user_role_$userId';

  String _verifiedKey(String userId) => 'user_verified_$userId';

  Future<void> _cacheAccountState(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    if (role != null) {
      await prefs.setString(_roleKey(userId), role!);
    }

    await prefs.setBool(_verifiedKey(userId), isVerified);
  }

  Future<bool> _loadCachedAccountState(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedRole = prefs.getString(_roleKey(userId));

    if (cachedRole == null) {
      return false;
    }

    role = cachedRole;
    isVerified = prefs.getBool(_verifiedKey(userId)) ?? true;
    return true;
  }

  Future<void> _saveUserRecord({
    required String userId,
    required String email,
    required String resolvedRole,
    required bool resolvedIsVerified,
  }) async {
    try {
      await Supabase.instance.client.from('users').upsert({
        'id': userId,
        'email': email,
        'role': resolvedRole,
        'is_verified': resolvedIsVerified,
      });
    } catch (e) {
      debugPrint('Error saving user record to DB: $e');
      // Some Supabase projects in this app do not have a public.users table.
      // Auth metadata + local cache are enough for the current flows.
    }
  }

  // 🔹 Check existing session (Auto Login)
  Future<void> checkSession() async {
    user = _service.getCurrentUser();

    if (user != null) {
      try {
        await fetchUserRole();
      } catch (e) {
        error = "Failed to load account details";
      }
    }

    notifyListeners();
  }

  // 🔹 Signup
  Future<void> signup(String email, String password, String roleInput) async {
    try {
      isLoading = true;
      notifyListeners();

      final res = await _service.signUp(email, password, roleInput);

      if (res.user != null) {
        user = res.user;
        role = roleInput;
        isVerified = true;

        // 🔥 SAVE ROLE IN DB
        await _saveUserRecord(
          userId: user!.id,
          email: email,
          resolvedRole: roleInput,
          resolvedIsVerified: true,
        );
        await _cacheAccountState(user!.id);

        await fetchUserRole();
      }

      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Login
  Future<void> login(String email, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      final res = await _service.login(email, password);

      if (res.user != null) {
        user = res.user;
        await fetchUserRole();
      }
    } on AuthException catch (e) {
      error = e.message;
    } catch (e) {
      error = "Login failed";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    try {
      await _service.logout();
      user = null;
      role = null;
      isVerified = false;
    } catch (e) {
      error = "Logout failed";
    }
    notifyListeners();
  }

  // 🔹 Check login state
  bool isLoggedIn() {
    return user != null;
  }

  Future<void> fetchUserRole() async {
    final user = _service.getCurrentUser();

    if (user == null) return;

    final metadata = user.userMetadata ?? {};
    final metadataRole = metadata['role']?.toString();
    final metadataVerified = metadata['is_verified'] != false;
    final loadedFromCache = await _loadCachedAccountState(user.id);

    if (metadataRole != null) {
      role = metadataRole;
      isVerified = metadataVerified;
    }

    try {
      final res = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (res != null) {
        role = res['role']?.toString() ?? metadataRole ?? role;
        isVerified = res['is_verified'] == true || metadataVerified;
      } else {
        // User exists in Auth but not in public.users table -> Migrate them
        role = metadataRole ?? 'student';
        isVerified = metadataVerified;
        await _saveUserRecord(
          userId: user.id,
          email: user.email ?? '',
          resolvedRole: role!,
          resolvedIsVerified: isVerified,
        );
      }

      if (role != null) {
        await _cacheAccountState(user.id);
      }
    } catch (e) {
      if (metadataRole != null) {
        role = metadataRole;
        isVerified = metadataVerified;
        await _cacheAccountState(user.id);
      } else if (!loadedFromCache) {
        error = "Failed to load account details";
      }
    }

    notifyListeners();
  }

  Future<void> deleteUser(String userId) async {
    // Delete from users table if it exists
    try {
      await Supabase.instance.client.from('users').delete().eq('id', userId);
    } catch (_) {}
    
    // Note: Deleting from auth.users requires admin/service_role keys 
    // or a custom Edge Function. For client-side apps without Edge Functions,
    // we manage the 'public.users' state.
  }

  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    if (role != 'admin') return [];
    try {
      // 1. Fetch all users
      final usersRes = await Supabase.instance.client.from('users').select();
      final users = List<Map<String, dynamic>>.from(usersRes as List);

      // 2. Fetch post counts for all users (group by uploader_id)
      final postsRes = await Supabase.instance.client
          .from('notes')
          .select('uploader_id');
      
      final postCounts = <String, int>{};
      for (final post in (postsRes as List)) {
        final uid = post['uploader_id']?.toString();
        if (uid != null) {
          postCounts[uid] = (postCounts[uid] ?? 0) + 1;
        }
      }

      // 3. Merge counts into user objects
      for (var u in users) {
        u['post_count'] = postCounts[u['id']] ?? 0;
        u['report_count'] = u['report_count'] ?? 0; // fallback if column missing
        u['is_deactivated'] = u['is_deactivated'] == true;
      }

      return users;
    } catch (e) {
      debugPrint('fetchAllUsers error: $e');
      return [];
    }
  }

  Future<void> toggleUserStatus(String userId, bool deactivate) async {
    await Supabase.instance.client
        .from('users')
        .update({'is_deactivated': deactivate})
        .eq('id', userId);
  }

  Future<List<Map<String, dynamic>>> fetchUserPosts(String userId) async {
    final res = await Supabase.instance.client
        .from('notes')
        .select()
        .eq('uploader_id', userId);
    return List<Map<String, dynamic>>.from(res as List);
  }
}
