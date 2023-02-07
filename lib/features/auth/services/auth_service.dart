import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

class AuthService {

  Future<AuthResponse> signUp(
    String email,
    String password,
    String role,
    String displayName,
    String phone,
  ) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      phone: phone.isNotEmpty ? phone : null,
      data: {
        'display_name': displayName,
        'role': role,
        'is_verified': true,
      },
    );
  }

  Future<AuthResponse> login(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
