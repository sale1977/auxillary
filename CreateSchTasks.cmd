:: schtasks /create /tn BackupSnapshot /tr backup.cmd /sc daily [/mo {1 - 365}] [/st <HH:MM>] [/sd <StartDate>] [/ed <EndDate>] /ru System
schtasks /create /tn "BackupSnapshot" /tr E:\backup.cmd /sc daily /mo 7 /sd 01/01/2000 /st 23:00 /ru System
eventcreate /T SUCCESS /L APPLICATION /D "Scheduled Tasks BackupSnapshot has been installed!" /id 100 /SO Snapshot
