import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/subjects.dart';
import '../notes/provider/notes_provider.dart';

class CategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes App"),
        centerTitle: true,
        elevation: 2,
      ),
      body: ListView.builder(
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(subjects[index]),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pop(context);
                Provider.of<NotesProvider>(context, listen: false)
                    .filterBySubject(subjects[index]);
              },
            ),
          );
        },
      ),
    );
  }
}