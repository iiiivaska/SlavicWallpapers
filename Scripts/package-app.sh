#!/bin/bash

# Конфигурация
APP_NAME="SlavicWallpapers"
ZIP_NAME="SlavicWallpaper-1.0.zip"

# Определяем возможные пути к собранному приложению
DERIVED_DIR="$HOME/Library/Developer/Xcode/DerivedData"
PROJECT_DIR="$(pwd)/.."
BUILD_DIRS=(
    "$DERIVED_DIR"
    "$PROJECT_DIR/build"
    "$PROJECT_DIR/DerivedData"
    "$PROJECT_DIR"
)

# Поиск приложения
APP_PATH=""
for dir in "${BUILD_DIRS[@]}"; do
    echo "Поиск в директории: $dir"
    FOUND_PATH=$(find "$dir" -name "$APP_NAME.app" -type d 2>/dev/null | grep -E "Debug|Release" | head -n 1)
    if [ ! -z "$FOUND_PATH" ]; then
        APP_PATH="$FOUND_PATH"
        break
    fi
done

if [ -z "$APP_PATH" ]; then
    echo "Ошибка: Приложение не найдено."
    echo "Пожалуйста, убедитесь что:"
    echo "1. Проект собран в Xcode (Product > Build)"
    echo "2. Имя приложения: $APP_NAME"
    echo "3. Проверенные директории:"
    for dir in "${BUILD_DIRS[@]}"; do
        echo "   - $dir"
    done
    exit 1
fi

# Подготовка приложения
echo "Подготовка приложения..."

# Создаем Frameworks директорию если её нет
mkdir -p "$APP_PATH/Contents/Frameworks"

# Удаляем атрибуты карантина и старые подписи
xattr -cr "$APP_PATH"
codesign --remove-signature "$APP_PATH"

# Подписываем все внутренние компоненты
find "$APP_PATH" -name "*.dylib" -type f | while read lib; do
    codesign --force --sign - "$lib"
done

# Подписываем основное приложение
codesign --force --deep --options runtime --sign - "$APP_PATH"

# Проверяем подпись
codesign --verify --verbose=4 "$APP_PATH"

# Очистка
rm -f "$ZIP_NAME"

# Создание архива
echo "Упаковка приложения из: $APP_PATH"
cd "$(dirname "$APP_PATH")"
zip -r "$OLDPWD/$ZIP_NAME" "$(basename "$APP_PATH")"
cd - > /dev/null

echo "Приложение успешно упаковано в $ZIP_NAME"
echo ""
echo "Инструкция по установке:"
echo "1. Распакуйте архив"
echo "2. Перетащите $APP_NAME.app в папку Applications"
echo "3. При первом запуске:"
echo "   - Нажмите Control + клик на приложении"
echo "   - Выберите 'Открыть'"
echo "   - Нажмите 'Открыть' в диалоговом окне" 