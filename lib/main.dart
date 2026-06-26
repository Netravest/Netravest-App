import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/emergency_provider.dart';
import 'pages/homepage_emergency.dart';
import 'pages/device_login_page.dart';

void main() {
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
      home: Consumer<EmergencyProvider>(
        builder: (context, provider, child) {
          if (provider.deviceCode.isEmpty) {
            return const DeviceLoginPage();
          }
          return const BerandaEmergency();
        },
      ),
    );
  }
}
