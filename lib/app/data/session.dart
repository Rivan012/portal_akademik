// ponytail: in-memory session only; upgrade to flutter_secure_storage for persistent auth.
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

  static void clear() {
    csrfToken = null;
    accessToken = null;
    username = null;
    xsrfToken = null;
    portalSession = null;
    idKrs = null;
    idNilai = null;
  }
}
