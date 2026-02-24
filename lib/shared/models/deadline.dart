/// A deadline/assignment entry.
class Deadline {
  final String shortname;
  final String name;
  final String niceDate;
  final String? status;

  const Deadline({
    required this.shortname,
    required this.name,
    required this.niceDate,
    this.status,
  });

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      shortname: json['shortname'] as String? ?? '',
      name: json['name'] as String? ?? '',
      niceDate: json['niceDate'] as String? ?? '',
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shortname': shortname,
      'name': name,
      'niceDate': niceDate,
      'status': status,
    };
  }
}
