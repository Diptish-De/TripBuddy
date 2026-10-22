import 'package:flutter_test/flutter_test.dart';
import 'package:trip_buddy/features/auth/domain/user_entity.dart';
import 'package:trip_buddy/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('AuthState Model Tests', () {
    test('Initial state is unauthenticated and not in demo mode', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.isDemo, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
    });

    test('copyWith updates state correctly for authenticated user', () {
      final user = UserEntity(
        id: 'u-123',
        displayName: 'Test User',
        email: 'test@example.com',
        createdAt: DateTime(2024, 1, 1),
      );

      const state = AuthState();
      final updated = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        isDemo: false,
        isLoading: false,
      );

      expect(updated.status, AuthStatus.authenticated);
      expect(updated.user?.displayName, 'Test User');
      expect(updated.isDemo, isFalse);
    });

    test('Demo mode state is correctly tagged as demo', () {
      final demoUser = UserEntity(
        id: 'demo-user-id',
        displayName: 'Alex Traveler',
        email: 'demo@tripbuddy.local',
        createdAt: DateTime(2024, 1, 1),
      );

      const state = AuthState();
      final demoState = state.copyWith(
        status: AuthStatus.authenticated,
        user: demoUser,
        isDemo: true,
      );

      expect(demoState.status, AuthStatus.authenticated);
      expect(demoState.isDemo, isTrue);
      expect(demoState.user?.id, 'demo-user-id');
    });
  });
}
