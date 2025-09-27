import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  // Email/Password Registration with OTP
  static Future<User?> registerWithEmail(String email, String password) async {
    try {
      print('AuthService: Attempting registration with email: $email');
      
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: null, // Force OTP instead of magic link
      );
      
      if (response.user != null) {
        print('AuthService: Registration successful, OTP sent to: $email');
        
        // Try to send OTP, but don't fail if rate limited (OTP already sent)
        try {
          await _supabase.auth.resend(
            type: OtpType.signup,
            email: email,
          );
        } on AuthException catch (resendError) {
          // Ignore rate limiting errors - OTP was already sent during signup
          if (resendError.message.contains('rate') || 
              resendError.message.contains('wait') ||
              resendError.message.contains('seconds')) {
            print('AuthService: Rate limited on resend, but OTP already sent during signup');
          } else {
            print('AuthService: Resend error (non-critical): ${resendError.message}');
          }
        }
        
        return response.user;
      } else {
        throw Exception('Registration failed - no user returned');
      }
    } on AuthException catch (e) {
      print('AuthService: Supabase AuthException: ${e.message}');
      
      // Don't show rate limiting errors to user if registration succeeded
      if (e.message.contains('rate') || e.message.contains('wait') || e.message.contains('seconds')) {
        throw Exception('Registration successful! Please check your email for the verification code.');
      }
      
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      print('AuthService: General exception: $e');
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  // Verify OTP Code
  static Future<User?> verifyOTP(String email, String otp) async {
    try {
      print('AuthService: Verifying OTP for email: $email');
      
      final AuthResponse response = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        email: email,
        token: otp,
      );
      
      if (response.user != null) {
        print('AuthService: OTP verification successful for: ${response.user?.email}');
        return response.user;
      } else {
        throw Exception('OTP verification failed - no user returned');
      }
    } on AuthException catch (e) {
      print('AuthService: OTP verification error: ${e.message}');
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      print('AuthService: General OTP error: $e');
      throw Exception('OTP verification failed: ${e.toString()}');
    }
  }

  // Send OTP Code (for resending)
  static Future<void> sendOTP(String email) async {
    try {
      print('AuthService: Sending OTP to email: $email');
      
      await _supabase.auth.signInWithOtp(email: email);
      
      print('AuthService: OTP sent successfully to: $email');
    } on AuthException catch (e) {
      print('AuthService: Send OTP error: ${e.message}');
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      print('AuthService: General send OTP error: $e');
      throw Exception('Failed to send OTP: ${e.toString()}');
    }
  }

  // Email/Password Login
  static Future<User?> loginWithEmail(String email, String password) async {
    try {
      print('AuthService: Attempting login with email: $email');
      
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        print('AuthService: Login successful for user: ${response.user?.email}');
        return response.user;
      } else {
        throw Exception('Login failed - no user returned');
      }
    } on AuthException catch (e) {
      print('AuthService: Supabase AuthException: ${e.message}');
      throw Exception(_getErrorMessage(e.message));
    } catch (e) {
      print('AuthService: General exception: $e');
      throw Exception('Login failed: ${e.toString()}');
    }
  }


  // Send Email Verification
  static Future<void> sendEmailVerification() async {
    try {
      if (currentUser?.email != null) {
        await _supabase.auth.resend(
          type: OtpType.signup,
          email: currentUser!.email!,
        );
      }
    } catch (e) {
      print('Email verification error: $e');
      throw Exception('Failed to send verification email: ${e.toString()}');
    }
  }

  // Password Reset
  static Future<void> sendPasswordReset(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      print('Password reset error: $e');
      throw Exception('Failed to send password reset email: ${e.toString()}');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;

  // Check if email is verified
  static bool get isEmailVerified => currentUser?.emailConfirmedAt != null;

  // Get user email
  static String? get userEmail => currentUser?.email;

  // Get user ID
  static String? get userId => currentUser?.id;

  // Get user display name
  static String? get userName => currentUser?.userMetadata?['full_name'];

  // Helper method to convert Supabase error messages to user-friendly messages
  static String _getErrorMessage(String? errorMessage) {
    if (errorMessage == null) return 'An error occurred. Please try again.';
    
    if (errorMessage.contains('Invalid login credentials')) {
      return 'Invalid email or password.';
    } else if (errorMessage.contains('User already registered')) {
      return 'An account already exists with this email address.';
    } else if (errorMessage.contains('Password should be at least')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (errorMessage.contains('Invalid email')) {
      return 'Please enter a valid email address.';
    } else if (errorMessage.contains('Email not confirmed')) {
      return 'Please verify your email address before signing in.';
    } else if (errorMessage.contains('rate') || errorMessage.contains('wait') || errorMessage.contains('seconds')) {
      return 'Please check your email for the verification code.';
    } else {
      return errorMessage;
    }
  }
}
