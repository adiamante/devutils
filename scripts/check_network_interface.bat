echo off
SETLOCAL ENABLEDELAYEDEXPANSION

for /F "tokens=*" %%I in ('netsh interface show interface') do (
	set interface=%%I
	
	for /F "tokens=1,2,3,4" %%a in ("%%I") do (
		::echo %%a %%b %%c %%d
		if %%b EQU Connected (
			if %%d NEQ vEthernet (
				netsh interface ipv4 show dns %%d
			)
		)
	)
)

pause