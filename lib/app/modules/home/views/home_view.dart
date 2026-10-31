import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const tabTitles = [
      'Portal Akademik',
      'Jadwal Kuliah',
      'KRS Mahasiswa',
      'Daftar Nilai',
      'Profil Mahasiswa',
    ];

    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: controller.currentIndex.value == 0
            ? _buildHomeAppBar()
            : AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                title: Text(
                  tabTitles[controller.currentIndex.value],
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                actions: [
                  if (controller.currentIndex.value == 4)
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      tooltip: 'Logout',
                      onPressed: controller.logout,
                    ),
                ],
              ),
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: [
            _buildHomeDashboardTab(),
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
          backgroundColor: Colors.white,
          elevation: 8,
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: const Color(0xFF94A3B8),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'KRS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline_rounded),
              activeIcon: Icon(Icons.star_rounded),
              label: 'Nilai',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // --- APP BAR FOR HOME TAB ---
  PreferredSizeWidget _buildHomeAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo_unib.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.school_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Portal Akademik',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Universitas Bengkulu',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF2563EB)),
          tooltip: 'Scan Presensi',
          onPressed: () => Get.toNamed(Routes.PRESENSI),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
          tooltip: 'Refresh Data',
          onPressed: controller.refreshHome,
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
          tooltip: 'Logout',
          onPressed: controller.logout,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // --- TAB 1: HOME DASHBOARD ---
  Widget _buildHomeDashboardTab() {
    return RefreshIndicator(
      onRefresh: controller.refreshHome,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 14),
        children: [
          _buildAcademicCard(),
          const SizedBox(height: 14),
          _buildQuickActions(),
          const SizedBox(height: 18),
          _buildTodayScheduleSection(),
          const SizedBox(height: 18),
          _buildRecentNewsSection(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 1. ACADEMIC SUMMARY CARD
  Widget _buildAcademicCard() {
    return Obx(() {
      final p = controller.profileData;
      final nama = (p['nama_mahasiswa'] ?? 'RIVAN ALFATONI').toString();
      final npm = (p['npm'] ?? 'G1F024047').toString();
      final prodi = (p['prodi']?['nama_prodi_id'] ?? 'Sistem Informasi').toString();
      final status = (p['nama_status_mahasiswa'] ?? 'Aktif').toString();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE68A),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Semester Ganjil 2026/2027',
                    style: TextStyle(
                      color: Color(0xFF92400E),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Selamat Datang,',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              nama,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$npm • $prodi',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  // 2. QUICK ACTIONS GRID (8 ICONS)
  Widget _buildQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                label: 'KRS',
                icon: Icons.assignment_outlined,
                bgColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFD97706),
                onTap: () => controller.changeTab(2),
              ),
              _buildActionItem(
                label: 'Jadwal',
                icon: Icons.calendar_month_rounded,
                bgColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF2563EB),
                onTap: () => controller.changeTab(1),
              ),
              _buildActionItem(
                label: 'Nilai',
                icon: Icons.verified_outlined,
                bgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF16A34A),
                onTap: () => controller.changeTab(3),
              ),
              _buildActionItem(
                label: 'Profil',
                icon: Icons.person_rounded,
                bgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                onTap: () => controller.changeTab(4),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                label: 'Transkrip',
                icon: Icons.menu_book_rounded,
                bgColor: const Color(0xFFFCE7F3),
                iconColor: const Color(0xFFDB2777),
                onTap: () => controller.changeTab(3),
              ),
              _buildActionItem(
                label: 'Presensi',
                icon: Icons.qr_code_scanner_rounded,
                bgColor: const Color(0xFFE0E7FF),
                iconColor: const Color(0xFF4F46E5),
                onTap: () => Get.toNamed(Routes.PRESENSI),
              ),
              _buildActionItem(
                label: 'Dosen PA',
                icon: Icons.people_alt_outlined,
                bgColor: const Color(0xFFCCFBF1),
                iconColor: const Color(0xFF0D9488),
                onTap: () => controller.changeTab(4),
              ),
              _buildActionItem(
                label: 'Pengumuman',
                icon: Icons.campaign_outlined,
                bgColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFEA580C),
                onTap: controller.fetchNews,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. JADWAL HARI INI SECTION
  Widget _buildTodayScheduleSection() {
    return Obx(() {
      final todayName = controller.todayNameIndonesian;
      final todayList = controller.todaySchedule;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Jadwal Hari Ini ($todayName)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => controller.changeTab(1),
                  child: const Text(
                    'Lihat Semua >',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (todayList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        color: Color(0xFFD97706),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tidak ada jadwal kuliah hari ini',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Istirahat atau cek jadwal lengkap minggu ini.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...todayList.map((item) {
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
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E7FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$startHour - $endHour',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4338CA),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$sks SKS',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          namaMk,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$kodeMk • Kelas $kelas • $namaRuang',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dosen: $dosen',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      );
    });
  }

  // 4. 5 BERITA TERAKHIR SECTION
  Widget _buildRecentNewsSection() {
    return Obx(() {
      final topNews = controller.top5News;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '5 Berita Terakhir',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Terkini',
                    style: TextStyle(
                      color: Color(0xFFD97706),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (controller.isLoadingNews.value && topNews.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (topNews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Belum ada berita terbaru.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...topNews.map((item) {
                final imageUrl = (item['image'] ?? '').toString();
                final title = (item['title'] ?? '-').toString();
                final category = (item['category'] ?? 'Pengumuman').toString();
                final date = (item['pubdate_formatted'] ?? item['pubdate'] ?? '').toString();
                final creator = (item['creator'] ?? 'Humas').toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: const Color(0xFFEFF6FF),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.newspaper_rounded,
                                    color: Color(0xFF3B82F6),
                                    size: 32,
                                  ),
                                )
                              : const Icon(
                                  Icons.newspaper_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 32,
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDBEAFE),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      color: Color(0xFF1D4ED8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              creator,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      );
    });
  }

  // --- TAB 2: JADWAL KULIAH LENGKAP ---
  Widget _buildScheduleTab() {
    return Obx(() {
      if (controller.isLoadingSchedule.value && controller.scheduleList.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.errorSchedule.isNotEmpty && controller.scheduleList.isEmpty) {
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$kodeMk • Kelas $kelas',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(namaRuang, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(dosen, style: const TextStyle(fontSize: 12)),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: gradeBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
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
      if (controller.errorProfile.isNotEmpty && controller.profileData.isEmpty) {
        return _buildErrorState(
          controller.errorProfile.value,
          controller.fetchProfile,
        );
      }

      final data = controller.profileData;
      final nama = (data['nama_mahasiswa'] ?? 'RIVAN ALFATONI').toString();
      final npm = (data['npm'] ?? 'G1F024047').toString();
      final prodi = (data['prodi']?['nama_prodi_id'] ?? 'Sistem Informasi').toString();
      final jenjang = (data['prodi']?['nama_jenjang_pendidikan'] ?? 'S1').toString();
      final gelar = (data['prodi']?['nama_gelar'] ?? 'SARJANA KOMPUTER').toString();
      final fakultas = (data['nama_fakultas'] ?? 'Teknik').toString();
      final status = (data['nama_status_mahasiswa'] ?? 'Aktif').toString();
      final jalur = (data['jalur_masuk'] ?? 'SNBT').toString();
      final noTes = (data['nomor_tes_masuk'] ?? '-').toString();
      final tglDaftar = (data['tanggal_daftar'] ?? '-').toString();
      final angkatan = (data['id_tahun_ajar'] != null ? data['id_tahun_ajar'].toString() : '2024');

      final dosenWali = data['dosen_wali'] as Map<String, dynamic>? ?? {};
      final dosenNama = (data['dosen_wali_nama'] ?? dosenWali['nama_dosen'] ?? '-').toString();
      final dosenGelar = (dosenWali['gelar_belakang'] ?? '').toString();
      final dosenFullNama = dosenGelar.isNotEmpty ? '$dosenNama, $dosenGelar' : dosenNama;
      final dosenNidn = (data['dosen_wali_nidn'] ?? dosenWali['nidn'] ?? '-').toString();
      final dosenNip = (dosenWali['nip'] ?? '-').toString();
      final dosenEmail = (dosenWali['email'] ?? '-').toString();
      final dosenTelp = (dosenWali['telepon'] ?? dosenWali['handphone'] ?? '-').toString();

      final nik = (data['nik'] ?? '-').toString();
      final nisn = (data['nisn'] ?? '-').toString();
      final jk = data['jenis_kelamin'] == 'L' ? 'Laki-laki' : (data['jenis_kelamin'] == 'P' ? 'Perempuan' : '-');
      final tmptLahir = (data['tempat_lahir'] ?? '-').toString();
      final tglLahir = (data['tanggal_lahir'] ?? '-').toString();
      final agama = (data['nama_agama'] ?? '-').toString();
      final goldar = (data['golongan_darah'] ?? data['kartu_golongan_darah'] ?? '-').toString();
      final statusNikah = (data['nama_status_nikah'] ?? '-').toString();
      final warganegara = (data['nama_kewarganegaraan'] ?? 'Indonesia').toString();

      final email = (data['email'] ?? '-').toString();
      final handphone = (data['handphone'] ?? '-').toString();
      final telepon = (data['telepon'] ?? '-').toString();
      final alamat = (data['alamat'] ?? '').toString();
      final dusun = (data['dusun'] ?? '').toString();
      final kel = (data['kelurahan'] ?? '').toString();
      final kec = (data['nm_kecamatan'] ?? '').toString();
      final kab = (data['nm_kabupaten'] ?? '').toString();
      final prov = (data['nm_provinsi'] ?? '').toString();
      final kodepos = (data['kode_pos'] ?? '').toString();
      final fullAlamat = [alamat, dusun.isNotEmpty ? 'Dusun $dusun' : '', kel.isNotEmpty ? 'Kel. $kel' : '', kec, kab, prov].where((s) => s.isNotEmpty).join(', ');
      final jenisTinggal = (data['nama_jenis_tinggal'] ?? '-').toString();
      final alatTransport = (data['nama_alat_transport'] ?? '-').toString();

      final smaNama = (data['nama_sma'] ?? '-').toString();
      final smaStatus = (data['nama_status_sma'] ?? '').toString();
      final smaJurusan = (data['nama_jurusan_sma'] ?? '-').toString();
      final smaTahun = '${data['sma_tahun_masuk'] ?? '-'} - ${data['sma_tahun_tamat'] ?? '-'}';
      final smaIjazah = (data['sma_nomor_ijazah'] ?? '-').toString();
      final smaNilai = (data['sma_nilai_ujian_akhir'] != null ? data['sma_nilai_ujian_akhir'].toString() : '-');
      final smaAlamat = (data['sma_alamat'] ?? '-').toString();

      final ayahNama = (data['ayah_nama'] ?? '-').toString();
      final ayahPekerjaan = (data['ayah_pekerjaan'] ?? '-').toString();
      final ayahPendidikan = (data['ayah_pendidikan'] ?? '-').toString();
      final ibuNama = (data['ibu_nama'] ?? '-').toString();
      final ibuPekerjaan = (data['ibu_pekerjaan'] ?? '-').toString();
      final ibuPendidikan = (data['ibu_pendidikan'] ?? '-').toString();
      final hubunganBiaya = (data['nama_hubungan_biaya'] ?? 'Orang Tua Kandung').toString();
      final sumberDana = (data['nama_sumber_dana'] ?? 'ORANG TUA/WALI').toString();

      final noVa = (data['no_va'] ?? '-').toString();
      final bank = (data['bank'] ?? 'Mandiri').toString().toUpperCase();

      return RefreshIndicator(
        onRefresh: controller.fetchProfile,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          children: [
            // HERO PROFILE CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 33,
                          backgroundColor: const Color(0xFFDBEAFE),
                          child: Text(
                            nama.isNotEmpty ? nama[0] : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nama,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: npm));
                                Get.snackbar(
                                  'Berhasil',
                                  'NPM $npm disalin ke clipboard',
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    npm,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.copy_rounded, size: 14, color: Colors.white70),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$prodi • $fakultas',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeroBadge(label: 'Status', value: status, color: const Color(0xFF22C55E)),
                      _buildHeroBadge(label: 'Jenjang', value: jenjang, color: const Color(0xFF60A5FA)),
                      _buildHeroBadge(label: 'Jalur', value: jalur, color: const Color(0xFFFBBF24)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECTIONS
            _buildSectionCard(
              title: 'Informasi Akademik',
              icon: Icons.school_rounded,
              accentColor: const Color(0xFF2563EB),
              children: [
                _buildInfoRow('Fakultas', fakultas),
                _buildInfoRow('Program Studi', '$prodi ($jenjang)'),
                _buildInfoRow('Gelar Kelulusan', gelar),
                _buildInfoRow('Status Mahasiswa', status),
                _buildInfoRow('Tahun Masuk / Angkatan', angkatan),
                _buildInfoRow('Jalur Masuk', jalur),
                _buildInfoRow('Nomor Tes Masuk', noTes),
                _buildInfoRow('Tanggal Pendaftaran', tglDaftar),
                _buildInfoRow(
                  'Virtual Account (VA)',
                  '$noVa ($bank)',
                  canCopy: noVa != '-',
                  copyText: noVa,
                ),
              ],
            ),
            const SizedBox(height: 14),

            _buildSectionCard(
              title: 'Dosen Pembimbing Akademik',
              icon: Icons.person_pin_rounded,
              accentColor: const Color(0xFF0D9488),
              children: [
                _buildInfoRow('Nama Dosen', dosenFullNama),
                _buildInfoRow('NIDN', dosenNidn),
                _buildInfoRow('NIP', dosenNip),
                _buildInfoRow('Email Dosen', dosenEmail),
                _buildInfoRow('Kontak Telepon', dosenTelp),
              ],
            ),
            const SizedBox(height: 14),

            _buildSectionCard(
              title: 'Biodata Pribadi',
              icon: Icons.badge_outlined,
              accentColor: const Color(0xFF9333EA),
              children: [
                _buildInfoRow('NIK (KTP)', nik, canCopy: nik != '-', copyText: nik),
                _buildInfoRow('NISN', nisn),
                _buildInfoRow('Tempat, Tanggal Lahir', '$tmptLahir, $tglLahir'),
                _buildInfoRow('Jenis Kelamin', jk),
                _buildInfoRow('Golongan Darah', goldar),
                _buildInfoRow('Agama', agama),
                _buildInfoRow('Status Pernikahan', statusNikah),
                _buildInfoRow('Kewarganegaraan', warganegara),
              ],
            ),
            const SizedBox(height: 14),

            _buildSectionCard(
              title: 'Kontak & Domisili',
              icon: Icons.location_on_outlined,
              accentColor: const Color(0xFFEA580C),
              children: [
                _buildInfoRow('Email Pribadi', email),
                _buildInfoRow('Nomor Handphone', handphone),
                _buildInfoRow('Telepon Rumah', telepon),
                _buildInfoRow('Alamat Lengkap', fullAlamat.isNotEmpty ? fullAlamat : '-'),
                _buildInfoRow('Kode Pos', kodepos.isNotEmpty ? kodepos : '-'),
                _buildInfoRow('Jenis Tempat Tinggal', jenisTinggal),
                _buildInfoRow('Alat Transportasi', alatTransport),
              ],
            ),
            const SizedBox(height: 14),

            _buildSectionCard(
              title: 'Pendidikan Asal (Sekolah)',
              icon: Icons.history_edu_rounded,
              accentColor: const Color(0xFFD97706),
              children: [
                _buildInfoRow('Nama Sekolah', smaStatus.isNotEmpty ? '$smaNama ($smaStatus)' : smaNama),
                _buildInfoRow('Jurusan', smaJurusan),
                _buildInfoRow('Tahun Masuk / Tamat', smaTahun),
                _buildInfoRow('Nomor Ijazah', smaIjazah),
                _buildInfoRow('Nilai Ujian Akhir', smaNilai),
                _buildInfoRow('Alamat Sekolah', smaAlamat),
              ],
            ),
            const SizedBox(height: 14),

            _buildSectionCard(
              title: 'Data Orang Tua & Pembiayaan',
              icon: Icons.family_restroom_rounded,
              accentColor: const Color(0xFF4F46E5),
              children: [
                _buildInfoRow('Nama Ayah', ayahNama),
                _buildInfoRow('Pekerjaan Ayah', ayahPekerjaan),
                _buildInfoRow('Pendidikan Ayah', ayahPendidikan),
                _buildInfoRow('Nama Ibu', ibuNama),
                _buildInfoRow('Pekerjaan Ibu', ibuPekerjaan),
                _buildInfoRow('Pendidikan Ibu', ibuPendidikan),
                _buildInfoRow('Penanggung Biaya', hubunganBiaya),
                _buildInfoRow('Sumber Dana', sumberDana),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Keluar dari Akun'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEE2E2),
                foregroundColor: const Color(0xFFDC2626),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFFECACA)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  Widget _buildHeroBadge({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool canCopy = false, String? copyText}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (canCopy && copyText != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: copyText));
                      Get.snackbar(
                        'Tersalin',
                        '$label berhasil disalin ke clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
