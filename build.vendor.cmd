@echo off
rem Public domain
rem http://unlicense.org/
rem Created by Grigore Stefan <g_stefan@yahoo.com>

call build.config.cmd

echo -^> vendor %PRODUCT_NAME%

if not exist vendor\ mkdir vendor
                                                                        
set WEB_LINK=https://github.com/g-stefan/grigore-stefan.ca/releases/download/v1.0.0/grigore-stefan.ca.crt.7z
if not exist vendor\grigore-stefan.ca.crt.7z curl --insecure --location %WEB_LINK% --output vendor\grigore-stefan.ca.crt.7z
