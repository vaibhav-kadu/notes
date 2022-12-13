import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/provider/auth_provider.dart';
import '../notes/models/note_model.dart';
import '../notes/provider/notes_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final notesProvider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: ${auth.user?.email ?? ''}"),
            Text("Role: ${auth.role ?? ''}"),
            const SizedBox(height: 20),
            _NotesSection(
              title: "Uploaded Notes",
              notes: notesProvider.uploadedNotes,
              emptyText: "No uploaded notes yet",
            ),
            const SizedBox(height: 16),
            _NotesSection(
              title: "Bookmarked Notes",
              notes: notesProvider.bookmarkedNotes,
              emptyText: "No bookmarked notes yet",
            ),
            const SizedBox(height: 16),
            _NotesSection(
              title: "Liked Notes",
              notes: notesProvider.likedNotes,
              emptyText: "No liked notes yet",
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await auth.logout();
              },
              child: Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}

class _NotesSection extends StatelessWidget {
  final String title;
  final List<NoteModel> notes;
  final String emptyText;

  const _NotesSection({
    required this.title,
    required this.notes,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$title (${notes.length})",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (notes.isEmpty)
              Text(emptyText)
            else
              Column(
                children: notes
                    .map(
                      (note) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(note.title),
                        subtitle: Text(note.subject),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
