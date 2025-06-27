class ApiConstants {
  static const String baseUrl = 'https://api.360aivpn.com';
  static const String serversEndpoint = '/api/servers';
  static const String apiToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbiIsImFjY2VzcyI6InN1ZG8iLCJpYXQiOjE3NTA5OTg1MjIsImV4cCI6MTc1MTA4NDkyMn0.DyOfyMrvhQGENWL2dbvls67X6GAmVUs9WrJ_4KuNCL8';

  // Connection timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}
