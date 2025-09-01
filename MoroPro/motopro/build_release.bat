@echo off
echo ========================================
echo    MotoPro - Build de Release
echo ========================================
echo.

echo 1. Limpando build anterior...
flutter clean

echo.
echo 2. Obtendo dependencias...
flutter pub get

echo.
echo 3. Gerando icones...
flutter pub run flutter_launcher_icons:main

echo.
echo 4. Gerando APK de release...
flutter build apk --release

echo.
echo 5. Gerando App Bundle (AAB)...
flutter build appbundle --release

echo.
echo ========================================
echo    BUILD CONCLUIDO!
echo ========================================
echo.
echo Arquivos gerados:
echo - APK: build\app\outputs\flutter-apk\app-release.apk
echo - AAB: build\app\outputs\bundle\release\app-release.aab
echo.
echo Para Play Store, use o arquivo AAB!
echo.
pause
