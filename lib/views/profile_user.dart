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

  // ===================== LOAD PROFILE =====================
  Future<void> loadProfile() async {
    try {
      final res = await AbsensiAPI.getProfile();
      user = res.data;
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal memuat profil");
    }
    setState(() => loading = false);
  }

  // ===================== LOGOUT =====================
  Future<void> _logout() async {
    await PreferenceHandler.clearAll();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreenDay33()),
      (_) => false,
    );
  }


  // ===================== DIALOG KONFIRMASI =====================
  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    String okText = "Ya",
    String cancelText = "Batal",
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(okText),
          ),
        ],
      ),
    );
  }

  // ===================== POPUP EDIT NAMA =====================
  Future<void> _showEditDialog() async {
    final TextEditingController nameC = TextEditingController(
      text: user?.name ?? "",
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35), // blur overlay
      builder: (_) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.88,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ================= TITLE =================
                    const Text(
                      "Edit Profil",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ================= NAMA =================
                    const Text(
                      "Nama Lengkap",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameC,
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.blue.shade500,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ================= READONLY FIELDS =================
                    _readonlyField("Email", user?.email ?? "-"),
                    _readonlyField("Jenis Kelamin", user?.jenisKelamin ?? "-"),
                    _readonlyField("Batch Ke", user?.batchKe ?? "-"),
                    _readonlyField("Pelatihan", user?.trainingTitle ?? "-"),

                    const SizedBox(height: 26),

                    // ================= BUTTONS =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Batal",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () async {
                            if (nameC.text.trim().isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Nama tidak boleh kosong",
                              );
                              return;
                            }

                            try {
                              await AbsensiAPI.editProfile(
                                name: nameC.text.trim(),
                              );
                              Fluttertoast.showToast(
                                msg: "Profil berhasil diperbarui",
                              );

                              Navigator.pop(context);
                              loadProfile();
                            } catch (e) {
                              Fluttertoast.showToast(
                                msg: "Gagal menyimpan perubahan",
                              );
                            }
                          },
                          child: const Text(
                            "Simpan",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
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
      },
    );
  }

  // ===================== READONLY FIELD =====================
  Widget _readonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                Icon(Icons.lock, size: 18, color: Colors.grey.shade500),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===================== UI =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Profil",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                children: [
                  // ===================== AVATAR =====================
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
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "-",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 24),

                  _infoTile("Batch Ke", user?.batchKe ?? "-"),
                  _infoTile("Pelatihan", user?.trainingTitle ?? "-"),
                  _infoTile("Jenis Kelamin", user?.jenisKelamin ?? "-"),

                  const SizedBox(height: 30),

                  // ===================== MENU LIST =====================
                  _menuItem(
                    icon: Icons.edit,
                    iconBg: Colors.blue.shade50,
                    iconColor: Colors.blue.shade700,
                    label: "Edit Profil",
                    onTap: _showEditDialog,
                  ),

                  _menuItem(
                    icon: Icons.logout_rounded,
                    iconBg: Colors.grey.shade200,
                    iconColor: Colors.grey.shade800,
                    label: "Logout",
                    onTap: () async {
                      final confirm = await _showConfirmDialog(
                        title: "Logout",
                        message:
                            "Anda akan keluar dari akun. Yakin ingin logout?",
                        okText: "Logout",
                      );
                      if (confirm == true) {
                        await _logout();
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  // ===================== TILE =====================
  Widget _infoTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // nilai di sebelah kanan
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // <<< FIX UTAMA
              softWrap: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
