// Created by Grigore Stefan <g_stefan@yahoo.com>
// Public domain (Unlicense) <http://unlicense.org>
// SPDX-FileCopyrightText: 2022 Grigore Stefan <g_stefan@yahoo.com>
// SPDX-License-Identifier: Unlicense

messageAction("vendor");

Shell.mkdirRecursivelyIfNotExists("vendor");

if (!Shell.fileExists("vendor/grigore-stefan.ca.crt.7z")) {
	var webLink = "https://github.com/g-stefan/grigore-stefan.ca/releases/download/v1.0.0/grigore-stefan.ca.crt.7z";
	var cmd = "curl --insecure --location "+webLink+" --output vendor/grigore-stefan.ca.crt.7z";
	Console.writeLn(cmd);
	exitIf(Shell.system(cmd));
};
