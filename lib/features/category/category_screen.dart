import 'package:flutter/material.dart';

import '../../core/constants/subjects.dart';

class CategoryScreen extends StatelessWidget {
  final ValueChanged<String> onSubjectSelected;

  const CategoryScreen({
    super.key,
    required this.onSubjectSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes App"),
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
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(subjects[index]),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => onSubjectSelected(subjects[index]),
            ),
          );
        },
      ),
    );
  }
}
