##  Overleaf i18 Configuration

> This is a detailed documentation on Overleaf's i18 configuration.

Overleaf has been translated into multiple languages. Through configuration, you can make your Overleaf Instance support your local language, or make it support multiple languages like the www.overleaf.com, users can choose the language they want in a list.

### Single Language Configuration

The language can be set via `OVERLEAF_SITE_LANGUAGE` (or `SHARELATEX_SITE_LANGUAGE` for versions `4.x` and earlier) with one of the following options:

- `en` - English (default)
- `es` - Spanish
- `pt` - Portuguese
- `de` - German
- `fr` - French
- `cs` - Czech
- `nl` - Dutch
- `sv` - Swedish
- `it` - Italian
- `tr` - Turkish
- `zh-CN` - Chinese (simplified)
- `no` - Norwegian
- `da` - Danish
- `ru` - Russian
- `ko` - Korean
- `ja` - Japanese
- `pl` - Polish
- `fi` - Finnish

The default language is English. But if you want to set the language to Chinese, you only need to add this line to `config/variables.env`. 

```bash
OVERLEAF_SITE_LANGUAGE=zh-CN
```

After that, run:

> [!WARNING] 
>
> If you make any changes to your overleaf container, backup/commit your changes to docker image, or you will lose all of your changes. 

```bash
bin/up
```

Then, you should see language changes in your website menu.

### Multiple Language Configuration

If you want your overleaf instance to support a list of languages, and users can swich their language **without re-login**, you need to do the following things.

Here we suppose your domain is `overleaftest.com`，and you also have its **wildcard domain name certificate**. You can use your 2-level domain, 3-level domain name, both are ok, but **don’t use localhost**, because it is a top-level domain name.

> If you want, use `dev-overleaf.com` for your localhost test.

#### 1）Reverse Proxy Nginx Config

Follow wiki [HTTPS reverse proxy using Nginx · overleaf/overleaf ](https://github.com/overleaf/overleaf/wiki/HTTPS-reverse-proxy-using-Nginx), you also need to add `proxy_set_header Host $host;`，so that web server can detect user’s request. Here is an example conf file.

```
server {
    listen 443 ssl;
    server_name    _; # Catch all, see http://nginx.org/en/docs/http/server_names.html

    server_name *.overleaftest.com;
    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    ssl_protocols               TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers   on;

    # used cloudflares ciphers https://github.com/cloudflare/sslconfig/blob/master/conf
    ssl_ciphers                 EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;

    # config to enable HSTS(HTTP Strict Transport Security) https://developer.mozilla.org/en-US/docs/Security/HTTP_Strict_Transport_Security
    # to avoid ssl stripping https://en.wikipedia.org/wiki/SSL_stripping#SSL_stripping	
    add_header Strict-Transport-Security "max-age=31536000; includeSubdomains;";

    server_tokens off;

    add_header X-Frame-Options SAMEORIGIN;

    add_header X-Content-Type-Options nosniff;

    client_max_body_size 50M;

    location / {
        proxy_pass http://localhost:5000; # change to whatever host/port the docker container is listening on.
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 3m;
        proxy_send_timeout 3m;
        
        # add this to your nginx conf
        proxy_set_header Host $host;
    }
}
```

#### 2）Cookie Config

Then, add `COOKIE_DOMAIN` to `config/variables.env`. Use a cookie that matches the wildcard domain name, otherwise the user will need to log in again after switching languages.

```bash
# don't forget `.` and replace with your own domain
COOKIE_DOMAIN=.overleaftest.com;
```

#### 3）Domain Map Config

Add `OVERLEAF_LANG_DOMAIN_MAPPING` to `config/variables.env`. This is a exmaple, users can visit

- `www.overleaftest.com`: to get English interface
- `cn.overleaftest.com`: to get Chinese interface

```bash
OVERLEAF_LANG_DOMAIN_MAPPING='{"www": {"lngCode": "en","url": "https:\/\/www.overleaftest.com"},"cn": {"lngCode": "zh-CN","url": "https:\/\/cn.overleaftest.com"}}'
```

If you need other languages, modify json for`OVERLEAF_LANG_DOMAIN_MAPPING` by yourself.
