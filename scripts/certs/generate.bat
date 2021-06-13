:: https://stackoverflow.com/questions/5181212/windows-in-batch-file-write-multiple-lines-to-text-file/5181213
if not exist "export" mkdir "export"
(
	echo authorityKeyIdentifier=keyid,issuer
	echo basicConstraints=CA:FALSE
	echo keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
	echo subjectAltName = @alt_names
	echo [alt_names]
	echo DNS.1 = local.com
	echo DNS.2 = bar.local.com
) > ./export/local.com.ext

::https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl
::one liner?
::docker run -it --rm -v %cd%/export:/export frapsoft/openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes -keyout export/docker.key -out export/docker.crt -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=*.docker"

::https://stackoverflow.com/questions/7580508/getting-chrome-to-accept-self-signed-localhost-certificate

::Generate private key
docker run -it --rm -v %cd%/export:/export frapsoft/openssl genrsa -des3 -out export/rootCA.key -passout pass:foobar 2048

::Generate root certificate
docker run -it --rm -v %cd%/export:/export frapsoft/openssl req -x509 -new -nodes -key export/rootCA.key -sha256 -days 825 -out export/rootCA.pem -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=*.local.com" -passin pass:foobar

::Generate a private key
docker run -it --rm -v %cd%/export:/export frapsoft/openssl genrsa -out export/local.com.key 2048

::Create a certificate-signing request
docker run -it --rm -v %cd%/export:/export frapsoft/openssl req -new -key export/local.com.key -out export/local.com.csr -subj "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=*.local.com"

::Create the signed certificate
docker run -it --rm -v %cd%/export:/export frapsoft/openssl x509 -req -in export/local.com.csr -CA export/rootCA.pem -CAkey export/rootCA.key -CAcreateserial -out export/local.com.crt -days 825 -sha256 -extfile export/local.com.ext -passin pass:foobar

pause