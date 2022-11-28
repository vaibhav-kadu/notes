class NoteModel {
  final String id;
  final String title;
  final String subject;
  final String fileUrl;

  NoteModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.fileUrl,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      fileUrl: json['file_url'],
    );
  }
}