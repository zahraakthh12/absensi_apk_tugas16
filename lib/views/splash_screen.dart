import 'dart:async';
import 'package:flutter/material.dart';
import 'package:absensi_apk_tugas16/views/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _fadeLogo;
  late Animation<double> _scaleLogo;

  late AnimationController _loadingController;
  late Animation<double> _dot1;
  late Animation<double> _dot2;
  late Animation<double> _dot3;

  @override
  void initState() {
    super.initState();

    // ====================== LOGO ANIMATION =========================
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeLogo = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    );

    _scaleLogo = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoController.forward();

    // ====================== LOADING DOTS ===========================
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _dot1 = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    _dot2 = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _dot3 = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    // ====================== NAVIGATE ================================
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreenDay33()),
      );
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB5D8FF), Color(0xFFDCEFFF), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fadeLogo,
                    child: ScaleTransition(
                      scale: _scaleLogo,
                      child: Image.asset(
                        "assets/images/sipresensi1.png",
                        width: 170,
                        height: 170,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Loading dots cute
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _dot1.value),
                          child: dot(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _dot2.value),
                          child: dot(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _dot3.value),
                          child: dot(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 35,
              left: 0,
              right: 0,
              child: Text(
                "Created by Zahra Khotimah",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withOpacity(0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dot() {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Color(0xFF6CA6E8),
        shape: BoxShape.circle,
      ),
    );
  }
}
