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

  RegisterModel user = RegisterModel();
  final _formKey = GlobalKey<FormState>();

  // Gender (L / P)
  String? selectedGender;

  // Training & Batch
  int? selectedTrainingId;
  int? selectedBatchId;

  List<TrainingModelData> trainings = [];
  List<BatchModelData> batches = [];

  // Foto Profil
  File? _pickedImageFile;
  String? _profilePhotoBase64;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  // PICK IMAGE
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

  // LOAD TRAINING & BATCH
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

  // REGISTER USER
  Future<void> _onRegisterPressed() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedGender == null ||
        selectedTrainingId == null ||
        selectedBatchId == null) {
      Fluttertoast.showToast(
        msg: "Jenis kelamin, program pelatihan, dan batch wajib dipilih.",
      );
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

  // BACKGROUND GRADIENT
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

            //== CARD PUTIH==
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

                    // NAMA
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

                    const SizedBox(height: 20),

                    // JENIS KELAMIN
                    buildTitle("Jenis Kelamin"),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // LAKI-LAKI
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedGender = "L");
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: selectedGender == "L"
                                      ? [
                                          Colors.blue.shade300,
                                          Colors.blue.shade100,
                                        ]
                                      : [
                                          Colors.blue.shade50,
                                          Colors.blue.shade50,
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedGender == "L"
                                        ? Colors.blue.shade200.withOpacity(0.6)
                                        : Colors.transparent,
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: selectedGender == "L"
                                      ? Colors.blue.shade600
                                      : Colors.blue.shade100,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.male_rounded,
                                    size: 38,
                                    color: selectedGender == "L"
                                        ? Colors.white
                                        : Colors.blue.shade600,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Laki-laki",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: selectedGender == "L"
                                          ? Colors.white
                                          : Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // PEREMPUAN
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedGender = "P");
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                gradient: LinearGradient(
                                  colors: selectedGender == "P"
                                      ? [
                                          Colors.pink.shade300,
                                          Colors.pink.shade100,
                                        ]
                                      : [
                                          Colors.blue.shade50,
                                          Colors.blue.shade50,
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: selectedGender == "P"
                                        ? Colors.pink.shade200.withOpacity(0.6)
                                        : Colors.transparent,
                                    blurRadius: 12,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(
                                  color: selectedGender == "P"
                                      ? Colors.pink.shade600
                                      : Colors.blue.shade100,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.female_rounded,
                                    size: 38,
                                    color: selectedGender == "P"
                                        ? Colors.white
                                        : Colors.pink.shade600,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Perempuan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: selectedGender == "P"
                                          ? Colors.white
                                          : Colors.pink.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // PROGRAM PELATIHAN (BOTTOM SHEET)
                    buildTitle("Program Pelatihan"),
                    const SizedBox(height: 10),
                    isLoadingDropdown
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: selectTraining,
                            child: buildSelectBox(
                              label: _getTrainingLabel(),
                              icon: Icons.school_outlined,
                            ),
                          ),

                    const SizedBox(height: 20),

                    // BATCH (BOTTOM SHEET)
                    buildTitle("Batch Pelatihan"),
                    const SizedBox(height: 10),
                    isLoadingDropdown
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: selectBatch,
                            child: buildSelectBox(
                              label: _getBatchLabel(),
                              icon: Icons.date_range_outlined,
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

            // SIGN IN
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

  // TITLE FIELD
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

  // TEXTFIELD ANIMASI
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
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.blue.shade700),
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

  // SELECT BOX (UNTUK BOTTOM SHEET)
  Widget buildSelectBox({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.blue.shade50,
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.blue.shade900),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 26,
            color: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  // LABEL HELPER
  String _getTrainingLabel() {
    if (selectedTrainingId == null) return "Pilih Program Pelatihan";
    if (trainings.isEmpty) return "Pilih Program Pelatihan";

    final item = trainings.firstWhere(
      (e) => e.id == selectedTrainingId,
      orElse: () => trainings.first,
    );
    return item.title ?? "Pilih Program Pelatihan";
  }

  String _getBatchLabel() {
    if (selectedBatchId == null) return "Pilih Batch Pelatihan";
    if (batches.isEmpty) return "Pilih Batch Pelatihan";

    final item = batches.firstWhere(
      (e) => e.id == selectedBatchId,
      orElse: () => batches.first,
    );
    return "Batch ${item.batchKe}";
  }

  // BOTTOM SHEET TRAINING
  Future<void> selectTraining() async {
    if (trainings.isEmpty) {
      Fluttertoast.showToast(msg: "Data pelatihan belum tersedia");
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Pilih Program Pelatihan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: trainings.length,
                      itemBuilder: (_, i) {
                        final item = trainings[i];
                        final isSelected = item.id == selectedTrainingId;
                        return ListTile(
                          leading: Icon(
                            Icons.school,
                            color: Colors.blue.shade700,
                          ),
                          title: Text(item.title ?? ""),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.blue.shade600,
                                )
                              : null,
                          onTap: () {
                            setState(() => selectedTrainingId = item.id);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // BOTTOM SHEET BATCH
  Future<void> selectBatch() async {
    if (batches.isEmpty) {
      Fluttertoast.showToast(msg: "Data batch belum tersedia");
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Pilih Batch Pelatihan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: batches.length,
                      itemBuilder: (_, i) {
                        final item = batches[i];
                        final isSelected = item.id == selectedBatchId;
                        return ListTile(
                          leading: Icon(
                            Icons.date_range_outlined,
                            color: Colors.blue.shade700,
                          ),
                          title: Text("Batch ${item.batchKe}"),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.blue.shade600,
                                )
                              : null,
                          onTap: () {
                            setState(() => selectedBatchId = item.id);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
