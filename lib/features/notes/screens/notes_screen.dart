import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/subjects.dart';
import '../../auth/provider/auth_provider.dart';
import '../models/note_model.dart';
import '../provider/notes_provider.dart';

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class NotesScreen extends StatefulWidget {
  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  static const _uploadTypes = <_UploadTypeOption>[
    _UploadTypeOption(value: 'notes', label: 'Notes'),
    _UploadTypeOption(value: 'mcq_test', label: 'MCQ Test'),
  ];

  String _formatUploadError(Object error) {
    if (error is StorageException &&
        error.message.contains('row-level security')) {
      return "Upload blocked by Supabase Storage policy. The 'notes' bucket needs an insert policy for the selected category/type folder.";
    }

    if (error is PostgrestException &&
        error.message.contains('row-level security')) {
      return "Upload saved the file, but the notes table rejected the insert because of a row-level security policy.";
    }

    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<_UploadRequest?> _showUploadDialog(BuildContext context) async {
    final titleController = TextEditingController();
    var selectedSubject = subjects.first;
    var selectedType = _uploadTypes.first.value;

    final result = await showDialog<_UploadRequest>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Upload PDF"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedSubject,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      items: subjects
                          .map(
                            (subject) => DropdownMenuItem(
                              value: subject,
                              child: Text(subject),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedSubject = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: "Upload Type",
                        border: OutlineInputBorder(),
                      ),
                      items: _uploadTypes
                          .map(
                            (type) => DropdownMenuItem(
                              value: type.value,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedType = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a title before uploading."),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      _UploadRequest(
                        title: title,
                        subject: selectedSubject,
                        type: selectedType,
                      ),
                    );
                  },
                  child: const Text("Continue"),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    return result;
  }

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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.canUploadNotes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Only teachers and admins can upload notes."),
        ),
      );
      return;
    }

    final uploadRequest = await _showUploadDialog(context);
    if (uploadRequest == null) {
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      try {
        File file = File(result.files.single.path!);

        await provider.uploadNoteSecure(
          uploadRequest.title,
          uploadRequest.subject,
          uploadRequest.type,
          file,
        );

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Uploaded to ${uploadRequest.subject} / ${uploadRequest.type == 'mcq_test' ? 'MCQ Test' : 'Notes'}",
            ),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_formatUploadError(e))),
        );
      }
    }
  }

  // 🔹 Open PDF URL
  Future<void> openPDF(String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final trimmedUrl = url.trim();

    if (trimmedUrl.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text("This note does not have a valid file URL.")),
      );
      return;
    }

    final uri = Uri.tryParse(trimmedUrl);
    if (uri == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text("The note link is invalid.")),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text("No app was found to open this note."),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Failed to open note: ${error.toString().replaceFirst('Exception: ', '')}",
          ),
        ),
      );
    }
  }

  Widget _buildThumbnailPlaceholder(NoteModel note) {
    final label = note.type == 'mcq_test' ? 'MCQ Test' : 'PDF Note';

    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.picture_as_pdf, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteThumbnail(NoteModel note) {
    const borderRadius = BorderRadius.vertical(top: Radius.circular(12));
    final thumbnailUrl = note.thumbnailUrl.trim();

    if (thumbnailUrl.isEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: _buildThumbnailPlaceholder(note),
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(
        thumbnailUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildThumbnailPlaceholder(note);
        },
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotesProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);


    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
        centerTitle: true,
        elevation: 2,
      ),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search notes...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                provider.searchNotes(value);
              },
            ),
          ),

          // 🔽 CONTENT AREA (IMPORTANT: must be Expanded)
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.filteredNotes.isEmpty
                ? const Center(child: Text("No notes available"))
                : ListView.builder(
              itemCount: provider.filteredNotes.length,
              itemBuilder: (context, index) {
                final note = provider.filteredNotes[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 8),
                  elevation: 3,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () => openPDF(note.fileUrl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // 🔹 Thumbnail
                      _buildNoteThumbnail(note),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          note.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),

                      Padding(
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(note.subject),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    note.isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                  ),
                                  onPressed: () => provider.toggleBookmark(note),
                                ),
                                IconButton(
                                  icon: Icon(
                                    note.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: note.isLiked ? Colors.red : null,
                                  ),
                                  onPressed: () => provider.toggleLike(note),
                                ),
                                Text("👁 ${note.views} views"),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_new),
                              onPressed: () => openPDF(note.fileUrl),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: authProvider.canManageNotes
          ? FloatingActionButton(
        onPressed: () => pickAndUpload(context),
        child: const Icon(Icons.upload),
      )
          : null,

    );
  }
}

class _UploadRequest {
  final String title;
  final String subject;
  final String type;

  const _UploadRequest({
    required this.title,
    required this.subject,
    required this.type,
  });
}

class _UploadTypeOption {
  final String value;
  final String label;

  const _UploadTypeOption({
    required this.value,
    required this.label,
  });
}
