#!/bin/bash
# Copyright (c) 2017 Aimirim STI.
set -e

# Import YML parser
source /home/kong/parse.sh

# Needed enviroment variables
if [ -z "${KONG_CERTIFICATES}" ]; then
    export KONG_CERTIFICATES="/etc/kong/certificates"
fi
if [ ! -d "${KONG_CERTIFICATES}" ]; then
    mkdir -p $KONG_CERTIFICATES
fi
if [ -z "${KONG_IP}" ]; then
    echo "ERROR: Could not find the variable 'KONG_IP'. Please set it as the server IP."
    exit 127
fi
if [ -z "${KONG_DNS}" ]; then
    KONG_DNS=$KONG_IP
fi

# Check for certification files
if [[ -f $KONG_CERTIFICATES/ca-cert.pem && -f $KONG_CERTIFICATES/server-cert.pem && -f $KONG_CERTIFICATES/server-key.pem ]]; then
    echo "INFO: Certifications exist. No actions needed."

else
    echo "INFO: Creating certifications."
    # Remove folder contents
    rm -f $KONG_CERTIFICATES/*

    # Default values
    certificate_expiration_days=7300 #20 years
    certificate_subject_country="BR"
    certificate_subject_state="Minas Gerais"
    certificate_subject_location="Uberlândia"
    certificate_subject_company="Aimirim STI"
    certificate_subject_email="contato@aimirimsti.com.br"

    # Parse configuration files into shell variables
    eval $(parse_yaml /home/kong/certificates.yml)
    # Write certificate ownership 
    subject_string=/C=$certificate_subject_country/ST=$certificate_subject_country/L=$certificate_subject_location/CN=$certificate_subject_company/emailAddress=$certificate_subject_email
    
    echo "subjectAltName=DNS:$KONG_DNS,DNS:$KONG_IP,IP:$KONG_IP" >$KONG_CERTIFICATES/server-ext.cnf

    # Generate CA's private key and self-signed certificate
    openssl req -x509 -newkey rsa:4096 \
        -days $certificate_expiration_days -nodes \
        -keyout $KONG_CERTIFICATES/ca-key.pem \
        -out $KONG_CERTIFICATES/ca-cert.pem \
        -subj "$subject_string"
    
    # Convert to Windows type certificate
    openssl x509 -inform PEM \
        -in $KONG_CERTIFICATES/ca-cert.pem \
        -outform DER \
        -out $KONG_CERTIFICATES/ca-cert.cer

    # Client signed certification
    openssl x509 -in $KONG_CERTIFICATES/ca-cert.pem -noout -text

    # Generate web server's private key and certificate signing request (CSR)
    openssl req -newkey rsa:4096 \
        -nodes -keyout $KONG_CERTIFICATES/server-key.pem \
        -out $KONG_CERTIFICATES/server-req.pem \
        -subj "$subject_string"

    # Use CA's private key to sign web server's CSR and get back the signed certificate
    openssl x509 -req -in $KONG_CERTIFICATES/server-req.pem \
        -days $certificate_expiration_days \
        -CA $KONG_CERTIFICATES/ca-cert.pem \
        -CAkey $KONG_CERTIFICATES/ca-key.pem \
        -CAcreateserial -out $KONG_CERTIFICATES/server-cert.pem \
        -extfile $KONG_CERTIFICATES/server-ext.cnf

    # Server signed certification
    openssl x509 -in $KONG_CERTIFICATES/server-cert.pem -noout -text

    # Remove temporary files
    rm $KONG_CERTIFICATES/ca-key.pem
    rm $KONG_CERTIFICATES/ca-cert.srl
    rm $KONG_CERTIFICATES/server-req.pem
    rm $KONG_CERTIFICATES/server-ext.cnf

fi
