# proto-storage_academy

This repository includes protocol buffer definition files to IdentityService and AcademyCodesService.

## How to use the APIs:
1. Create JWT auth token with call to `IdentityService.Create`, payload is authentication details
2. In response, you get `refreshToken` and `accessToken`. Use `accessToken` as the payload when calling `AcademyCodesService.UseCode` to authorize the request
3. The lifetime of the issued `accessToken` is usually 5 minutes, with older token the `AcademyCodesService.UseCode` returns `TokenError`.
4. Get new `accessToken` by calling `IdentityService.Refresh` with `refreshToken` provided in step 2

---

How to generate PHP code based on protocol buffers:
[https://grpc.io/docs/languages/php/](https://grpc.io/docs/languages/php/)

E.g. (not tested) :
```
protoc \
  --proto_path=proto-storage_academy \
  --php_out=proto-storage_academy/academy_codes_service/php \
  --grpc_out=proto-storage_academy/academy_codes_service/grpc \
  --plugin=protoc-gen-grpc=/bin/grpc_php_plugin \
  ./proto-storage_academy/academy_codes_service/academyCodes.v1.proto

protoc \
  --proto_path=proto-storage_academy \
  --php_out=proto-storage_academy/identity_service/php \
  --grpc_out=proto-storage_academy/identity_service/grpc \
  --plugin=protoc-gen-grpc=/bin/grpc_php_plugin \
  ./proto-storage_academy/identity_service/common.proto

protoc \
  --proto_path=proto-storage_academy \
  --php_out=proto-storage_academy/identity_service/php \
  --grpc_out=proto-storage_academy/identity_service/grpc \
  --plugin=protoc-gen-grpc=/bin/grpc_php_plugin \
  ./proto-storage_academy/identity_service/identity.v1.proto
```

## Dockerfile
Example of building the client stubs are in the `Dockerfile`, this is to
demonstrate the correctness of the files and can be also used to build the files
for production, then mount the image and copy the needed `.php` files.
Note that building the `grpc_php_plugin` from the source (best practice)
and the `pecl install grpc` command take a long time (~27 minutes on decent CPU).

`docker build -t academy-grpc-php -f ./Dockerfile .`

`docker run -it --rm academy-grpc-php` will display the generated files:

```
/src/proto-storage_academy
|-- academy_codes_service
|   |-- academyCodes.v1.proto
|   |-- grpc
|   |   `-- Appelis
|   |       `-- AcademyCodes
|   |           `-- V1
|   |               `-- AcademyCodesServiceClient.php
|   `-- php
|       |-- Appelis
|       |   `-- AcademyCodes
|       |       `-- V1
|       |           |-- UseCodeRequest.php
|       |           |-- UseCodeResponse
|       |           |   `-- UseCodeInvalidPayload.php
|       |           |-- UseCodeResponse.php
|       |           `-- UseCodeResponse_UseCodeInvalidPayload.php
|       `-- GPBMetadata
|           `-- AcademyCodesService
|               `-- AcademyCodesV1.php
`-- identity_service
    |-- common.proto
    |-- grpc
    |   `-- Appelis
    |       `-- Identity
    |           `-- V1
    |               `-- IdentityServiceClient.php
    |-- identity.v1.proto
    `-- php
        |-- Appelis
        |   `-- Identity
        |       |-- Common
        |       |   `-- V1
        |       |       |-- PermissionError.php
        |       |       |-- Token.php
        |       |       `-- TokenError.php
        |       `-- V1
        |           |-- CreateRequest
        |           |   |-- Credentials.php
        |           |   |-- DeviceKey.php
        |           |   |-- ProjectUserLoginToken.php
        |           |   `-- UserLoginToken.php
        |           |-- CreateRequest.php
        |           |-- CreateRequest_Credentials.php
        |           |-- CreateRequest_DeviceKey.php
        |           |-- CreateRequest_ProjectUserLoginToken.php
        |           |-- CreateRequest_UserLoginToken.php
        |           |-- CreateResponse
        |           |   `-- Error.php
        |           |-- CreateResponse.php
        |           |-- CreateResponse_Error.php
        |           |-- RefreshRequest.php
        |           |-- RefreshResponse
        |           |   `-- Error.php
        |           |-- RefreshResponse.php
        |           |-- RefreshResponse_Error.php
        |           `-- TokenPayload.php
        `-- GPBMetadata
            `-- IdentityService
                |-- Common.php
                `-- IdentityV1.php

28 directories, 32 files
```

Following command will copy the library files to the `lib` directory:
`docker run -it --rm -v $(pwd)/lib:/mnt --name academy-grpc-php-1 academy-grpc-php cp -r /usr/lib/proto-storage_academy/ /mnt`
