## TLS Proxy for Overleaf Toolkit environment

An optional TLS proxy for terminating https connections, based on NGINX.

Run `bin/init --tls` to initialise local configuration with NGINX proxy configuration, or to add NGINX proxy configuration to an existing local configuration. A sample private key is created in `config/nginx/certs/overleaf_key.pem` and a dummy certificate in `config/nginx/certs/overleaf_certificate.pem`. Either replace these with your actual private key and certificate, or set the values of the `TLS_PRIVATE_KEY_PATH` and `TLS_CERTIFICATE_PATH` variables to the paths of your actual private key and certificate respectively.

A default config for NGINX is provided in `config/nginx/nginx.conf` which may be customised to your requirements. The path to the config file can be changed with the `NGINX_CONFIG_PATH` variable.

When the [SHARELATEX_PORT](overleaf-rc.md#sharelatex_port) variable is set, the port in the `proxy_pass` statement in `nginx.conf` needs to be changed to match.

By default the https web interface will be available on `https://localhost:443`. The port can be changed via the `TLS_PORT` variable. 