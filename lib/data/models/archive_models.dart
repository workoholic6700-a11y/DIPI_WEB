/// The kinds of real material that can be collected at the Archive Desk.
enum ArchiveEntryKind {
  memory,
  photograph,
  letter,
  voice,
  birthday,
  recipe,
  familyFact,
}

/// Whether an archive entry is ready to be treated as family history.
enum ArchiveEntryStatus { needsConfirmation, confirmed }

/// A device-local record made at the Archive Desk.
///
/// Archive entries are deliberately separate from the viewer models. Saving a
/// note here never makes it appear as a memory, birthday, recipe, or other fact
/// in the family app. A later publishing workflow must make that choice
/// explicitly.
class ArchiveEntry {
  ArchiveEntry._({
    required this.id,
    required this.kind,
    required this.title,
    required this.details,
    required this.sourceName,
    required this.status,
    required this.createdAt,
    this.eventDate,
  });

  factory ArchiveEntry.create({
    required String id,
    required ArchiveEntryKind kind,
    required String title,
    required String details,
    required String sourceName,
    required ArchiveEntryStatus status,
    required DateTime createdAt,
    DateTime? eventDate,
  }) {
    final cleanId = id.trim();
    final cleanTitle = title.trim();
    final cleanSource = sourceName.trim();
    if (cleanId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'must not be empty');
    }
    if (cleanTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'must not be empty');
    }
    if (cleanSource.isEmpty) {
      throw ArgumentError.value(
        sourceName,
        'sourceName',
        'must name who supplied or can confirm this entry',
      );
    }

    return ArchiveEntry._(
      id: cleanId,
      kind: kind,
      title: cleanTitle,
      details: details.trim(),
      sourceName: cleanSource,
      status: status,
      createdAt: createdAt,
      eventDate: eventDate,
    );
  }

  factory ArchiveEntry.fromJson(Map<String, dynamic> json) {
    return ArchiveEntry.create(
      id: json['id'] as String,
      kind: ArchiveEntryKind.values.byName(json['kind'] as String),
      title: json['title'] as String,
      details: json['details'] as String? ?? '',
      sourceName: json['sourceName'] as String,
      status: ArchiveEntryStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      eventDate: json['eventDate'] == null
          ? null
          : DateTime.parse(json['eventDate'] as String),
    );
  }

  final String id;
  final ArchiveEntryKind kind;
  final String title;
  final String details;

  /// The person who supplied this information, or who can confirm it.
  final String sourceName;
  final ArchiveEntryStatus status;
  final DateTime createdAt;
  final DateTime? eventDate;

  bool get isConfirmed => status == ArchiveEntryStatus.confirmed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'title': title,
    'details': details,
    'sourceName': sourceName,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'eventDate': eventDate?.toIso8601String(),
  };
}
