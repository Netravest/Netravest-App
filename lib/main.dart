import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'providers/emergency_provider.dart';
import 'pages/homepage_emergency.dart';
import 'pages/homepage_companion.dart';
import 'pages/device_login_page.dart';
import 'pages/user_login_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await GoogleSignIn.instance.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (context) => EmergencyProvider(),
      child: const NetravestApp(),
    ),
  );
}

class NetravestApp extends StatelessWidget {
  const NetravestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color.fromARGB(255, 255, 74, 0),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const UserLoginPage();
          }

          return Consumer<EmergencyProvider>(
            builder: (context, provider, child) {
              if (provider.deviceCode.isEmpty) {
                return const DeviceLoginPage();
              }
              if (provider.userRole == 'pendamping') {
                return const BerandaPendamping();
              }
              return const BerandaEmergency();
            },
          );
        },
      ),
    );
  }
}
