@echo off
rem Public domain
rem http://unlicense.org/
rem Created by Grigore Stefan <g_stefan@yahoo.com>

if not exist vendor\ mkdir vendor
                                                                        
if not exist vendor\grigore-stefan.ca.crt.7z curl --insecure --location https://github.com/g-stefan/grigore-stefan.ca/releases/download/v1.0.0/grigore-stefan.ca.crt.7z --output vendor\grigore-stefan.ca.crt.7z
