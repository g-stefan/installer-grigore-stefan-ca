// Created by Grigore Stefan <g_stefan@yahoo.com>
// Public domain (Unlicense) <http://unlicense.org>
// SPDX-FileCopyrightText: 2022 Grigore Stefan <g_stefan@yahoo.com>
// SPDX-License-Identifier: Unlicense

Fabricare.include("vendor");

// ---

messageAction("make");

if (Shell.fileExists("temp/build.done.flag")) {
	return;
};

Shell.removeDirRecursivelyForce("output");
Shell.mkdirRecursivelyIfNotExists("temp");

Shell.system("7z x vendor/grigore-stefan.ca.crt.7z -aoa -ooutput");

Shell.filePutContents("temp/build.done.flag", "done");
