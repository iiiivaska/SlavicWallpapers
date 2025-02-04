#!/bin/bash

# Конфигурация
APP_NAME="Slavic Wallpaper"
DMG_NAME="SlavicWallpaper-1.0"
VOLUME_NAME="Slavic Wallpaper"

# Очистка
rm -rf "build/$DMG_NAME.dmg"

# Создание DMG
create-dmg \
  --volname "$VOLUME_NAME" \
  --volicon "Assets/AppIcon.icns" \
  --background "Assets/dmg-background.png" \
  --window-pos 200 120 \
  --window-size 800 400 \
  --icon-size 100 \
  --icon "$APP_NAME.app" 200 190 \
  --hide-extension "$APP_NAME.app" \
  --app-drop-link 600 185 \
  "build/$DMG_NAME.dmg" \
  "build/Release/$APP_NAME.app" 