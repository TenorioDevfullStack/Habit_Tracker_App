@echo off
echo 🎨 COMPILANDO COM NOVA LOGO...
echo.

echo 🧹 Limpando projeto...
flutter clean

echo 📦 Baixando dependencias...
flutter pub get

echo 🔨 Compilando APK com nova logo...
flutter build apk --release

echo.
echo ✅ PRONTO! Nova logo implementada!
echo 📱 APK gerado: build\app\outputs\flutter-apk\app-release.apk
echo.
pause 