;--------------------------------
; Grigore Stefan CA Installer
;
; Public domain
; http://unlicense.org/
; Created by Grigore Stefan <g_stefan@yahoo.com>
;

!include "MUI2.nsh"
!include "LogicLib.nsh"

; The name of the installer
Name "Grigore Stefan CA"

; Version
!define GrigoreStefanCAVersion "$%PRODUCT_VERSION%"

; The file to write
OutFile "installer\grigore-stefan-ca-${GrigoreStefanCAVersion}-installer.exe"

Unicode True
RequestExecutionLevel admin
BrandingText "Grigore Stefan [ github.com/g-stefan ]"

!define SoftwareInstallDir "$PROGRAMFILES64\XYO"
!define SoftwareMainDir "\XYO"
!define SoftwareSubDir "\Certificate CA"
!define SoftwareRegKey "Software\XYO\Certificate CA"
!define UninstallRegKey "Software\Microsoft\Windows\CurrentVersion\Uninstall\Grigore Stefan CA"
!define UninstallName "Uninstall Certificate CA"

; The default installation directory
InstallDir "${SoftwareInstallDir}"

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKLM "${SoftwareRegKey}" "InstallPath"

;--------------------------------
;Interface Settings

!define MUI_ABORTWARNING
!define MUI_ICON "util\system-installer.ico"
!define MUI_UNICON "util\system-installer.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "util\xyo-installer-wizard.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "util\xyo-uninstaller-wizard.bmp"

;--------------------------------
;Pages

!define MUI_COMPONENTSPAGE_SMALLDESC
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "release\license.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!ifdef INNER
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!endif

;--------------------------------
;Languages

!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Generate signed uninstaller
!ifdef INNER
	!echo "Inner invocation"                  ; just to see what's going on
	OutFile "build\dummy-installer.exe"       ; not really important where this is
	SetCompress off                           ; for speed
!else
	!echo "Outer invocation"
 
	; Call makensis again against current file, defining INNER.  This writes an installer for us which, when
	; it is invoked, will just write the uninstaller to some location, and then exit.
 
	!makensis '/NOCD /DINNER "util\${__FILE__}"' = 0
 
	; So now run that installer we just created as build\dummy-installer.exe.  Since it
	; calls quit the return value isn't zero.
 
	!system 'set __COMPAT_LAYER=RunAsInvoker&"build\dummy-installer.exe"' = 2
 
	; That will have written an uninstaller binary for us.  Now we sign it with your
	; favorite code signing tool.
 
	!system 'grigore-stefan.sign "Grigore Stefan CA" "build\${UninstallName}.exe"' = 0
 
	; Good.  Now we can carry on writing the real installer. 	 
!endif

;--------------------------------
;Signed uninstaller: Generate uninstaller only
Function .onInit
!ifdef INNER 
	; If INNER is defined, then we aren't supposed to do anything except write out
	; the uninstaller.  This is better than processing a command line option as it means
	; this entire code path is not present in the final (real) installer.
	SetSilent silent
	WriteUninstaller "$EXEDIR\${UninstallName}.exe"
	Quit  ; just bail out quickly when running the "inner" installer
!endif
FunctionEnd

;--------------------------------
;Installer Sections

Section "Grigore Stefan CA (required)" MainSection

	SectionIn RO
	SetRegView 64

	WriteRegStr HKLM "${SoftwareRegKey}" "InstallPath" "$INSTDIR"	

	; Write the uninstall keys for Windows
	WriteRegStr HKLM "${UninstallRegKey}" "DisplayName" "Grigore Stefan CA"
	WriteRegStr HKLM "${UninstallRegKey}" "Publisher" "Grigore Stefan [ github.com/g-stefan ]"
	WriteRegStr HKLM "${UninstallRegKey}" "DisplayVersion" "${GrigoreStefanCAVersion}"
	WriteRegStr HKLM "${UninstallRegKey}" "DisplayIcon" '"$INSTDIR\Uninstallers\${UninstallName}.ico"'
	WriteRegStr HKLM "${UninstallRegKey}" "UninstallString" '"$INSTDIR\Uninstallers\${UninstallName}.exe"'
	WriteRegDWORD HKLM "${UninstallRegKey}" "NoModify" 1
	WriteRegDWORD HKLM "${UninstallRegKey}" "NoRepair" 1

	; Set output path to the installation directory.
	SetOutPath "$INSTDIR${SoftwareSubDir}"

	; Program files
	File /r "release\*"

; Uninstaller
!ifndef INNER
	SetOutPath "$INSTDIR\Uninstallers"
	; this packages the signed uninstaller 
	File "build\${UninstallName}.exe"
	; add extra icon also
	File "/oname=${UninstallName}.ico" "release\xyo.ico"
!endif

	; Computing EstimatedSize
	Call GetInstalledSize
	Pop $0
	WriteRegDWORD HKLM "${UninstallRegKey}" "EstimatedSize" "$0"

	; Install Certificate
	Push "$INSTDIR${SoftwareSubDir}\grigore-stefan.ca.crt"
	Call AddCertificateToStore
	Pop $0
	${If} $0 != success
		MessageBox MB_OK "import failed: $0"
	${EndIf}

	; Remove files
	SetOutPath $TEMP

	RMDir /r "$INSTDIR${SoftwareSubDir}"

SectionEnd

;--------------------------------
;Descriptions

;Language strings
LangString DESC_MainSection ${LANG_ENGLISH} "Grigore Stefan CA"

;Assign language strings to sections
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${MainSection} $(DESC_MainSection)
!insertmacro MUI_FUNCTION_DESCRIPTION_END

;--------------------------------
;Uninstaller Section
!ifdef INNER
Section "Uninstall"

	SetRegView 64

	;--------------------------------
	; Validating $INSTDIR before uninstall

	!macro BadPathsCheck
	StrCpy $R0 $INSTDIR "" -2
	StrCmp $R0 ":\" bad
	StrCpy $R0 $INSTDIR "" -14
	StrCmp $R0 "\Program Files" bad
	StrCpy $R0 $INSTDIR "" -8
	StrCmp $R0 "\Windows" bad
	StrCpy $R0 $INSTDIR "" -6
	StrCmp $R0 "\WinNT" bad
	StrCpy $R0 $INSTDIR "" -9
	StrCmp $R0 "\system32" bad
	StrCpy $R0 $INSTDIR "" -8
	StrCmp $R0 "\Desktop" bad
	StrCpy $R0 $INSTDIR "" -23
	StrCmp $R0 "\Documents and Settings" bad
	StrCpy $R0 $INSTDIR "" -13
	StrCmp $R0 "\My Documents" bad done
	bad:
	  MessageBox MB_OK|MB_ICONSTOP "Install path invalid!"
	  Abort
	done:
	!macroend
 
	ClearErrors
	ReadRegStr $INSTDIR HKLM "${SoftwareRegKey}" "InstallPath"
	IfErrors +2
	StrCmp $INSTDIR "" 0 +2
		StrCpy $INSTDIR "${SoftwareInstallDir}"
 
	# Check that the uninstall isn't dangerous.
	!insertmacro BadPathsCheck
 
	# Does path end with "${SoftwareMainDir}${SoftwareSubDir}"?
	!define CHECK_PATH "${SoftwareMainDir}"
	StrLen $R1 "${CHECK_PATH}"
	StrCpy $R0 "$INSTDIR" "" -$R1
	StrCmp $R0 "${CHECK_PATH}" +3
		MessageBox MB_YESNO|MB_ICONQUESTION "${CHECK_PATH} - $R1 : $R0 - $INSTDIR - Unrecognised uninstall path. Continue anyway?" IDYES +2
		Abort
 
	IfFileExists "$INSTDIR\Uninstallers\*.*" 0 +2
	IfFileExists "$INSTDIR\Uninstallers\${UninstallName}.ico" +3
		MessageBox MB_OK|MB_ICONSTOP "Install path invalid!"
		Abort

	DetailPrint "Uninstall ..."

	;--------------------------------
	; Do Uninstall

	SetOutPath $TEMP

	; Remove Certificate
	Push ""
	Call un.RemoveCertificateFromStore
	Pop $0
	${If} $0 != success
		MessageBox MB_OK "remove failed: $0"
	${EndIf}

	; Remove registry keys
	DeleteRegKey HKLM "${SoftwareRegKey}"
	DeleteRegKey HKLM "${UninstallRegKey}"

	; Remove files and uninstaller
	RMDir /r "$INSTDIR${SoftwareSubDir}"
	Delete "$INSTDIR\Uninstallers\${UninstallName}.exe"
	Delete "$INSTDIR\Uninstallers\${UninstallName}.ico"
	RMDir "$INSTDIR\Uninstallers"
	RMDir "$INSTDIR"

SectionEnd
!endif

;--------------------------------
;Functions

; Return on top of stack the total size of the selected (installed) sections, formated as DWORD
Var GetInstalledSize.total
Function GetInstalledSize
	StrCpy $GetInstalledSize.total 0

	${if} ${SectionIsSelected} ${MainSection}
		SectionGetSize ${MainSection} $0
		IntOp $GetInstalledSize.total $GetInstalledSize.total + $0
	${endif}
 
	IntFmt $GetInstalledSize.total "0x%08X" $GetInstalledSize.total
	Push $GetInstalledSize.total
FunctionEnd

; Register certificate in Root CA
!define CERT_QUERY_OBJECT_FILE 1
!define CERT_QUERY_CONTENT_FLAG_ALL 16382
!define CERT_QUERY_FORMAT_FLAG_ALL 14
!define CERT_STORE_PROV_SYSTEM 10
!define CERT_STORE_OPEN_EXISTING_FLAG 0x4000
!define CERT_SYSTEM_STORE_LOCAL_MACHINE 0x20000
!define CERT_STORE_ADD_ALWAYS 4
 
Function AddCertificateToStore

	Exch $0
	Push $1
	Push $R0
 
	System::Call "crypt32::CryptQueryObject(i ${CERT_QUERY_OBJECT_FILE}, w r0, \
		i ${CERT_QUERY_CONTENT_FLAG_ALL}, i ${CERT_QUERY_FORMAT_FLAG_ALL}, \
		i 0, i 0, i 0, i 0, i 0, i 0, *i .r0) i .R0"
 
	${If} $R0 <> 0
		System::Call "crypt32::CertOpenStore(i ${CERT_STORE_PROV_SYSTEM}, i 0, i 0, \
			i ${CERT_STORE_OPEN_EXISTING_FLAG}|${CERT_SYSTEM_STORE_LOCAL_MACHINE}, \
			w 'ROOT') i .r1"
 
		${If} $1 <> 0
			System::Call "crypt32::CertAddCertificateContextToStore(i r1, i r0, \
				i ${CERT_STORE_ADD_ALWAYS}, i 0) i .R0"
			System::Call "crypt32::CertFreeCertificateContext(i r0)"
 
			${If} $R0 = 0
				StrCpy $0 "Unable to add certificate to certificate store"
			${Else}
				StrCpy $0 "success"
			${EndIf}
 
			System::Call "crypt32::CertCloseStore(i r1, i 0)" 
		${Else}
 
		      System::Call "crypt32::CertFreeCertificateContext(i r0)"
		      StrCpy $0 "Unable to open certificate store"
 
   		 ${EndIf}
	${Else}
 
		StrCpy $0 "Unable to open certificate file"
 
	${EndIf}
 
	Pop $R0
	Pop $1
	Exch $0
 
FunctionEnd

; Remove certificate from Root CA
!ifdef INNER
!define X509_ASN_ENCODING 1
!define CERT_FIND_SUBJECT_STR 0x80007
!define CERT_SUBJ_NAME "Grigore Stefan [ github.com/g-stefan ]"

Function un.RemoveCertificateFromStore

	Exch $0
	Push $1
	Push $2
	Push $R0
	Push $R1
	Push $R2
 
	System::Call "crypt32::CertOpenStore(i ${CERT_STORE_PROV_SYSTEM}, i 0, i 0, \
		i ${CERT_STORE_OPEN_EXISTING_FLAG}|${CERT_SYSTEM_STORE_LOCAL_MACHINE}, \
		w 'ROOT') i .r1"
 
	${If} $1 <> 0
			
		System::Call "crypt32::CertFindCertificateInStore(i r1, \
		i ${X509_ASN_ENCODING}, i 0, i ${CERT_FIND_SUBJECT_STR}, \
		w '${CERT_SUBJ_NAME}', null) i .r2"

		${If} $2 <> 0
			System::Call "crypt32::CertDeleteCertificateFromStore(i r2) i .R0"
 
			${If} $R0 = 0
				StrCpy $0 "Unable to remove certificate from certificate store"
			${Else}
				StrCpy $0 "success"
			${EndIf}

		${Else}
			StrCpy $0 "success" ; not found
		${EndIf}
 
		System::Call "crypt32::CertCloseStore(i r1, i 0)"
	${Else}

	      StrCpy $0 "Unable to open certificate store"
 
	${EndIf}
 
	Pop $R2
	Pop $R1
	Pop $R0
	Pop $2
	Pop $1
	Exch $0
 
FunctionEnd
!endif
