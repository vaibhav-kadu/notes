import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Supabase Connected")),
      ),
    );
  }
}