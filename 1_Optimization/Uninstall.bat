@echo off
chcp 65001 >nul
rem Збірка від Pozdnyakova
setlocal
for %%F in (Windows WinGDK) do call :restore "%LOCALAPPDATA%\Stalker2\Saved\Config\%%F"
echo Готово. .pak видаляється окремо: Uninstall_Pak.bat
pause
exit /b

:restore
if not exist "%~1\Engine.ini" exit /b
attrib -r "%~1\Engine.ini" >nul
if exist "%~1\Engine.ini.bak" (
  copy /y "%~1\Engine.ini.bak" "%~1\Engine.ini" >nul
  del "%~1\Engine.ini.bak"
  echo [OK] Відновлено старий Engine.ini
) else (
  ren "%~1\Engine.ini" "Engine.ini.disabled"
  echo [OK] Engine.ini моду вимкнено
)
exit /b
