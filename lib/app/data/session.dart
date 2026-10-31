import 'package:shared_preferences/shared_preferences.dart';

// ponytail: SharedPreferences storage; upgrade to flutter_secure_storage when encryption at rest is mandated.
class Session {
  static String? csrfToken;
  static String? accessToken;
  static String? username;
  static String? xsrfToken;
  static String? portalSession;
  static String? idKrs;
  static String? idNilai;

  static const String fallbackIdKrs =
      'eyJpdiI6Inhydll3SnNsdzNkTjA0ekFBWmd6ckE9PSIsInZhbHVlIjoiSkszZHdURGVqS2NJS3lNZmxvaGpHUT09IiwibWFjIjoiNDNjODQyOWNlNTc0ZTMyZTllMGY1MWNjZDU4ZDhhMWZiNjZiNDg3YjYzMTVkYjU3OWIzOWM5N2U3MWY3NTY4OCIsInRhZyI6IiJ9';

  static const String fallbackIdNilai =
      'eyJpdiI6ImFoL29ZM2x5RUcrMnJNVFFFM0RKbVE9PSIsInZhbHVlIjoiUDB3ZXZzTk1LUjBGVFZBQktGRHN2UT09IiwibWFjIjoiMGQ1YzEyNjgzZDhlZTIzMWE0MzA3MjcyNjRjNGZlZDU0M2U3MTFmNWQ4ZmVhZjc0Yjc4MDFjYjM0YTY2MWM0MiIsInRhZyI6IiJ9';

  static String get effectiveIdKrs =>
      (idKrs != null && idKrs!.isNotEmpty) ? idKrs! : fallbackIdKrs;

  static String get effectiveIdNilai =>
      (idNilai != null && idNilai!.isNotEmpty) ? idNilai! : fallbackIdNilai;

  static bool get isAuthenticated =>
      accessToken != null && accessToken!.isNotEmpty;

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    csrfToken = prefs.getString('csrfToken');
    accessToken = prefs.getString('accessToken');
    username = prefs.getString('username');
    xsrfToken = prefs.getString('xsrfToken');
    portalSession = prefs.getString('portalSession');
    idKrs = prefs.getString('idKrs');
    idNilai = prefs.getString('idNilai');
  }

  static Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    if (csrfToken != null) await prefs.setString('csrfToken', csrfToken!);
    if (accessToken != null) await prefs.setString('accessToken', accessToken!);
    if (username != null) await prefs.setString('username', username!);
    if (xsrfToken != null) await prefs.setString('xsrfToken', xsrfToken!);
    if (portalSession != null) await prefs.setString('portalSession', portalSession!);
    if (idKrs != null) await prefs.setString('idKrs', idKrs!);
    if (idNilai != null) await prefs.setString('idNilai', idNilai!);
  }

  static Future<void> clear() async {
    csrfToken = null;
    accessToken = null;
    username = null;
    xsrfToken = null;
    portalSession = null;
    idKrs = null;
    idNilai = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
