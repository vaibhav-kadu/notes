import '../../../core/supabase_client.dart';
import '../models/note_model.dart';
import 'dart:io';

class NotesService {
  String _slugify(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String _typeFolder(String type) {
    return type == 'mcq_test' ? 'mcq-test' : 'notes';
  }

  Future<void> addNote(
    String title,
    String subject,
    String fileUrl,
    String type,
  ) async {
    final user = supabase.auth.currentUser;
    final Map<String, dynamic> data = {
      'title': title,
      'subject': subject,
      'file_url': fileUrl,
      'type': type,
      'uploader_id': user?.id,
    };

    try {
      // Add email only if column exists (optional check or just try-catch)
      await supabase.from('notes').insert({
        ...data,
        'uploader_email': user?.email,
      });
    } catch (e) {
      // Fallback if uploader_email column is missing
      await supabase.from('notes').insert(data);
    }
  }

  Future<void> incrementView(String noteId) async {
    try {
      await supabase.rpc('increment_note_views', params: {'note_id': noteId});
    } catch (e) {
      // Fallback if RPC doesn't exist
      try {
        final res = await supabase.from('notes').select('views_count').eq('id', noteId).single();
        final current = res['views_count'] as int? ?? 0;
        await supabase.from('notes').update({'views_count': current + 1}).eq('id', noteId);
      } catch (_) {}
    }
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

    final result = <NoteModel>[];
    final seenKeys = <String>{};

    for (int i = 0; i < latestList.length; i++) {
      final latestNote = latestList[i];
      final latestKey = latestNote.id.isNotEmpty ? latestNote.id : latestNote.fileUrl;
      if (seenKeys.add(latestKey)) {
        result.add(latestNote);
      }

      if (i < popularList.length) {
        final popularNote = popularList[i];
        final popularKey =
            popularNote.id.isNotEmpty ? popularNote.id : popularNote.fileUrl;
        if (seenKeys.add(popularKey)) {
          result.add(popularNote);
        }
      }
    }

    return result;
  }

  Future<String> uploadPDF(
    File file, {
    required String subject,
    required String type,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Please log in before uploading a PDF");
    }

    final extension = file.path.contains('.')
        ? file.path.split('.').last.toLowerCase()
        : 'pdf';
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final objectPath =
        '${_slugify(subject)}/${_typeFolder(type)}/${user.id}/$fileName';

    await supabase.storage.from('notes').upload(objectPath, file);

    final publicUrl = supabase.storage
        .from('notes')
        .getPublicUrl(objectPath);

    return publicUrl;
  }
}
