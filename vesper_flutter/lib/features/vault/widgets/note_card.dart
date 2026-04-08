import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.title,
    required this.summary,
    required this.date,
    required this.duration,
    required this.mood,
    required this.tags,
    this.onTap,
  });

  final String title;
  final String summary;
  final DateTime date;
  final String duration;
  final String mood;
  final List<String> tags;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MoodBadge(mood: mood),
                Text(
                  duration,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: tags.map((tag) => _TagChip(label: tag)).toList(),
                  ),
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(date),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodBadge extends StatelessWidget {
  const _MoodBadge({required this.mood});
  final String mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        mood.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        '#$label',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
    );
  }
}
