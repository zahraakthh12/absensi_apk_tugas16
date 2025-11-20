import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';
import 'package:absensi_apk_tugas16/service/absensi_api.dart';
import 'package:absensi_apk_tugas16/service/api.dart';
import 'package:absensi_apk_tugas16/views/bottom_nav.dart';
import 'package:absensi_apk_tugas16/views/dashboard_attend.dart';
import 'package:absensi_apk_tugas16/views/regist_screen.dart';
import 'package:absensi_apk_tugas16/widgets/login_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreenDay33 extends StatefulWidget {
  const LoginScreenDay33({super.key});
  static const id = "/login_screen18";

  @override
  State<LoginScreenDay33> createState() => _LoginScreenDay33State();
}

class _LoginScreenDay33State extends State<LoginScreenDay33>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isVisibility = false;
  bool emailFocus = false;
  bool passFocus = false;

  final _formKey = GlobalKey<FormState>();

  // ANIMATION
  late AnimationController _logoController;
  late Animation<double> _fadeLogo;
  late Animation<double> _scaleLogo;

  @override
  void initState() {
    super.initState();

    // LOGO ANIMATION — lembut & premium
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeLogo = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);

    _scaleLogo = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [buildBackground(), buildLayer()]));
  }

  // ===========================================================
  // BACKGROUND GRADIENT BIRU PASTEL
  // ===========================================================
  Container buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFB5D8FF), Color(0xFFDCEFFF), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // ===========================================================
  // MAIN LAYER LOGIN
  // ===========================================================
  SafeArea buildLayer() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // ========================== LOGO ==========================
              FadeTransition(
                opacity: _fadeLogo,
                child: ScaleTransition(
                  scale: _scaleLogo,
                  child: Image.asset(
                    "assets/images/sipresensi.png",
                    width: 120,
                    height: 120,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ======================== TITLE =========================
              const Text(
                "Selamat Datang!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Masuk untuk melanjutkan",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 32),

              // ====================== CARD LOGIN ======================
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 26,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildTitle("Alamat Email"),
                      const SizedBox(height: 10),
                      animatedTextField(
                        controller: emailController,
                        hint: "Masukkan email Anda",
                        focus: emailFocus,
                        icon: Icons.email_outlined,
                        onFocusChange: (v) => setState(() => emailFocus = v),
                        validator: validateEmail,
                      ),

                      const SizedBox(height: 18),

                      buildTitle("Kata Sandi"),
                      const SizedBox(height: 10),
                      animatedTextField(
                        controller: passwordController,
                        hint: "Masukkan kata sandi",
                        isPassword: true,
                        focus: passFocus,
                        icon: Icons.lock_outline,
                        onFocusChange: (v) => setState(() => passFocus = v),
                        validator: validatePassword,
                      ),

                      const SizedBox(height: 5),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Lupa Password?",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // LOGIN BUTTON
                      LoginButton(
                        text: "Masuk",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            await handleLogin();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ======================== REGISTER LINK ========================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Belum punya akun?",
                    style: TextStyle(fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreenDay34(),
                        ),
                      );
                    },
                    child: Text(
                      "Daftar",
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================
  // LOGIN LOGIC
  // ===========================================================
  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await AuthAPI.loginUser(
        email: emailController.text,
        password: passwordController.text,
      );

      await PreferenceHandler.saveToken(result.data!.token!);
      await PreferenceHandler.saveLogin(true);
      await PreferenceHandler.saveName(result.data!.user!.name ?? "");

      final profile = await AbsensiAPI.getProfile();
      await PreferenceHandler.savePhoto(profile.data?.profilePhoto ?? "");

      Fluttertoast.showToast(msg: "Login Berhasil");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Email atau password salah");
    }
  }

  // ===========================================================
  // VALIDATOR
  // ===========================================================
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Email tidak boleh kosong";
    if (!value.contains('@')) return "Email tidak valid";
    if (!RegExp(
      r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
    ).hasMatch(value)) {
      return "Format Email tidak valid";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Password tidak boleh kosong";
    if (value.length < 6) return "Minimal 6 karakter";
    return null;
  }

  // ===========================================================
  // UI REUSABLE
  // ===========================================================
  Widget buildTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  // TEXTFIELD ANIMASI GLOW
  Widget animatedTextField({
    required TextEditingController controller,
    required String hint,
    required bool focus,
    required Function(bool) onFocusChange,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: EdgeInsets.only(bottom: focus ? 4 : 0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: focus
                ? Colors.blue.shade200.withOpacity(0.55)
                : Colors.transparent,
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(20),
      ),
      child: FocusScope(
        child: Focus(
          onFocusChange: onFocusChange,
          child: TextFormField(
            controller: controller,
            validator: validator,
            obscureText: isPassword ? !isVisibility : false,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue.shade600),
              hintText: hint,
              filled: true,
              fillColor: Colors.blue.shade50,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isVisibility ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blue.shade700,
                      ),
                      onPressed: () {
                        setState(() => isVisibility = !isVisibility);
                      },
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}
