import 'package:flutter/material.dart';
import 'package:vesper_flutter/features/vault/widgets/note_card.dart';

class VaultScreen extends StatelessWidget {
  const VaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleNotes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = _sampleNotes[index];
          return NoteCard(
            title: note.title,
            summary: note.summary,
            date: note.date,
            duration: note.duration,
            mood: note.mood,
            tags: note.tags,
            onTap: () {},
          );
        },
      ),
    );
  }
}

class _SampleNote {
  final String title;
  final String summary;
  final DateTime date;
  final String duration;
  final String mood;
  final List<String> tags;

  _SampleNote({
    required this.title,
    required this.summary,
    required this.date,
    required this.duration,
    required this.mood,
    required this.tags,
  });
}

final _sampleNotes = [
  _SampleNote(
    title: 'Product Brainstorming: Vesper v2',
    summary: 'Discussion about adding real-time collaboration and cloud sync options for power users while maintaining privacy.',
    date: DateTime.now().subtract(const Duration(days: 1)),
    duration: '12:45',
    mood: 'focused',
    tags: ['work', 'design', 'ideas'],
  ),
  _SampleNote(
    title: 'Morning Reflections',
    summary: 'Thoughts on personal growth, reading goals for the quarter, and the importance of deep work sessions.',
    date: DateTime.now().subtract(const Duration(days: 2)),
    duration: '05:20',
    mood: 'reflective',
    tags: ['personal', 'journal'],
  ),
  _SampleNote(
    title: 'Weekly Sync with Engineering',
    summary: 'Sprint planning results, discussion on the new Rust bridge architecture, and resolving the build toolchain issues.',
    date: DateTime.now().subtract(const Duration(days: 3)),
    duration: '45:12',
    mood: 'energetic',
    tags: ['work', 'engineering', 'sprint'],
  ),
];
