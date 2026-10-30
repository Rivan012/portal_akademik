import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const titles = [
      'Berita UNIB',
      'Jadwal Kuliah',
      'KRS Mahasiswa',
      'Daftar Nilai',
      'Profil Mahasiswa',
    ];

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(titles[controller.currentIndex.value]),
          actions: [
            if (controller.currentIndex.value == 4)
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Logout',
                onPressed: controller.logout,
              ),
          ],
        ),
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            _buildNewsTab(),
            _buildScheduleTab(),
            _buildKrsTab(),
            _buildNilaiTab(),
            _buildProfileTab(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.newspaper_outlined),
              activeIcon: Icon(Icons.newspaper),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'KRS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.grade_outlined),
              activeIcon: Icon(Icons.grade),
              label: 'Nilai',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: HOME (BERITA) ---
  Widget _buildNewsTab() {
    return Obx(() {
      if (controller.isLoadingNews.value && controller.newsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorNews.isNotEmpty && controller.newsList.isEmpty) {
        return _buildErrorState(
          controller.errorNews.value,
          controller.fetchNews,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchNews,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.newsList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.newsList[index];
            final imageUrl = item['image'] as String?;
            final title = item['title'] ?? '-';
            final category = item['category'] ?? 'Berita';
            final date = item['pubdate_formatted'] ?? item['pubdate'] ?? '';
            final creator = item['creator'] ?? '';

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageUrl != null && imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 120,
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              date,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (creator.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Oleh: $creator',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  // --- TAB 2: JADWAL KULIAH ---
  Widget _buildScheduleTab() {
    return Obx(() {
      if (controller.isLoadingSchedule.value &&
          controller.scheduleList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorSchedule.isNotEmpty &&
          controller.scheduleList.isEmpty) {
        return _buildErrorState(
          controller.errorSchedule.value,
          controller.fetchSchedule,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchSchedule,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.scheduleList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.scheduleList[index];
            final day = item['day']?['day_indonesian'] ?? '-';
            final startHour = item['sch_start_hour'] ?? '';
            final endHour = item['sch_end_hour'] ?? '';
            final mkTawar = item['mk_tawar'] ?? {};
            final mkKelas = item['mk_kelas'] ?? {};
            final room = item['room'] ?? {};
            final dosen = item['dosen_names'] ?? '-';

            final namaMk = mkTawar['mkt_nama_matakuliah'] ?? '-';
            final kodeMk = mkTawar['mkt_kode_matakuliah'] ?? '-';
            final sks = mkTawar['mkt_sks_kurikulum'] ?? '-';
            final kelas = mkKelas['mks_nama_kelas'] ?? '-';
            final namaRuang = room['rm_name'] ?? '-';

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$day, $startHour - $endHour',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '$sks SKS',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      namaMk,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$kodeMk • Kelas $kelas',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.meeting_room_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            namaRuang,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dosen,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // --- TAB 3: KRS ---
  Widget _buildKrsTab() {
    return Obx(() {
      if (controller.isLoadingKrs.value && controller.krsList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorKrs.isNotEmpty && controller.krsList.isEmpty) {
        return _buildErrorState(
          controller.errorKrs.value,
          controller.fetchKRS,
        );
      }

      int totalSks = 0;
      for (final item in controller.krsList) {
        final sks = item['total_sks'];
        if (sks is int) {
          totalSks += sks;
        } else if (sks is num) {
          totalSks += sks.toInt();
        }
      }

      return RefreshIndicator(
        onRefresh: controller.fetchKRS,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              color: Colors.blue.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.school, color: Colors.blueAccent),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total SKS Terpilih',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          '$totalSks SKS (${controller.krsList.length} Mata Kuliah)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...controller.krsList.map((item) {
              final namaMk = item['nama_matakuliah'] ?? '-';
              final kodeMk = item['kode_matakuliah'] ?? '-';
              final namaKelas = item['nama_kelas'] ?? item['kode_kelas'] ?? '-';
              final semester = item['semester'] ?? '-';
              final sks = item['total_sks'] ?? 0;

              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    namaMk,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$kodeMk • Kelas $namaKelas • Sem $semester'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$sks SKS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  // --- TAB 4: NILAI ---
  Widget _buildNilaiTab() {
    return Obx(() {
      if (controller.isLoadingNilai.value && controller.nilaiList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorNilai.isNotEmpty && controller.nilaiList.isEmpty) {
        return _buildErrorState(
          controller.errorNilai.value,
          controller.fetchNilai,
        );
      }
      return RefreshIndicator(
        onRefresh: controller.fetchNilai,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.nilaiList.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = controller.nilaiList[index];
            final namaMk = item['nama_matakuliah'] ?? '-';
            final kodeMk = item['kode_matakuliah'] ?? '-';
            final namaKelas = item['nama_kelas'] ?? '-';
            final sks = item['sks'] ?? '-';
            final tahunAjar = item['tahun_ajar'] ?? '';
            final hurufMutu = item['huruf_mutu'] ?? '-';
            final angkaMutu = item['angka_mutu'] ?? '-';

            Color gradeBg = Colors.grey.shade100;
            Color gradeColor = Colors.grey.shade800;
            if (hurufMutu.toString().startsWith('A')) {
              gradeBg = Colors.green.shade50;
              gradeColor = Colors.green.shade800;
            } else if (hurufMutu.toString().startsWith('B')) {
              gradeBg = Colors.blue.shade50;
              gradeColor = Colors.blue.shade800;
            } else if (hurufMutu.toString().startsWith('C')) {
              gradeBg = Colors.orange.shade50;
              gradeColor = Colors.orange.shade800;
            } else if (hurufMutu.toString().startsWith('D') ||
                hurufMutu.toString().startsWith('E')) {
              gradeBg = Colors.red.shade50;
              gradeColor = Colors.red.shade800;
            }

            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tahunAjar.isNotEmpty)
                            Text(
                              tahunAjar,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            namaMk,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$kodeMk • Kelas $namaKelas • $sks SKS',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: gradeBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: gradeColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$hurufMutu',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: gradeColor,
                            ),
                          ),
                          Text(
                            '$angkaMutu',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: gradeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // --- TAB 5: PROFILE ---
  Widget _buildProfileTab() {
    return Obx(() {
      if (controller.isLoadingProfile.value && controller.profileData.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorProfile.isNotEmpty &&
          controller.profileData.isEmpty) {
        return _buildErrorState(
          controller.errorProfile.value,
          controller.fetchProfile,
        );
      }

      final data = controller.profileData;
      final nama = data['nama_mahasiswa'] ?? '-';
      final npm = data['npm'] ?? '-';
      final prodi = data['prodi']?['nama_prodi_id'] ?? '-';
      final fakultas = data['nama_fakultas'] ?? '-';
      final dosenWali = data['dosen_wali_nama'] ??
          data['dosen_wali']?['nama_dosen'] ??
          '-';
      final status = data['nama_status_mahasiswa'] ?? 'Aktif';
      final email = data['email'] ?? '-';
      final telepon = data['telepon'] ?? '-';
      final jalur = data['jalur_masuk'] ?? '-';

      return RefreshIndicator(
        onRefresh: controller.fetchProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.blueAccent.shade100,
                    child: Text(
                      nama.isNotEmpty ? nama[0] : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nama,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    npm,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileRow(
                      Icons.account_balance_outlined,
                      'Fakultas',
                      fakultas,
                    ),
                    const Divider(height: 20),
                    _buildProfileRow(Icons.school_outlined, 'Program Studi', prodi),
                    const Divider(height: 20),
                    _buildProfileRow(
                      Icons.person_pin_outlined,
                      'Dosen Pembimbing',
                      dosenWali,
                    ),
                    const Divider(height: 20),
                    _buildProfileRow(Icons.route_outlined, 'Jalur Masuk', jalur),
                    const Divider(height: 20),
                    _buildProfileRow(Icons.email_outlined, 'Email', email),
                    const Divider(height: 20),
                    _buildProfileRow(Icons.phone_outlined, 'Telepon', telepon),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProfileRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, Future<void> Function() onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
