import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/auth_wrapper.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/notes/provider/notes_provider.dart';
import 'features/quiz/provider/quiz_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://peylohengsmmdniizkcf.supabase.co',
    anonKey: 'sb_publishable_boReR1a1HcfxBA_T-Lgkfg_GviXdxwQ',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔹 Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..checkSession(),
        ),

        // 🔹 Notes Provider
        ChangeNotifierProvider(
          create: (_) => NotesProvider(),
        ),

        // 🔹 Quiz Provider (NEW)
        ChangeNotifierProvider(
          create: (_) => QuizProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthWrapper(),
      ),
    );
  }
}
