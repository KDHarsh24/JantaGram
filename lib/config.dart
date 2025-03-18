class Config {
  static const String baseUrl = 'https://jantagram-production.up.railway.app';
  static const String emailUrl = 'https://azure-jackal-487135.hostingersite.com';
  static String sendOtpUrl = '$baseUrl/send-otp';
  static String verifyOtpUrl = '$baseUrl/verify-otp';
  static String getStudentUrl = '$baseUrl/students/get';
  static String insertAttendanceUrl(String rollNumber) => '$baseUrl/students/$rollNumber';
  static List<String> foodSavingQuotes = [
    "“Wasting food is like stealing from the poor.”",
    "“Save food, save lives.”",
    "“Think before you throw.”",
    "“Every meal counts, don't waste it.”",
    "“Reduce food waste, feed more people.”",
    "“Small actions can make a big difference. Save food!”"
  ];
}
