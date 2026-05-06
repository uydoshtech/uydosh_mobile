.PHONY: help bump-build bump-patch bump-minor bump-major version build-apk build-aab build-ios

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

version: ## Show current version
	@echo "Current version:"
	@grep '^version:' pubspec.yaml

bump-build: ## Bump build number (1.0.0+1 -> 1.0.0+2)
	@echo "Bumping build number..."
	@python3 scripts/bump_version.py build

bump-patch: ## Bump patch version (1.0.0+1 -> 1.0.1+1)
	@echo "Bumping patch version..."
	@python3 scripts/bump_version.py patch

bump-minor: ## Bump minor version (1.0.0+1 -> 1.1.0+1)
	@echo "Bumping minor version..."
	@python3 scripts/bump_version.py minor

bump-major: ## Bump major version (1.0.0+1 -> 2.0.0+1)
	@echo "Bumping major version..."
	@python3 scripts/bump_version.py major

commit-version: bump-build ## Bump version and commit changes
	@echo "Committing version bump..."
	@git add pubspec.yaml lib/presentation/widgets/burger_menu_widget.dart lib/base/constants/app_version.dart
	@git commit -m "Bump version [skip ci]"
	@echo "Version bumped and committed!"

# Release build targets.
#
# Flags:
#   --tree-shake-icons               Strip unused glyphs from MaterialIcons /
#                                    CupertinoIcons (~1.5–3 MB).
#   --obfuscate                      Strip Dart symbol names from the AOT
#                                    snapshot.
#   --split-debug-info=...           Required by --obfuscate; keep these
#                                    symbols safe (commit them or upload to
#                                    Crashlytics) so we can desymbolicate
#                                    stack traces from production crashes.
#   --split-per-abi (APK)            Emits one APK per ABI instead of a fat
#                                    universal APK (~40% install size
#                                    reduction). Play Store users get the
#                                    equivalent automatically through the AAB
#                                    target.
#   --target-platform=$(ANDROID_PLATFORMS)
#                                    Restricts Flutter's per-ABI Dart AOT
#                                    snapshots to arm64-v8a only. We dropped
#                                    armv7 (32-bit) — the userbase on
#                                    pre-2017 ARM-only devices is negligible
#                                    on Android 8+ (our minSdk=26) and the
#                                    32-bit slice contributes ~9–11 MB of
#                                    duplicated `libapp.so` + `libflutter.so`
#                                    + native plugin code per device.
#                                    The Gradle `ndk.abiFilters` block alone
#                                    is ignored by Flutter when generating
#                                    per-ABI snapshots, so this flag is the
#                                    one that actually matters. Cuts the AAB
#                                    upload by ~12 MB and shaves CI time too.
#
#                                    To restore armv7 support: change to
#                                    `android-arm,android-arm64` here AND
#                                    add `'armeabi-v7a'` back to
#                                    `ndk.abiFilters` in
#                                    `android/app/build.gradle`.

ANDROID_SYMBOLS := build/symbols/android
IOS_SYMBOLS := build/symbols/ios
ANDROID_PLATFORMS := android-arm64

build-apk: ## Build release per-ABI APKs (sideload only; Play uses AAB)
	flutter build apk --release \
	  --tree-shake-icons \
	  --split-per-abi \
	  --target-platform=$(ANDROID_PLATFORMS) \
	  --obfuscate --split-debug-info=$(ANDROID_SYMBOLS)

build-aab: ## Build release Android App Bundle with tree-shaken icons
	flutter build appbundle --release \
	  --tree-shake-icons \
	  --target-platform=$(ANDROID_PLATFORMS) \
	  --obfuscate --split-debug-info=$(ANDROID_SYMBOLS)

build-ios: ## Build release iOS IPA with tree-shaken icons
	flutter build ipa --release \
	  --tree-shake-icons \
	  --obfuscate --split-debug-info=$(IOS_SYMBOLS)

analyze-size-android: ## Treemap of release AAB contents (open the printed JSON in DevTools)
	flutter build appbundle --release --tree-shake-icons --analyze-size --target-platform=android-arm64

analyze-size-ios: ## Treemap of release iOS contents (open the printed JSON in DevTools)
	flutter build ios --release --tree-shake-icons --analyze-size

