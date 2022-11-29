import '../../../core/supabase_client.dart';
import '../models/note_model.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase_client.dart';

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