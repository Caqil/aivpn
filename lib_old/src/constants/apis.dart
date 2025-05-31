class Apis {
  static const baseUrl = 'https://360aivpn.com';
  static const api = '/api/v1';
  static const signUpApi = '${baseUrl + api}/auth/register';
  static const loginApi = '${baseUrl + api}/auth/login';
  static const confirmAccountApi = '${baseUrl + api}/auth/verify';
  static const forgotPasswordApi = '${baseUrl + api}/auth/forgot-password';
  static const confirmResetPasswordApi = '${baseUrl + api}/auth/reset-password';
  static const profilesApi = '${baseUrl + api}/profiles';
  static const deleteProfilesApi = '${baseUrl + api}/users/';
  static const serverApi = '${baseUrl + api}/server';
}
