import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/session.dart';

class PresensiController extends GetxController {
  late final MobileScannerController scannerController;
  final manualCodeController = TextEditingController();

  final isScanning = true.obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isSuccess = false.obs;
  final isError = false.obs;
  final statusMessage = ''.obs;
  final isTorchOn = false.obs;

  final qrData = <String, dynamic>{}.obs;
  final claimToken = ''.obs;
  final countdownSeconds = 0.obs;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    manualCodeController.dispose();
    scannerController.dispose();
    super.onClose();
  }

  void toggleTorch() {
    scannerController.toggleTorch();
    isTorchOn.toggle();
  }

  void switchCamera() {
    scannerController.switchCamera();
  }

  void handleBarcode(BarcodeCapture capture) {
    if (!isScanning.value || isLoading.value) return;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.trim().isNotEmpty) {
        processQr(rawValue);
        break;
      }
    }
  }

  String extractQrCode(String input) {
    var raw = input.trim();
    if (raw.contains('/presensi/qr/')) {
      final match = RegExp(r'/presensi/qr/([^/?#]+)').firstMatch(raw);
      if (match != null) {
        return match.group(1)!;
      }
    }
    return raw;
  }

  Future<void> processQr(String input) async {
    final code = extractQrCode(input);
    if (code.isEmpty) return;

    isScanning.value = false;
    isLoading.value = true;
    isError.value = false;
    isSuccess.value = false;
    statusMessage.value = '';
    _countdownTimer?.cancel();

    try {
      final url =
          'https://api-gateway.unib.ac.id/backend/api/v1/academic/bap/qr-presence/scan/${Uri.encodeComponent(code)}';

      final response = await _authorizedGet(url);

      if (response != null && response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>? ?? {};
        qrData.assignAll(data);
        claimToken.value = data['claim_token']?.toString() ?? '';

        final expiresIn = data['claim_expires_in'];
        if (expiresIn is int && expiresIn > 0) {
          _startCountdown(expiresIn);
        }

        if (data['active'] == false) {
          isError.value = true;
          statusMessage.value = 'QR presensi sudah tidak aktif.';
        }
      } else {
        isError.value = true;
        statusMessage.value =
            response?['message']?.toString() ?? 'QR tidak valid atau kedaluwarsa.';
      }
    } catch (e) {
      isError.value = true;
      statusMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recordPresence() async {
    if (claimToken.isEmpty) return;

    isSubmitting.value = true;
    isError.value = false;

    try {
      const url =
          'https://api-gateway.unib.ac.id/backend/api/v1/academic/bap/qr-presence/scan';

      final body = jsonEncode({'claim_token': claimToken.value});
      final response = await _authorizedPost(url, body);

      if (response != null && response['success'] == true) {
        isSuccess.value = true;
        final already = response['data']?['already_recorded'] == true;
        statusMessage.value = already
            ? 'Kehadiran Anda sebelumnya sudah tercatat.'
            : (response['message']?.toString() ?? 'Kehadiran berhasil dicatat!');
      } else {
        isError.value = true;
        statusMessage.value =
            response?['message']?.toString() ?? 'Gagal mencatat kehadiran.';
      }
    } catch (e) {
      isError.value = true;
      statusMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isSubmitting.value = false;
    }
  }

  void resetScanner() {
    _countdownTimer?.cancel();
    isError.value = false;
    isSuccess.value = false;
    statusMessage.value = '';
    qrData.clear();
    claimToken.value = '';
    manualCodeController.clear();
    isScanning.value = true;
  }

  void _startCountdown(int seconds) {
    countdownSeconds.value = seconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
      } else {
        timer.cancel();
        if (!isSuccess.value) {
          isError.value = true;
          statusMessage.value = 'Waktu konfirmasi presensi telah habis.';
        }
      }
    });
  }

  Future<dynamic> _authorizedGet(String url) async {
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
      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return decoded;
      } else {
        throw Exception(decoded['message'] ?? 'Error status ${res.statusCode}');
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
      final decoded = jsonDecode(body);
      if (res.statusCode == 200) {
        return decoded;
      } else {
        throw Exception(decoded['message'] ?? 'Error status ${res.statusCode}');
      }
    } finally {
      client.close();
    }
  }

  Future<dynamic> _authorizedPost(String url, String jsonBody) async {
    if (kIsWeb) {
      final webUrl = url.replaceFirst(
        'https://api-gateway.unib.ac.id/backend/api',
        'http://127.0.0.1:8080/api',
      );
      final res = await http.post(
        Uri.parse(webUrl),
        headers: {
          'Authorization': 'Bearer ${Session.accessToken}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonBody,
      );
      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return decoded;
      } else {
        throw Exception(decoded['message'] ?? 'Error status ${res.statusCode}');
      }
    }

    final client = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;

    try {
      final req = await client.postUrl(Uri.parse(url));
      req.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer ${Session.accessToken}',
      );
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.add(utf8.encode(jsonBody));

      final res = await req.close();
      final body = await utf8.decodeStream(res);
      final decoded = jsonDecode(body);
      if (res.statusCode == 200) {
        return decoded;
      } else {
        throw Exception(decoded['message'] ?? 'Error status ${res.statusCode}');
      }
    } finally {
      client.close();
    }
  }
}
