# LDAP

Available in Overleaf Server Pro is the ability to use a LDAP server to manage users. It is also possible to use with Active Directory systems. 

LDAP is configured in the Toolkit via [`variables.env`](./configuration.md).

The [Developer wiki](https://github.com/overleaf/overleaf/wiki/Server-Pro:-LDAP-Config) contains further documentation on the available Environment Variables and other configuration elements. 

## Example

At Overleaf, we test the LDAP integration against a [test openldap server](https://github.com/rroemhild/docker-test-openldap). The following is an example of a working configuration:

```
# added to variables.env

SHARELATEX_LDAP_URL=ldap://ldap:389
SHARELATEX_LDAP_SEARCH_BASE=ou=people,dc=planetexpress,dc=com
SHARELATEX_LDAP_SEARCH_FILTER=(uid={{username}})
SHARELATEX_LDAP_BIND_DN=cn=admin,dc=planetexpress,dc=com
SHARELATEX_LDAP_BIND_CREDENTIALS=GoodNewsEveryone
SHARELATEX_LDAP_EMAIL_ATT=mail
SHARELATEX_LDAP_NAME_ATT=cn
SHARELATEX_LDAP_LAST_NAME_ATT=sn
SHARELATEX_LDAP_UPDATE_USER_DETAILS_ON_LOGIN=true
```

The `openldap` needs to run in the same network as the `sharelatex` container (which by default would be `overleaf_default`), so we'll proceed with the following steps:

- Run `docker network create overleaf_default` (will possibly fail due to a `network with name overleaf_default already exists` error, that's ok).
- Start `openldap` container with `docker run --network=overleaf_default --name=ldap rroemhild/test-openldap:1.1`
- Edit `variables.env` to add the LDAP Environment Variables as listed above.
- Restart Server Pro

You should be able to login using `fry` as both username and password.
