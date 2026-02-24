/// Represents a stored user session with credentials and token info.
class UserSession {
  final String studentId;
  final String encodedCredentials;
  final String? token;
  final String? encodedToken;
  final DateTime? tokenExpiry;
  final String? name;
  final String? avatarHash;

  const UserSession({
    required this.studentId,
    required this.encodedCredentials,
    this.token,
    this.encodedToken,
    this.tokenExpiry,
    this.name,
    this.avatarHash,
  });

  UserSession copyWith({
    String? studentId,
    String? encodedCredentials,
    String? token,
    String? encodedToken,
    DateTime? tokenExpiry,
    String? name,
    String? avatarHash,
  }) {
    return UserSession(
      studentId: studentId ?? this.studentId,
      encodedCredentials: encodedCredentials ?? this.encodedCredentials,
      token: token ?? this.token,
      encodedToken: encodedToken ?? this.encodedToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      name: name ?? this.name,
      avatarHash: avatarHash ?? this.avatarHash,
    );
  }

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      studentId: json['studentId'] as String,
      encodedCredentials: json['encodedCredentials'] as String,
      token: json['token'] as String?,
      encodedToken: json['encodedToken'] as String?,
      tokenExpiry: json['tokenExpiry'] != null
          ? DateTime.parse(json['tokenExpiry'] as String)
          : null,
      name: json['name'] as String?,
      avatarHash: json['avatarHash'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'encodedCredentials': encodedCredentials,
      'token': token,
      'encodedToken': encodedToken,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'name': name,
      'avatarHash': avatarHash,
    };
  }
}
