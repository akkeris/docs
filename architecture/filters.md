# Filters `beta`

<!-- toc -->
## Introduction

Filters intercept requests coming in to an akkeris application and provide additional functionality or checks.  Each filter type provides a unique functionality that can be shared or "attached" to applications. 

While currently only one filter exists, more are on their way.

## Authentication Filters

| Filter Type | Description |
| :--- | :--- |
| jwt  | JWT Authentication Filters allow asserting the incoming HTTP request has a valid JWT token. |

### Creating an Authentication Filter

To create a JWT authentication filter you'll need:

1. The JWKS URI that has the JWKS certificate and authorization configuration.
2. The JWKS Issuer to validate on the incoming request.

To protect an app with this filter, first create the filter:

```bash
aka filters:create my-jwt-filter \
  -d "The description of the filter" \
  -o test-org \
  -t jwt \
  --jwt-issuer "https://example.com" \
  --jwt-jwks-uri "https://example.com/.well-known/jwks.json"
```

Congratulations! You've just created your first filter. To apply this filter to an application continue on to the section [Attaching a Filter](filters.md#attaching-a-filter) You can confirm the filter was successfully created by running `aka filters`. It should list your filter and it's ID.

## Attaching a Filter

Once filters are created they can then be attached to an application. Once attached those filters will apply to all requests coming to the application from both sites, from the direct app url or from inter-space communications. When attaching it you may also exclude specific prefix paths from the filter being applied. This is useful if you need to exempt health checks or debugging end points from authorization.

The command below will attach the filter created in [Creating an Authentication Filter](filters.md#creating-an-authentication-filter) to the app `myapp-space`.

```bash
aka filters:attach -a myapp-space my-jwt-filter --excludes "/health-check" --excludes "/debug/"
```

Once attached, almost all HTTP requests will require authorization (with the exception of `/health-check` and `/debug`).