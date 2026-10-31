import 'package:flutter_test/flutter_test.dart';
import 'package:portal_akademik/app/modules/presensi/controllers/presensi_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Presensi code extraction logic', () {
    final controller = PresensiController();

    // Raw code
    const raw = '1.1234567890.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
    expect(controller.extractQrCode(raw), equals(raw));

    // Full URL from UNIB portal
    const url = 'https://portal.unib.ac.id/mahasiswa/academic/presensi/qr/1.1234567890.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
    expect(controller.extractQrCode(url), equals(raw));

    // URL with trailing slash or query params
    const urlWithParams = 'https://portal.unib.ac.id/mahasiswa/academic/presensi/qr/1.1234567890.AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA?test=1';
    expect(controller.extractQrCode(urlWithParams), equals(raw));
  });
}
