import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../data/session.dart';
import '../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  final newsList = <Map<String, dynamic>>[].obs;
  final scheduleList = <Map<String, dynamic>>[].obs;
  final krsList = <Map<String, dynamic>>[].obs;
  final nilaiList = <Map<String, dynamic>>[].obs;
  final profileData = <String, dynamic>{}.obs;

  final isLoadingNews = false.obs;
  final isLoadingSchedule = false.obs;
  final isLoadingKrs = false.obs;
  final isLoadingNilai = false.obs;
  final isLoadingProfile = false.obs;

  final errorNews = ''.obs;
  final errorSchedule = ''.obs;
  final errorKrs = ''.obs;
  final errorNilai = ''.obs;
  final errorProfile = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNews();
  }

  void changeTab(int index) {
    currentIndex.value = index;
    switch (index) {
      case 0:
        if (newsList.isEmpty) fetchNews();
        break;
      case 1:
        if (scheduleList.isEmpty) fetchSchedule();
        break;
      case 2:
        if (krsList.isEmpty) fetchKRS();
        break;
      case 3:
        if (nilaiList.isEmpty) fetchNilai();
        break;
      case 4:
        if (profileData.isEmpty) fetchProfile();
        break;
    }
  }

  Future<dynamic> _authorizedGet(String url) async {
    if (!Session.isAuthenticated) {
      Get.offAllNamed(Routes.LOGIN);
      return null;
    }

    if (kIsWeb) {
      final webUrl = url.replaceFirst(
        'https://api-gateway.unib.ac.id/backend/api',
        'http://127.0.0.1:8080/api',
      );
      final res = await http.get(
        Uri.parse(webUrl),
        headers: {
          'Authorization': 'Bearer ${Session.accessToken}',
          'Accept': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      } else if (res.statusCode == 401) {
        Session.clear();
        Get.offAllNamed(Routes.LOGIN);
        return null;
      } else {
        throw Exception('Status ${res.statusCode}');
      }
    }

    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${Session.accessToken}',
      );
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');

      final res = await req.close();
      final body = await utf8.decodeStream(res);

      if (res.statusCode == 200) {
        return jsonDecode(body);
      } else if (res.statusCode == 401) {
        Session.clear();
        Get.offAllNamed(Routes.LOGIN);
        return null;
      } else {
        throw Exception('Status ${res.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Future<void> fetchNews() async {
    isLoadingNews.value = true;
    errorNews.value = '';
    try {
      final json = await _authorizedGet(
        'https://api-gateway.unib.ac.id/backend/api/v1/news',
      );
      if (json != null && json['data'] is List) {
        newsList.assignAll((json['data'] as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      errorNews.value = 'Gagal memuat berita: $e';
    } finally {
      isLoadingNews.value = false;
    }
  }

  Future<void> fetchSchedule() async {
    isLoadingSchedule.value = true;
    errorSchedule.value = '';
    try {
      const url =
          'https://api-gateway.unib.ac.id/backend/api/v1/academic/schedule?draw=1&start=0&length=20';
      final json = await _authorizedGet(url);
      if (json != null && json['data'] is List) {
        scheduleList.assignAll(
          (json['data'] as List).cast<Map<String, dynamic>>(),
        );
      }
    } catch (e) {
      errorSchedule.value = 'Gagal memuat jadwal: $e';
    } finally {
      isLoadingSchedule.value = false;
    }
  }

  Future<void> fetchKRS() async {
    isLoadingKrs.value = true;
    errorKrs.value = '';
    try {
      final idKrsEncoded = Uri.encodeQueryComponent(Session.effectiveIdKrs);
      final url =
          'https://api-gateway.unib.ac.id/backend/api/v1/krs/student/krs-selected?id_krs=$idKrsEncoded&id_mahasiswa=0';
      final json = await _authorizedGet(url);
      if (json != null && json['data'] is List) {
        krsList.assignAll((json['data'] as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      errorKrs.value = 'Gagal memuat KRS: $e';
    } finally {
      isLoadingKrs.value = false;
    }
  }

  Future<void> fetchNilai() async {
    isLoadingNilai.value = true;
    errorNilai.value = '';
    try {
      final idNilaiEncoded = Uri.encodeComponent(Session.effectiveIdNilai);
      final url =
          'https://api-gateway.unib.ac.id/backend/api/v1/grade/grade-list-student/$idNilaiEncoded?draw=1&start=0&length=50';
      final json = await _authorizedGet(url);
      if (json != null && json['data'] is List) {
        nilaiList
            .assignAll((json['data'] as List).cast<Map<String, dynamic>>());
      }
    } catch (e) {
      errorNilai.value = 'Gagal memuat nilai: $e';
    } finally {
      isLoadingNilai.value = false;
    }
  }

  Future<void> fetchProfile() async {
    isLoadingProfile.value = true;
    errorProfile.value = '';
    try {
      final npm = Session.username ?? 'G1F024047';
      final url =
          'https://api-gateway.unib.ac.id/backend/api/v1/mahasiswa/get/profile/profile?id_mahasiswa=$npm';
      final json = await _authorizedGet(url);
      if (json != null && json['data'] is Map) {
        profileData.assignAll(json['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      errorProfile.value = 'Gagal memuat profil: $e';
    } finally {
      isLoadingProfile.value = false;
    }
  }

  void logout() {
    Session.clear();
    Get.offAllNamed(Routes.LOGIN);
  }
}
