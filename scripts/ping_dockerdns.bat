SETLOCAL ENABLEDELAYEDEXPANSION

for /F "tokens=*" %%f in ('docker inspect -f "{{ range.NetworkSettings.Networks }}{{ .IPAddress }}{{ end }}" dockerdns') do (
	docker run -it --rm --dns=%%f alpine ping -c 4 dockerdns.docker
)

pause