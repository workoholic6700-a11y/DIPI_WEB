# Our Home · web app

The Rai family app — the same one as the phone app in `../DIPI` — built to run
in a browser. It is a copy. Nothing here changes the phone app, and nothing in
the phone app changes this.

## Run it on this computer

```powershell
flutter run -d edge -t lib/main_viewer.dart --dart-define-from-file=env.json
```

Always pass `-t lib/main_viewer.dart` (there is no `lib/main.dart`) and
`--dart-define-from-file=env.json` (without it the app runs in demo mode with
the bundled photos only). `env.json` is never committed.

## Build the website

```powershell
flutter build web --release -t lib/main_viewer.dart --dart-define-from-file=env.json
```

The finished site is `build/web`. To try the build itself, serve that folder,
e.g. `python -m http.server 8080 --bind 127.0.0.1 --directory build/web`, and
open <http://127.0.0.1:8080>. Opening `index.html` straight from disk does not
work; browsers block it.

## Publish on GitHub Pages

`.github/workflows/publish-web.yml` builds and publishes the site every time
`main` is pushed.

1. Create a repository on your **personal** GitHub account and push this
   folder to its `main` branch.
2. In the repository: **Settings → Pages → Source: GitHub Actions**.
3. **Settings → Secrets and variables → Actions**, add `SUPABASE_URL` and
   `SUPABASE_ANON_KEY` with the same values as `env.json`. Only the anon /
   publishable key — the workflow refuses a secret key.
4. **Actions → Publish web app → Run workflow** (or push again). The address
   appears on the finished run: `https://<username>.github.io/<repository>/`.

Anyone with that address can open the site and everything bundled in it —
photos, letters, names, places. GitHub Pages has no password. `noindex` keeps
it out of search results but does not make it private.

## How the web copy differs from the phone app

Only where a browser can't do what Android does:

| On the phone | In the browser |
| --- | --- |
| Download photo → Pictures/Our Home | Downloads to the browser's Downloads folder |
| Village postcard **Save** → Pictures/Our Home | Downloads the postcard |
| Village postcard **Share** → Android share sheet | Phone browsers open the share sheet; computer browsers download it and say so |
| Dipisha's World turns the phone sideways by itself | A browser can't force rotation — turn the phone by hand |
| The app fills the phone | On a wide window (laptop, tablet) the app stays phone width in the middle; Dipisha's World and her rooms use the whole window |
| Taps give a small vibration | No vibration |

Web-only files, which don't exist in the phone app:

- `lib/core/utils/browser_file.dart`, `browser_file_stub.dart`, `browser_file_web.dart`
- `lib/core/web/phone_frame.dart`
- `web/index.html`, `web/manifest.json`, `.github/workflows/publish-web.yml`
- `test/web_shell_test.dart`, and `test/launcher_icon_test.dart` (web icons only)

Files that exist in both apps but have web lines added:

- `lib/main_viewer.dart` — wraps the app in `PhoneFrame`
- `lib/shared/widgets/landscape_scope.dart`, `portrait_scope.dart` — `ScreenShape`
- `lib/data/gallery/photo_download_service.dart` — `kIsWeb` download
- `lib/features/viewer/village/village_photography.dart` — `kIsWeb` save and share

## Bringing over changes from the phone app

Copy the changed files from `../DIPI/lib` (and `assets/`) into this folder,
**except** the five files just above — merge those by hand, or the web
additions are lost. Then:

```powershell
flutter analyze
flutter test
```

`test/web_shell_test.dart` fails if the web lines were overwritten.
