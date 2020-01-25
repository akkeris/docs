# Filters `beta`

### Table of Contents

<!-- toc -->

## Introduction

Filters intercept requests coming in to an akkeris application (or site the applicaton is a part of) and provide additional functionality or checks.  Each filter has unique functionalities. A filter is first created then can be shared or "attached" to applications. This allows for central managemennt and reuse of functionality.  Changes to filters are applied when an app is deployed (however apps are automatically deployed if a filter is attached or detached).


## Filter Types

| Filter Type | Description |
| :---------- | :--- |
| jwt         | JWT Authentication filters allow asserting the incoming HTTP request has a valid JWT token. |
| cors        | CORS filters respond to `OPTIONS` HTTP requests with the policy set by the CORS Filter. |

Each filter type has different options available to it, for more information see `aka filters:create --help` or Apps API Platform documentation.

## Creating a Filter

In this example we'll create a JWT filter to protect an app, to do so we'll need the following:

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

Once attached, almost all HTTP requests will require authorization (with the exception of `/health-check` and `/debug`). In addition to the `--excludes` option an `--includes` option also exists and by default includes everything. More than one path may be included (just as excludes) by specifying the `--includes` option multiple times.