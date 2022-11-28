import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';

class NotesProvider with ChangeNotifier {
  final NotesService _service = NotesService();

  List<NoteModel> notes = [];
  bool isLoading = false;

  Future<void> loadNotes() async {
    isLoading = true;
    notifyListeners();

    notes = await _service.fetchNotes();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(String title, String subject, String fileUrl) async {
    await _service.addNote(title, subject, fileUrl);
    await loadNotes();
  }
}