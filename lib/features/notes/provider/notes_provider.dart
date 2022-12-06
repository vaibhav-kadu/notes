import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import 'dart:io';

class NotesProvider with ChangeNotifier {
  final NotesService _service = NotesService();

  List<NoteModel> notes = [];
  bool isLoading = false;

  Future<void> loadNotes() async {
    isLoading = true;
    notifyListeners();

    notes = await _service.fetchMixedFeed();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(String title, String subject, String fileUrl) async {
    await _service.addNote(title, subject, fileUrl);
    await loadNotes();
  }

  Future<void> uploadNoteSecure(
      String title, String subject, File file) async {

    final user = supabase.auth.currentUser;

    final res = await supabase
        .from('users')
        .select()
        .eq('id', user!.id)
        .single();

    if (res['role'] != 'teacher' || res['is_verified'] != true) {
      throw Exception("Only verified teachers can upload");
    }

    await uploadNote(title, subject, file);
  }

  Future<void> uploadNote(String title, String subject, File file) async {
    isLoading = true;
    notifyListeners();

    final fileUrl = await _service.uploadPDF(file);

    await _service.addNote(title, subject, fileUrl);

    await loadNotes();

    isLoading = false;
    notifyListeners();
  }
}