@echo off
rem Public domain
rem http://unlicense.org/
rem Created by Grigore Stefan <g_stefan@yahoo.com>

call build\build.config.cmd

echo -^> make %PRODUCT_NAME%

if exist output\ rmdir /Q /S output

mkdir output

7z x vendor/grigore-stefan.ca.crt.7z -aoa -ooutput
