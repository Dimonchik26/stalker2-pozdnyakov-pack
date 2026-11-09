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
if not exist "%SRC%presets\Performance\Engine.ini" (
  echo [!] Спочатку розпакуйте архів повністю ^(ПКМ - Видобути все^), потім запускайте файл з розпакованої папки.
  pause
  exit /b
)
echo ==================================================
echo   S.T.A.L.K.E.R. 2 - мод оптимізації v4.5: Engine.ini
echo   Збірка від Pozdnyakova
echo ==================================================
echo.
echo  Пресети від найкращої картинки до найбільшого FPS
echo  ^(орієнтовно, у полі; у поселеннях FPS нижчий через процесор^):
echo.
echo  1 - Продуктивність              ~30 FPS
echo  2 - Максимальна продуктивність  35-40 FPS
echo  3 - Найвища продуктивність      40-45 FPS
echo  4 - Недо-жорстка                45-50 FPS
echo  5 - Жорстка 60ФПС               60+ FPS  ^(графіка в стилі "Поклик Прип'яті"^)
echo.
echo  У грі: всі налаштування на мінімум, згладжування TSR, роздільність TSR 50
echo  ^(для пресету 5 - 40^). Мало FPS або фризи - ставте менше 50.
echo.
choice /c 12345 /n /m "Оберіть пресет (1-5): "
set "PRESET=Performance"
if errorlevel 2 set "PRESET=MaxPerf"
if errorlevel 3 set "PRESET=Ultimate"
if errorlevel 4 set "PRESET=SemiHard"
if errorlevel 5 set "PRESET=Hard60"
echo.
echo --------------------------------------------------
echo  КОМПІЛЯЦІЯ ШЕЙДЕРІВ ПРИ ЗАПУСКУ ГРИ
echo  Рекомендуємо ЗАЛИШИТИ. Довго вона йде лише перший раз ^(і після
echo  оновлення гри, драйвера або зміни налаштувань^), наступні запуски -
echo  кілька секунд.
echo  Якщо вимкнути: гра стартує швидше, але шейдери збиратимуться прямо
echo  під час гри - більше фризів ^(особливо при появі NPC^) і нижча
echo  плавність / продуктивність.
echo --------------------------------------------------
echo  1 - ЗАЛИШИТИ компіляцію ^(рекомендовано^)
echo  2 - вимкнути компіляцію
choice /c 12 /n /m "Ваш вибір (1 або 2): "
set "NOWARM="
if errorlevel 2 set "NOWARM=1"
set "INI_SRC=%SRC%presets\%PRESET%\Engine.ini"
if not defined NOWARM goto warm_done
set "INI_SRC=%TEMP%\s2_engine_nowarmup.ini"
> "%INI_SRC%" echo [SystemSettings]
>> "%INI_SRC%" echo r.PSOWarmup.WarmupMaterials=0
findstr /v /b /l /c:"[SystemSettings]" /c:"r.PSOWarmup.WarmupMaterials=" "%SRC%presets\%PRESET%\Engine.ini" >> "%INI_SRC%"
echo [!] Компіляцію шейдерів буде вимкнено ^(r.PSOWarmup.WarmupMaterials=0^).
:warm_done
echo.
set "INSTALLED="
for %%F in (Windows WinGDK) do call :install "%LOCALAPPDATA%\Stalker2\Saved\Config\%%F"
if not defined INSTALLED (
  echo [!] Папку налаштувань гри не знайдено - запустіть гру один раз і повторіть.
  pause
  exit /b
)
echo.
choice /c YN /n /m "Призначити грі відеокарту NVIDIA та увімкнути макс. продуктивність? (Y/N): "
if errorlevel 2 goto done
call :findgame %1
if not defined GAME goto nogame
for %%E in ("%GAME%\Stalker2\Binaries\Win64\Stalker2-Win64-Shipping.exe" "%GAME%\Stalker2.exe") do if exist %%E reg add "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /v "%%~E" /t REG_SZ /d "GpuPreference=2;" /f >nul
echo [OK] Грі призначено відеокарту NVIDIA.
:nogame
powercfg -setactive SCHEME_MIN >nul 2>&1 && echo [OK] Схема живлення: Висока продуктивність.
:done
echo.
echo Готово. У грі: всі налаштування на мінімум, TSR, роздільність TSR 50, генерація кадрів - вимкнена.
echo Екран 2K ^(2560x1600^) - ставте роздільність 1920x1200. Детальніше в README.txt
echo .pak встановлюється окремо: Install_Pak.bat
pause
exit /b

:install
if not exist "%~1" exit /b
if exist "%~1\Engine.ini" attrib -r "%~1\Engine.ini" >nul
if exist "%~1\Engine.ini" if not exist "%~1\Engine.ini.bak" copy /y "%~1\Engine.ini" "%~1\Engine.ini.bak" >nul
copy /y "%INI_SRC%" "%~1\Engine.ini" >nul || (echo [!] Не вдалося скопіювати в %~1 & exit /b)
attrib +r "%~1\Engine.ini" >nul
set "INSTALLED=1"
echo [OK] Engine.ini ^(%PRESET%^) встановлено: %~1
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
