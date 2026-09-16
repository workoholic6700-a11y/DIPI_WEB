// Convert BS dates the family gives us into AD. Not app code — a command-line
// helper, so printing is the whole point of it.
//
// Run with:  dart run tool/convert_bs.dart
//
// Never convert these by hand: BS month lengths vary year to year, so only the
// maintained package gets it right. Edit the map below and re-run.
// ignore_for_file: avoid_print
import 'package:nepali_utils/nepali_utils.dart';

void main() {
  // Baisakh=1, Jestha=2, Ashadh=3, Shrawan=4, Bhadra/Bhadau=5, Ashwin=6,
  // Kartik=7, Mangsir=8, Poush=9, Magh=10, Falgun=11, Chaitra=12
  const given = <String, (int, int, int)>{
    'Mummy (Sanchu)  2044 Baisakh 5': (2044, 1, 5),
    'Papa (Rup Raj)  2043 Jestha 7': (2043, 2, 7),
    'Kopa (Dalbahadur) 2025 Bhadau 15': (2025, 5, 15),
  };

  final now = DateTime.now();
  for (final e in given.entries) {
    final (y, m, d) = e.value;
    final ad = NepaliDateTime(y, m, d).toDateTime();
    var age = now.year - ad.year;
    if (now.month < ad.month || (now.month == ad.month && now.day < ad.day)) {
      age--;
    }
    print(e.key);
    print('   AD  ${ad.year}-${ad.month.toString().padLeft(2, '0')}-'
        '${ad.day.toString().padLeft(2, '0')}   (age $age today)');
    print('   BS  ${NepaliDateFormat('MMMM d, yyyy', Language.nepali)
        .format(NepaliDateTime(y, m, d))}');
    print('');
  }
}
