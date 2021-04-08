## TLS Proxy for Overleaf Toolkit environment

This provides an nginx proxy for overleaf-toolkit with TLS certificates loaded.

The first time you bring up the toolkit environment, this will generate TLS certificates for the web server(s) and a CA certificate in `tls_proxy/certs`.

The TLS certificates will be generated for a comma-separated list of domains specified in the `OL_DOMAINS` environment variable. The default value is for `localhost` and `overleaf-toolkit.com`.

For local testing you can add `overleaf-toolkit.com` to your `/etc/hosts` file.


**Mac users note:** Apache may be running on your machine by default. If the toolkit environment fails to come up, you should run `sudo apachectl stop`. To make this change permanent, run: `sudo launchctl unload -w /Applications/Server.app/Contents/ServerRoot/System/Library/LaunchDaemons/com.apple.serviceproxy.plist`.

You will need to configure your system to trust the new CA certificate, so that you get a green padlock in your browser and can use command-line tools like `curl`.

The new root CA certificate you need to trust will be `tls_proxy/certs/minica.pem` and you should add it thusly:

### On Mac

Run this command:

```
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain tls_proxy/certs/minica.pem
```

##### Using Firefox?

You need to manually add the certificate to Firefox.
To do so go to Firefox's settings and search for the "Certificates" section. Click "View Certificates..." then "Import...".

### On Linux

Linux is more complicated, as not all trust stores work the same way and it can differ based on distribution.

To add the certificate to the system-wide trust store so that command-line tools work, run these commands, after bringing up the toolkit env:

```
sudo mkdir -p /usr/local/share/ca-certificates
sudo cp tls_proxy/certs/minica.pem /usr/local/share/ca-certificates/minica.crt
# note different extension here
sudo update-ca-certificates
```

Unfortunately, your *browser* will not trust the system CA store. Instead you need to run (as your normal user, not root):

```
certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n "Overleaf Minica" -i tls_proxy/certs/minica.pem
```
If running Chromium as a snap (e.g. on Ubuntu > 20.04) run
```
certutil -d $HOME/snap/chromium/current/.pki/nssdb -A -t "C,," -n "Overleaf Minica" -i tls_proxy/certs/minica.pem
```

This should work, but might not in all cases. If your browser still does not trust the site certificate at https://localhost/ you may need to manually add it to the list of trusted certificates in your browser's settings.

```

