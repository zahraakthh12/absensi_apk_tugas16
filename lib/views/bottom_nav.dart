import 'package:flutter/material.dart';
import 'package:absensi_apk_tugas16/views/dashboard_attend.dart';
import 'package:absensi_apk_tugas16/views/absensi_screen.dart';
import 'package:absensi_apk_tugas16/views/profile_user.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const DashboardScreen(),
    const AttendancePage(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      // KEHADIRAN DI TENGAH
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () => setState(() => currentIndex = 1),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade400,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.access_time_filled_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 10,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              // HOME (kiri)
              Expanded(
                child: _navItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  label: "Beranda",
                ),
              ),

              // LABEL KEHADIRAN DI TENGAH
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      "Kehadiran",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: currentIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: currentIndex == 1
                            ? Colors.blue.shade900
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              // PROFIL
              Expanded(
                child: _navItem(
                  index: 2,
                  icon: Icons.person_outline,
                  label: "Profil",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET ITEM NAV (HOME & PROFIL)
  Widget _navItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isActive = currentIndex == index;

    return InkWell(
      onTap: () => setState(() => currentIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isActive ? Colors.blue.shade900 : Colors.grey,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.blue.shade900 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
