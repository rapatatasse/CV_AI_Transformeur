@echo off
title Assistant de Configuration Pro - Projet CV
pushd "%~dp0"
color 0F

:: --- FONCTIONS ---
:ShowProgress
setlocal
set "label=%~1"
echo.
echo  %label%
for /l %%i in (1,1,20) do (
    set "fill="
    for /l %%j in (1,1,%%i) do set "fill=!fill!█"
    set "void="
    for /l %%j in (%%i,1,20) do set "void=!void!░"
    echo  !fill!!void! (づ｡◕‿‿◕｡)づ
    ping localhost -n 2 >nul
)
echo  [OK]
endlocal
goto :eof

:: --- DEBUT ---
cls
echo.
echo  ==========================================
echo      Installation logiciel Projet CV          
echo  ==========================================
echo.

:: 1. VERIF PYTHON
echo  [1] Analyse de Python...
python --version >temp_py.txt 2>nul
if exist temp_py.txt (
    set /p currentVer=<temp_py.txt
    echo  --> VERSION ACTUELLE : %currentVer%
    del temp_py.txt
    
    :: Simple verification de version (Python 3.12+)
    echo %currentVer% | find "3.12" >nul
    if errorlevel 1 (
        echo  --> Statut : Version trop ancienne.
        echo  Voulez-vous installer Python 3.12 ? (O/N)
        set /p ans=
        if /i "%ans%"=="O" (
            call :ShowProgress "Mise a jour en cours..."
            winget install Python.Python.3.12 --silent --force
            timeout /t 10 >nul
        )
    ) else (
        echo  --> Statut : Ton Python est a jour !
    )
) else (
    echo  --> Statut : Python n'est PAS installe !
    echo  Python est absent. L'installer ? (O/N)
    set /p ans=
    if /i "%ans%"=="O" (
        call :ShowProgress "Installation de Python 3.12..."
        winget install Python.Python.3.12 --silent
        timeout /t 10 >nul
    )
)

:: 2. VERIF INTERPRETEUR PYTHON
echo.
echo  [2] Analyse de l'interpreteur Python...
python -c "import sys; print(sys.executable)" >temp_interp.txt 2>nul
if exist temp_interp.txt (
    set /p interpPath=<temp_interp.txt
    echo  --> INTERPRETEUR : %interpPath%
    echo  --> Statut : Interpreteur Python fonctionnel !
    del temp_interp.txt
) else (
    echo  --> Statut : Interpreteur Python inaccessible.
)

:: 3. VERIF LM STUDIO
echo.
echo  [3] Analyse de LM Studio...
set "lmStudioFound=0"

:: Verification dans les chemins d'installation
if exist "%LOCALAPPDATA%\LM Studio\LM Studio.exe" (
    set "lmStudioFound=1"
    set "lmStudioPath=%LOCALAPPDATA%\LM Studio\LM Studio.exe"
)
if exist "%PROGRAMFILES%\LM Studio\LM Studio.exe" (
    set "lmStudioFound=1"
    set "lmStudioPath=%PROGRAMFILES%\LM Studio\LM Studio.exe"
)
if exist "%PROGRAMFILES(X86)%\LM Studio\LM Studio.exe" (
    set "lmStudioFound=1"
    set "lmStudioPath=%PROGRAMFILES(X86)%\LM Studio\LM Studio.exe"
)

:: Verification via winget
winget list --id "ElementLabs.LMStudio" --exact >temp_winget.txt 2>nul
findstr /i "LM Studio" temp_winget.txt >nul
if not errorlevel 1 set "lmStudioFound=1"
if exist temp_winget.txt del temp_winget.txt

if "%lmStudioFound%"=="1" (
    if defined lmStudioPath (
        echo  --> CHEMINS : %lmStudioPath%
    )
    echo  --> Statut : LM Studio est pret.
    echo  --> LM Studio est pret a etre utilise !
) else (
    echo  --> Statut : LM Studio est PAS installe !
    echo  LM Studio est absent. L'installer ? (O/N)
    set /p ans=
    if /i "%ans%"=="O" (
        call :ShowProgress "Installation de LM Studio..."
        winget install --id ElementLabs.LMStudio --accept-source-agreements --accept-package-agreements --force
        timeout /t 15 >nul
    )
)

echo.
echo  [ Termine ! Appuie sur une touche pour quitter ]
pause >nul
