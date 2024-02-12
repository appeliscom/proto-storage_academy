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
protoc --proto_path=proto-storage_academy \
  --php_out=proto-storage_academy/academy_codes_service/php \
  --grpc_out=proto-storage_academy/academy_codes_service/php \
  --plugin=protoc-gen-grpc=bins/opt/grpc_php_plugin \
  ./proto-storage_academy/academy_codes_service/academyCodes.v1.proto

protoc --proto_path=proto-storage_academy \
  --php_out=proto-storage_academy/identity_service/php \
  --grpc_out=proto-storage_academy/identity_service/php \
  --plugin=protoc-gen-grpc=bins/opt/grpc_php_plugin \
  ./proto-storage_academy/identity_service/common.proto

protoc --proto_path=proto-storage_academy \
  --php_out=proto-storage_academy/identity_service/php \
  --grpc_out=proto-storage_academy/identity_service/php \
  --plugin=protoc-gen-grpc=bins/opt/grpc_php_plugin \
  ./proto-storage_academy/identity_service/identity.v1.proto
```
