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


| Name                                         | Default value          | Suggested value                                      | Required | Description                                                                                   |
|:---------------------------------------------|:----------------------:|:-----------------------------------------------------|:--------:|:----------------------------------------------------------------------------------------------|
| CORS_ORIGINS                                 | `*` (via `cors.yaml`)  | `https://folio.example.com https://.*\\.example.com` | false    | Space-separated list of allowed origins (fully-qualified URLs or PCRE regexes) for the Kong CORS plugin. When set, `entrypoint.sh` overrides the default `*` at runtime via PATCH to the Admin API after `deck sync`. Enables production CORS restrictions without rebuilding the image. |
| KONG_NGINX_HTTPS_LARGE_CLIENT_HEADER_BUFFERS |       -                |     4 200k                                           |   true   | Sets buffer size for large headers to embedded nginx. (https)                                 |
| KONG_NGINX_HTTP_LARGE_CLIENT_HEADER_BUFFERS  |       -                |     4 200k                                           |   true   | Sets buffer size for large headers to embedded nginx. (http)                                  |
| KONG_NGINX_HTTP_CLIENT_MAX_BODY_SIZE         |      1m                |      256m                                            |  false   | Sets the maximum allowed size of the client request body. Required for uploading large files. |

See https://github.com/Kong/kong/blob/master/kong.conf.default for other environment variable configuration options for kong.

## Testing

* `./test.sh` – basic smoke test of the running container (auth header rewriting).
* `./test-cors.sh` – exercises the `CORS_ORIGINS` feature (KONG-48). Start the stack with the desired `CORS_ORIGINS` value first.
