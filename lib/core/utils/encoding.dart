import 'dart:convert';

/// Encodes [id] and [password] into the UIT auth format.
///
/// Format: base64("3sn@fah.{id}:{password}")
String encodeCredentials(String id, String password) {
  final raw = '3sn@fah.$id:$password';
  return base64Encode(utf8.encode(raw));
}

/// Encodes a [token] into the UIT auth format for subsequent API calls.
///
/// Format: base64("3sn@fah.{token}:")
String encodeToken(String token) {
  final raw = '3sn@fah.$token:';
  return base64Encode(utf8.encode(raw));
}
