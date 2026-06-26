import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/emergency_provider.dart';

class DeviceLoginPage extends StatefulWidget {
  const DeviceLoginPage({super.key});

  @override
  State<DeviceLoginPage> createState() => _DeviceLoginPageState();
}

class _DeviceLoginPageState extends State<DeviceLoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _statusMessage = 'Siap menghubungkan';

  // Animasi tekan tombol
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = _scaleController;
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleConnect(
    EmergencyProvider provider, {
    bool simulate = false,
  }) async {
    if (!simulate && !_formKey.currentState!.validate()) {
      return;
    }

    final code = simulate ? 'NV-SIMULASI' : _codeController.text.trim();

    setState(() {
      _statusMessage = simulate
          ? 'Menginisialisasi simulator...'
          : 'Menghubungkan ke broker ${provider.mqttHost}...';
    });

    final success = await provider.connectDevice(code, simulate: simulate);

    if (!mounted) return;

    if (success) {
      provider.showPopupSnackBar(
        context,
        simulate
            ? '⚡ Berhasil masuk ke Mode Simulasi!'
            : '✅ Perangkat $code Terkoneksi!',
        simulate ? Colors.orange : Colors.green,
      );
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      setState(() {
        _statusMessage = 'Gagal menghubungkan. Silakan coba lagi.';
      });
      provider.showPopupSnackBar(
        context,
        '⚠️ Gagal menghubungkan ke perangkat!',
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();
    final isConnecting = provider.isConnectingDevice;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          image: DecorationImage(
            image: AssetImage('assets/images/startup.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Container Kartu Putih Utama untuk login/pairing
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 30.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(55),
                        ),
                        child: _buildLoginForm(context, provider, isConnecting),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    EmergencyProvider provider,
    bool isConnecting,
  ) {
    if (isConnecting) {
      return Column(
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: Color.fromARGB(255, 255, 74, 0),
              strokeWidth: 5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _statusMessage,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Proses ini membutuhkan waktu beberapa saat...',
            style: TextStyle(color: Colors.black54, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Row Header: Teks di Kiri, Icon di Kanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Koneksikan\nperangkat\nAnda',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
              ),
              const Icon(
                Icons.shape_line_rounded,
                size: 60,
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 50),

          // 2. Teks "Masukkan kode Anda"
          const Text(
            'Masukkan kode Anda',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),

          // 3. Input Kode (TextFormField dengan border bulat hitam)
          TextFormField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
            textAlign: TextAlign.center,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: 'Kode perangkat',
              hintStyle: const TextStyle(
                color: Colors.black38,
                fontSize: 20,
                letterSpacing: 0,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(45),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.black, width: 2.5),
                borderRadius: BorderRadius.circular(45),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.redAccent, width: 2),
                borderRadius: BorderRadius.circular(45),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(45),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Kode perangkat wajib diisi';
              }
              if (value.trim().length < 4) {
                return 'Minimal kode adalah 4 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 25),

          // 4. Tombol Hubungkan dengan efek tekan (scale down)

          // 5. Kode Pintas Cepat (Sekarang di dalam card putih)
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.black12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'KODE PINTAS CEPAT',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.black12)),
            ],
          ),
          const SizedBox(height: 12),
          Center(child: _buildShortcutButton('NV-1001')),
          const SizedBox(height: 25),
          GestureDetector(
            onTapDown: (_) => _scaleController.reverse(),
            onTapUp: (_) => _scaleController.forward(),
            onTapCancel: () => _scaleController.forward(),
            onTap: () => _handleConnect(provider),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 50),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 74, 0),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Text(
                  'Hubungkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutButton(String code) {
    return InkWell(
      onTap: () {
        _codeController.text = code;
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          code,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
