.PHONY: help bump-build bump-patch bump-minor bump-major version

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

