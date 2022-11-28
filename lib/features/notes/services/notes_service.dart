import '../../../core/supabase_client.dart';
import '../models/note_model.dart';

class NotesService {

  Future<void> addNote(String title, String subject, String fileUrl) async {
    await supabase.from('notes').insert({
      'title': title,
      'subject': subject,
      'file_url': fileUrl,
    });
  }

  Future<List<NoteModel>> fetchNotes() async {
    final res = await supabase.from('notes').select();

    return (res as List)
        .map((e) => NoteModel.fromJson(e))
        .toList();
  }
}