#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME=${1:-give_me}

echo "Creating Flutter project: $PROJECT_NAME"
flutter create "$PROJECT_NAME"

echo "Copying skeleton files into $PROJECT_NAME"
cp -R lib assets pubspec.yaml README.md "$PROJECT_NAME"/

echo "Done. Next:"
echo "  cd $PROJECT_NAME"
echo "  flutter pub get"
echo "  flutter run"
