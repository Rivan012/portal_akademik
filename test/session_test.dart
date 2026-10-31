import 'package:flutter_test/flutter_test.dart';
import 'package:portal_akademik/app/data/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Session fallbacks, persistence and getters test', () async {
    await Session.clear();
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

    await Session.save();

    // Reset memory values
    Session.accessToken = null;
    Session.username = null;
    expect(Session.isAuthenticated, isFalse);

    // Load back from SharedPreferences
    await Session.load();
    expect(Session.isAuthenticated, isTrue);
    expect(Session.accessToken, equals('test_token'));
    expect(Session.username, equals('G1F024047'));
    expect(Session.idKrs, equals('custom_krs_123'));
    expect(Session.idNilai, equals('custom_nilai_456'));

    await Session.clear();
    expect(Session.effectiveIdKrs, equals(Session.fallbackIdKrs));
    expect(Session.effectiveIdNilai, equals(Session.fallbackIdNilai));
    expect(Session.isAuthenticated, isFalse);
    expect(Session.username, isNull);
  });
}
