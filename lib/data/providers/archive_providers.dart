import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/archive_models.dart';

/// Device-local Archive Desk entries.
///
/// These are intentionally stored under their own key and are never surfaced
/// through viewer providers. This first slice is a safe collection inbox, not
/// a publishing system.
class ArchiveEntriesNotifier extends Notifier<List<ArchiveEntry>> {
  static const prefsKey = 'archive_desk_entries_v1';

  @override
  List<ArchiveEntry> build() {
    _restore();
    return const [];
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(prefsKey);
    if (saved == null) return;

    final restored = <ArchiveEntry>[];
    for (final value in saved) {
      try {
        restored.add(
          ArchiveEntry.fromJson(jsonDecode(value) as Map<String, dynamic>),
        );
      } on Object {
        // One damaged draft must not hide the rest of the family archive.
      }
    }
    restored.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = restored;
  }

  Future<void> save(ArchiveEntry entry) async {
    final next = [
      entry,
      for (final existing in state)
        if (existing.id != entry.id) existing,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = next;
    await _persist(next);
  }

  Future<void> _persist(List<ArchiveEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(prefsKey, [
      for (final entry in entries) jsonEncode(entry.toJson()),
    ]);
  }
}

final archiveEntriesProvider =
    NotifierProvider<ArchiveEntriesNotifier, List<ArchiveEntry>>(
      ArchiveEntriesNotifier.new,
    );
