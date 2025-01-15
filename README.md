# kong

## Introduction

A docker image for kong.

## Environment Variables


| Name                                         | Default value | Suggested value | Required | Description                                                                                   |
|:---------------------------------------------|:-------------:|:---------------:|:--------:|:----------------------------------------------------------------------------------------------|
| KONG_NGINX_HTTPS_LARGE_CLIENT_HEADER_BUFFERS |       -       |     4 200k      |   true   | Sets buffer size for large headers to embedded nginx. (https)                                 |
| KONG_NGINX_HTTP_LARGE_CLIENT_HEADER_BUFFERS  |       -       |     4 200k      |   true   | Sets buffer size for large headers to embedded nginx. (http)                                  |
| KONG_NGINX_HTTP_CLIENT_MAX_BODY_SIZE         |      1m       |      256m       |  false   | Sets the maximum allowed size of the client request body. Required for uploading large files. |
