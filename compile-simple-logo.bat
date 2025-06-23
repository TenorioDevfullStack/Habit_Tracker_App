@echo off
echo 🎨 COMPILANDO COM LOGO UNICA...
echo.

echo 📍 Verificando logo...
if exist "android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" (
    echo ✅ Logo encontrada!
) else (
    echo ❌ Logo nao encontrada! Coloque o arquivo primeiro.
    pause
    exit
)

echo.
echo 🧹 Limpando projeto...
flutter clean

echo 📦 Baixando dependencias...
flutter pub get

echo 🔨 Compilando with nova logo...
flutter build apk --release

echo.
if exist "build\app\outputs\flutter-apk\app-release.apk" (
    echo ✅ SUCESSO! APK gerado com nova logo!
    echo 📱 Arquivo: build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo 🚀 Abrindo pasta do APK...
    explorer build\app\outputs\flutter-apk
) else (
    echo ❌ Erro na compilacao!
)

echo.
pause 