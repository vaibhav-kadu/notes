import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

class AuthService {

  Future<AuthResponse> signUp(
    String email,
    String password,
    String role,
  ) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
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
