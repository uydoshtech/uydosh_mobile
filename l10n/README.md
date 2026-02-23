# Localization (l10n)

This app uses Flutter's ARB-based localization. Strings are stored in:

- `app_en.arb` – English (template)
- `app_ru.arb` – Russian
- `app_uz.arb` – Uzbek

## Regenerating localizations

After editing any `.arb` file, run:

```bash
flutter gen-l10n
```

This updates `lib/l10n/app_localizations.dart` and the per-locale files.

## Extracting strings from app_strings.dart

To re-sync ARB files from the legacy `app_strings.dart` (e.g. after adding new keys there):

```bash
python3 scripts/extract_strings_to_arb.py
flutter gen-l10n
```

## Usage

**With `BuildContext`** (preferred for new code):

```dart
import 'package:uy_dosh/base/localization/l10n_extension.dart';

Text(context.l10n.home)
Text(context.l10n.compatibility_match_percentage("75"))
```

**Without context** (blocs, callbacks):

```dart
import 'package:uy_dosh/base/localization/l10n.dart';

L10n.get("home")
L10n.getWithParams("compatibility_match_percentage", params: {"percent": "75"})
```

## Migration path

Gradually replace `L10n.get("key")` with `context.l10n.key` when you have a `BuildContext`. The ARB files are the source of truth; `app_strings.dart` remains as a fallback for context-less usage until migration is complete.
