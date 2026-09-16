import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/i18n/l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/archive_models.dart';
import '../../data/providers/archive_providers.dart';
import '../../shared/widgets/language_toggle.dart';

class ArchiveDeskScreen extends ConsumerWidget {
  const ArchiveDeskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final entries = ref.watch(archiveEntriesProvider);
    final waiting = entries.where((entry) => !entry.isConfirmed).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF1E2CC),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEntrySheet(context),
        backgroundColor: AppColors.purpleDeep,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(trS(lang, 'Collect something')),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Pushed from the album desk this needs a way back; as its own
            // app (main_archive.dart) it is the root and there is nowhere
            // to go, so the arrow is only drawn when it can actually pop.
            if (Navigator.of(context).canPop())
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4, 2, 0, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BackButton(color: Color(0xFF43271E)),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              sliver: SliverToBoxAdapter(
                child: _DeskHeader(
                  total: entries.length,
                  waiting: waiting,
                  lang: lang,
                ),
              ),
            ),
            if (entries.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyDesk(
                  lang: lang,
                  onAdd: () => _openEntrySheet(context),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
                sliver: SliverList.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _ArchiveFolder(
                    entry: entries[index],
                    lang: lang,
                    onTap: () =>
                        _openEntrySheet(context, entry: entries[index]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEntrySheet(BuildContext context, {ArchiveEntry? entry}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFFFFBF4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ArchiveEntryForm(entry: entry),
    );
  }
}

class _DeskHeader extends StatelessWidget {
  const _DeskHeader({
    required this.total,
    required this.waiting,
    required this.lang,
  });

  final int total;
  final int waiting;
  final AppLang lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF6A4230),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF43271E), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🗄️', style: TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trS(lang, 'The Archive Desk'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xFFFFF0D6),
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      trS(
                        lang,
                        'Collect first. Confirm carefully. Publish later.',
                      ),
                      style: const TextStyle(
                        color: Color(0xFFE8CFB0),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const LanguageToggle(compact: true),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DeskLabel(text: '$total ${trS(lang, 'collected')}'),
              _DeskLabel(text: '$waiting ${trS(lang, 'need confirmation')}'),
              _DeskLabel(text: trS(lang, 'On this device only')),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeskLabel extends StatelessWidget {
  const _DeskLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF3E281F),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFB9915F)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFFFEBCB),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyDesk extends StatelessWidget {
  const _EmptyDesk({required this.lang, required this.onAdd});

  final AppLang lang;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 20, 26, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📂', style: TextStyle(fontSize: 58)),
            const SizedBox(height: 14),
            Text(
              trS(lang, 'The first folder is waiting'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trS(
                lang,
                'Save a real memory, question, photograph note, or recording idea. Nothing collected here appears in the family app yet.',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.create_new_folder_rounded),
              label: Text(trS(lang, 'Start a folder')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveFolder extends StatelessWidget {
  const _ArchiveFolder({
    required this.entry,
    required this.lang,
    required this.onTap,
  });

  final ArchiveEntry entry;
  final AppLang lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = entry.isConfirmed
        ? const Color(0xFF3E7652)
        : const Color(0xFF9A6422);
    return Semantics(
      button: true,
      label: '${entry.title}. ${_statusLabel(entry.status, lang)}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 14, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1AD74)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F4A2C1D),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7C98F),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    _kindEmoji(entry.kind),
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${trS(lang, 'Source')}: ${entry.sourceName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.11),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          _statusLabel(entry.status, lang),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit_note_rounded, color: Color(0xFF8A6848)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchiveEntryForm extends ConsumerStatefulWidget {
  const _ArchiveEntryForm({this.entry});

  final ArchiveEntry? entry;

  @override
  ConsumerState<_ArchiveEntryForm> createState() => _ArchiveEntryFormState();
}

class _ArchiveEntryFormState extends ConsumerState<_ArchiveEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _details;
  late final TextEditingController _source;
  late ArchiveEntryKind _kind;
  late ArchiveEntryStatus _status;
  DateTime? _eventDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _title = TextEditingController(text: entry?.title);
    _details = TextEditingController(text: entry?.details);
    _source = TextEditingController(text: entry?.sourceName);
    _kind = entry?.kind ?? ArchiveEntryKind.memory;
    _status = entry?.status ?? ArchiveEntryStatus.needsConfirmation;
    _eventDate = entry?.eventDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _details.dispose();
    _source.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 12, 18, bottom + 18),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4C2AE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                trS(
                  lang,
                  widget.entry == null
                      ? 'New archive folder'
                      : 'Review archive folder',
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                trS(
                  lang,
                  'A source is required. Confirmed entries still stay here until a separate publishing step is built.',
                ),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              DropdownButtonFormField<ArchiveEntryKind>(
                initialValue: _kind,
                decoration: InputDecoration(
                  labelText: trS(lang, 'Kind of material'),
                ),
                items: [
                  for (final kind in ArchiveEntryKind.values)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(
                        '${_kindEmoji(kind)}  ${_kindLabel(kind, lang)}',
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _kind = value ?? _kind),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: trS(lang, 'Title or question'),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? trS(lang, 'Give this folder a title')
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _details,
                minLines: 3,
                maxLines: 7,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: trS(lang, 'What we know so far'),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _source,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: trS(lang, 'Who supplied this or can confirm it?'),
                  prefixIcon: const Icon(Icons.record_voice_over_rounded),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? trS(lang, 'Name the person who can verify it')
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<ArchiveEntryStatus>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: trS(lang, 'Verification'),
                ),
                items: [
                  for (final status in ArchiveEntryStatus.values)
                    DropdownMenuItem(
                      value: status,
                      child: Text(_statusLabel(status, lang)),
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _status = value ?? _status),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_rounded),
                label: Text(
                  _eventDate == null
                      ? trS(lang, 'Add a known date (optional)')
                      : DateFormat.yMMMd().format(_eventDate!),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.inventory_2_rounded),
                  label: Text(trS(lang, 'Keep in the Archive Desk')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final now = DateTime.now();
    final existing = widget.entry;
    final entry = ArchiveEntry.create(
      id: existing?.id ?? 'archive-${now.microsecondsSinceEpoch}',
      kind: _kind,
      title: _title.text,
      details: _details.text,
      sourceName: _source.text,
      status: _status,
      createdAt: existing?.createdAt ?? now,
      eventDate: _eventDate,
    );
    await ref.read(archiveEntriesProvider.notifier).save(entry);
    if (mounted) Navigator.of(context).pop();
  }
}

String _kindLabel(ArchiveEntryKind kind, AppLang lang) =>
    trS(lang, switch (kind) {
      ArchiveEntryKind.memory => 'Memory',
      ArchiveEntryKind.photograph => 'Photograph',
      ArchiveEntryKind.letter => 'Letter',
      ArchiveEntryKind.voice => 'Voice recording',
      ArchiveEntryKind.birthday => 'Birthday',
      ArchiveEntryKind.recipe => 'Recipe',
      ArchiveEntryKind.familyFact => 'Family fact',
    });

String _kindEmoji(ArchiveEntryKind kind) => switch (kind) {
  ArchiveEntryKind.memory => '📖',
  ArchiveEntryKind.photograph => '🌼',
  ArchiveEntryKind.letter => '💌',
  ArchiveEntryKind.voice => '🎙️',
  ArchiveEntryKind.birthday => '🎂',
  ArchiveEntryKind.recipe => '🥣',
  ArchiveEntryKind.familyFact => '🌿',
};

String _statusLabel(ArchiveEntryStatus status, AppLang lang) => trS(
  lang,
  status == ArchiveEntryStatus.confirmed
      ? 'Confirmed by source'
      : 'Needs confirmation',
);
