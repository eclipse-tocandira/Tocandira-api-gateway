#!/bin/bash
# Copyright (c) 2017 Aimirim STI.
set -e

# Check for port redirection variable 
if [ -z "${NGINX_HTTP_PORT}" ]; then
    echo "ERROR: Could not find the variable 'NGINX_HTTP_PORT'. Please set the http port to be redirected into HTTPS."
    exit 127
fi

# Update .conf files that do not accept enviroment variables
mv /home/kong/nginx.conf.template /etc/kong/nginx.conf
sed -i 's@NGINX_REDIRECT_PORT@'"$NGINX_HTTP_PORT"'@g' /etc/kong/nginx.conf

mv /home/kong/kong.conf.template /etc/kong/kong.conf
sed -i 's@CERTIFICATES_FOLDER@'"$KONG_CERTIFICATES"'@g' /etc/kong/kong.conf
