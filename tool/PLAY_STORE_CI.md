# Google Play automated uploads (Android)

This repo can upload a signed `.aab` to Google Play automatically via GitHub Actions.

## Trigger

- Tag a commit with `android-*` (see `tool/release_android_tag.sh`), then push the tag.
- Or tag both platforms at once with `tool/release_mobile_tags.sh` (creates and pushes both `android-*` and `ios-*` tags).
  - If you want it to bump the version first: `bash tool/release_mobile_tags.sh --bump build --commit`
- Or run the workflow manually via `workflow_dispatch` and choose:
  - `play_track` (default: `internal`)
  - `play_release_status` (default: `draft`)

The workflow builds:
- AAB (for Google Play)

## Required GitHub Secrets

Existing secrets used for Android signing:
- `ANDROID_KEYSTORE_BASE64`: base64 of your `upload-keystore.jks`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_KEY_ALIAS`

New secret for Google Play upload:
- `PLAY_SERVICE_ACCOUNT_JSON_BASE64`: the **service account JSON key** that has access to the app in Play Console.
  - You can store it as **raw JSON** (recommended), or as **base64** (also supported).

To create the base64 value:

```bash
base64 -i path/to/service-account.json | pbcopy
```

## One-time Play Console setup

In Play Console:
- `Setup → API access`: link your Google Cloud project
- Grant the service account access to the app (at least "Release manager")

## Android developer verification (required by Sep 2026)

Google requires apps to have their **package name registered/verified** for “Android developer verification”. If it’s not done, the app may become **not installable on certified Android devices in select countries starting September, 2026**.

- **Package name (applicationId)**: `com.uydosh.app`
  - Source of truth: `android/app/build.gradle` (`namespace` / `applicationId`)
  - Fastlane: `fastlane/Appfile` (`package_name`)

Do the one-time registration for `com.uydosh.app` on the Android developer verification page in Play Console (under your developer account).

## Recommended operating modes

- **Prepare release, manual final publish**:
  - Enable Play Console "Managed publishing"
  - Use `play_release_status = draft`

- **Fully automatic publishing**:
  - Use `play_release_status = completed`
  - (Be cautious: policy/metadata prompts can still block rollout in Play Console.)

