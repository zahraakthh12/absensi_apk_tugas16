// ===========================================================
//                  PROFILE SCREEN – MODERN UI
// ===========================================================

import 'package:absensi_apk_tugas16/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:absensi_apk_tugas16/models/profile_model.dart';
import 'package:absensi_apk_tugas16/service/absensi_api.dart';
import 'package:absensi_apk_tugas16/preferences/preference_handler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  Data? user;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // LOAD USER
  Future<void> loadProfile() async {
    try {
      final res = await AbsensiAPI.getProfile();
      user = res.data;
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat profil");
    }
    setState(() => loading = false);
  }

  // LOGOUT
  Future<void> _logout() async {
    await PreferenceHandler.clearAll();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreenDay33()),
      (_) => false,
    );
  }

  // POPUP KONFIRMASI
  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Ya, Logout"),
          ),
        ],
      ),
    );
  }

  // POPUP EDIT PROFIL
  Future<void> _showEditDialog() async {
    final nameC = TextEditingController(text: user?.name ?? "");

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: Material(
          color: Colors.black.withOpacity(0.25),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Edit Profil",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                // FIELD NAMA
                const Text("Nama Lengkap"),
                const SizedBox(height: 6),
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.blue.shade600,
                        width: 1.3,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // READONLY
                _readonlyField("Email", user?.email ?? "-"),
                _readonlyField("Jenis Kelamin", user?.jenisKelamin ?? "-"),
                _readonlyField("Batch Ke", user?.batchKe ?? "-"),
                _readonlyField("Pelatihan", user?.trainingTitle ?? "-"),

                const SizedBox(height: 26),

                // BUTTON
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Batal",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (nameC.text.trim().isEmpty) {
                          Fluttertoast.showToast(
                            msg: "Nama tidak boleh kosong",
                          );
                          return;
                        }

                        try {
                          await AbsensiAPI.editProfile(name: nameC.text.trim());
                          Fluttertoast.showToast(
                            msg: "Profil berhasil diperbarui",
                          );

                          Navigator.pop(context);
                          loadProfile();
                        } catch (e) {
                          Fluttertoast.showToast(msg: "Gagal memperbarui");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        child: Text(
                          "Simpan",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // FIELD READONLY
  Widget _readonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(child: Text(value)),
                Icon(Icons.lock, color: Colors.grey.shade500, size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MAIN UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9F2FF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // AVATAR
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: Colors.blue.shade100,
                    backgroundImage: user?.profilePhoto != null
                        ? NetworkImage(user!.profilePhoto!)
                        : null,
                    child: user?.profilePhoto == null
                        ? Text(
                            (user?.name?[0] ?? "-").toUpperCase(),
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    user?.name ?? "-",
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    user?.email ?? "-",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 30),

                  // INFO
                  _infoTile("Batch Ke", user?.batchKe ?? "-"),
                  _infoTile("Pelatihan", user?.trainingTitle ?? "-"),
                  _infoTile("Jenis Kelamin", user?.jenisKelamin ?? "-"),

                  const SizedBox(height: 28),

                  // MENU
                  _menuItem(
                    icon: Icons.edit,
                    label: "Edit Profil",
                    bg: Colors.blue.shade50,
                    color: Colors.blue.shade700,
                    onTap: _showEditDialog,
                  ),
                  _menuItem(
                    icon: Icons.logout,
                    label: "Logout",
                    bg: Colors.red.shade50,
                    color: Colors.red.shade700,
                    onTap: () async {
                      final confirm = await _showConfirmDialog(
                        title: "Logout",
                        message: "Yakin ingin keluar?",
                      );
                      if (confirm == true) _logout();
                    },
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                    child: Text(
                      "Created by Zahra Khotimah",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // TILE INFO
  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // MENU ITEM
  Widget _menuItem({
    required IconData icon,
    required String label,
    required Color bg,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
