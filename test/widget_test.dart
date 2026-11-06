import 'package:flutter_test/flutter_test.dart';
import 'package:techyd/utils/validators.dart';

void main() {
  group('Validators', () {
    test('email', () {
      expect(Validators.email('shyam@example.com'), isNull);
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('phone (Indian 10-digit mobile)', () {
      expect(Validators.phone('9876543210'), isNull);
      expect(Validators.phone('1234567890'), isNotNull);
      expect(Validators.phone('98765'), isNotNull);
    });

    test('password needs letter + number, min 6', () {
      expect(Validators.password('abc123'), isNull);
      expect(Validators.password('abcdef'), isNotNull);
      expect(Validators.password('123456'), isNotNull);
      expect(Validators.password('a1'), isNotNull);
    });

    test('name', () {
      expect(Validators.name('Megha Shyam'), isNull);
      expect(Validators.name('Al'), isNotNull);
      expect(Validators.name('R2D2 bot'), isNotNull);
    });

    test('optional url', () {
      expect(Validators.optionalUrl(''), isNull);
      expect(Validators.optionalUrl('https://example.com/join'), isNull);
      expect(Validators.optionalUrl('example.com'), isNotNull);
    });

    test('integer range', () {
      final v = Validators.integer(label: 'Capacity', min: 1, max: 5000);
      expect(v('100'), isNull);
      expect(v('0'), isNotNull);
      expect(v('abc'), isNotNull);
      expect(v('6000'), isNotNull);
    });
  });
}
