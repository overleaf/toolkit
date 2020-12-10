# LDAP

Available in Overleaf Server Pro is the ability to use a LDAP server to manage users. It is also possible to use with Active Directory systems. 

LDAP is configured via [`variables.env`](./configuration.md)

## Environment Variables

- `SHARELATEX_LDAP_URL` =
    Url of the LDAP server,
    E.g. `ldaps://ldap.example.com:636`

- `SHARELATEX_LDAP_EMAIL_ATT` =
  The email attribute the LDAP server will return, defaults to `mail`

- `SHARELATEX_LDAP_NAME_ATT` =
  The property name holding the name of the user which is used in the application

- `SHARELATEX_LDAP_LAST_NAME_ATT` =
  If your LDAP server has a first and last name then this can be used in conjuction with `SHARELATEX_LDAP_NAME_ATT`

- `SHARELATEX_LDAP_PLACEHOLDER` =
  The placeholder for the login form, defaults to `Username`

- `SHARELATEX_LDAP_UPDATE_USER_DETAILS_ON_LOGIN` =
  If set to `true`, will update the user first_name and last_name field on each login, and turn off the user-details form on /user/settings page.
  Otherwise, details will be fetched only on first login.

- `SHARELATEX_LDAP_BIND_DN` =
    Optional, e.g. `uid=myapp,ou=users,o=example.com`.

- `SHARELATEX_LDAP_BIND_CREDENTIALS` =
    Password for bindDn.

- `SHARELATEX_LDAP_BIND_PROPERTY` =
    Optional, default `dn`. Property of user to bind against client
    e.g. `name`, `email`

- `SHARELATEX_LDAP_SEARCH_BASE` =
    The base DN from which to search for users by username.
     E.g. `ou=users,o=example.com`

- `SHARELATEX_LDAP_SEARCH_FILTER` =
    LDAP search filter with which to find a user by username, e.g.
    `(uid={{username}})`. Use the literal `{{username}}` to have the
    given username be interpolated in for the LDAP search.

- `SHARELATEX_LDAP_SEARCH_SCOPE` =
    Optional, default `sub`. Scope of the search, one of `base`,
    `one`, or `sub`.

- `SHARELATEX_LDAP_SEARCH_ATTRIBUTES` =
    Optional, default all. Json array of attributes to fetch from LDAP server.

- `SHARELATEX_LDAP_GROUP_DN_PROPERTY` =
    Optional, default `dn`. The property of user object to use in
    `{{dn}}` interpolation of groupSearchFilter.

- `SHARELATEX_LDAP_GROUP_SEARCH_BASE` =
    Optional. The base DN from which to search for groups. If defined,
    also groupSearchFilter must be defined for the search to work.

- `SHARELATEX_LDAP_GROUP_SEARCH_SCOPE` =
    Optional, default `sub`.

- `SHARELATEX_LDAP_GROUP_SEARCH_FILTER` =
    Optional. LDAP search filter for groups. The following literals are
    interpolated from the found user object: `{{dn}}` the property
    configured with `groupDnProperty`. Optionally you can also assign a function instead,
    which passes a user object, from this a dynamic groupsearchfilter can be retrieved.

- `SHARELATEX_LDAP_GROUP_SEARCH_ATTRIBUTES` =
    Optional, default all. Json array of attributes to fetch from LDAP server.

- `SHARELATEX_LDAP_CACHE` =
    Optional, default `false`. If `true`, then up to 100 credentials at a
    time will be cached for 5 minutes.

- `SHARELATEX_LDAP_TIMEOUT` =
    Optional, default `Infinity`. How long the client should let
    operations live for before timing out.

- `SHARELATEX_LDAP_CONNECT_TIMEOUT` =
    Optional, default is up to the OS. How long the client should wait
    before timing out on TCP connections.

- `SHARELATEX_LDAP_TLS_OPTS_CA_PATH` = 
  A JSON array of paths to the CA file for TLS, must be accessible to the docker container.
	E.g. `-env SHARELATEX_LDAP_TLS_OPTS_CA_PATH='["/var/one.pem", "/var/two.pem"]' `

- `SHARELATEX_LDAP_TLS_OPTS_REJECT_UNAUTH` =
   If `true`, the server certificate is verified against the list of supplied CAs.

## Example

At Overleaf, we test the LDAP integration against a [test openldap server](https://github.com/rroemhild/docker-test-openldap). The following is an example of a working configuration:

```
# added to variables.env

SHARELATEX_TEMPLATES_USER_ID=578773160210479700917ee5
SHARELATEX_NEW_PROJECT_TEMPLATE_LINKS=[ {"name":"All Templates","url":"/templates/all"}, {"name":"All Categories","url":"/templates"}, {"name":"reports","url":"/templates/reports"}, {"name":"External","url":"https://somewhere.com/templates/reports"} ]
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
- Start `openldap` container with `docker run --network=overleaf_default --name=ldap rroemhild/test-openldap`
- Edit `variables.env` to add the LDAP Environment Variables as listed above.
- Restart Server Pro

You should be able to login using `fry` as both username and password.

### Testing, Config & Debugging

After bootstrapping Server Pro for the first time, an existing LDAP user must be given admin permissions visiting `/launchpad` page (or [via CLI](./quick-start-guide.md), but in this case ignoring password confirmation). 

LDAP users will appear in Overleaf Admin Panel once they log in first time with their initial credentials.

As LDAP is heavily configurable and flexible by nature it can be a good starting point to have a working example with ldapsearch or even used by another application.

```sh
ldapsearch -H ldap://ad.mydomain.com:389 -x -D ENUMuser@mydomain.com -w ENUMpass -b ou=people,dc=mydomain,dc=com "CN=\*ENUMuser\*" mail
```

## Internals

Internally, Overleaf LDAP uses the [passport-ldapauth](https://github.com/vesse/passport-ldapauth) library. Most of these configuration options are passed through to the `server` config object which is used to configure `passport-ldapauth`. If you are having issues configuring LDAP, it is worth reading the README for `passport-ldapauth` to get a feel for the configuration it expects.
