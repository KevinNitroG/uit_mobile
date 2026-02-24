/// A notification entry.
class UitNotification {
  final String id;
  final String title;
  final String content;
  final String dated;

  const UitNotification({
    required this.id,
    required this.title,
    required this.content,
    required this.dated,
  });

  factory UitNotification.fromJson(Map<String, dynamic> json) {
    return UitNotification(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      dated: json['dated'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'content': content, 'dated': dated};
  }
}
