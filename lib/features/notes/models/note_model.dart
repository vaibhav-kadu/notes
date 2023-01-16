class NoteModel {
  final String id;
  final String title;
  final String subject;
  final String fileUrl;
  final String thumbnailUrl;
  final String type;
  final int views;
  final DateTime createdAt;
  bool isBookmarked;
  bool isLiked;
  bool isUploaded;

  NoteModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.type,
    required this.views,
    required this.createdAt,
    this.isBookmarked = false,
    this.isLiked = false,
    this.isUploaded = false,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['created_at']?.toString() ?? '');

    return NoteModel(
      id: json['id']?.toString() ??
          json['file_url']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      thumbnailUrl: json['thumbnail_url']?.toString() ?? '',
      type: json['type']?.toString() ?? 'notes',
      views: json['views_count'] is int
          ? json['views_count'] as int
          : int.tryParse(json['views_count']?.toString() ?? '') ?? 0,
      createdAt: createdAt ?? DateTime.now(),
      isBookmarked: json['is_bookmarked'] == true,
      isLiked: json['is_liked'] == true,
      isUploaded: json['is_uploaded'] == true,
    );
  }

  NoteModel copyWith({
    String? id,
    String? title,
    String? subject,
    String? fileUrl,
    String? thumbnailUrl,
    String? type,
    int? views,
    DateTime? createdAt,
    bool? isBookmarked,
    bool? isLiked,
    bool? isUploaded,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      type: type ?? this.type,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLiked: isLiked ?? this.isLiked,
      isUploaded: isUploaded ?? this.isUploaded,
    );
  }
}
