import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/session.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validasi',
        'Username dan password wajib diisi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    isLoading.value = true;

    // Web environment: browser sandboxes forbid cookie manipulation & CORS. Route via dev proxy.
    if (kIsWeb) {
      try {
        final res = await http.post(
          Uri.parse('http://127.0.0.1:8080/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'username': username, 'password': password}),
        );
        final data = jsonDecode(res.body);
        if (res.statusCode == 200 && data['success'] == true) {
          Session.csrfToken = data['csrf_token'];
          Session.xsrfToken = data['xsrf_token'];
          Session.portalSession = data['portal_session'];
          Session.accessToken = data['access_token'];
          Session.username = data['username'];
          Session.idKrs = data['id_krs'];
          Session.idNilai = data['id_nilai'];
          await Session.save();
          Get.offAllNamed(Routes.HOME);
          return;
        } else {
          throw Exception(data['message'] ?? 'Login gagal. Pastikan dev_proxy.py berjalan.');
        }
      } catch (e) {
        Get.snackbar(
          'Login Gagal (Web)',
          'Jalankan "python dev_proxy.py" di terminal!\n${e.toString().replaceAll("Exception: ", "")}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          duration: const Duration(seconds: 6),
        );
      } finally {
        isLoading.value = false;
      }
      return;
    }

    // Native environment (Android / iOS / Desktop): direct sockets via dart:io
    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    try {
      // 1. GET login page ambil cookie dan CSRF token
      final req1 = await client.getUrl(Uri.parse('https://portal.unib.ac.id/login/login'));
      req1.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
      req1.headers.set(HttpHeaders.acceptHeader, 'text/html,application/xhtml+xml,application/json');
      final res1 = await req1.close();
      final cookies = <Cookie>[...res1.cookies];
      final body1 = await utf8.decodeStream(res1);

      final csrfMatch = RegExp(r'name="_token"\s+value="([^"]+)"').firstMatch(body1) ??
          RegExp(r"name='_token'\s+value='([^']+)'").firstMatch(body1);
      final csrf = csrfMatch?.group(1) ?? '';

      if (csrf.isEmpty) {
        throw Exception('Token CSRF tidak ditemukan di halaman login');
      }

      // 2. POST kredensial login
      final req2 = await client.postUrl(Uri.parse('https://portal.unib.ac.id/login/login'));
      req2.followRedirects = false;
      req2.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
      req2.headers.set(HttpHeaders.refererHeader, 'https://portal.unib.ac.id/login/login');
      req2.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded; charset=UTF-8');

      final cookieHeaderVal = cookies.map((c) => '${c.name}=${c.value}').join('; ');
      req2.headers.set(HttpHeaders.cookieHeader, cookieHeaderVal);

      final payload = {
        '_token': csrf,
        'username': username,
        'password': password,
      };
      final bodyData = payload.entries
          .map((e) => '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
          .join('&');
      req2.add(utf8.encode(bodyData));

      final res2 = await req2.close();
      for (final c in res2.cookies) {
        cookies.removeWhere((item) => item.name == c.name);
        cookies.add(c);
      }

      final location = res2.headers.value(HttpHeaders.locationHeader);
      final body2 = await utf8.decodeStream(res2);

      if (res2.statusCode != 302 && res2.statusCode != 200) {
        throw Exception('HTTP ${res2.statusCode}: Respons server tidak terduga');
      }

      if (location != null && location.contains('/login')) {
        throw Exception('Username atau password salah');
      }

      // 3. Ekstrak access token dari redirect atau body
      String targetHtml = body2;
      if (location != null && !location.contains('/login')) {
        final nextUri = Uri.parse(location).isAbsolute
            ? Uri.parse(location)
            : Uri.parse('https://portal.unib.ac.id').resolve(location);

        final req3 = await client.getUrl(nextUri);
        req3.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
        req3.headers.set(
          HttpHeaders.cookieHeader,
          cookies.map((c) => '${c.name}=${c.value}').join('; '),
        );

        final res3 = await req3.close();
        targetHtml = await utf8.decodeStream(res3);
      }

      final patterns = [
        RegExp(r"""Alpine\.store\(\s*['"]access_token['"]\s*,\s*['"]([^'"]+)['"]\s*\)"""),
        RegExp(r"""['"]access_token['"]\s*:\s*['"]([^'"]+)['"]"""),
      ];

      String? accessToken;
      for (final p in patterns) {
        final m = p.firstMatch(targetHtml);
        if (m != null) {
          accessToken = m.group(1);
          break;
        }
      }

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Login gagal atau access token tidak ditemukan');
      }

      Session.csrfToken = csrf;
      Session.accessToken = accessToken;
      Session.username = username;
      for (final c in cookies) {
        if (c.name == 'XSRF-TOKEN') {
          Session.xsrfToken = Uri.decodeComponent(c.value);
        } else if (c.name == 'portal_session') {
          Session.portalSession = Uri.decodeComponent(c.value);
        }
      }

      // ponytail: scrape dynamic KRS & Nilai IDs on login; fallback to known token if parse fails.
      try {
        final krsReq = await client.getUrl(Uri.parse('https://portal.unib.ac.id/krs/registration'));
        krsReq.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
        krsReq.headers.set(HttpHeaders.cookieHeader, cookies.map((c) => '${c.name}=${c.value}').join('; '));
        final krsRes = await krsReq.close();
        final krsBody = await utf8.decodeStream(krsRes);
        final krsMatch = RegExp(r'idKRS:\s*[\x27\x22]([^\x27\x22]+)[\x27\x22]').firstMatch(krsBody);
        if (krsMatch != null) {
          Session.idKrs = krsMatch.group(1);
        }
      } catch (_) {}

      try {
        final gradeReq = await client.getUrl(Uri.parse('https://portal.unib.ac.id/grade/student'));
        gradeReq.headers.set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)');
        gradeReq.headers.set(HttpHeaders.cookieHeader, cookies.map((c) => '${c.name}=${c.value}').join('; '));
        final gradeRes = await gradeReq.close();
        final gradeBody = await utf8.decodeStream(gradeRes);
        final gradeMatch = RegExp(r'grade-list-student/([a-zA-Z0-9%_\-\+=]+)').firstMatch(gradeBody);
        if (gradeMatch != null) {
          Session.idNilai = gradeMatch.group(1);
        }
      } catch (_) {}

      await Session.save();

      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar(
        'Login Gagal',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        duration: const Duration(seconds: 4),
      );
    } finally {
      client.close();
      isLoading.value = false;
    }
  }
}
