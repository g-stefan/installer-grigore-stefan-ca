@echo off
rem Public domain
rem http://unlicense.org/
rem Created by Grigore Stefan <g_stefan@yahoo.com>

echo -^> installer grigore-stefan-ca

call build.config.cmd

if exist installer\ rmdir /Q /S installer
mkdir installer

if exist build\ rmdir /Q /S build
mkdir build

makensis.exe /NOCD "util\grigore-stefan-ca-installer.nsi"

call grigore-stefan.sign "Grigore Stefan CA" "installer\grigore-stefan-ca-%PRODUCT_VERSION%-installer.exe"

if exist build\ rmdir /Q /S build
