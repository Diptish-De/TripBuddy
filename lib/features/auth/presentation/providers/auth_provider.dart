import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/mock_data.dart';
import '../../domain/user_entity.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 800));
    // Auto-login with mock user for demo
    state = AuthState(
      status: AuthStatus.authenticated,
      user: MockData.currentUser,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 1200));
    // Mock login
    state = AuthState(
      status: AuthStatus.authenticated,
      user: MockData.currentUser,
    );
    return true;
  }

  Future<bool> signUp(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 1500));
    final user = UserEntity(
      id: 'user-new',
      displayName: name,
      email: email,
      createdAt: DateTime.now(),
    );
    state = AuthState(
      status: AuthStatus.authenticated,
      user: user,
    );
    return true;
  }

  void logout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authProvider).user;
});
