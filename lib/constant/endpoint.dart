class Endpoint {
  static const baseUrl = 'https://appabsensi.mobileprojp.com/api';

  static const register = '$baseUrl/register';
  static const login = '$baseUrl/login';
  static const trainings = '$baseUrl/trainings';
  static const trainingBatches = '$baseUrl/batches';
  static const profile = '$baseUrl/profile';
  static const histroyAttend = '$baseUrl/absen/history';
  static const checkIn = '$baseUrl/absen/check-in';
  static const checkOut = '$baseUrl/absen/check-out';
  static const todayPresence = '$baseUrl/absen/today';
  static const updateProfilePhoto = '$baseUrl/profile';
  static const todayAttendance = '$baseUrl/absen/today';
  static const presenceStats = '$baseUrl/absen/stats';
  static const deleteAbsen = '$baseUrl/absen';
}
