import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:posa_ai_app/utils/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  Session? _session;
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  AuthProvider() {
    _initialize();
  }

  // Getters
  Session? get session => _session;
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _session != null;
  bool get isAdmin => _userData?['role'] == AppConstants.roleAdmin;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Initialize and listen to auth changes
  void _initialize() {
    // Get initial session
    _session = _supabaseClient.auth.currentSession;
    _currentUser = _supabaseClient.auth.currentUser;
    loadUserData();
    _isLoading = false;
    notifyListeners();

    // Listen to auth state changes
    _supabaseClient.auth.onAuthStateChange.listen((data) {
      _session = data.session;
      _currentUser = data.session?.user;
      loadUserData();
      notifyListeners();
    });
  }

  Future<bool> loadUserData() async {
    if (_currentUser != null) {
      try {
        final userData = await _supabaseClient
            .from('users')
            .select()
            .eq('uid', _currentUser!.id)
            .single();
        _userData = userData;
        notifyListeners();
        return true;
      } catch (e) {
        debugPrint('Error loading user data: $e');
        return false;
      }
    } else {
      _userData = null;
      return false;
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      _setLoading(true);
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) throw Exception('Sign up failed');

      // Create user profile
      await addUser({
        'uid': response.user!.id,
        'email': email,
        'role': AppConstants.roleUser,
        'profileimage': '',
        'plan': 'Free',
        'taskcount': 0,
        'tasklimit': 10,
        'locale': 'en',
        'provider': 'email',
        'isverified': false,
        'isbanned': false,
        'referrerid': null,
        'orgid': null,
        'metadata': null,
      });
    } catch (e) {
      debugPrint("$e");
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    final res = await _supabaseClient.from('users').insert(userData).select();
    debugPrint("res :$res");
  }

  Future<void> signIn(String email, String password) async {
    try {
      _setLoading(true);
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _supabaseClient.auth.signOut();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);

      if (kIsWeb) {
        // Web OAuth flow
        await _supabaseClient.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: null,
          scopes: 'email profile',
          authScreenLaunchMode: LaunchMode.platformDefault,
        );
      }
      if (Platform.isWindows) {
        await signInWithGoogleDesktop();
      } else {
        // Native Google Sign-In flow
        await _nativeGoogleSignIn();
      }
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogleDesktop() async {
    final authUrl = await Supabase.instance.client.auth.getOAuthSignInUrl(
      provider: OAuthProvider.google,
      redirectTo: 'http://localhost:3000/auth/callback',
    );

    if (await canLaunchUrl(Uri.parse(authUrl.url))) {
      await launchUrl(Uri.parse(authUrl.url));
    } else {
      throw Exception('Could not launch browser for Google sign-in');
    }
  }

  Future<void> _nativeGoogleSignIn() async {
    try {
      debugPrint("Starting Google Sign-In process");

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'], // Avoid sensitive scopes during dev
        serverClientId: AppConstants.webClientId, // Required for Supabase
        // clientId: AppConstants.iosClientId, // For iOS if needed
      );

      // Optional: force sign out to prompt login screen
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint("User canceled sign-in");
        return;
      }

      final googleAuth = await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Missing accessToken or idToken');
      }

      debugPrint("Signing in with Supabase...");

      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint("Signed in: ${response.user?.email}");

      // Check if user exists in our database
      if (response.user != null) {
        try {
          await _supabaseClient
              .from('users')
              .select()
              .eq('uid', response.user!.id)
              .single();
        } catch (e) {
          // User doesn't exist, create profile
          await addUser({
            'uid': response.user!.id,
            'email': response.user!.email,
            'role': AppConstants.roleUser
          });
        }
      }
    } catch (e) {
      debugPrint("Google sign-in failed: $e");
      rethrow;
    }
  }
}
