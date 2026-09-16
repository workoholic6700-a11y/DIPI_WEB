# Working on the Our Home web app

This folder is the **web copy** of the Rai family app. The phone app lives in
`../DIPI` and is the original. Diksha asked for the web app to be a separate
copy: **never edit `../DIPI` from work in this folder.**

## Read this first

**[DECISIONS.md](DECISIONS.md)** — choices the family has already made that
look like bugs from the outside. If a change would reverse one, **ask Diksha
first.** The one that catches everyone: tapping the envelope on the Home table
opens Dipisha's World gate, *not* the letter.

It is a family **heirloom**, so the hardest rule is: **never invent a family
fact.** Ship the visible gap and name who can fill it.

It is a private personal project, never associated with anyone's employer. Do
not publish, push or log in to hosting from this PC — Diksha publishes it
herself from her own GitHub account (see README).

## Running it

```powershell
flutter run -d edge -t lib/main_viewer.dart --dart-define-from-file=env.json
flutter build web --release -t lib/main_viewer.dart --dart-define-from-file=env.json
```

Always pass both `-t` and `--dart-define-from-file=env.json`.

## Web-only code

Every difference from the phone app is listed in README → "How the web copy
differs", with the files it touches. Keep web additions small and contained so
shared files still match the phone app line for line everywhere else, and keep
`test/web_shell_test.dart` passing. On a wide window the app is shown at phone
width (`PhoneFrame`) — don't design wide layouts; the screens are phone screens.

## The design direction

Same as the phone app: every screen is a place or an object in the family home,
not a webpage of cards. **Nothing loops** (the garden visitors are the one
chosen exception, see DECISIONS.md). **Nothing is claimed** — no badge for a
state the models don't store.

## Conventions

- Nepali via `trS(lang, 'English string')`; add the pair to `core/i18n/l10n.dart`.
- BS dates via `nepali_utils` — never convert a date by hand.
- Short names via `FamilyMember.shortName`, never `name.split(' ').first`.
- Photos through `AppPhotos` slots, always with an `errorBuilder`.
- When you fix something the project cares about, write a test, not a comment.
