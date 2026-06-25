# kong

## Introduction

A Kong docker image with customizations for FOLIO.

It routes requests from outside a FOLIO host (like Stripes front-end user interface, or external scripts) to the modules.

For details see
* https://folio-org.atlassian.net/wiki/spaces/PLATFORM/pages/193134643/Folio+Eureka+Platform+Overview
* https://konghq.com/products/kong-gateway

The kong docker image is customized by changing settings and by enabling plugins:
* Some settings are changed via environment variables set in the `Dockerfile`.
* Some settings are changed via the config files in the `config` directory.
* `deck` and `auth-headers-manager` plugin are enabled by the `Dockerfile`.
* The `auth-headers-manager` plugin is configured in the `auth-headers-manager` directory to
  populate HTTP authorization headers `Authorization` and `X-Okapi-Token` from cookie `folioAccessToken`.

## Version

The major and minor version of folio-kong matches the major and minor version of the kong container it is based on.

The patch version of folio-kong starts at 0 and gets incremented for each release.

## Environment Variables


| Name                                         |     Default value     | Suggested value                                      | Required | Description                                                                                                                                                                                                                                                                                                                                                 |
|:---------------------------------------------|:---------------------:|:-----------------------------------------------------|:--------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| CORS_ORIGINS                                 | `*` (via `cors.yaml`) | `https://folio.example.com https://.*\\.example.com` |  false   | Space-separated list of allowed origins (fully-qualified URLs or PCRE regexes) for the Kong CORS plugin. When set, `entrypoint.sh` converts it to a YAML block sequence in `DECK_CORS_ORIGINS` before `deck sync`, so origins are applied via deck template substitution in `cors.yaml`. Enables production CORS restrictions without rebuilding the image. |
| KONG_NGINX_HTTPS_LARGE_CLIENT_HEADER_BUFFERS |           -           | 4 200k                                               |   true   | Sets buffer size for large headers to embedded nginx. (https)                                                                                                                                                                                                                                                                                               |
| KONG_NGINX_HTTP_LARGE_CLIENT_HEADER_BUFFERS  |           -           | 4 200k                                               |   true   | Sets buffer size for large headers to embedded nginx. (http)                                                                                                                                                                                                                                                                                                |
| KONG_NGINX_HTTP_CLIENT_MAX_BODY_SIZE         |          1m           | 256m                                                 |  false   | Sets the maximum allowed size of the client request body. Required for uploading large files.                                                                                                                                                                                                                                                               |

See https://github.com/Kong/kong/blob/master/kong.conf.default for other environment variable configuration options for kong.

## CORS Configuration

The CORS plugin is enabled via `config/cors.yaml` and controlled through the `CORS_ORIGINS`
environment variable (see table above).

### Known Issue: Single Plain-URL Origin (Kong 3.9.1)

Kong's CORS plugin has a fast path for exactly **one plain-URL origin**: when `n_origins == 1`
and the value contains no regex characters, Kong sets `Access-Control-Allow-Origin`
unconditionally — without checking the request `Origin` header. Any client request receives
the header regardless of what `Origin` it sends.

**Example of the problem:**

```
CORS_ORIGINS="https://folio.example.com"   # single plain URL
```

A request from `https://evil.com` still gets `Access-Control-Allow-Origin: https://folio.example.com`.

**Workarounds** (all three are equivalent in effect):

1. **Anchored regex** (recommended) — use regex syntax so Kong takes the iterative match path:
   ```
   CORS_ORIGINS="^https:\/\/folio\.example\.com$"
   ```

2. **Duplicate URL** — repeat the same URL twice to force `n_origins == 2`:
   ```
   CORS_ORIGINS="https://folio.example.com https://folio.example.com"
   ```

3. **Second distinct origin** — applicable when multiple origins are genuinely needed:
   ```
   CORS_ORIGINS="https://folio.example.com https://admin.example.com"
   ```
## Testing

* `./test.sh` – basic smoke test of the running container (auth header rewriting).
* `./test-cors.sh` – exercises the `CORS_ORIGINS` feature (KONG-48). Start the stack with the desired `CORS_ORIGINS` value first.
