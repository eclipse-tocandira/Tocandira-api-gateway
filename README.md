# Api Gateway

This repository contains a pre-configured version of Kong that:
- Redirects `Http` requests to `Https`
- Generate self-signed certificates if none is provided

## Dependencies
This repository is a docker image. To use it one will need:
```
$ sudo apt install docker docker.io
```
Also some configurations regarding the addition of your user to the docker group may be needed.
```
$ sudo usermod -aG docker $USER
```
After the execution of the past command a Logout and Login is needed.

## Building the image
```
$ docker build -t ApiGateway:<tag> .
```
With:
- `<tag>`: as the image version, i.e. `0.2.0`

## Configurations
- Enviroment Variables:
    - `KONG_IP`: The server IP
    - `NGINX_HTTP_PORT`: The HTTP port number to redirect into HTTPS
- Volumes:
    - `/etc/kong/kong.yml`: Configuration file
    - `/etc/kong/certificates`: Certificate folder containing: `ca-cert.pem`,`server-cert.pem` and `server-key.pem` files
    - `/home/kong/certificates.yml` (optional): Certificate configurations

## Running the image
Once the image is in docker, to run this api gateway use:
```
$ docker run -e KONG_IP=<server_ip> -e NGINX_HTTP_PORT=<redirect_port> ApiGateway:<tag>
```
With:
- `<tag>`: as the image version, i.e. `0.2.0`
- `<server_ip>`: as the host IP address
- `<redirect_port>`: as the `Http` port that will be redirected to `Https`