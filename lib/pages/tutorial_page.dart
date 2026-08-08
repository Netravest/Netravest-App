import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';
import 'tutorial/sos_tutorial.dart';
import 'tutorial/location_tutorial.dart';
import 'tutorial/settings_tutorial.dart';
import 'tutorial/device_tutorial.dart';
import 'tutorial/contact_tutorial.dart';
import 'tutorial/vest_info_tutorial.dart';
import 'tutorial/account_tutorial.dart';
import 'tutorial/vest_usage_tutorial.dart';

class TutorialPage extends StatefulWidget {
  final String userId;
  const TutorialPage({super.key, required this.userId});

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  bool _isShowingVestCategory =
      false; // false = App Tutorial, true = Vest Tutorial
  int _selectedStepIndex =
      -1; // -1 means showing Roadmap view, 0+ means showing Detail view
  bool _isAudioPlaying = false;
  double _audioWaveHeight = 0.0;

  late PageController _pageController;
  int _currentSubPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // App tutorial steps
  final List<Map<String, dynamic>> _appSteps = [
    {
      'title': 'Tombol SOS',
      'icon': 'sos',
      'description':
          'Gunakan tombol SOS besar untuk memicu alarm darurat seketika.',
      'pages': (BuildContext context) => getSosTutorialData(context),
    },
    {
      'title': 'Bagikan Lokasi',
      'icon': 'location',
      'description':
          'Kirimkan koordinat lokasi GPS presisi Anda ke kontak terdekat secara otomatis.',
      'pages': (BuildContext context) => getLocationTutorialData(context),
    },
    {
      'title': 'Pengaturan',
      'icon': 'settings',
      'description':
          'Konfigurasi ambang ketukan tombol SOS, durasi video darurat, dan preferences.',
      'pages': (BuildContext context) => getSettingsTutorialData(context),
    },
    {
      'title': 'Menambahkan Kontak',
      'icon': 'contact',
      'description':
          'Kelola nomor telepon penting keluarga atau kerabat dekat sebagai kontak darurat.',
      'pages': (BuildContext context) => getContactTutorialData(context),
    },
    {
      'title': 'Akun Pengguna',
      'icon': 'account',
      'description':
          'Kelola data profil, sinkronisasi Cloud Firestore, dan sesi masuk Anda.',
      'pages': (BuildContext context) => getAccountTutorialData(context),
    },
  ];

  // Vest tutorial steps
  final List<Map<String, dynamic>> _vestSteps = [
    {
      'title': 'Cara Pakai Rompi',
      'icon': 'vest_wear',
      'description':
          'Panduan mengenakan rompi pintar, menyalakan daya, dan memahami getaran navigasi.',
      'pages': (BuildContext context) => getVestUsageTutorialData(context),
    },
    {
      'title': 'Perangkat',
      'icon': 'device',
      'description':
          'Hubungkan ponsel ke modul rompi pintar Anda secara wireless menggunakan Bluetooth.',
      'pages': (BuildContext context) => getDeviceTutorialData(context),
    },
    {
      'title': 'Informasi Rompi',
      'icon': 'info',
      'description':
          'Pantau status baterai, konektivitas cloud, kamera, dan sensor LiDAR rompi.',
      'pages': (BuildContext context) => getVestInfoTutorialData(context),
    },
  ];

  void _skipTutorial() {
    final provider = context.read<EmergencyProvider>();
    provider.completeTutorial(widget.userId);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _backToRoadmap() {
    setState(() {
      _selectedStepIndex = -1;
      _currentSubPageIndex = 0;
      _isAudioPlaying = false;
    });
  }

  void _toggleAudio() {
    setState(() {
      _isAudioPlaying = !_isAudioPlaying;
    });

    if (_isAudioPlaying) {
      _simulateAudioWave();
    }
  }

  void _simulateAudioWave() async {
    while (_isAudioPlaying && mounted) {
      for (double i = 0.0; i <= 1.0; i += 0.2) {
        if (!_isAudioPlaying || !mounted) break;
        setState(() {
          _audioWaveHeight = i;
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
      for (double i = 1.0; i >= 0.0; i -= 0.2) {
        if (!_isAudioPlaying || !mounted) break;
        setState(() {
          _audioWaveHeight = i;
        });
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _selectedStepIndex == -1
            ? _buildRoadmapView()
            : _buildDetailView(),
      ),
    );
  }

  Widget _buildRoadmapView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Distribute space dynamically to avoid scroll
        final double totalGridHeight =
            constraints.maxHeight -
            165.0; // Subtract header, footer, and tab bar height
        final int rowCount = _isShowingVestCategory ? 2 : 3;
        final double boxHeight =
            (totalGridHeight - (rowCount - 1) * 16.0) / rowCount;

        final List<Map<String, dynamic>> activeSteps = _isShowingVestCategory
            ? _vestSteps
            : _appSteps;

        return Stack(
          children: [
            // Fixed-height container layout - NO SCROLL
            Padding(
              padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
              child: Column(
                children: [
                  // Tab Category Selector
                  Container(
                    margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isShowingVestCategory = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_isShowingVestCategory
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Tutorial Aplikasi',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !_isShowingVestCategory
                                      ? Colors.black
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _isShowingVestCategory = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _isShowingVestCategory
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Tutorial Rompi',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _isShowingVestCategory
                                      ? Colors.black
                                      : Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Grid content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Column(
                        children: List.generate(rowCount, (rowIndex) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: rowIndex < (rowCount - 1) ? 16.0 : 0.0,
                              ),
                              child: Row(
                                children: [
                                  // Left box
                                  Expanded(
                                    child: (rowIndex * 2 < activeSteps.length)
                                        ? _buildGridBox(rowIndex * 2, boxHeight)
                                        : const SizedBox(),
                                  ),
                                  const SizedBox(width: 18),
                                  // Right box
                                  Expanded(
                                    child:
                                        (rowIndex * 2 + 1 < activeSteps.length)
                                        ? _buildGridBox(
                                            rowIndex * 2 + 1,
                                            boxHeight,
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Close Button
                  Center(
                    child: GestureDetector(
                      onTap: _skipTutorial,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tutup',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(
                              Icons.close_rounded,
                              color: Colors.black,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridBox(int index, double height) {
    final activeSteps = _isShowingVestCategory ? _vestSteps : _appSteps;
    final step = activeSteps[index];
    final bool isHighlighted = step['title'] == 'Bagikan Lokasi';

    // Text layout adjust dynamically based on grid box height
    final double iconSize = height > 130 ? 22.0 : 18.0;
    final double iconBoxSize = height > 130 ? 40.0 : 32.0;
    final double titleFontSize = height > 130 ? 17.5 : 15.0;
    final double descFontSize = height > 130 ? 9.5 : 8.5;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStepIndex = index;
          _currentSubPageIndex = 0;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        });
      },
      child: Container(
        height: height,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isHighlighted
                ? const Color.fromARGB(255, 255, 255, 255)
                : Colors.transparent,
            width: isHighlighted ? 2.5 : 0.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Box (Black Squircle)
            Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: _buildCustomIcon(step['icon'], Colors.white, iconSize),
              ),
            ),
            SizedBox(height: height > 130 ? 10 : 6),
            // Title (wraps downwards if too long)
            Text(
              step['title'],
              style: TextStyle(
                color: Colors.black,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: height > 130 ? 4 : 2),
            // Description (Unique for each box)
            Expanded(
              child: Text(
                step['description'],
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: descFontSize,
                  height: 1.2,
                ),
                maxLines: height > 135 ? 4 : 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailView() {
    final activeSteps = _isShowingVestCategory ? _vestSteps : _appSteps;
    final step = activeSteps[_selectedStepIndex];
    final List<Map<String, dynamic>> subPagesData = step['pages'] != null
        ? (step['pages'] as List<Map<String, dynamic>> Function(BuildContext))(
            context,
          )
        : [];

    int absoluteIndex = _selectedStepIndex;
    if (_isShowingVestCategory) {
      if (_selectedStepIndex == 0) absoluteIndex = 8;
      if (_selectedStepIndex == 1) absoluteIndex = 4;
      if (_selectedStepIndex == 2) absoluteIndex = 6;
    } else {
      if (_selectedStepIndex == 4) absoluteIndex = 5;
      if (_selectedStepIndex == 5) absoluteIndex = 7;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Image container (loads local file with phone mockup fallback)
        Expanded(
          flex: _isShowingVestCategory ? 7 : 5,
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(55)),
            ),
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(42),
              child: Image.asset(
                _isShowingVestCategory
                    ? 'assets/images/tutorial_step_vest_${_selectedStepIndex + 1}.png'
                    : 'assets/images/tutorial_step_app_${_selectedStepIndex + 1}.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback: Display our simulated phone UI mockup so the app runs without crashing
                  return Container(
                    color: Colors.black,
                    child: Stack(
                      children: [
                        // Phone status bar notch mockup
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 28,
                          child: Container(
                            color: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '9:46',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.wifi,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.signal_cellular_4_bar,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.battery_5_bar_sharp,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      '52%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Phone screen content
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 28.0,
                            ), // Below notch
                            child: _buildSimulatedPhoneUI(absoluteIndex),
                          ),
                        ),

                        // Information banner explaining replacement path
                        Positioned(
                          bottom: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              _isShowingVestCategory
                                  ? '💡 Gambar tutorial_step_vest_${_selectedStepIndex + 1}.png belum ditemukan.\nLetakkan gambar Anda di assets/images/tutorial_step_vest_${_selectedStepIndex + 1}.png'
                                  : '💡 Gambar tutorial_step_app_${_selectedStepIndex + 1}.png belum ditemukan.\nLetakkan gambar Anda di assets/images/tutorial_step_app_${_selectedStepIndex + 1}.png',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Info details section
        Expanded(
          flex: _isShowingVestCategory ? 3 : 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + Title Row
                Row(
                  children: [
                    // White rounded square outline
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Center(
                        child: _buildCustomIcon(step['icon'], Colors.black, 26),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        step['title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Bullet points & Description list matching screenshot layout
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentSubPageIndex = index;
                      });
                    },
                    children: subPagesData.map((pageData) {
                      final String description = pageData['description'] ?? '';
                      final List<String> bullets = List<String>.from(
                        pageData['bullets'] ?? [],
                      );

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...List.generate(bullets.length, (bulletIndex) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${bulletIndex + 1}. ',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        bullets[bulletIndex],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.5,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (_isAudioPlaying) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.speaker_phone_rounded,
                          color: Color.fromARGB(255, 255, 74, 0),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '🔊 "Audio deskripsi aktif: Membaca teks panduan..."',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // 3. Dot Page Indicator matching the current tutorial sub-pages
        if (subPagesData.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(subPagesData.length, (dotIndex) {
              final bool isActive = _currentSubPageIndex == dotIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: isActive ? 16.0 : 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.0),
                  color: isActive ? Colors.white : Colors.white24,
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
        ] else ...[
          const SizedBox(height: 22),
        ],

        // 4. Premium Bottom Navigation Row
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Circular outline Back arrow
              GestureDetector(
                onTap: () {
                  if (_currentSubPageIndex > 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _backToRoadmap();
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),

              // White Pill Speaker Button
              GestureDetector(
                onTap: _toggleAudio,
                child: Container(
                  width: 148,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isAudioPlaying
                              ? Icons.volume_up_rounded
                              : Icons.volume_mute_rounded,
                          color: Colors.black,
                          size: 26,
                        ),
                        if (_isAudioPlaying) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: List.generate(4, (index) {
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 1.5,
                                ),
                                width: 3,
                                height: 8 + (index * 4 * _audioWaveHeight),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(1.5),
                                ),
                              );
                            }),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Circular outline Next/Play arrow
              GestureDetector(
                onTap: () {
                  if (_currentSubPageIndex < subPagesData.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _backToRoadmap();
                  }
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(
                      _currentSubPageIndex < subPagesData.length - 1
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.check_rounded,
                      color: Colors.white,
                      size: _currentSubPageIndex < subPagesData.length - 1
                          ? 20
                          : 32,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Draw custom black squircle icons matching reference layout
  Widget _buildCustomIcon(String type, Color color, double size) {
    if (type == 'sos') {
      return Container(
        width: size + 6,
        height: size + 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Text(
            'SOS',
            style: TextStyle(
              color: color,
              fontSize: size * 0.4,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
    } else if (type == 'location') {
      return Icon(Icons.gps_fixed_rounded, color: color, size: size);
    } else if (type == 'floating') {
      return Icon(Icons.grid_view_rounded, color: color, size: size);
    } else if (type == 'settings') {
      return Icon(Icons.settings_rounded, color: color, size: size);
    } else if (type == 'device') {
      // Custom pager/rompi remote widget
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: size * 0.45,
            height: size * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: color, width: 1.8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(width: size * 0.25, height: 1.5, color: color),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 2,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      );
    } else if (type == 'contact') {
      return Icon(Icons.phone_rounded, color: color, size: size);
    } else if (type == 'info') {
      return Text(
        'i',
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
          fontFamily: 'serif',
        ),
      );
    } else if (type == 'account') {
      return Icon(Icons.account_circle_rounded, color: color, size: size);
    } else if (type == 'vest_wear') {
      return Icon(Icons.accessibility_new_rounded, color: color, size: size);
    }
    return Icon(Icons.help_rounded, color: color, size: size);
  }

  // Simulated screens helper
  Widget _buildSimulatedPhoneUI(int index) {
    switch (index) {
      case 0: // SOS Button screen simulation
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 5),
                ),
                child: const Center(
                  child: Text(
                    'SOS',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Address Bar + Share Location Side Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 74, 0),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            'UPI Kampus Cibiru, Jalan BBK Sind...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Time Display
              const Text(
                '21:46:09',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        );
      case 1: // Bagikan Lokasi simulation
        return Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 50,
                        ),
                      ),
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            'Peta Lokasi GPS Aktif',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.share,
                    color: Color.fromARGB(255, 255, 74, 0),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'SOS! Kirim koordinat ke WhatsApp...',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 74, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Kirim',
                      style: TextStyle(color: Colors.white, fontSize: 9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      case 2: // Floating widget simulation
        return Stack(
          children: [
            // Mock home screen launcher background
            Positioned.fill(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.apps, color: Colors.white54, size: 20),
                        Icon(Icons.search, color: Colors.white54, size: 20),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildMockAppIcon(Icons.phone, 'Telepon'),
                        const SizedBox(width: 16),
                        _buildMockAppIcon(Icons.message, 'Pesan'),
                        const SizedBox(width: 16),
                        _buildMockAppIcon(Icons.camera_alt, 'Kamera'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Picture-in-picture floating widget mockup
            Positioned(
              right: 12,
              bottom: 24,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color.fromARGB(255, 255, 74, 0),
                    width: 2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'PiP Netravest',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Sensor: AKTIF',
                      style: TextStyle(color: Colors.green, fontSize: 7),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      case 3: // Settings page simulation
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PENGATURAN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.white24),
              _buildSimulatedSettingTile(
                icon: Icons.touch_app,
                title: 'Jumlah Ketukan SOS',
                value: '5 Kali',
              ),
              _buildSimulatedSettingTile(
                icon: Icons.mic,
                title: 'Durasi Rekaman Darurat',
                value: '30 Detik',
              ),
              _buildSimulatedSettingSwitch(
                icon: Icons.front_hand,
                title: 'Mode Kidal',
                val: false,
              ),
              _buildSimulatedSettingSwitch(
                icon: Icons.gps_fixed,
                title: 'Gunakan GPS Ponsel',
                val: true,
              ),
            ],
          ),
        );
      case 4: // Pair device simulation
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bluetooth_searching,
                color: Color.fromARGB(255, 255, 74, 0),
                size: 40,
              ),
              const SizedBox(height: 12),
              const Text(
                'KONEKSI ROMPI PINTAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white30),
                ),
                child: const Text(
                  'NV-SIMULASI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 74, 0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'HUBUNGKAN',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      case 5: // Add Contact simulation
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'KONTAK DARURAT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 74, 0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '+ Tambah',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildSimulatedContactItem('Polisi', '110', isDefault: true),
              _buildSimulatedContactItem('Ambulans', '118', isDefault: true),
              _buildSimulatedContactItem(
                'Ibu (Kontak Saya)',
                '08123456789',
                isDefault: false,
              ),
            ],
          ),
        );
      case 6: // Vest status panel simulation
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'STATUS ROMPI PINTAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(color: Colors.white24),
              const SizedBox(height: 4),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.7,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSimulatedVestStatusCard(
                      'Baterai',
                      '87%',
                      Icons.battery_charging_full_rounded,
                      Colors.green,
                    ),
                    _buildSimulatedVestStatusCard(
                      'Jaringan',
                      'ONLINE',
                      Icons.cloud_done,
                      Colors.blue,
                    ),
                    _buildSimulatedVestStatusCard(
                      'Kamera',
                      'AKTIF',
                      Icons.videocam,
                      Colors.green,
                    ),
                    _buildSimulatedVestStatusCard(
                      'Sensor LiDAR',
                      'AKTIF',
                      Icons.sensors,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case 7: // User Account Profile Simulation
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 10),
                const Text(
                  'pengguna.baru@netravest.com',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Peran: Tunanetra',
                    style: TextStyle(color: Colors.white70, fontSize: 9),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text(
                    'Keluar Akun',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      case 8: // Vest usage simulation (illustrated)
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.accessibility_new_rounded,
                color: Color.fromARGB(255, 255, 74, 0),
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'PANDUAN FISIK ROMPI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.vibration_rounded,
                          color: Color.fromARGB(255, 255, 74, 0),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Getaran pundak kiri/kanan = rintangan di sisi tersebut.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.power_rounded,
                          color: Colors.greenAccent,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tekan tombol power 3 detik untuk hidup/mati.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  // Simulated widget sub-components
  Widget _buildMockAppIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 7)),
      ],
    );
  }

  Widget _buildSimulatedSettingTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 74, 0),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedSettingSwitch({
    required IconData icon,
    required String title,
    required bool val,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
          Icon(
            val ? Icons.toggle_on : Icons.toggle_off,
            color: val ? const Color.fromARGB(255, 255, 74, 0) : Colors.white30,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedContactItem(
    String name,
    String phone, {
    required bool isDefault,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_circle,
            color: isDefault
                ? Colors.white38
                : const Color.fromARGB(255, 255, 74, 0),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  phone,
                  style: const TextStyle(color: Colors.white54, fontSize: 8),
                ),
              ],
            ),
          ),
          if (!isDefault)
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 14,
            ),
        ],
      ),
    );
  }

  Widget _buildSimulatedVestStatusCard(
    String title,
    String val,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white54, fontSize: 7),
                ),
                Text(
                  val,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw single diagonal line + horizontal connectors
class RoadmapPathPainter extends CustomPainter {
  final double rowHeight;
  final double boxHeight;
  final double yStart;
  final double width;
  final double height;

  RoadmapPathPainter({
    required this.rowHeight,
    required this.boxHeight,
    required this.yStart,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    // Start coordinates for the single diagonal line
    // Goes from top-right to bottom-left
    final Offset start = Offset(width * 0.65, 0);
    final Offset end = Offset(width * 0.05, height + 40);

    canvas.drawLine(start, end, paint);

    // Draw horizontal lines connecting the right-side boxes to the diagonal line
    for (int i = 0; i < 5; i++) {
      final double yCenter = yStart + (i * rowHeight) + (boxHeight / 2);

      // Calculate intersection x of the diagonal line at yCenter
      // Formula: x = start.x - (yCenter - start.y) * (start.x - end.x) / (end.y - start.y)
      final double dx =
          start.dx -
          (yCenter - start.dy) * (start.dx - end.dx) / (end.dy - start.dy);

      // Right box left edge
      final double rightBoxLeft = width * 0.5 - 2;

      canvas.drawLine(
        Offset(rightBoxLeft, yCenter),
        Offset(dx, yCenter),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RoadmapPathPainter oldDelegate) {
    return oldDelegate.rowHeight != rowHeight ||
        oldDelegate.boxHeight != boxHeight ||
        oldDelegate.yStart != yStart ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}
