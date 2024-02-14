# LDAP

Available in Overleaf Server Pro is the ability to use a LDAP server to manage users. It is also possible to use with Active Directory systems. 

LDAP is configured in the Toolkit via [`variables.env`](./configuration.md).

The `EXTERNAL_AUTH` variable must be set to `ldap`, to enable the LDAP module:

```
EXTERNAL_AUTH=ldap
```

(To preserve backward compatibility with older configuration files, if
`EXTERNAL_AUTH` is not set, but `OVERLEAF_LDAP_URL` is set (`SHARELATEX_LDAP_URL` for versions `4.x` and older), then the LDAP
module will be activated. We still recommend setting `EXTERNAL_AUTH` explicitely)

After bootstrapping Server Pro for the first time with LDAP authentication, an existing LDAP user must be given admin permissions visiting `/launchpad` page (or [via CLI](https://github.com/overleaf/overleaf/wiki/Creating-and-managing-users#creating-the-first-admin-user), but in this case ignoring password confirmation). 

LDAP users will appear in Overleaf Admin Panel once they log in first time with their initial credentials.

The [Developer wiki](https://github.com/overleaf/overleaf/wiki/Server-Pro:-LDAP-Config) contains further documentation on the available Environment Variables and other configuration elements. 

## Example

At Overleaf, we test the LDAP integration against a [test openldap server](https://github.com/rroemhild/docker-test-openldap). The following is an example of a working configuration:

```
# added to variables.env
# For versions of Overleaf CE/Server Pro `4.x` and older use the 'SHARELATEX_' prefix instead of 'OVERLEAF_'

EXTERNAL_AUTH=ldap
OVERLEAF_LDAP_URL=ldap://ldap:389
OVERLEAF_LDAP_SEARCH_BASE=ou=people,dc=planetexpress,dc=com
OVERLEAF_LDAP_SEARCH_FILTER=(uid={{username}})
OVERLEAF_LDAP_BIND_DN=cn=admin,dc=planetexpress,dc=com
OVERLEAF_LDAP_BIND_CREDENTIALS=GoodNewsEveryone
OVERLEAF_LDAP_EMAIL_ATT=mail
OVERLEAF_LDAP_NAME_ATT=cn
OVERLEAF_LDAP_LAST_NAME_ATT=sn
OVERLEAF_LDAP_UPDATE_USER_DETAILS_ON_LOGIN=true
```

The `openldap` needs to run in the same network as the `sharelatex` container (which by default would be `overleaf_default`), so we'll proceed with the following steps:

- Run `docker network create overleaf_default` (will possibly fail due to a `network with name overleaf_default already exists` error, that's ok).
- Start `openldap` container with `docker run --network=overleaf_default --name=ldap rroemhild/test-openldap:1.1`
- Edit `variables.env` to add the LDAP Environment Variables as listed above.
- Restart Server Pro

You should be able to login using `fry` as both username and password.
