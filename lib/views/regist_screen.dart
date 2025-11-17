import 'dart:convert';
import 'dart:io';

import 'package:absensi_apk_tugas16/extensions/navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:absensi_apk_tugas16/models/batch_model.dart';
import 'package:absensi_apk_tugas16/models/regist_model.dart';
import 'package:absensi_apk_tugas16/models/training_model.dart';
import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';
import 'package:absensi_apk_tugas16/service/api.dart';
import 'package:absensi_apk_tugas16/views/login_screen.dart';
import 'package:absensi_apk_tugas16/widgets/login_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterScreenDay34 extends StatefulWidget {
  const RegisterScreenDay34({super.key});
  static const id = "/register_day34";

  @override
  State<RegisterScreenDay34> createState() => _RegisterScreenDay34State();
}

class _RegisterScreenDay34State extends State<RegisterScreenDay34> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isVisibility = false;
  bool isLoading = false;
  bool isLoadingDropdown = false;

  // Fokus animasi TextField
  bool emailFocus = false;
  bool passFocus = false;
  bool nameFocus = false;

  // Fokus animasi Dropdown
  bool isGenderFocused = false;
  bool isTrainingFocused = false;
  bool isBatchFocused = false;

  RegisterModel user = RegisterModel();
  final _formKey = GlobalKey<FormState>();

  String? selectedGender;
  int? selectedTrainingId;
  int? selectedBatchId;

  List<TrainingModelData> trainings = [];
  List<BatchModelData> batches = [];

  File? _pickedImageFile;
  String? _profilePhotoBase64;

  final List<Map<String, String>> genderOptions = const [
    {"label": "Laki-laki", "value": "L"},
    {"label": "Perempuan", "value": "P"},
  ];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      final XFile? picked = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      final ext = picked.path.split('.').last.toLowerCase();
      String mime = (ext == 'png') ? "png" : "jpeg";

      final base64Str = base64Encode(bytes);
      final dataUri = 'data:image/$mime;base64,$base64Str';

      setState(() {
        _pickedImageFile = File(picked.path);
        _profilePhotoBase64 = dataUri;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memilih gambar: $e");
    }
  }

  Future<void> _loadDropdownData() async {
    setState(() => isLoadingDropdown = true);

    try {
      final trainingList = await TrainingAPI.getTrainings();
      final batchList = await TrainingAPI.getTrainingBatches();

      setState(() {
        trainings = trainingList;
        batches = batchList;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat data dropdown");
    }

    setState(() => isLoadingDropdown = false);
  }

  /// REGISTER BUTTON
  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGender == null ||
        selectedTrainingId == null ||
        selectedBatchId == null) {
      Fluttertoast.showToast(msg: "Semua field wajib diisi.");
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await AuthAPI.registerUser(
        email: emailController.text.trim(),
        name: nameController.text.trim(),
        password: passwordController.text,
        jenisKelamin: selectedGender!,
        batchId: selectedBatchId!,
        trainingId: selectedTrainingId!,
        profilePhoto: _profilePhotoBase64 ?? "",
      );

      user = result;

      if (user.data?.token != null) {
        await PreferenceHandler.saveToken(user.data!.token!);
      }

      setState(() => isLoading = false);

      Fluttertoast.showToast(msg: "Registrasi Berhasil 🎉");
      context.pushReplacement(LoginScreenDay33());
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Stack(children: [buildBackground(), buildLayer()]));
  }

  // GRADIENT BIRU PASTEL
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

  // MAIN LAYER
  SafeArea buildLayer() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Column(
          children: [
            const Text(
              "Buat Akun Baru",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Daftar untuk melanjutkan",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 30),

            // CARD UI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade100.withOpacity(0.4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // FOTO PROFIL
                    GestureDetector(
                      onTap: _pickImage,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade300,
                                  Colors.blue.shade100,
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                              backgroundImage: _pickedImageFile != null
                                  ? FileImage(_pickedImageFile!)
                                  : null,
                              child: _pickedImageFile == null
                                  ? Icon(
                                      Icons.camera_alt,
                                      color: Colors.blue.shade600,
                                      size: 32,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _pickedImageFile == null
                                ? "Tambah Foto Profil"
                                : "Ganti Foto Profil",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // EMAIL
                    buildTitle("Alamat Email"),
                    const SizedBox(height: 10),
                    animatedTextField(
                      controller: emailController,
                      hint: "Masukkan email Anda",
                      icon: Icons.email_outlined,
                      focus: emailFocus,
                      onFocusChange: (v) => setState(() => emailFocus = v),
                      validator: (v) => v == null || v.isEmpty
                          ? "Email tidak boleh kosong"
                          : (!v.contains("@")
                                ? "Format email tidak valid"
                                : null),
                    ),

                    const SizedBox(height: 18),

                    // PASSWORD
                    buildTitle("Kata Sandi"),
                    const SizedBox(height: 10),
                    animatedTextField(
                      controller: passwordController,
                      hint: "Masukkan kata sandi",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      focus: passFocus,
                      onFocusChange: (v) => setState(() => passFocus = v),
                      validator: (v) => v == null || v.isEmpty
                          ? "Kata sandi tidak boleh kosong"
                          : (v.length < 6 ? "Minimal 6 karakter" : null),
                    ),

                    const SizedBox(height: 18),

                    // NAME
                    buildTitle("Nama Lengkap"),
                    const SizedBox(height: 10),
                    animatedTextField(
                      controller: nameController,
                      hint: "Masukkan nama lengkap",
                      icon: Icons.person_outline,
                      focus: nameFocus,
                      onFocusChange: (v) => setState(() => nameFocus = v),
                      validator: (v) => v == null || v.isEmpty
                          ? "Nama tidak boleh kosong"
                          : null,
                    ),

                    const SizedBox(height: 18),

                    // GENDER DROPDOWN
                    buildTitle("Jenis Kelamin"),
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: dropdownAnimatedDecoration(isGenderFocused),
                      child: DropdownButtonFormField<String>(
                        value: selectedGender,
                        isExpanded: true,
                        decoration: dropdownNoBorder(),
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.blue.shade700,
                          size: 26,
                        ),
                        items: genderOptions
                            .map(
                              (g) => DropdownMenuItem(
                                value: g["value"],
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      color: Colors.blue.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(g["label"]!),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onTap: () => setState(() => isGenderFocused = true),
                        onChanged: (v) {
                          setState(() {
                            selectedGender = v;
                            isGenderFocused = false;
                          });
                        },
                        validator: (v) =>
                            v == null ? "Pilih jenis kelamin" : null,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // TRAINING DROPDOWN
                    buildTitle("Program Pelatihan"),
                    const SizedBox(height: 10),
                    isLoadingDropdown
                        ? const CircularProgressIndicator()
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: dropdownAnimatedDecoration(
                              isTrainingFocused,
                            ),
                            child: DropdownButtonFormField<int>(
                              value: selectedTrainingId,
                              isExpanded: true,
                              decoration: dropdownNoBorder(),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.blue.shade700,
                                size: 26,
                              ),
                              items: trainings
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t.id,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.school_outlined,
                                            color: Colors.blue.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(t.title ?? ""),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onTap: () =>
                                  setState(() => isTrainingFocused = true),
                              onChanged: (v) {
                                setState(() {
                                  selectedTrainingId = v;
                                  isTrainingFocused = false;
                                });
                              },
                              validator: (v) =>
                                  v == null ? "Pilih program pelatihan" : null,
                            ),
                          ),

                    const SizedBox(height: 18),

                    // BATCH DROPDOWN
                    buildTitle("Batch Pelatihan"),
                    const SizedBox(height: 10),
                    isLoadingDropdown
                        ? const CircularProgressIndicator()
                        : AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            decoration: dropdownAnimatedDecoration(
                              isBatchFocused,
                            ),
                            child: DropdownButtonFormField<int>(
                              value: selectedBatchId,
                              isExpanded: true,
                              decoration: dropdownNoBorder(),
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.blue.shade700,
                                size: 26,
                              ),
                              items: batches
                                  .map(
                                    (b) => DropdownMenuItem(
                                      value: b.id,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.date_range_outlined,
                                            color: Colors.blue.shade700,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text("Batch ${b.batchKe}"),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onTap: () =>
                                  setState(() => isBatchFocused = true),
                              onChanged: (v) {
                                setState(() {
                                  selectedBatchId = v;
                                  isBatchFocused = false;
                                });
                              },
                              validator: (v) =>
                                  v == null ? "Pilih batch pelatihan" : null,
                            ),
                          ),

                    const SizedBox(height: 28),

                    // BUTTON REGISTER
                    LoginButton(
                      text: "Daftar",
                      isLoading: isLoading,
                      onPressed: _onRegisterPressed,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // SIGN IN LINK
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Sudah punya akun? "),
                TextButton(
                  onPressed: () => context.pushReplacement(LoginScreenDay33()),
                  child: Text(
                    "Masuk",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Judul Field
  Widget buildTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  // Textfield animasi dan icon
  Widget animatedTextField({
    required TextEditingController controller,
    required String hint,
    required bool focus,
    required Function(bool) onFocusChange,
    IconData? icon,
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
            decoration: InputDecoration(
              prefixIcon: icon != null
                  ? Icon(icon, color: Colors.blue.shade700)
                  : null,
              hintText: hint,
              filled: true,
              fillColor: Colors.blue.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: () =>
                          setState(() => isVisibility = !isVisibility),
                      icon: Icon(
                        isVisibility ? Icons.visibility_off : Icons.visibility,
                        color: Colors.blue.shade700,
                      ),
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }

  // Dropdown Animasi
  BoxDecoration dropdownAnimatedDecoration(bool isFocused) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: LinearGradient(
        colors: [
          isFocused ? Colors.blue.shade200 : Colors.blue.shade50,
          isFocused ? Colors.blue.shade100 : Colors.blue.shade50,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          blurRadius: isFocused ? 12 : 4,
          spreadRadius: isFocused ? 1 : 0,
          color: Colors.blue.shade200.withOpacity(isFocused ? 0.6 : 0.2),
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  InputDecoration dropdownNoBorder() {
    return const InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    );
  }
}
