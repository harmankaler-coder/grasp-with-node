import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/notes_model.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  Future<void> openFile(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open file';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(note.description,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            const Text("Files",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: note.fileUrls.length,
                itemBuilder: (context, index) {
                  final file = note.fileUrls[index];
                  final name = file.split('/').last;

                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file,
                          color: Colors.teal),
                      title: Text(name),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => openFile(file),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}