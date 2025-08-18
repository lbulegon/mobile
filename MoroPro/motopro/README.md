# motopro

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

flutter clean
flutter pub get
flutter pub run flutter_launcher_icons:main
flutter run

Celular Sem cabo

- adb shell ip route
- adb tcpip 5555
- adb connect 192.168.0.31:5555 
- adb devices



Pra gerar o APK é isso aqui:

bash
Copiar
Editar
# Release (único APK universal — maior)
flutter build apk --release
Saída: build/app/outputs/flutter-apk/app-release.apk

Dicas úteis:

APK por arquitetura (menor tamanho):

bash
Copiar
Editar
flutter build apk --release --split-per-abi
Saídas:
app-armeabi-v7a-release.apk, app-arm64-v8a-release.apk, app-x86_64-release.apk

Se você usa flavors:

bash
Copiar
Editar
flutter build apk --release --flavor prod -t lib/main_prod.dart
Instalar no dispositivo:

bash
Copiar
Editar
adb install -r build/app/outputs/flutter-apk/app-release.apk
Para Play Store, prefira AAB:

bash
Copiar
Editar
flutter build appbundle --release
Saída: build/app/outputs/bundle/release/app-release.aab

Obs.: garanta que o app está assinado no release (keystore configurado em android/key.properties e referenciado no build.gradle).