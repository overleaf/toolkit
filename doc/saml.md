# Overleaf SAML

Available in Overleaf Server Pro is the ability to use a SAML server to manage users.

SAML is configured in the Toolkit via [`variables.env`](./configuration.md).

The `EXTERNAL_AUTH` variable must be set to `saml`, to enable the SAML module:

```
EXTERNAL_AUTH=saml
```

(To preserve backward compatibility with older configuration files, if
`EXTERNAL_AUTH` is not set, but `SHARELATEX_SAML_ENTRYPOINT` is set (`SHARELATEX_LDAP_URL` for versions `4.x` and older), then the SAML
module will be activated. We still recommend setting `EXTERNAL_AUTH` explicitely)

The [Developer wiki](https://github.com/overleaf/overleaf/wiki/Server-Pro:-SAML-Config) contains further documentation on the available Environment Variables and other configuration elements. 

## Example

At Overleaf, we test the SAML integration against a SAML test server. The following is an example of a working configuration:

```
# added to variables.env
# For versions of Overleaf CE/Server Pro `4.x` and older use the 'SHARELATEX_' prefix instead of 'OVERLEAF_'

EXTERNAL_AUTH=saml
OVERLEAF_SAML_ENTRYPOINT=http://localhost:8081/simplesaml/saml2/idp/SSOService.php
OVERLEAF_SAML_CALLBACK_URL=http://saml/saml/callback
OVERLEAF_SAML_ISSUER=sharelatex-test-saml
OVERLEAF_SAML_IDENTITY_SERVICE_NAME=SAML Test Server
OVERLEAF_SAML_EMAIL_FIELD=email
OVERLEAF_SAML_FIRST_NAME_FIELD=givenName
OVERLEAF_SAML_LAST_NAME_FIELD=sn
OVERLEAF_SAML_UPDATE_USER_DETAILS_ON_LOGIN=true
```

The `sharelatex/saml-test` image needs to run in the same network as the `sharelatex` container (which by default would be `overleaf_default`), so we'll proceed with the following steps:

- Run `docker network create overleaf_default` (will possibly fail due to a `network with name overleaf_default already exists` error, that's ok).
- Start `saml-test` container with some environment parameters:

```
docker run --network=overleaf_default --name=saml                 \
    --publish='8081:80'                                           \
    --env SAML_BASE_URL_PATH='http://localhost:8081/simplesaml/'  \
    --env SAML_TEST_SP_ENTITY_ID='sharelatex-test-saml'           \
    --env SAML_TEST_SP_LOCATION='http://localhost/saml/callback'  \
    sharelatex/saml-test 
```

- Edit `variables.env` to add the SAML Environment Variables as listed above.
- Restart Server Pro.

You should be able to login using `sally` as username and `sall123` as password.
