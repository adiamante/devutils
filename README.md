# devutils

![dns](https://github.com/adiamante/devutils/blob/main/images/dns.svg)

A set of generic utility docker services to facilitate Windows development of microservice oriented projects. Current services enable the following:

- host name with pattern *.docker redirect to loopback address '127.0.0.1' to be resolved by nginx listening on port 80 and 443
- implicit http host resolving to named docker services

## Prerequisites

Windows 10 machine (not tested in other windows machines)

Docker for Windows (tested with WSL2)

## Set up

Clone project and run dns_install.bat. 

Then go to http://demo.docker to verify. 

If that does not work and pinging the pattern *.docker does not return 127.0.0.1, your network interface might not be be Wi-fi or Ethernet. If that is the case, edit [dns_install.bat](https://github.com/adiamante/devutils/blob/main/dns_install.bat) near the bottom with your network interface name and run again.

### dns_install.bat

Sets Wi-fi network interface primary DNS to '127.0.0.1' (This will point to localdns service port 53 in dns-docker-compose.yml).

Sets Wi-fi network interface secondary DNS to '8.8.8.8' so you can still use internet.

Sets Ethernet network interface primary DNS to '127.0.0.1'.

Sets Ethernet network interface secondary DNS to '8.8.8.8' so you can still use internet.

Create docker bridge network dockerdev for utilizing docker dns service discovery (alternative could be explicit dns resolvers that utilize docker socket).

Execute docker-compose up on dns-docker-compose.yml

## localdns docker service

DNS that will resolve names with docker as domain to '127.0.0.1'. This enables pointing to docker service without setting it in host file.

## nginx service

nginx serves as a reverse proxy that has the configuration to resolve urls by subdomain name given the domain name is docker. Ex. http://demo.docker will resolve to service named 'demo.docker'. A prerequisite to resolving services is that the service be in the same network as nginx. For this example, the custom network dockerdev is utilized. Note that demo.docker in dns-docker-compose.yml does not expose ports to host. With the naming convention *.docker, services are resolved properly whether in the host machine or docker's internal network.

## Example

run dns-example_up.bat. http://example.docker should now resolve to the service example.docker.

## Usage

Create a docker-compose file and name the service with the pattern *.docker. Make sure the docker network devdns is being used. After your service is up, you can now access with the browser by using http://{servicename}. Use [dns-example-docker-compose.yml](https://github.com/adiamante/devutils/blob/main/dns-example-docker-compose.yml) for reference.

## Limitations

The utility docker services only enables implicit resolving for http applications. Tcp/udp based services such as sql, mail servers or message queue servers run on the transport layer which do not provide enough information for a reverse proxy to redirect traffic.

Your service may run on a different port than 80 or 443. You may have to alter '/nginx/conf.d/http.websiteconf' to accomidate.

## nginx service alternatives

### nginx proxy

[nginx proxy](https://index.docker.io/u/jwilder/nginx-proxy/) provides a more explicit approach in that you provide container environment variables to define the URL/port.

### HAproxy

HAproxy is also a viable alternative since it can also serve as a reverse proxy.

## Tcp/Udp reverse proxy notes

In theory, usage of SNI (Service Name Indication) through TLS handshake can provide a reverse proxy (nginx/HAproxy) enough information for server redirection. It proved more trouble than it was worth attempting to port forward to services with an ssh server in the internal docker network.

If a Windows host can ping linux containers, there would be no need for a reverse proxy and it would work for tcp and udp services. All we would need is a DNS service with access to the docker engine ([devdns](https://github.com/ruudud/devdns) or something utilizing [docker-gen](https://github.com/jwilder/docker-gen) would suffice). Unfortunately this is a limitation of docker for Windows. Apparently, linux hosts can ping linux containers straight out of the box (maybe be because the host and container are both linux). It would be cool if Windows developers got some love though. 