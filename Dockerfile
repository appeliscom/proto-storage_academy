FROM php:7.4-cli

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    curl \
    ranger \
    neovim \
    cmake \
    libz-dev \
    tree \
    && rm -rf /var/lib/apt/lists/*

RUN curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.18.0/protoc-3.18.0-linux-x86_64.zip && \
    unzip protoc-3.18.0-linux-x86_64.zip -d /usr/local && \
    rm protoc-3.18.0-linux-x86_64.zip

RUN \
  git clone -b v1.61.1 https://github.com/grpc/grpc && \
  cd grpc && \
  git submodule update --init && \
  mkdir -p cmake/build && \
  cd cmake/build && \
  cmake ../.. && \
  make protoc grpc_php_plugin && \
  mv /grpc/cmake/build/grpc_php_plugin /bin

RUN pecl install grpc

RUN docker-php-ext-enable grpc

WORKDIR /src

COPY academy_codes_service /src/proto-storage_academy/academy_codes_service
COPY identity_service /src/proto-storage_academy/identity_service

RUN \
  mkdir -p proto-storage_academy/academy_codes_service/php && \
  mkdir -p proto-storage_academy/academy_codes_service/grpc && \
  mkdir -p proto-storage_academy/identity_service/php && \
  mkdir -p proto-storage_academy/identity_service/grpc

RUN protoc \
  --proto_path=proto-storage_academy \
  --php_out=proto-storage_academy/academy_codes_service/php \
  --grpc_out=proto-storage_academy/academy_codes_service/grpc \
  --plugin=protoc-gen-grpc=/bin/grpc_php_plugin \
  ./proto-storage_academy/academy_codes_service/academyCodes.v1.proto

RUN protoc \
  --proto_path=proto-storage_academy \
  --php_out=proto-storage_academy/identity_service/php \
  --grpc_out=proto-storage_academy/identity_service/grpc \
  --plugin=protoc-gen-grpc=/bin/grpc_php_plugin \
  ./proto-storage_academy/identity_service/common.proto

RUN protoc \
  --proto_path=proto-storage_academy \
  --php_out=proto-storage_academy/identity_service/php \
  --grpc_out=proto-storage_academy/identity_service/grpc \
  --plugin=protoc-gen-grpc=/bin/grpc_php_plugin \
  ./proto-storage_academy/identity_service/identity.v1.proto

CMD ["tree", "/src/proto-storage_academy"]
