
set opensslExePath="C:\Program Files\Git\usr\bin\openssl.exe"
set domain=host.docker.internal
set password=password
set CA=rootCA

echo %domain%

:: https://stackoverflow.com/questions/5181212/windows-in-batch-file-write-multiple-lines-to-text-file/5181213
if not exist "%domain%" mkdir "%domain%"
(
	echo authorityKeyIdentifier=keyid,issuer
	echo basicConstraints=CA:FALSE
	echo keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
	echo subjectAltName = @alt_names
	echo [alt_names]
	echo DNS.1 = %domain%
) > ./%domain%/%domain%.ext

::https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate

::Generate private key
%opensslExePath% genrsa -des3 -out %domain%/%CA%.key -passout pass:%password% 2048


::Generate root certificate
%opensslExePath% req -x509 -new -nodes -key %domain%/%CA%.key -sha256 -days 825 -out %domain%/%CA%.pem -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=*.%domain%" -passin pass:%password%

::Generate a private key
%opensslExePath% genrsa -out %domain%/%domain%.key 2048

::Create a certificate-signing request
%opensslExePath% req -new -key %domain%/%domain%.key -out %domain%/%domain%.csr -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=*.%domain%"

::Create the signed certificate
%opensslExePath% x509 -req -in %domain%/%domain%.csr -CA %domain%/%CA%.pem -CAkey %domain%/%CA%.key -CAcreateserial -out %domain%/%domain%.crt -days 825 -sha256 -extfile %domain%/%domain%.ext -passin pass:%password%

::Crt to pem
%opensslExePath% x509 -in %domain%/%domain%.crt -out %domain%/%domain%.pem -outform PEM

pause