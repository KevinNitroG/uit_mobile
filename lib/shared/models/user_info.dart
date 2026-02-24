/// User profile information from the `/v2/data?task=current` endpoint.
class UserInfo {
  final String name;
  final String sid;
  final String mail;
  final String status;
  final String course;
  final String major;
  final String dob;
  final String role;
  final String className;
  final String address;
  final String avatar;

  const UserInfo({
    required this.name,
    required this.sid,
    required this.mail,
    required this.status,
    required this.course,
    required this.major,
    required this.dob,
    required this.role,
    required this.className,
    required this.address,
    required this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      name: json['name'] as String? ?? '',
      sid: json['sid'] as String? ?? '',
      mail: json['mail'] as String? ?? '',
      status: json['status'] as String? ?? '',
      course: json['course'] as String? ?? '',
      major: json['major'] as String? ?? '',
      dob: json['dob'] as String? ?? '',
      role: json['role'] as String? ?? '',
      className: json['class'] as String? ?? '',
      address: json['address'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sid': sid,
      'mail': mail,
      'status': status,
      'course': course,
      'major': major,
      'dob': dob,
      'role': role,
      'class': className,
      'address': address,
      'avatar': avatar,
    };
  }
}
