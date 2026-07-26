import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserLoginPage extends StatefulWidget {
  const UserLoginPage({super.key});

  @override
  State<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUpMode = false;
  bool _isLoading = false;
  String _errorMessage = '';

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
    _emailController.dispose();
    _passwordController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Future<void> _handleEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_isSignUpMode) {
        // Register
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _showSnackBar('🎉 Akun berhasil didaftarkan!', Colors.green);
      } else {
        // Login
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _showSnackBar('👋 Selamat datang kembali!', Colors.green);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFriendlyErrorMessage(e.code);
      });
      _showSnackBar(_errorMessage, Colors.redAccent);
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan sistem: $e';
      });
      _showSnackBar(_errorMessage, Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      _showSnackBar('🚀 Masuk menggunakan Akun Google!', Colors.green);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = _getFriendlyErrorMessage(e.code);
      });
      _showSnackBar(_errorMessage, Colors.redAccent);
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung dengan Google. Silakan periksa koneksi Anda.';
      });
      _showSnackBar(_errorMessage, Colors.redAccent);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFriendlyErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'user-not-found':
        return 'Pengguna tidak ditemukan. Silakan daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Kata sandi salah. Silakan coba lagi.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar dengan akun lain.';
      case 'operation-not-allowed':
        return 'Metode masuk ini belum diaktifkan.';
      case 'weak-password':
        return 'Kata sandi terlalu lemah. Gunakan minimal 6 karakter.';
      case 'network-request-failed':
        return 'Koneksi jaringan gagal. Harap periksa koneksi internet Anda.';
      default:
        return 'Autentikasi gagal: $code';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      // Card Putih Utama
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 30.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(55),
                        ),
                        child: _isLoading
                            ? _buildLoadingState()
                            : _buildAuthForm(),
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

  Widget _buildLoadingState() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20),
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 255, 74, 0),
            strokeWidth: 5,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Mengautentikasi...',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'Harap tunggu sebentar...',
          style: TextStyle(color: Colors.black54, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Teks & Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  _isSignUpMode ? 'Daftar\nAkun baru' : 'Selamat\ndatang',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
              ),
              const Icon(
                Icons.account_circle_rounded,
                size: 60,
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Switcher Mode (Masuk / Daftar)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(35),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSignUpMode = false;
                        _errorMessage = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_isSignUpMode
                            ? const Color.fromARGB(255, 255, 74, 0)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Masuk',
                        style: TextStyle(
                          color: !_isSignUpMode ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSignUpMode = true;
                        _errorMessage = '';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _isSignUpMode
                            ? const Color.fromARGB(255, 255, 74, 0)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Daftar',
                        style: TextStyle(
                          color: _isSignUpMode ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Input Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
              hintText: 'Email Anda',
              hintStyle: const TextStyle(color: Colors.black38),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
                borderRadius: BorderRadius.circular(45),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email wajib diisi';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                return 'Format email tidak valid';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Input Password
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.black, fontSize: 16),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.black54),
              hintText: 'Kata Sandi',
              hintStyle: const TextStyle(color: Colors.black38),
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
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
                borderSide: const BorderSide(color: Colors.redAccent, width: 2.5),
                borderRadius: BorderRadius.circular(45),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi wajib diisi';
              }
              if (value.length < 6) {
                return 'Kata sandi minimal 6 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Error Message Display
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                _errorMessage,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // Tombol Utama (Masuk / Daftar)
          GestureDetector(
            onTapDown: (_) => _scaleController.reverse(),
            onTapUp: (_) => _scaleController.forward(),
            onTapCancel: () => _scaleController.forward(),
            onTap: _handleEmailAuth,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 74, 0),
                  borderRadius: BorderRadius.circular(45),
                ),
                child: Text(
                  _isSignUpMode ? 'Daftar Sekarang' : 'Masuk',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Divider Pilihan Lain
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.black12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'ATAU MASUK DENGAN',
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
          const SizedBox(height: 16),

          // Tombol Google Sign-in
          OutlinedButton.icon(
            icon: Image.network(
              'https://developers.google.com/identity/images/g-logo.png',
              height: 24,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.login_rounded,
                color: Colors.black87,
              ),
            ),
            label: const Text(
              'Akun Google',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.black26, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(45),
              ),
            ),
            onPressed: _handleGoogleSignIn,
          ),
        ],
      ),
    );
  }
}
