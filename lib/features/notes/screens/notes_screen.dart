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

  Future<void> uploadNoteSecure(...) async {
  final user = supabase.auth.currentUser;

  final res = await supabase
      .from('users')
      .select()
      .eq('id', user!.id)
      .single();

  if (res['role'] != 'teacher' || res['is_verified'] != true) {
  throw Exception("Not authorized");
  }

  // upload logic
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

    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(note.thumbnailUrl, height: 180, width: double.infinity, fit: BoxFit.cover),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(note.title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(note.subject),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("👁 ${note.views} views"),
              IconButton(
                icon: Icon(Icons.open_in_new),
                onPressed: () => openPDF(note.fileUrl),
              )
            ],
          )
        ],
      ),
    );
  }
}