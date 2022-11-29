import 'package:flutter/material.dart';
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

    notes = await _service.fetchNotes();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(String title, String subject, String fileUrl) async {
    await _service.addNote(title, subject, fileUrl);
    await loadNotes();
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