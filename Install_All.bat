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
if not exist "%SRC%1_Optimization\Install.bat" (
  echo [!] Спочатку розпакуйте архів повністю ^(ПКМ - Видобути все^), потім запускайте Install_All.bat з розпакованої папки.
  pause
  exit /b
)
echo ==================================================
echo   S.T.A.L.K.E.R. 2 - встановлення всіх модів
echo   Збірка від Pozdnyakova
echo ==================================================
echo  1. Оптимізація: Engine.ini ^(графіка^) + .pak ^(A-Life, процесор^)
echo  2. Мод на вагу 200 кг
set "NOSP="
if not exist "%SRC%3_Spavner\Install_Spavner.bat" set "NOSP=1"
if not defined NOSP echo  3. Спавнер ^(ReShade + Spawner + UE4SS^)
if defined NOSP echo  ^(спавнер у цю версію не входить - окремий мод, див. README.txt^)
echo.
echo  Закрийте гру перед встановленням.
echo.
call :findgame %1
if not defined GAME goto nogame
echo Папка гри: "%GAME%"
echo.
echo  1 - Встановити все
echo  2 - Вибрати, що встановлювати
echo.
choice /c 12 /n /m "Ваш вибір (1 або 2): "
set "DO_INI=1"
set "DO_PAK=1"
set "DO_W=1"
set "DO_SP=1"
if errorlevel 2 goto ask
goto run

:ask
echo.
choice /c YN /n /m "Оптимізація - Engine.ini (графіка, відеокарта)? (Y/N): "
if errorlevel 2 set "DO_INI="
choice /c YN /n /m "Оптимізація - .pak (A-Life і фізика, процесор)? (Y/N): "
if errorlevel 2 set "DO_PAK="
choice /c YN /n /m "Мод на вагу 200 кг? (Y/N): "
if errorlevel 2 set "DO_W="
if defined NOSP goto run
choice /c YN /n /m "Спавнер? (Y/N): "
if errorlevel 2 set "DO_SP="

:run
if defined NOSP set "DO_SP="
set "PAKS=%GAME%\Stalker2\Content\Paks"
if not exist "%PAKS%\No_Shader_Warmup_p.pak" goto step1
echo.
echo [!] Знайдено No_Shader_Warmup_p.pak - він вимикає компіляцію шейдерів
echo     і заважає моду оптимізації ^(фризи при появі NPC^).
choice /c YN /n /m "Перенести його в Stalker2\Content\ModBackup? (Y/N): "
if errorlevel 2 goto step1
if not exist "%GAME%\Stalker2\Content\ModBackup\" mkdir "%GAME%\Stalker2\Content\ModBackup"
move /y "%PAKS%\No_Shader_Warmup_p.pak" "%GAME%\Stalker2\Content\ModBackup\" >nul && echo [OK] No_Shader_Warmup_p.pak перенесено в ModBackup.

:step1
if not defined DO_INI goto step2
echo.
echo ---------- 1/4  Оптимізація: Engine.ini ----------
call "%SRC%1_Optimization\Install.bat" "%GAME%"
:step2
if not defined DO_PAK goto step3
echo.
echo ---------- 2/4  Оптимізація: .pak ----------
call "%SRC%1_Optimization\Install_Pak.bat" "%GAME%"
:step3
if not defined DO_W goto step4
echo.
echo ---------- 3/4  Мод на вагу 200 кг ----------
call "%SRC%2_CarryWeight_200kg\Install_CarryWeight_200kg.bat" "%GAME%"
:step4
if not defined DO_SP goto finish
echo.
echo ---------- 4/4  Спавнер ----------
call "%SRC%3_Spavner\Install_Spavner.bat" "%GAME%"

:finish
echo.
echo ==================================================
echo  Готово.
echo  У грі: усі налаштування на мінімум, згладжування TSR,
echo  роздільність TSR 50 ^(для пресету 5 - 40^), динамічна роздільність
echo  і генерація кадрів - вимкнені, текстури - Низькі.
if not defined NOSP echo  Спавнер: F2 ^(на ноутбуці може бути Fn+F2^).
echo  Детальний опис модів - README.txt
echo  Якщо щось не встановилось - MANUAL_INSTALL.txt
echo ==================================================
pause
exit /b

:nogame
echo [!] Папку гри не знайдено. Запустіть ще раз і вкажіть шлях вручну
echo     ^(або впишіть його в CUSTOM_GAME_PATH на початку цього файлу^).
echo     Або встановіть моди вручну за інструкцією MANUAL_INSTALL.txt.
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
echo Вкажіть папку гри ^(можна перетягнути папку в це вікно^).
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
for %%U in ("%T%" "%T%\.." "%T%\..\.." "%T%\..\..\.." "%T%\..\..\..\..") do if not defined GAME if exist "%%~fU\Stalker2\Binaries\Win64\Stalker2-Win64-Shipping.exe" set "GAME=%%~fU"
exit /b
