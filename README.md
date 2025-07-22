# kong

## Introduction

A Kong docker image with customizations for FOLIO.

It routes requests from outside a FOLIO host (like Stripes front-end user interface, or external scripts) to the modules.

For details see
* https://folio-org.atlassian.net/wiki/spaces/PLATFORM/pages/193134643/Folio+Eureka+Platform+Overview
* https://konghq.com/products/kong-gateway

## Version

The major and minor version of folio-kong matches the major and minor version of the kong container it is based on.

The patch version of folio-kong starts at 0 and gets incremented for each release.

## Environment Variables


| Name                                         | Default value | Suggested value | Required | Description                                                                                   |
|:---------------------------------------------|:-------------:|:---------------:|:--------:|:----------------------------------------------------------------------------------------------|
| KONG_NGINX_HTTPS_LARGE_CLIENT_HEADER_BUFFERS |       -       |     4 200k      |   true   | Sets buffer size for large headers to embedded nginx. (https)                                 |
| KONG_NGINX_HTTP_LARGE_CLIENT_HEADER_BUFFERS  |       -       |     4 200k      |   true   | Sets buffer size for large headers to embedded nginx. (http)                                  |
| KONG_NGINX_HTTP_CLIENT_MAX_BODY_SIZE         |      1m       |      256m       |  false   | Sets the maximum allowed size of the client request body. Required for uploading large files. |

See https://github.com/Kong/kong/blob/master/kong.conf.default for other environment variable configration options for kong.
