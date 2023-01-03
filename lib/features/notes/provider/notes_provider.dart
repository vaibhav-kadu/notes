import 'package:flutter/material.dart';
import '../../../core/supabase_client.dart';
import '../models/note_model.dart';
import '../services/notes_service.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../../../core/services/notification_service.dart';

class NotesProvider with ChangeNotifier {
  final NotesService _service = NotesService();
  List<NoteModel> filteredNotes = [];
  StreamSubscription? _notesSubscription;

  List<NoteModel> notes = [];
  bool isLoading = false;
  Set<String> _bookmarkedNoteKeys = {};
  Set<String> _likedNoteKeys = {};
  Set<String> _uploadedNoteKeys = {};
  String? _loadedUserId;

  NotesProvider() {
    _initRealtime();
  }

  void _initRealtime() {
    supabase.auth.onAuthStateChange.listen((_) {
      _notesSubscription?.cancel();
      _setupSubscription();
    });
    _setupSubscription();
  }

  void _setupSubscription() {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    _notesSubscription = supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> data) {
          for (final row in data) {
            final updatedNote = NoteModel.fromJson(row);
            if (updatedNote.uploaderId == userId) {
              final existingIndex = notes.indexWhere((n) => n.id == updatedNote.id);
              if (existingIndex != -1) {
                final existing = notes[existingIndex];
                if (updatedNote.likesCount > existing.likesCount) {
                  NotificationService.showNotification(
                    title: 'New Like! ❤️',
                    body: 'Someone liked your note: ${updatedNote.title}',
                  );
                }
              }
            }
          }
        }, onError: (error) {
          debugPrint('Supabase Realtime Stream Error: $error');
          // Silence timeout errors to prevent app crashes
        });
  }

  @override
  void dispose() {
    _notesSubscription?.cancel();
    super.dispose();
  }

  List<NoteModel> get bookmarkedNotes =>
      notes.where((note) => note.isBookmarked).toList();

  List<NoteModel> get likedNotes =>
      notes.where((note) => note.isLiked).toList();

  List<NoteModel> get uploadedNotes =>
      notes.where((note) => note.isUploaded).toList();

  String _currentUserId() => supabase.auth.currentUser?.id ?? 'guest';

  String _storageKey(String prefix) => '${prefix}_${_currentUserId()}';

  String _noteKey(NoteModel note) => note.id.isNotEmpty ? note.id : note.fileUrl;

  Future<String?> _resolveCurrentRole() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final metadataRole = user.userMetadata?['role']?.toString();
    if (metadataRole != null && metadataRole.isNotEmpty) {
      return metadataRole;
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role_${user.id}');
  }

  bool _matchesActivity(Set<String> activityKeys, NoteModel note) {
    final key = _noteKey(note);
    return activityKeys.contains(key) || activityKeys.contains(note.fileUrl);
  }

  void _updateActivity(Set<String> activityKeys, NoteModel note, bool value) {
    final key = _noteKey(note);

    if (value) {
      activityKeys.add(key);
      activityKeys.add(note.fileUrl);
    } else {
      activityKeys.remove(key);
      activityKeys.remove(note.fileUrl);
    }
  }

  Future<void> _loadUserActivity() async {
    final userId = _currentUserId();
    if (_loadedUserId == userId) return;

    final prefs = await SharedPreferences.getInstance();
    _bookmarkedNoteKeys =
        (prefs.getStringList(_storageKey('notes_bookmarks')) ?? []).toSet();
    _likedNoteKeys =
        (prefs.getStringList(_storageKey('notes_likes')) ?? []).toSet();
    _uploadedNoteKeys =
        (prefs.getStringList(_storageKey('notes_uploaded')) ?? []).toSet();
    _loadedUserId = userId;
  }

  Future<void> _saveUserActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _storageKey('notes_bookmarks'),
      _bookmarkedNoteKeys.toList(),
    );
    await prefs.setStringList(
      _storageKey('notes_likes'),
      _likedNoteKeys.toList(),
    );
    await prefs.setStringList(
      _storageKey('notes_uploaded'),
      _uploadedNoteKeys.toList(),
    );
  }

  void _applyUserActivity() {
    for (final note in notes) {
      note.isBookmarked = _matchesActivity(_bookmarkedNoteKeys, note);
      note.isLiked = _matchesActivity(_likedNoteKeys, note);
      note.isUploaded = _matchesActivity(_uploadedNoteKeys, note);
    }
  }


  Future<void> cacheNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final data = notes
        .map((e) => {
      'id': e.id,
      'title': e.title,
      'subject': e.subject,
      'file_url': e.fileUrl,
      'thumbnail_url': e.thumbnailUrl,
              'type': e.type,
              'views_count': e.views,
              'created_at': e.createdAt.toIso8601String(),
              'is_bookmarked': e.isBookmarked,
              'is_liked': e.isLiked,
              'is_uploaded': e.isUploaded,
            })
        .toList();

    await prefs.setString('notes_cache', jsonEncode(data));
  }

  Future<void> loadFromCache() async {
    await _loadUserActivity();
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('notes_cache');

    if (data == null) return;

    try {
      final decoded = jsonDecode(data) as List<dynamic>;

      notes = decoded
          .map((e) => NoteModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      _applyUserActivity();
      filteredNotes = List<NoteModel>.from(notes);
      notifyListeners();
    } catch (_) {
      await prefs.remove('notes_cache');
    }
  }



  Future<void> toggleBookmark(NoteModel note) async {
    note.isBookmarked = !note.isBookmarked;
    _updateActivity(_bookmarkedNoteKeys, note, note.isBookmarked);
    await _saveUserActivity();
    await cacheNotes();
    notifyListeners();
  }

  Future<void> toggleLike(NoteModel note) async {
    note.isLiked = !note.isLiked;
    _updateActivity(_likedNoteKeys, note, note.isLiked);

    try {
      // Sync to Supabase
      await supabase.from('notes').update({
        'likes_count': note.isLiked ? (note.likesCount + 1) : (note.likesCount - 1),
      }).eq('id', note.id);
    } catch (e) {
      // Fallback if column doesn't exist
    }

    await _saveUserActivity();
    await cacheNotes();

    notifyListeners();
  }

  void filterBySubject(String subject) {
    filteredNotes =
        notes.where((note) => note.subject == subject).toList();
    notifyListeners();
  }

  Future<void> incrementView(NoteModel note) async {
    await _service.incrementView(note.id);
    // Update local state
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = notes[index].copyWith(views: notes[index].views + 1);
      filteredNotes = notes.map((n) => n.id == note.id ? notes[index] : n).toList();
      notifyListeners();
    }
  }

  Future<void> loadNotes() async {
    await _loadUserActivity();
    await loadFromCache(); // load offline first

    isLoading = true;
    notifyListeners();

    try {
      notes = await _service.fetchMixedFeed();
      _applyUserActivity();
      filteredNotes = List<NoteModel>.from(notes); // update search list
      await cacheNotes(); // save offline
    } catch (e) {
      // fallback already handled by cache
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(
    String title,
    String subject,
    String fileUrl,
    String type,
  ) async {
    await _service.addNote(title, subject, fileUrl, type);
    await loadNotes();
  }

  Future<void> uploadNoteSecure(
      String title, String subject, String type, File file) async {

    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception("Please log in to upload notes");
    }

    final role = await _resolveCurrentRole();
    final canUpload = role == 'admin' || role == 'teacher';

    if (!canUpload) {
      throw Exception("Only admins and teachers can upload");
    }

    await uploadNote(title, subject, type, file);
  }

  Future<void> uploadNote(
    String title,
    String subject,
    String type,
    File file,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final fileUrl = await _service.uploadFile(
        file,
        subject: subject,
        type: type,
      );

      await _service.addNote(title, subject, fileUrl, type);

      _uploadedNoteKeys.add(fileUrl);
      await _saveUserActivity();

      await loadNotes();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void searchNotes(String query) {
    if (query.isEmpty) {
      filteredNotes = List<NoteModel>.from(notes);
    } else {
      filteredNotes = notes
          .where((note) =>
              note.title.toLowerCase().contains(query.toLowerCase()) ||
              note.subject.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<void> deleteNote(String noteId) async {
    await _service.deleteNote(noteId);
    await loadNotes();
  }
}
