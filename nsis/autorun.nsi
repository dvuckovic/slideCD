; slideCD v3.1 - NSIS autorun script
; Prepares the client system for Mozilla's XULRunner,
; and executes slideCD XUL app

SetCompressor /SOLID lzma ;compress this app using LZMA whole compressor
!include WinMessages.nsh ;some globals, necessary for untgz plugin
OutFile "autorun.exe" ;output filename
Icon "kscd.ico" ;that slick slideCD icon (borrowed from KDE)
UninstallIcon "kscd.ico" ;the same
SilentInstall silent ;prevent any window popups from our app
SilentUnInstall silent ;same with uninstaller

;main script function
Section "-Program files"
	;unpack xulrunner from slideCD medium to the local TEMP dir
	untgz::extract -d "$TEMP" -z "$EXEDIR\slideCD\xulrunner.tgz"

	;check for existence of additional plugins for XULRunner
	IfFileExists "$EXEDIR\slideCD\plugins" 0 Plugins_Missing

	;check for existence of local Mozilla Plugins folder
	IfFileExists "$APPDATA\Mozilla\Plugins" Plugins_Exists Flash_Copy
Plugins_Exists:
	;backup them if they exist
	Rename "$APPDATA\Mozilla\Plugins" "$APPDATA\Mozilla\Plugins.old"
Flash_Copy:
	;now create new Mozilla Plugins dir, and copy all plugins from slideCD to it
	CreateDirectory "$APPDATA\Mozilla\Plugins"
	CopyFiles /SILENT "$EXEDIR\slideCD\plugins\*.*" "$APPDATA\Mozilla\Plugins"
Plugins_Missing:
	;execute slideCD XUL app using unpacked XULRunner
	Exec '"$TEMP\xulrunner\xulrunner.exe" "$EXEDIR\slideCD\application.ini"'

	;registry key used for purging slideCD temp files
	;needed if something go wrong and they are not purged on exit
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\RunOnce" "Purge slideCD tmp files" "$TEMP\purge-slideCD.exe"

	;output uninstaller (purger)
	WriteUninstaller "$TEMP\purge-slideCD.exe"

Recheck:
	;check if everything went well with XULRunner and if it loaded our XUL app
	IfFileExists "$TEMP\xulrunner\loaded.tmp" Destroy_Banner Recheck
	
Destroy_Banner:
	;then, and only then, destroy "Loading, please wait..." dialog
	Banner::destroy

	Quit
SectionEnd

Section "Uninstall"
	;give XULRunner some time to exit (1sec is enough for most systems)
	Sleep 1000

	;delete our fail-safe registry entry for purging temp files
	DeleteRegValue HKLM "Software\Microsoft\Windows\CurrentVersion\RunOnce" "Purge slideCD tmp files"

	;remove Mozilla Plugins folder
	RMDir /r /REBOOTOK "$APPDATA\Mozilla\Plugins"

	;restore backup of local Mozilla Plugins
	IfFileExists "$APPDATA\Mozilla\Plugins.old" 0 Delete_Temp
	Rename /REBOOTOK "$APPDATA\Mozilla\Plugins.old" "$APPDATA\Mozilla\Plugins"

Delete_Temp:
	;now delete complete XULRunner and uninstaller exe file
	RMDir /r /REBOOTOK "$TEMP\xulrunner"
	Delete /REBOOTOK "$TEMP\purge-slideCD.exe"

	;destroy "Closing, please wait..." dialog
	Banner::destroy

	Quit
SectionEnd
Function .onInit
	;show our modal loading dialog
	Banner::show /NOUNLOAD "Loading, please wait..."
FunctionEnd
Function un.onInit
	;show our modal closing dialog
	Banner::show /NOUNLOAD "Closing, please wait..."
FunctionEnd