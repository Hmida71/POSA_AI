import 'package:posa_ai_app/services/supabase_service.dart';

class AuthService {
  final SupabaseService _supabaseService;

  AuthService({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      return await _supabaseService.signUp(email, password);
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      return await _supabaseService.signIn(email, password);
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseService.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
}
