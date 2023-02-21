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

    final verified =
        auth.isVerified;

    final email =
        auth.user?.email ?? 'user@email.com';

    final primary =
        Theme.of(context).colorScheme.primary;

    return Scaffold(

      body: CustomScrollView(

        slivers: [

          // ───────────────── APP BAR ─────────────────

          SliverAppBar(

            pinned: true,

            expandedHeight: 300,

            centerTitle: true,

            title: const Text(
              'Profile',
            ),

            flexibleSpace: FlexibleSpaceBar(

              background: SafeArea(

                child: Padding(

                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 20,
                    right: 20,
                  ),

                  child: Column(

                    children: [

                      // Avatar

                      CircleAvatar(

                        radius: 48,

                        backgroundColor: primary,

                        child: Text(

                          email
                              .substring(0, 1)
                              .toUpperCase(),

                          style: const TextStyle(
                            fontSize: 34,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Email + verified

                      Row(

                        mainAxisAlignment:
                        MainAxisAlignment.center,

                        children: [

                          Flexible(

                            child: Text(

                              email,

                              overflow:
                              TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.w700,
                              ),
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

                      const SizedBox(height: 6),

                      // Role

                      Container(

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(

                          color:
                          primary.withValues(alpha: 0.12),

                          borderRadius:
                          BorderRadius.circular(20),
                        ),

                        child: Text(

                          role.toUpperCase(),

                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

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
                            value:
                            totalLikes.toString(),
                            label: 'Likes',
                          ),

                          _StatItem(
                            value:
                            saved.length.toString(),
                            label: 'Saved',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ───────────────── UPLOAD HEADER ─────────────────

          SliverToBoxAdapter(

            child: Padding(

              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                12,
              ),

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

          // ───────────────── EMPTY STATE ─────────────────

          if (uploaded.isEmpty)

            const SliverToBoxAdapter(

              child: Padding(

                padding: EdgeInsets.all(40),

                child: Center(

                  child: Text(
                    'No uploads yet',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            )

          // ───────────────── GRID ─────────────────

          else

            SliverPadding(

              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
              ),

              sliver: SliverGrid(

                delegate:
                SliverChildBuilderDelegate(

                      (context, index) {

                    final note = uploaded[index];

                    return Container(

                      margin: const EdgeInsets.all(4),

                      decoration: BoxDecoration(

                        borderRadius:
                        BorderRadius.circular(14),

                        color: Colors.grey.shade200,
                      ),

                      clipBehavior: Clip.antiAlias,

                      child: Stack(

                        fit: StackFit.expand,

                        children: [

                          // Image preview

                          if (note.isImage)

                            Image.network(

                              note.fileUrl,

                              fit: BoxFit.cover,

                              errorBuilder:
                                  (_, __, ___) {

                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                  ),
                                );
                              },
                            )

                          // Other file types

                          else

                            Center(

                              child: Icon(

                                note.isPdf
                                    ? Icons.picture_as_pdf
                                    : note.isVideo
                                    ? Icons.play_circle_fill
                                    : note.isDoc
                                    ? Icons.description
                                    : Icons.insert_drive_file,

                                size: 42,

                                color: primary,
                              ),
                            ),

                          // Bottom overlay

                          Positioned(

                            left: 0,
                            right: 0,
                            bottom: 0,

                            child: Container(

                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),

                              color:
                              Colors.black54,

                              child: Text(

                                note.title,

                                maxLines: 1,

                                overflow:
                                TextOverflow.ellipsis,

                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },

                  childCount: uploaded.length,
                ),

                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(

                  crossAxisCount: 3,

                  crossAxisSpacing: 6,

                  mainAxisSpacing: 6,
                ),
              ),
            ),

          // ───────────────── LOGOUT ─────────────────

          SliverToBoxAdapter(

            child: Padding(

              padding: const EdgeInsets.all(24),

              child: ElevatedButton.icon(

                onPressed: () async {

                  await auth.logout();
                },

                icon: const Icon(Icons.logout),

                label: const Text('Logout'),

                style: ElevatedButton.styleFrom(
                  minimumSize:
                  const Size(double.infinity, 50),
                ),
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
            fontSize: 22,
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