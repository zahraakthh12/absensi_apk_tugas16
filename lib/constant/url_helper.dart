class UrlHelper {
  static const String publicUrl = 'https://appabsensi.mobileprojp.com//public/';

  static String buildProfileUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final cleaned = path.trim();
    if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
      return cleaned;
    }
    // avoid double slash
    if (publicUrl.endsWith('/') && cleaned.startsWith('/')) {
      return publicUrl + cleaned.substring(1);
    }
    return publicUrl + cleaned;
  }
}