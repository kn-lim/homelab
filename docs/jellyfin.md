# jellyfin

## SSO

Plugin: https://github.com/9p4/jellyfin-plugin-sso

Run the following `curl` command to create the OpenID configuration:

```sh
curl -v -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "oidEndpoint": "https://idp.neon-wyrm.ts.net/.well-known/openid-configuration",
    "oidClientId": "TSIDP_CLIENT_ID",
    "oidSecret": "TSIDP_CLIENT_SECRET",
    "enabled": true,
    "enableAuthorization": true,
    "enableAllFolders": true,
    "enabledFolders": [],
    "adminRoles": ["jellyfin-admin"],
    "roles": ["jellyfin-user", "jellyfin-admin"],
    "enableFolderRoles": false,
    "enableLiveTvRoles": false,
    "enableLiveTv": false,
    "roleClaim": "groups",
    "oidScopes": ["openid email profile"],
    "disableHttps": false,
    "doNotValidateEndpoints": false,
    "doNotValidateIssuerName": false,
    "schemeOverride": "https"
  }' \
  "https://jellyfin.neon-wyrm.ts.net/sso/OID/Add/tsidp?api_key=JELLYFIN_API_KEY"
```
