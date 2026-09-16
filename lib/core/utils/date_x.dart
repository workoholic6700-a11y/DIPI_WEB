import 'package:intl/intl.dart';

/// Date & time helpers used across the app.
extension DateX on DateTime {
  String get prettyDate => DateFormat('d MMMM, yyyy').format(this);
  String get shortDate => DateFormat('d MMM yyyy').format(this);
  String get dayMonth => DateFormat('d MMM').format(this);
  String get weekdayLong => DateFormat('EEEE').format(this);
  String get yearOnly => DateFormat('yyyy').format(this);
  String get timeOfDay => DateFormat('h:mm a').format(this);

  /// "Today", "Yesterday", or a friendly date.
  String get relativeLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final that = DateTime(year, month, day);
    final diff = today.difference(that).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) return '$diff days ago';
    return prettyDate;
  }

  /// Age in whole years from this birthday until [now].
  int ageOn([DateTime? now]) {
    final ref = now ?? DateTime.now();
    var age = ref.year - year;
    if (ref.month < month || (ref.month == month && ref.day < day)) age--;
    return age;
  }

  /// The next occurrence of this month/day on or after [now] (for birthdays).
  DateTime nextAnniversary([DateTime? now]) {
    final ref = now ?? DateTime.now();
    var next = DateTime(ref.year, month, day);
    if (next.isBefore(DateTime(ref.year, ref.month, ref.day))) {
      next = DateTime(ref.year + 1, month, day);
    }
    return next;
  }

  int daysUntilNextAnniversary([DateTime? now]) {
    final ref = now ?? DateTime.now();
    final today = DateTime(ref.year, ref.month, ref.day);
    return nextAnniversary(ref).difference(today).inDays;
  }
}

/// Time-of-day greeting shown on the home screen ("Good Morning Dipisha 🌸").
String greetingForNow([DateTime? now]) {
  final hour = (now ?? DateTime.now()).hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  if (hour < 21) return 'Good Evening';
  return 'Good Night';
}
