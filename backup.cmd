@echo off
:: Autor: Alexander Scharmer
:: Help: https://technet.microsoft.com/en-us/library/cc725744.aspx#BKMK_sys_perms
:: Prepare SystemEnvironment

title DriveSnapshot-Backup-Utility by iT.SALE 2021. Happy Backup-ing!

COLOR 2F

set NumberOfVersionsToKeep=5
set exclude=\Temp,\Windows\Memory.dmp,\Windows\Minidump\*,\PerfLogs\*,\Windows\Temp\*
set LogDir=E:\Backup\Logs
set destination=E:\Backup\%computername%

:: Auf vollständige oder differentielle Datensicherung pruefen
 set /p Version=< Version.txt >NUL 2>&1
 set Version=%Version: =% >NUL 2>&1
 set /A Version=Version %% NumberOfVersionsToKeep + 1
 echo %Version% > Version.txt

 if %Version%==1 goto :fullbackup

:: Differentielle Datensicherung
 IF EXIST %LogDir%\Current.log del %LogDir%\Current.log /q >NUL 2>&1

snapshot64.exe HDWIN:* %Destination%\Diff-%Version%-$disk.sna -h%Destination%\Full-$date-$computername-$disk.hsh -W -Go --novss -L0 --LogFile:%LogDir%\Current.log --CreateDir --FullIfHashIsMissing
:: snapshot64.exe C: %Destination%\Diff-%Version%-$disk.sna -h%Destination%\Full-1-$disk.hsh -RW -Go --AllWriters -L0 --LogFile:%LogDir%\Current.log --exclude:%exclude%

 GOTO :end


::::###### Vollstaendige Datensicherung ::######
:fullbackup
::###### Alte Datensicherung entfernen ::######
  del %destination%\Prev*.* /q >NUL 2>&1
  del %destination%\Diff*.* /q >NUL 2>&1
::###### Vorige Datensicherung umbenennen ######
  del %LogDir%\Current.log /q 
  :: pushd %destination% && forfiles.exe -m *.sna -d -%NumberOfVersionsToKeep% -c "cmd /c del @path"
  :: pushd %destination% && forfiles.exe -m *.hsh -d -%NumberOfVersionsToKeep% -c "cmd /c del @path"
popd

eventcreate /T SUCCESS /L APPLICATION /D "Backup with DriveSnapshot starts successfully!" /id 100 /SO Snapshot
rem Vollstandige Datensicherung ausfuehren
"%~DP0snapshot64.exe" HDWIN:* %destination%\Full-$date-$computername-$disk -L99999999 -W -L0 -R --LogFile:%LogDir%\Current.log --CreateDir --FullIfHashIsMissing --exclude:%exclude%

if %errorlevel% == 0 (
	
copy %LogDir%\Current.log %LogDir%\%Version%.txt /y  >NUL 2>&1
	echo.
	echo Backup mit DriveSnapshot ist fehlerfrei durchgelaufen.
	eventcreate /T SUCCESS /L APPLICATION /D "BackupSnapshot ends successfully!" /id 100 /SO Snapshot

) else (

	echo Fehler bei der Ausführung von DriveSnapshot ist aufgetreten! Kontrollieren Sie die Eventlogs!
	:: Hier können zusätzliche Programme aufgerufen werden
	eventcreate /T ERROR /L APPLICATION /D "BackupSnapshot did NOT runs successfully!" /id 100 /SO Snapshot
)

:end
copy %LogDir%\Current.log %LogDir%\%Version%.txt /y >NUL 2>&1
wevtutil qe application "/q:*[System[(EventID=100)]]" /rd:true /f:text /c:1