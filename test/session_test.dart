import 'package:flutter_test/flutter_test.dart';
import 'package:portal_akademik/app/data/session.dart';

void main() {
  test('Session fallbacks and getters test', () {
    Session.clear();
    expect(Session.effectiveIdKrs, equals(Session.fallbackIdKrs));
    expect(Session.effectiveIdNilai, equals(Session.fallbackIdNilai));
    expect(Session.isAuthenticated, isFalse);

    Session.idKrs = 'custom_krs_123';
    Session.idNilai = 'custom_nilai_456';
    Session.accessToken = 'test_token';
    Session.username = 'G1F024047';

    expect(Session.effectiveIdKrs, equals('custom_krs_123'));
    expect(Session.effectiveIdNilai, equals('custom_nilai_456'));
    expect(Session.isAuthenticated, isTrue);
    expect(Session.username, equals('G1F024047'));

    Session.clear();
    expect(Session.effectiveIdKrs, equals(Session.fallbackIdKrs));
    expect(Session.effectiveIdNilai, equals(Session.fallbackIdNilai));
    expect(Session.isAuthenticated, isFalse);
    expect(Session.username, isNull);
  });
}
