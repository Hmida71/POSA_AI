import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posa_ai_app/utils/constants.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Auth Methods
  Future<Map<String, dynamic>> signUp(String email, String password) async {
    final response =
        await _supabase.auth.signUp(email: email, password: password);
    if (response.user == null) throw Exception('Sign up failed');

    return {
      'id': response.user!.id,
      'email': email,
      'role': AppConstants.roleUser
    };
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Sign in failed');

    final userData = await _supabase
        .from('users')
        .select('id, email, role')
        .eq('id', response.user!.id)
        .single();

    return userData;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
