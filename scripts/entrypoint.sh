#!/bin/bash
# Copyright (c) 2017 Aimirim STI.
set -e

# Call certificate manager
source /home/kong/manage_certificates.sh

# Update files that do not accept enviroment variables
source /home/kong/update_conf.sh

# Check for YML configuration file
if [ ! -f "/etc/kong/kong.yml" ]; then
    echo "ERROR: Could not find configuration file 'kong.yml'. Please mount this file to '/etc/kong/kong.ym'."
    exit 127
fi

# Start Kong
kong start -c /etc/kong/kong.conf