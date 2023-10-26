@echo off
setlocal enabledelayedexpansion
set GIT_BRANCH=main
set GIT_REPO_URL=https://github.com/../../...git
set LATEST_COMMIT=git %GIT_REPO_URL% rev-parse --short HEAD

if exist cached.conf (
    echo Installation already completed. Skipping installation. Checking for updates...
    MOSTRECENTCOMMIT=git %GIT_REPO_URL% rev-parse --short HEAD
    if %MOSTRECENTCOMMIT% equ %LATEST_COMMIT% (
        echo No updates found.
        pause
        exit
    )
    echo Updates found. Updating...
    git pull %GIT_REPO_URL% %GIT_BRANCH% --depth 1
    echo Installation completed.
    echo app_version = %LATEST_COMMIT% >> cached.conf
    echo Installing packages from requirements.txt...
    pip install -r requirements.txt
    echo Update completed.
    pause
)

set PYTHON_VERSION=3.10.0
set REQUIREMENTS_FILE=requirements.txt
echo Installing git...
git --version
if %errorlevel% equ 0 (
    echo Git is already installed.
) else (
    echo Installing Git...
    curl -L https://github.com/git-for-windows/git/releases/latest/download/Git-2.42.0.2-64-bit.exe -o GitInstaller.exe
    start /wait GitInstaller.exe /SILENT /COMPONENTS="icons,assoc,ext\reg\shellhere,assoc_sh"
    del GitInstaller.exe
    git --version
    if %errorlevel% equ 0 (
        echo Git installation completed successfully.
    ) else (
        echo Git installation failed.
    )
)


echo Setting up git...
git config --global user.name "..."
git config --global user.email "..."

echo Cloning repo...
git clone %GIT_REPO_URL% --branch %GIT_BRANCH% --single-branch --depth 1

echo Installing Python %PYTHON_VERSION%...
curl https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip -o python.zip
mkdir python
tar -xf python.zip -C python
set "PYTHON_DIR=python\python-%PYTHON_VERSION%-embed-amd64"
set "PATH=%CD%\%PYTHON_DIR%;%PATH%"

echo Installing pip...
python -m ensurepip --upgrade
python -m pip install --upgrade pip --user

if exist %REQUIREMENTS_FILE% (
    echo Installing packages from %REQUIREMENTS_FILE%...
    pip install -r %REQUIREMENTS_FILE%
) else (
    echo %REQUIREMENTS_FILE% not found. Skipping package installation.
)

del python.zip

echo init = true > cached.conf
echo app_version = %LATEST_COMMIT% >> cached.conf

echo Installation completed.
pause
