# Overleaf SAML

Available in Overleaf Server Pro is the ability to use a SAML server to manage users.

In Overleaf Server Pro, the SAML auth module is configured via environment variables.

## Configuration

- `SHARELATEX_SAML_IDENTITY_SERVICE_NAME`
    * Display name for the Identity service, used on the login page

- `SHARELATEX_SAML_EMAIL_FIELD`
    * Name of the Email field in user profile, default to 'nameID'.
	  Alias: `SHARELATEX_SAML_EMAIL_FIELD_NAME`

- `SHARELATEX_SAML_FIRST_NAME_FIELD`
    * Name of the firstName field in user profile, default to 'givenName'

- `SHARELATEX_SAML_LAST_NAME_FIELD`
    * Name of the lastName field in user profile, default to 'lastName'

- `SHARELATEX_SAML_UPDATE_USER_DETAILS_ON_LOGIN`
    * If set to `true`, will update the user first_name and last_name field on each login,
      and turn off the user-details form on `/user/settings` page.

- `SHARELATEX_SAML_ENTRYPOINT`
    * Entrypoint url for the SAML Identity Service
	
- `SHARELATEX_SAML_CALLBACK_URL`
    * Callback URL for Overleaf service. Should be the full URL of the `/saml/callback` path.
      Example: `http://sharelatex.example.com/saml/callback`

- `SHARELATEX_SAML_ISSUER`
    * The Issuer name

- `SHARELATEX_SAML_CERT`
    * (optional) Identity Provider certificate, used to validate incoming SAML messages.
	  Example: `MIICizCCAfQCCQCY8tKaMc0BMjANBgkqh ... W==`
	  See [full documentation](https://github.com/bergie/passport-saml/blob/master/README.md#security-and-signatures)

- `SHARELATEX_SAML_PRIVATE_CERT`
    * (optional) Path to a private key in pem format, used to sign auth requests sent by passport-saml
	  Example: `/some/path/cert.pm`
	  See [full documentation](https://github.com/bergie/passport-saml/blob/master/README.md#security-and-signatures)

- `SHARELATEX_SAML_DECRYPTION_PVK`
    * Optional private key that will be used to attempt to decrypt any encrypted assertions that are received

- `SHARELATEX_SAML_SIGNATURE_ALGORITHM`
    * Optionally set the signature algorithm for signing requests,
	  valid values are 'sha1' (default) or 'sha256'

- `SHARELATEX_SAML_ADDITIONAL_PARAMS`
    * JSON dictionary of additional query params to add to all requests

- `SHARELATEX_SAML_ADDITIONAL_AUTHORIZE_PARAMS`
    * JSON dictionary of additional query params to add to 'authorize' requests
	  Example: ` {"some_key": "some_value"} `

- `SHARELATEX_SAML_IDENTIFIER_FORMAT`
    * if present, name identifier format to request from identity provider (default: urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress)
	
- `SHARELATEX_SAML_ACCEPTED_CLOCK_SKEW_MS`
    * Time in milliseconds of skew that is acceptable between client and server when checking OnBefore and NotOnOrAfter assertion
	  condition validity timestamps. Setting to -1 will disable checking these conditions entirely. Default is 0.

- `SHARELATEX_SAML_ATTRIBUTE_CONSUMING_SERVICE_INDEX`
    * optional `AttributeConsumingServiceIndex` attribute to add to AuthnRequest to instruct the IDP which attribute set to attach
	  to the response ([link](http://blog.aniljohn.com/2014/01/data-minimization-front-channel-saml-attribute-requests.html))

- `SHARELATEX_SAML_AUTHN_CONTEXT`
    * if present, name identifier format to request auth context
	  (default: `urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport`)

- `SHARELATEX_SAML_FORCE_AUTHN `
    * if `true`, the initial SAML request from the service provider specifies that the IdP should force re-authentication of the user,
	  even if they possess a valid session.

- `SHARELATEX_SAML_DISABLE_REQUESTED_AUTHN_CONTEXT `
    * if `true`, do not request a specific auth context

- `SHARELATEX_SAML_SKIP_REQUEST_COMPRESSION `
    * if set to `true`, the SAML request from the service provider won't be compressed.

- `SHARELATEX_SAML_AUTHN_REQUEST_BINDING`
    * if set to `HTTP-POST`, will request authentication from IDP via HTTP POST binding, otherwise defaults to HTTP Redirect

- `SHARELATEX_SAML_VALIDATE_IN_RESPONSE_TO`
    * if truthy, then InResponseTo will be validated from incoming SAML responses

- `SHARELATEX_SAML_REQUEST_ID_EXPIRATION_PERIOD_MS`
    * Defines the expiration time when a Request ID generated for a SAML request will not be valid if seen
	  in a SAML response in the `InResponseTo` field.  Default is 8 hours.

- `SHARELATEX_SAML_CACHE_PROVIDER`
    * Defines the implementation for a cache provider used to store request Ids generated in SAML requests as
	  part of `InResponseTo` validation.  Default is a built-in in-memory cache provider.
	  See [link](https://github.com/bergie/passport-saml/blob/master/README.md)

- `SHARELATEX_SAML_LOGOUT_URL`
    * base address to call with logout requests (default: `entryPoint`)

- `SHARELATEX_SAML_LOGOUT_CALLBACK_URL`
    * The value with which to populate the `Location` attribute in the `SingleLogoutService` elements in the generated service provider metadata.

- `SHARELATEX_SAML_ADDITIONAL_LOGOUT_PARAMS`
    * JSON dictionary of additional query params to add to 'logout' requests

## Using Http Post

Note, if `SHARELATEX_SAML_AUTHN_REQUEST_BINDING` is set to `HTTP-POST`, then `SHARELATEX_SAML_SKIP_REQUEST_COMPRESSION` must also be set to `true`.


## Configuration Example

At Overleaf, we test the SAML integration against a SAML test server. The following is an example of a working configuration:

```
# added to variables.env

SHARELATEX_SAML_ENTRYPOINT=http://localhost:8081/simplesaml/saml2/idp/SSOService.php
SHARELATEX_SAML_CALLBACK_URL=http://saml/saml/callback
SHARELATEX_SAML_ISSUER=sharelatex-test-saml
SHARELATEX_SAML_IDENTITY_SERVICE_NAME=SAML Test Server
SHARELATEX_SAML_EMAIL_FIELD=email
SHARELATEX_SAML_FIRST_NAME_FIELD=givenName
SHARELATEX_SAML_LAST_NAME_FIELD=sn
SHARELATEX_SAML_UPDATE_USER_DETAILS_ON_LOGIN=true
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


## Metadata for the Identity Provider

The Identity Provider will need to be configured to recognize the Overleaf server as a "Service Provider". Consult the documentation for your SAML server for instructions on how to do this.

Here is an example of appropriate Service Provider metadata, note the `AssertionConsumerService.Location`, `EntityDescriptor.entityID` and `EntityDescriptor.ID` properties, and set as appropriate.

```
<?xml version="1.0"?>
<EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
                  xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
                  entityID="sharelatex-saml"
                  ID="sharelatex_saml">
  <SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</NameIDFormat>
    <AssertionConsumerService index="1"
                              isDefault="true"
                              Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
                              Location="http://sharelatex-host/saml/callback" />
  </SPSSODescriptor>
</EntityDescriptor>
```

## Internals

Internally, the [passport-saml](https://github.com/bergie/passport-saml) module is used, and these config values are passed along to `passport-saml`.