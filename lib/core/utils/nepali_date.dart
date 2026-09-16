import 'package:nepali_utils/nepali_utils.dart';

/// Bikram Sambat (BS) date helpers. The family thinks of birthdays in BS
/// (e.g. Diksha चैत १३, २०६१), so when the app is in Nepali we show BS dates in
/// Devanagari using the maintained `nepali_utils` calendar (no hand-typed table).

/// "जेठ १४, २०७५" — full BS date with month name, day and year in Devanagari.
String bsLongDate(DateTime ad) => NepaliDateFormat('MMMM d, yyyy', Language.nepali)
    .format(ad.toNepaliDateTime());

/// "जेठ १४" — BS day + month name (no year), for compact captions.
String bsDayMonth(DateTime ad) =>
    NepaliDateFormat('MMMM d', Language.nepali).format(ad.toNepaliDateTime());

/// "२०७५" — BS year only, in Devanagari.
String bsYear(DateTime ad) =>
    NepaliDateFormat('yyyy', Language.nepali).format(ad.toNepaliDateTime());

/// The BS weekday + full date, e.g. "आइतबार, असार ३०, २०८३".
String bsFullWithWeekday(DateTime ad) =>
    NepaliDateFormat('EEE, MMMM d, yyyy', Language.nepali)
        .format(ad.toNepaliDateTime());
