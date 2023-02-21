import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../notes/provider/notes_provider.dart';

class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final auth =
    context.watch<AuthProvider>();

    final notesProvider =
    context.watch<NotesProvider>();

    final uploaded =
        notesProvider.uploadedNotes;

    final saved =
        notesProvider.bookmarkedNotes;

    final totalLikes = uploaded.fold<int>(
      0,
          (sum, note) => sum + note.likesCount,
    );

    final role =
        auth.role ?? 'student';

    final isTeacher =
        auth.role == 'teacher';

    final verified =
        auth.isVerified;

    return Scaffold(

      body: CustomScrollView(

        slivers: [

          SliverAppBar(

            pinned: true,

            expandedHeight: 280,

            flexibleSpace: FlexibleSpaceBar(

              background: Container(

                padding: const EdgeInsets.only(
                  top: 80,
                  left: 20,
                  right: 20,
                ),

                child: Column(

                  children: [

                    // Avatar
                    CircleAvatar(
                      radius: 45,
                      backgroundColor:
                      Theme.of(context)
                          .colorScheme
                          .primary,

                      child: Text(
                        auth.user?.email
                            ?.substring(0, 1)
                            .toUpperCase() ??
                            'U',

                        style: const TextStyle(
                          fontSize: 34,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Email + badge
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,

                      children: [

                        Flexible(
                          child: Text(
                            auth.user?.email ?? '',

                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.w700,
                            ),

                            overflow:
                            TextOverflow.ellipsis,
                          ),
                        ),

                        if (verified)

                          const Padding(
                            padding:
                            EdgeInsets.only(left: 6),

                            child: Icon(
                              Icons.verified,
                              color: Colors.blue,
                              size: 20,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      (auth.role ?? 'student').toUpperCase(),

                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Stats
                    Row(

                      mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,

                      children: [

                        _StatItem(
                          value:
                          uploaded.length.toString(),
                          label: 'Posts',
                        ),

                        _StatItem(
                          value: totalLikes.toString(),
                          label: 'Likes',
                        ),

                        _StatItem(
                          value: saved.length.toString(),
                          label: 'Saved',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Upload section
          SliverToBoxAdapter(

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(

                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    'Your Uploads',

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    '${uploaded.length} files',
                  ),
                ],
              ),
            ),
          ),

          // Grid
          SliverPadding(

            padding:
            const EdgeInsets.symmetric(horizontal: 12),

            sliver: SliverGrid(

              delegate:
              SliverChildBuilderDelegate(

                    (context, index) {

                  final note = uploaded[index];

                  return Container(

                    margin: const EdgeInsets.all(6),

                    decoration: BoxDecoration(

                      borderRadius:
                      BorderRadius.circular(16),

                      image: note.isImage
                          ? DecorationImage(
                        image:
                        NetworkImage(note.fileUrl),
                        fit: BoxFit.cover,
                      )
                          : null,

                      color: Colors.grey.shade200,
                    ),

                    child: note.isImage

                        ? null

                        : Center(

                      child: Icon(

                        note.isPdf
                            ? Icons.picture_as_pdf
                            : note.isVideo
                            ? Icons.play_circle
                            : Icons.description,

                        size: 42,
                      ),
                    ),
                  );
                },

                childCount: uploaded.length,
              ),

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(

                crossAxisCount: 3,

                crossAxisSpacing: 8,

                mainAxisSpacing: 8,
              ),
            ),
          ),

          // Logout
          SliverToBoxAdapter(

            child: Padding(

              padding: const EdgeInsets.all(24),

              child: ElevatedButton.icon(

                onPressed: () async {

                  await auth.logout();
                },

                icon: const Icon(Icons.logout),

                label: const Text('Logout'),
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {

  final String value;
  final String label;

  const _StatItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        Text(
          value,

          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}