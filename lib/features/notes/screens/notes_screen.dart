import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/notes_provider.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<NotesProvider>(context, listen: false).loadNotes()
    );
  }

  // 🔹 Pick & Upload PDF
  Future<void> pickAndUpload(BuildContext context) async {
    final provider = Provider.of<NotesProvider>(context, listen: false);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      await provider.uploadNote(
        "Sample Note",
        "Engineering",
        file,
      );
    }
  }

  // 🔹 Open PDF URL
  Future<void> openPDF(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotesProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Notes 📚")),

      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.notes.isEmpty
          ? const Center(child: Text("No notes available"))
          : ListView.builder(
        itemCount: provider.notes.length,
        itemBuilder: (context, index) {
          final note = provider.notes[index];

          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf,
                  color: Colors.red),
              title: Text(note.title),
              subtitle: Text(note.subject),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => openPDF(note.fileUrl),
            ),
          );
        },
      ),

      // 🔹 Upload Button
      floatingActionButton: FloatingActionButton(
        onPressed: () => pickAndUpload(context),
        child: const Icon(Icons.upload),
      ),
    );
  }
}