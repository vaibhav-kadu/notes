class NoteModel {
  final String id;
  final String title;
  final String subject;
  final String fileUrl;
  final String thumbnailUrl;
  final String type;
  final int views;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.type,
    required this.views,
    required this.createdAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      subject: json['subject'] ?? '',
      fileUrl: json['file_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ??
          'https://via.placeholder.com/300x200.png?text=No+Image',
      type: json['type'] ?? 'pdf',
      views: json['views_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}