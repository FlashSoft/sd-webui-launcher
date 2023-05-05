
@echo off
title SD-WebUI Launcher
setlocal ENABLEDELAYEDEXPANSION
echo **********************************************************
echo * SD WebUI Launcher 1.0
echo * Author: FlashSoft
echo **********************************************************

set PYTHON=%~dp0%python\python
set GIT=%~dp0%git\cmd\git
set VENV_DIR=%~dp0%venv
set PATH=%PATH%;%~dp0%git\cmd
set COMMANDLINE_ARGS=

set DEFAULT_WEBUI=stable-diffusion-webui
set WEBUI=stable-diffusion-webui
set DOWNLOAD_DIR=%~dp0%download
set WEBUI_GIT_URL=https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
set GIT_PAGE_URL=https://git-scm.com/downloads
set GIT_DOWNLOAD_URL=https://github.com/git-for-windows/git/releases/download/v2.40.1.windows.1/MinGit-2.40.1-64-bit.zip
set PYTHON_PAGE_URL=https://www.python.org/downloads/windows/
set PYTHON_DOWNLOAD_URL=https://www.python.org/ftp/python/3.10.11/python-3.10.11-embed-amd64.zip

if "%1" neq "" (set WEBUI=%1)
md %DOWNLOAD_DIR%>nul 2<&1

%GIT% >nul 2<&1
if %ERRORLEVEL% neq 1 (
  echo git not found.
  echo download embed python.
  powershell -Command "Invoke-WebRequest -Uri %GIT_DOWNLOAD_URL% -OutFile %DOWNLOAD_DIR%\git.zip"
  echo expand git.
  powershell -Command "Expand-Archive -Path %DOWNLOAD_DIR%\git.zip -DestinationPath .\git"
)
git config --global http.sslverify "false"

%PYTHON% -c "" >nul 2<&1
if %ERRORLEVEL% neq 0 (
  echo python not found.
  echo download python.
  powershell -Command "Invoke-WebRequest -Uri %PYTHON_DOWNLOAD_URL% -OutFile %DOWNLOAD_DIR%\python.zip"
  echo expand python.
  powershell -Command "Expand-Archive -Path %DOWNLOAD_DIR%\python.zip -DestinationPath .\python"
  echo install pip.
  powershell -Command "Invoke-WebRequest -Uri https://bootstrap.pypa.io/get-pip.py -OutFile %DOWNLOAD_DIR%\get-pip.py"
  %PYTHON% %DOWNLOAD_DIR%\get-pip.py
  echo enable python.
  echo import site>> %~dp0%python\python310._pth
  echo install virtualenv.
  %~dp0%python\Scripts\pip install virtualenv
)

if not exist "stable-diffusion-webui" (
  echo sd webui not found.
  echo clone stable-diffusion-webui.
  git clone %WEBUI_GIT_URL% stable-diffusion-webui
)
if not exist %VENV_DIR% (
  echo init venv.
  %PYTHON% -m virtualenv %VENV_DIR%
)


echo check display info.
if not exist "%DOWNLOAD_DIR%\display.txt" (dxdiag /t %DOWNLOAD_DIR%\display.txt)
set DISPLAY_BIZ_NAME=unknown 
set /a DISPLAY_MEM_SIZE=0 M>nul 2<&1 
:check_display
if EXIST "%DOWNLOAD_DIR%\display.txt" (
  for /f "tokens=1,2,* delims=:" %%a in ('findstr /c:" Card name:" /c:"Dedicated Memory:" "%DOWNLOAD_DIR%\display.txt"') do (
  set /a tee+=1
  if !tee! == 1 set DISPLAY_BIZ_NAME=%%b
  if !tee! == 2 set /a DISPLAY_MEM_SIZE=%%b>nul 2<&1 
  )
) else (
  powershell -Command "Start-Sleep -m 1000"
  echo checking...
  goto check_display
)

if "%DEFAULT_WEBUI%" == "%WEBUI%" (
  echo %DISPLAY_BIZ_NAME% | findstr "NVIDIA" > nul && (
    if %DISPLAY_MEM_SIZE% gtr 7999 (
      set COMMANDLINE_ARGS=%COMMANDLINE_ARGS% --xformers
    ) else (if %DISPLAY_MEM_SIZE% gtr 3999 (
      set COMMANDLINE_ARGS=%COMMANDLINE_ARGS% --medvram --xformers
    ) else (
      set COMMANDLINE_ARGS=%COMMANDLINE_ARGS% --lowvram --xformers
    ))
  ) || (
    set COMMANDLINE_ARGS=%COMMANDLINE_ARGS% --use-cpu all
  )
)

echo **************************************************************
echo *    display type: %DISPLAY_BIZ_NAME%
echo *    display mem: %DISPLAY_MEM_SIZE% MB
echo *    venv path: %VENV_DIR%
echo *    webui: %WEBUI%
echo *    command line args: %COMMANDLINE_ARGS%
echo **************************************************************
 
cd %WEBUI%
call webui.bat
pause