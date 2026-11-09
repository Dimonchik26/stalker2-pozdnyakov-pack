@echo off
chcp 65001 >nul
setlocal
set "SRC=%~dp0"
rem ================== ШЛЯХ ДО ГРИ (необов'язково) ==================
rem Якщо гра лежить у нестандартному місці - впишіть шлях до папки гри
rem між лапками, наприклад:
rem   set "CUSTOM_GAME_PATH=D:\Games\S.T.A.L.K.E.R. 2"
rem Або впишіть шлях одним рядком у файл game_path.txt поруч із цим .bat.
rem Знайдений шлях запам'ятовується в game_path.txt автоматично.
set "CUSTOM_GAME_PATH="
rem =================================================================
if not exist "%SRC%paks\z_CarryWeight200_P.pak" (
  echo [!] Спочатку розпакуйте архів повністю ^(ПКМ - Видобути все^).
  pause
  exit /b
)
echo ==================================================
echo   S.T.A.L.K.E.R. 2 - Мод на вагу 200 кг ^(для патча 2.0.x^)
echo   Збірка від Pozdnyakova
echo ==================================================
echo  Закрийте гру перед встановленням.
echo.
call :findgame %1
if not defined GAME goto nogame
set "MODS=%GAME%\Stalker2\Content\Paks\~mods"
if not exist "%MODS%\" mkdir "%MODS%"
if exist "%MODS%\z_CarryWeight200.pak" del /q "%MODS%\z_CarryWeight200.pak" && echo [OK] Видалено стару версію z_CarryWeight200.pak ^(давала чорний екран під час сну^).
copy /y "%SRC%paks\z_CarryWeight200_P.pak" "%MODS%\" >nul
if errorlevel 1 goto copyfail
echo [OK] Встановлено z_CarryWeight200_P.pak
echo.
pause
exit /b

:nogame
echo [!] Папку гри не знайдено. Запустіть ще раз і вкажіть шлях вручну.
pause
exit /b

:copyfail
echo [!] Не вдалося скопіювати. Закрийте гру і запустіть від імені адміністратора.
pause
exit /b

:findgame
call :findgame_core %1
if not defined GAME exit /b
>"%SRC%game_path.txt" echo %GAME%
exit /b

:findgame_core
set "GAME="
if not "%~1"=="" call :trypath "%~1"
if defined GAME exit /b
if defined CUSTOM_GAME_PATH call :trypath "%CUSTOM_GAME_PATH%"
if defined GAME exit /b
if defined CUSTOM_GAME_PATH echo [!] Шлях у CUSTOM_GAME_PATH не підходить - шукаю гру сам.
set "SAVED="
if exist "%SRC%game_path.txt" set /p SAVED=<"%SRC%game_path.txt"
if defined SAVED call :trypath "%SAVED%"
if defined GAME exit /b
if not defined GAME call :trypath "%CD%"
if not defined GAME call :trypath "%SRC%."
if defined GAME exit /b
echo Шукаю папку гри, це може зайняти до кількох хвилин...
for %%D in (C D E F G H I J) do for %%R in ("Games" "Ігри" "Игры" "Program Files (x86)" "Program Files" "SteamLibrary" "XboxGames" "Steam") do if not defined GAME if exist "%%D:\%%~R\" call :searchroot "%%D:\%%~R"
if defined GAME exit /b
echo.
echo Папку гри не знайдено автоматично.
echo Вкажіть папку гри або папку ~mods ^(можна перетягнути папку в це вікно^).
set "P="
set /p "P=Шлях: "
if defined P call :trypath "%P%"
exit /b

:searchroot
for /f "delims=" %%E in ('where /r "%~1" Stalker2-Win64-Shipping.exe 2^>nul') do if not defined GAME call :trypath "%%~dpE"
exit /b

:trypath
set "T=%~1"
set "T=%T:"=%"
if "%T:~-1%"=="\" set "T=%T:~0,-1%"
for %%U in ("%T%" "%T%\.." "%T%\..\.." "%T%\..\..\.." "%T%\..\..\..\..") do if not defined GAME if exist "%%~fU\Stalker2\Content\Paks\" set "GAME=%%~fU"
exit /b
