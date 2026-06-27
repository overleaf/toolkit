## Apache TLS Proxy for Overleaf
If you intent to run Overleaf behind the host's let's encrypt TLS apache proxy, you're in the right place!

If you are not using Let's Encrypt but still want to run your Overleaf instance behind apache, have a look at the appendix (bottom of this file).

### Overleaf setup
In this guide, we assume that overleaf is already running on your host in HTTP, without the included NGINX TLS proxy.

Since we will be running overleaf behind a proxy, we have to change a couple of options in our configuration files.

In your ```config/variables.env```, please ensure that the options are set as below.
Make sure to change overleaf.example.com to your domain.
```env
OVERLEAF_BEHIND_PROXY=true
OVERLEAF_SECURE_COOKIE=true

OVERLEAF_SITE_URL=https://overleaf.example.com
```

In your ```config/overleaf.rc```, make sure that the options are set as below :
```env
OVERLEAF_LISTEN_IP=127.0.0.1
OVERLEAF_LISTEN_PORT=8080
NGINX_ENABLED=false
```
Note that the listen port can be changed, but will have to be changed in the apache configuration file.


If needed, reinitialize your docker containers with the commands below.
**WARNING : this will remove your tex libraries in the sharelatex container.**

Refer to [this page](https://github.com/storca/toolkit/blob/master/doc/ce-upgrading-texlive.md#saving-your-changes) if you want to save your TeX install. Redis, mongo data and your documents will still be here.

```sh
bin/docker-compose down
bin/up
```

### Apache setup
For the apache setup, we assume that you already obtained a valid certificate from Let's Encrypt for your domain.

The apache configuration file is based on a VirtualHost. This file can be found in ```lib/config-seed/apache-le-ssl.conf```. 

**Make sure to change :**

* the ```ServerName``` to your domain name
* the **port** if you changed it
* the **path to your TLS private key and certificate.**

The following modules are required :
```
mod_ssl
mod_rewrite
mod_proxy
```

#### Redirecting HTTP to HTTPS
If needed, you can use the following configuration for your HTTP virtual host. Make sure to change your domain name and the port that you've set in your ```config/overleaf.rc```.
```conf
# HTTP to HTTPS redirection
<VirtualHost *:80>
    ServerName overleaf.example.com
    RewriteEngine On
    RewriteCond %{REQUEST_URI} !^/.well-known/acme-challenge/
    RewriteRule ^.*$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,QSA,L]
</VirtualHost>
```

Run ```systemctl reload apache2``` and you should be good to go!

## Appendix
### TLDR - just give me the options that work for websockets and secure cookies
```conf
RewriteEngine On
RewriteCond %{HTTP:Upgrade} =websocket [NC]
RewriteRule /(.*)           ws://127.0.0.1:8080/$1 [P,L]
RewriteCond %{HTTP:Upgrade} !=websocket [NC]
RewriteRule /(.*)           http://127.0.0.1:8080/$1 [P,L]

<IfModule mod_proxy.c>
    ProxyRequests Off
    # There is no ProxyPass directive ! It is handled by the second RewriteCond
    ProxyPassReverse / http://127.0.0.1:8080/
</IfModule>

<Location />
    ProxyAddHeaders On
    RequestHeader set X-Forwarded-Proto "https"
    RequestHeader set X-Forwarded-For "%{REMOTE_ADDR}s"
    RequestHeader set Host "%{HTTP_HOST}e"
</Location>

# To avoid SSL stripping https://en.wikipedia.org/wiki/SSL_stripping#SSL_stripping
Header always set Strict-Transport-Security "max-age=31536000; includeSubdomains;"

#ServerTokens Prod
LimitRequestBody 52428800
```

### For a TLS configuration not using Let's Encrypt
If you are not using Let's Encrpyt but you already have certificates, you can get a TLS configuration for apache from [Mozilla](https://ssl-config.mozilla.org/). Let's Encrypt configurations are based on those.

Depending on your setup (single host or multi-host) derive the configuration you need from Mozilla's website and **add the configuration in the TLDR statement above** to forward websockets and make secure cookies work.