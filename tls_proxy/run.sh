#!/bin/sh

CERT_FOLDER=${OL_DOMAINS%%,*}

cd /certs
rm -rf $CERT_FOLDER

/usr/bin/minica --domains $OL_DOMAINS && \
  cat $CERT_FOLDER/cert.pem minica.pem > nginx_certificate.pem && \
  cp $CERT_FOLDER/key.pem nginx_key.pem && \
  chmod a+r *.pem && \
  rm -rf $CERT_FOLDER

nginx -g "daemon off;"

