import 'package:flutter/foundation.dart';
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
    final Map<String, dynamic> data = {
      'title': title,
      'subject': subject,
      'file_url': fileUrl,
      'type': type,
      // uploader_id removed because it's missing in your DB
    };

    // We strictly use only the columns that exist in your DB schema.
    await supabase.from('notes').insert(data).select('id');
  }

  Future<void> incrementView(String noteId) async {
    try {
      // Manual increment using only 'views_count' column
      final res = await supabase.from('notes').select('views_count').eq('id', noteId).maybeSingle();
      if (res == null) return;
      final current = res['views_count'] as int? ?? 0;
      await supabase.from('notes').update({'views_count': current + 1}).eq('id', noteId);
    } catch (e) {
      debugPrint('Manual view increment failed. Error: $e');
    }
  }

  Future<List<NoteModel>> fetchMixedFeed() async {
    // Explicitly list ONLY columns that actually exist in your database
    const columns = 'id, title, subject, file_url, created_at, thumbnail_url, type, views_count';

    final latest = await supabase
        .from('notes')
        .select(columns)
        .order('created_at', ascending: false)
        .limit(10);

    final popular = await supabase
        .from('notes')
        .select(columns)
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

  Future<String> uploadFile(
    File file, {
    required String subject,
    required String type,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Please log in before uploading");
    }

    final extension = file.path.contains('.')
        ? file.path.split('.').last.toLowerCase()
        : 'file';
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

  Future<void> deleteNote(String noteId) async {
    await supabase.from('notes').delete().eq('id', noteId);
  }
}
