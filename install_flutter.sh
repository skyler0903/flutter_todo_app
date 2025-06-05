#!/bin/bash

# Install Flutter
git clone https://github.com/flutter/flutter.git -b stable --depth 1
export PATH="$PATH:`pwd`/flutter/bin"

# Ensure Flutter dependencies are installed
flutter doctor
flutter pub get

# Build the Flutter web app
flutter build web
