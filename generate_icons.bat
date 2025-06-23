@echo off
echo Gerando icones Android em tamanhos padrao...

REM Definindo cores
set BG_COLOR=#1976D2
set FG_COLOR=#FFFFFF

REM Criando icones em diferentes tamanhos usando magick (se disponivel)
echo Tentando usar ImageMagick para gerar icones...

REM mdpi: 48x48
magick -size 48x48 xc:"%BG_COLOR%" -fill "%FG_COLOR%" -stroke "%FG_COLOR%" -strokewidth 2 -draw "path 'M14,27 L19,32 L34,17'" android/app/src/main/res/mipmap-mdpi/ic_launcher.png 2>nul

REM hdpi: 72x72  
magick -size 72x72 xc:"%BG_COLOR%" -fill "%FG_COLOR%" -stroke "%FG_COLOR%" -strokewidth 3 -draw "path 'M21,40 L29,48 L51,26'" android/app/src/main/res/mipmap-hdpi/ic_launcher.png 2>nul

REM xhdpi: 96x96
magick -size 96x96 xc:"%BG_COLOR%" -fill "%FG_COLOR%" -stroke "%FG_COLOR%" -strokewidth 4 -draw "path 'M28,54 L38,64 L68,34'" android/app/src/main/res/mipmap-xhdpi/ic_launcher.png 2>nul

REM xxhdpi: 144x144
magick -size 144x144 xc:"%BG_COLOR%" -fill "%FG_COLOR%" -stroke "%FG_COLOR%" -strokewidth 6 -draw "path 'M42,81 L57,96 L102,51'" android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png 2>nul

REM xxxhdpi: 192x192
magick -size 192x192 xc:"%BG_COLOR%" -fill "%FG_COLOR%" -stroke "%FG_COLOR%" -strokewidth 8 -draw "path 'M56,108 L76,128 L136,68'" android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png 2>nul

if %errorlevel% neq 0 (
    echo ImageMagick nao encontrado. Vou tentar metodo alternativo...
    goto alternative
)

echo Icones gerados com sucesso!
goto end

:alternative
echo Usando metodo alternativo - Flutter icon generator
echo Para gerar icones, use: flutter pub get e depois flutter pub run flutter_launcher_icons:main

:end
echo Concluido!
pause 