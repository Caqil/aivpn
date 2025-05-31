class ApiConstants {
  static const String baseUrl = 'https://dash.bgtunnel.com';
  static const String serversEndpoint = '/api/servers';
  static const String apiToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJjYWtyNCIsImFjY2VzcyI6InN1ZG8iLCJpYXQiOjE3NDY4NDkwNzUsImV4cCI6MjY5MjkyOTA3NX0.7QLWKHftA8XD9QIPNaryEY6svl5uZ00mcvIkZ2AITZw';

  // Connection timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
