import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotesProvider with ChangeNotifier {
  final NotesService _service = NotesService();
  List<NoteModel> filteredNotes = [];

  List<NoteModel> notes = [];
  bool isLoading = false;


  Future<void> cacheNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final data = notes.map((e) => {
      'title': e.title,
      'subject': e.subject,
      'file_url': e.fileUrl,
    }).toList();

    prefs.setString('notes_cache', jsonEncode(data));
  }

  Future<void> loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('notes_cache');

    if (data != null) {
      final decoded = jsonDecode(data) as List;

      notes = decoded.map((e) => NoteModel.fromJson(e)).toList();
      notifyListeners();
    }
  }


  void toggleBookmark(NoteModel note) {
    note.isBookmarked = !note.isBookmarked;
    notifyListeners();
  }

  void filterBySubject(String subject) {
    filteredNotes =
        notes.where((note) => note.subject == subject).toList();
    notifyListeners();
  }

  Future<void> loadNotes() async {
    await loadFromCache(); // load offline first

    isLoading = true;
    notifyListeners();

    try {
      notes = await _service.fetchMixedFeed();
      filteredNotes = notes; // update search list
      await cacheNotes(); // save offline
    } catch (e) {
      // fallback already handled by cache
    }

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

  void searchNotes(String query) {
    if (query.isEmpty) {
      filteredNotes = notes;
    } else {
      filteredNotes = notes
          .where((note) =>
      note.title.toLowerCase().contains(query.toLowerCase()) ||
          note.subject.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
}