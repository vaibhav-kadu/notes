import '../../../core/supabase_client.dart';
import '../models/note_model.dart';
import 'dart:io';
import '../../../core/supabase_client.dart';

class NotesService {

  Future<void> addNote(String title, String subject, String fileUrl) async {
    await supabase.from('notes').insert({
      'title': title,
      'subject': subject,
      'file_url': fileUrl,
    });
  }

  Future<List<NoteModel>> fetchMixedFeed() async {
    final latest = await supabase
        .from('notes')
        .select()
        .order('created_at', ascending: false)
        .limit(10);

    final popular = await supabase
        .from('notes')
        .select()
        .order('views_count', ascending: false)
        .limit(10);

    List<NoteModel> latestList =
    (latest as List).map((e) => NoteModel.fromJson(e)).toList();

    List<NoteModel> popularList =
    (popular as List).map((e) => NoteModel.fromJson(e)).toList();

    List<NoteModel> result = [];

    for (int i = 0; i < latestList.length; i++) {
      result.add(latestList[i]);

      if (i < popularList.length) {
        result.add(popularList[i]);
      }
    }

    return result;
  }

  Future<String> uploadPDF(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();

    await supabase.storage
        .from('notes')
        .upload(fileName, file);

    final publicUrl = supabase.storage
        .from('notes')
        .getPublicUrl(fileName);

    return publicUrl;
  }
}