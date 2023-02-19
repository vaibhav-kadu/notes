class AppNotification {

  final int id;
  final String title;
  final String message;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {

    return AppNotification(
      id: json['id'],
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? '',
      referenceId: json['reference_id']?.toString(),
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.tryParse(
        json['created_at'] ?? '',
      ) ?? DateTime.now(),
    );
  }
}