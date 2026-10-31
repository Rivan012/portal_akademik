import 'package:flutter_test/flutter_test.dart';
import 'package:portal_akademik/app/data/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Token extraction and Session storage', () async {
    const htmlSample = '''
      <html>
        <head><title>Dashboard</title></head>
        <body>
          <script>
            Alpine.store('access_token', 'test_access_token_12345');
          </script>
        </body>
      </html>
    ''';

    final pattern = RegExp(r"""Alpine\.store\(\s*['"]access_token['"]\s*,\s*['"]([^'"]+)['"]\s*\)""");
    final match = pattern.firstMatch(htmlSample);
    expect(match?.group(1), equals('test_access_token_12345'));

    Session.csrfToken = 'test_csrf';
    Session.accessToken = match?.group(1);

    expect(Session.isAuthenticated, isTrue);
    expect(Session.csrfToken, equals('test_csrf'));
    expect(Session.accessToken, equals('test_access_token_12345'));

    await Session.clear();
    expect(Session.isAuthenticated, isFalse);
    expect(Session.accessToken, isNull);
  });
}
