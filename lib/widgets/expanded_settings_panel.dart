import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/emergency_provider.dart';
import '../pages/tutorial_page.dart';

class ExpandedSettingsPanel extends StatelessWidget {
  const ExpandedSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmergencyProvider>();

    return Container(
      key: const ValueKey('settings_expanded'),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.settings_suggest_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Pengaturan',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () => provider.toggleSettingsExpansion(),
              ),
            ],
          ),

          // Scrollable Settings Box Area (3-Column Grid)
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // 4-Tile Grid (3 columns)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.5,
                  children: [
                    // 1. Ketukan SOS (Cycle)
                    _buildSettingBoxTile(
                      icon: Icons.touch_app_rounded,
                      label: 'Ketukan SOS',
                      isActive: false,

                      statusWidget: Text(
                        '${provider.sosTapThreshold}X',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 255, 74, 0),
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                      onTap: () {
                        final options = [3, 5, 8, 10];
                        final index = options.indexOf(provider.sosTapThreshold);
                        final nextValue = options[(index + 1) % options.length];
                        provider.setSosTapThreshold(nextValue);
                        provider.showPopupSnackBar(
                          context,
                          '🎯 Ketukan SOS disetel ke: $nextValue kali',
                          Colors.green,
                        );
                      },
                    ),

                    // 3. Sumber Lokasi HP (Toggle)
                    _buildSettingBoxTile(
                      icon: Icons.gps_fixed_rounded,
                      label: 'Lokasi HP',
                      isActive: provider.usePhoneGps,
                      onTap: () {
                        final nextVal = !provider.usePhoneGps;
                        provider.toggleUsePhoneGps(nextVal, context);
                      },
                    ),

                    // 4. Mode Kidal (Toggle)
                    _buildSettingBoxTile(
                      icon: Icons.front_hand_rounded,
                      label: 'Mode Kidal',
                      isActive: provider.isLeftHanded,
                      onTap: () {
                        final nextVal = !provider.isLeftHanded;
                        provider.toggleLeftHanded(nextVal);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 5. Panduan Tutorial — Full-width button
                _buildSettingBoxTile(
                  icon: Icons.menu_book_rounded,
                  label: 'Panduan Tutorial',
                  isActive: false,
                  isFullWidth: true,
                  customColor: const Color(0xFF1A1A2E),
                  onTap: () {
                    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TutorialPage(userId: userId),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),
                const Divider(color: Colors.black12, thickness: 1),
                const SizedBox(height: 12),

                // Bottom Side-by-Side Action Buttons
                Row(
                  children: [
                    // Reset Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.red[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          provider.resetSettings();
                          provider.showPopupSnackBar(
                            context,
                            '🔄 Pengaturan berhasil di-reset!',
                            Colors.green,
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.restore_rounded, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Reset',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sign Out Button
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () async {
                          provider.toggleSettingsExpansion();
                          provider.disconnectDevice();
                          await FirebaseAuth.instance.signOut();
                          await GoogleSignIn.instance.signOut();
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Keluar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
  }

  // Box Item Template (Icon + Label + Status Badge)
  Widget _buildSettingBoxTile({
    required IconData icon,
    required String label,
    required bool isActive,
    Widget? statusWidget,
    VoidCallback? onTap,
    double iconSize = 60,
    bool isFullWidth = false,
    Color? customColor,
  }) {
    final color =
        customColor ??
        (isActive
            ? const Color.fromARGB(255, 255, 74, 0)
            : const Color(0xFFF5F5F5));
    final contentColor = (customColor != null || isActive)
        ? Colors.white
        : Colors.black87;

    if (isFullWidth) {
      return SizedBox(
        height: 150,
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            splashColor: Colors.white24,
            highlightColor: Colors.white12,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: contentColor, size: iconSize),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color.fromARGB(76, 255, 74, 0),
        highlightColor: const Color.fromARGB(25, 255, 74, 0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: contentColor, size: iconSize),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: contentColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (statusWidget != null) ...[
                const SizedBox(height: 5),
                statusWidget,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
