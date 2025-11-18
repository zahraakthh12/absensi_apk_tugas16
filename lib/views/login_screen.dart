import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';
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

class _LoginScreenDay33State extends State<LoginScreenDay33> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isVisibility = false;

  // Fokus animasi textfield
  bool emailFocus = false;
  bool passFocus = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [buildBackground(), buildLayer()]));
  }

  // BACKGROUND GRADIENT BIRU PASTEL
  Container buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB5D8FF),
            const Color(0xFFDCEFFF),
            Colors.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  // MAIN LAYER LOGIN
  SafeArea buildLayer() {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // TITLE
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

              const SizedBox(height: 35),

              // CARD LOGIN
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
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

                      const SizedBox(height: 5),

                      // LOGIN BUTTON
                      LoginButton(
                        text: "Masuk",
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              final result = await AuthAPI.loginUser(
                                email: emailController.text,
                                password: passwordController.text,
                              );

                              await PreferenceHandler.saveToken(
                                result.data!.token!,
                              );
                              await PreferenceHandler.saveLogin(true);

                              // NOTIFIKASI LOGIN BERHASIL
                              Fluttertoast.showToast(
                                msg: "Login Berhasil",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  170,
                                  201,
                                  171,
                                ),
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );

                              // NAVIGASI
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainNavigation(),
                                ),
                              );
                            } catch (e) {
                              Fluttertoast.showToast(
                                msg: "Email atau password salah",
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  192,
                                  151,
                                  150,
                                ),
                                textColor: Colors.white,
                                gravity: ToastGravity.TOP,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // REGISTER LINK
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

  // HANDLE LOGIN LOGIC
  Future<void> handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await AuthAPI.loginUser(
        email: emailController.text,
        password: passwordController.text,
      );

      // SIMPAN TOKEN
      await PreferenceHandler.saveToken(result.data!.token!);

      // SIMPAN STATUS LOGIN
      await PreferenceHandler.saveLogin(true);

      // SIMPAN NAMA USER
      await PreferenceHandler.saveName(result.data!.user!.name ?? "");

      Fluttertoast.showToast(msg: "Login Berhasil");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Email atau password salah");
    }
  }

  // VALIDATOR
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

  // UI REUSABLE
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
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.only(bottom: focus ? 4 : 0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: focus
                ? Colors.blue.shade200.withOpacity(0.6)
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
                vertical: 14,
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
