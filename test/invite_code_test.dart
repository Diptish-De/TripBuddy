import 'package:flutter_test/flutter_test.dart';
import 'package:trip_buddy/features/trips/presentation/providers/trip_provider.dart';

void main() {
  group('Trip Invite Code Tests', () {
    test('generateInviteCode produces 6-character uppercase codes', () {
      for (int i = 0; i < 50; i++) {
        final code = TripsNotifier.generateInviteCode();
        expect(code.length, 6);
        expect(code, equals(code.toUpperCase()));
        // Ensure no ambiguous characters
        expect(code.contains('0'), isFalse);
        expect(code.contains('O'), isFalse);
        expect(code.contains('1'), isFalse);
        expect(code.contains('I'), isFalse);
        // Valid chars only: 2-9 and A-Z (excluding O, I)
        expect(RegExp(r'^[2-9A-HJ-NP-Z]{6}$').hasMatch(code), isTrue);
      }
    });

    test('generateInviteCode produces unique codes', () {
      final codes = <String>{};
      for (int i = 0; i < 100; i++) {
        codes.add(TripsNotifier.generateInviteCode());
      }
      // With 32^6 possibilities (~1 billion), 100 samples should be distinct
      expect(codes.length, 100);
    });
  });
}
