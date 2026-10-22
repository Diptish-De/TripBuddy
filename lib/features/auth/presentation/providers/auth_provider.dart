import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/user_entity.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? backupEmail;
  final bool isDemo;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.backupEmail,
    this.isDemo = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? backupEmail,
    bool? isDemo,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      backupEmail: backupEmail ?? this.backupEmail,
      isDemo: isDemo ?? this.isDemo,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  StreamSubscription<AuthState>? _authSubscription;

  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  SupabaseClient? get _client => SupabaseConfig.client;

  Future<void> _init() async {
    // If Supabase is available, subscribe to auth state changes
    final client = _client;
    if (client != null) {
      client.auth.onAuthStateChange.listen((data) {
        final session = data.session;
        if (session != null && !state.isDemo) {
          final user = _userFromSupabase(session.user);
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
            backupEmail: user.email,
            isDemo: false,
          );
        } else if (data.event == AuthChangeEvent.signedOut && !state.isDemo) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      });
    }

    await checkAuth();
  }

  UserEntity _userFromSupabase(User user) {
    final metadata = user.userMetadata ?? {};
    final displayName = metadata['full_name'] as String? ??
        metadata['name'] as String? ??
        (user.email != null ? user.email!.split('@').first : 'Traveler');

    return UserEntity(
      id: user.id,
      displayName: displayName,
      email: user.email ?? '',
      avatarUrl: metadata['avatar_url'] as String?,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
    );
  }

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDemoMode = prefs.getBool('is_demo_mode') ?? false;

      if (savedDemoMode) {
        final localName = prefs.getString('user_display_name') ?? 'Alex Traveler';
        final localEmail = prefs.getString('user_backup_email') ?? 'demo@tripbuddy.local';
        final demoUser = UserEntity(
          id: 'demo-user-id',
          displayName: localName,
          email: localEmail,
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150',
          createdAt: DateTime.now(),
        );
        MockData.currentUser = demoUser;
        MockData.userNames[demoUser.id] = demoUser.displayName;

        state = AuthState(
          status: AuthStatus.authenticated,
          user: demoUser,
          backupEmail: localEmail,
          isDemo: true,
          isLoading: false,
        );
        return;
      }

      final client = _client;
      if (client != null) {
        final session = client.auth.currentSession;
        if (session != null) {
          final user = _userFromSupabase(session.user);
          state = AuthState(
            status: AuthStatus.authenticated,
            user: user,
            backupEmail: user.email,
            isDemo: false,
            isLoading: false,
          );
          return;
        }
      }

      state = const AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[AuthNotifier] checkAuth error: $e');
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
      );
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final client = _client;
    if (client == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Supabase is not configured or offline. Please check your credentials or continue in Demo Mode.',
      );
      return false;
    }

    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Sign in failed. Please check your credentials.',
        );
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_demo_mode', false);

      final userEntity = _userFromSupabase(user);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: userEntity,
        backupEmail: userEntity.email,
        isDemo: false,
        isLoading: false,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Connection failed: ${e.toString()}');
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final client = _client;
    if (client == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Supabase is not configured or offline. Please check your credentials or continue in Demo Mode.',
      );
      return false;
    }

    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name, 'name': name},
      );

      final user = response.user;
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Sign up failed. Please try again.',
        );
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_demo_mode', false);

      // If email confirmation is enabled, session might be null
      if (response.session == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Confirmation email sent! Please check your inbox before logging in.',
        );
        return false;
      }

      final userEntity = _userFromSupabase(user);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: userEntity,
        backupEmail: userEntity.email,
        isDemo: false,
        isLoading: false,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Sign up error: ${e.toString()}');
      return false;
    }
  }

  Future<void> continueAsDemo() async {
    state = state.copyWith(isLoading: true, error: null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_demo_mode', true);

    final name = prefs.getString('user_display_name') ?? 'Alex Traveler';
    final email = prefs.getString('user_backup_email') ?? 'demo@tripbuddy.local';

    final demoUser = UserEntity(
      id: 'demo-user-id',
      displayName: name,
      email: email,
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150',
      createdAt: DateTime.now(),
    );

    MockData.currentUser = demoUser;
    MockData.userNames[demoUser.id] = demoUser.displayName;

    state = AuthState(
      status: AuthStatus.authenticated,
      user: demoUser,
      backupEmail: email,
      isDemo: true,
      isLoading: false,
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_demo_mode', false);

    final client = _client;
    if (client != null && !state.isDemo) {
      try {
        await client.auth.signOut();
      } catch (e) {
        debugPrint('[AuthNotifier] SignOut error: $e');
      }
    }

    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> updateProfile(String name, String backupEmail) async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_display_name', name);
      await prefs.setString('user_backup_email', backupEmail);

      final client = _client;
      if (client != null && !state.isDemo && client.auth.currentUser != null) {
        await client.auth.updateUser(
          UserAttributes(data: {'full_name': name, 'name': name}),
        );
        try {
          await client.from('profiles').update({
            'display_name': name,
          }).eq('id', client.auth.currentUser!.id);
        } catch (_) {}
      }

      final currentUser = state.user;
      final updatedUser = UserEntity(
        id: currentUser?.id ?? 'demo-user-id',
        displayName: name,
        email: backupEmail.isNotEmpty ? backupEmail : (currentUser?.email ?? ''),
        avatarUrl: currentUser?.avatarUrl ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=150',
        createdAt: currentUser?.createdAt ?? DateTime.now(),
      );

      MockData.currentUser = updatedUser;
      MockData.userNames[updatedUser.id] = updatedUser.displayName;

      state = state.copyWith(
        user: updatedUser,
        backupEmail: backupEmail,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Deprecated/compatibility stubs
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(
      error: 'Google Sign-In requires native platform client configuration in Supabase Dashboard. Use email/password or Demo Mode.',
    );
    return false;
  }

  Future<void> signInWithGoogleMock() async => continueAsDemo();

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});

final isDemoModeProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isDemo;
});
