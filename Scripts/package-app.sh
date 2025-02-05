#!/bin/bash

# Переходим в корневую директорию проекта
cd "$(dirname "$0")/.." || exit 1

# Определяем пути
APP_NAME="SlavicWallpapers"
BUILD_DIR="build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR/Export"
APP_PATH="$EXPORT_PATH/$APP_NAME.app"
DMG_PATH="$BUILD_DIR/$APP_NAME.dmg"

# Очищаем предыдущие сборки
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Архивируем проект
xcodebuild archive \
    -scheme "$APP_NAME" \
    -archivePath "$ARCHIVE_PATH" \
    -configuration Release

# Удаляем атрибуты карантина
xattr -cr "$ARCHIVE_PATH"

# Подписываем все компоненты
find "$ARCHIVE_PATH" -name "*.dylib" -o -name "*.framework" | while read -r file; do
    codesign --force --sign - "$file"
done

# Подписываем приложение
codesign --force --deep --sign - "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app"

# Создаем DMG
mkdir -p "$EXPORT_PATH"
cp -R "$ARCHIVE_PATH/Products/Applications/$APP_NAME.app" "$EXPORT_PATH/"

# Создаем DMG
hdiutil create -volname "$APP_NAME" -srcfolder "$EXPORT_PATH" -ov -format UDZO "$DMG_PATH"

echo "App packaged successfully!"
echo "DMG location: $DMG_PATH" 