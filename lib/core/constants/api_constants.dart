class ApiConstants {
  static const String baseUrl = 'https://dash.bgtunnel.com';
  static const String apiToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjYWtyNCIsImFjY2VzcyI6InN1ZG8iLCJpYXQiOjE3NTIwMzUxMzIsImV4cCI6MjY5ODExNTEzMn0.v9A-KD3UZNtLTpvdcMk_wh3ORE_p-JRUHjghZVh51Rg';

  // Connection timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
