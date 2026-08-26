# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID=1000 \
      APP_GID=1000

# APP
  ARG BUILD_SRC=https://github.com/Koenkk/zigbee2mqtt.git \
      BUILD_ROOT=/zigbee2mqtt \
      NODE_ENV=production

# :: FOREIGN IMAGES
  FROM 11notes/util AS util
  FROM 11notes/util:bin AS util-bin
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:localhealth AS distroless-localhealth


# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: NODE WITH EMBEDDED SERIALPORT
  FROM alpine:edge AS distroless-node-serial
  COPY --from=util-bin / /

  RUN set -ex; \
    apk --update --no-cache add \
      git \
      gpg \
      gpg-agent \
      pv \
      wget \
      g++ \
      libgcc \
      linux-headers \
      make \
      python3 \
      upx \
      binutils \
      py-setuptools;

  RUN set -ex; \
    mkdir -p /node; \
    NODE_VERSION=$(curl -s https://nodejs.org/dist/index.json | jq -r '[.[] | select(.lts != false)][0].version' | sed 's|v||'); \
    wget -O node.tar.xz https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz; \
    tar xf node.tar.xz --strip-components=1 -C /node;

  COPY ./build/ /

  RUN set -ex; \
    git clone https://github.com/serialport/bindings-cpp.git /node/src/serialport_bindings; \
    git clone https://github.com/nodejs/node-addon-api.git /node/deps/node-addon-api;

  RUN set -ex; \
    sed -i '/^NODE_API_MODULE(serialport, init);/d' /node/src/serialport_bindings/src/serialport.cpp; \
    sed -i '/^#include ".\/serialport.h"/d' /node/src/serialport_bindings/src/serialport.cpp; \
    head /node/src/serialport_bindings/src/serialport.cpp; \
    cat /node/serialport.cpp /node/src/serialport_bindings/src/serialport.cpp > /tmp/serialport.cpp && mv /tmp/serialport.cpp /node/src/serialport_bindings/src/serialport.cpp;

  RUN set -ex; \
    cd /node; \
    git config --global user.email "11notes@github.com"; \
    git config --global user.name "11notes"; \
    git init; \
    git add node.gyp; \
    git commit -m "original"; \
    git apply --3way node.gyp.patch;

  RUN set -ex; \
    cd /node; \
    ./configure --fully-static --enable-static;

  RUN --mount=type=cache,target=/node/out,sharing=locked \
    set -ex; \
    cd /node; \
    make -s -j $(nproc) 2>&1 > /dev/null;

  RUN --mount=type=cache,target=/node/out,sharing=locked \
    set -ex; \
    eleven distroless /node/out/Release/node;    

  RUN set -ex; \
    /distroless/usr/local/bin/node -e "const binding = process._linkedBinding('serialport_bindings'); console.log('success: ', Object.keys(binding));"

# :: ZIGBEE2MQTT
  FROM node:lts-alpine AS build
  COPY --from=util / /
  ARG APP_VERSION \
      BUILD_SRC \
      BUILD_ROOT \
      NODE_ENV

  RUN set -ex; \
    apk --update --no-cache add \
      git \
      jq \
      make \
      gcc \
      g++ \
      python3 \
      linux-headers;

  RUN set -ex; \
    eleven git clone ${BUILD_SRC} ${APP_VERSION};

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    npm install -g "$(jq -r '.packageManager' package.json)"; \
    pnpm install --frozen-lockfile --prod --no-optional; \
    rm -rf $(find ./node_modules/.pnpm/ -wholename "*/@serialport/bindings-cpp/prebuilds" -type d); \
    pnpm rebuild @serialport/bindings-cpp;

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    printf '%s\n' \
      "\"use strict\";" \
      "Object.defineProperty(exports, \"__esModule\", { value: true });" \
      "exports.binding = void 0;" \
      "exports.binding = process._linkedBinding('serialport_bindings');" \
      > ./node_modules/.pnpm/@serialport+bindings-cpp@13.0.1/node_modules/@serialport/bindings-cpp/dist/serialport-bindings.js; \
    cat ./node_modules/.pnpm/@serialport+bindings-cpp@13.0.1/node_modules/@serialport/bindings-cpp/dist/serialport-bindings.js;

# :: ZIGBEE2MQTT DIST
  FROM build AS dist
  ARG BUILD_ROOT

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    pnpm add -D typescript; \
    pnpm run build;


# :: FILE-SYSTEM
  FROM alpine AS file-system
  ARG APP_ROOT
  RUN set -ex; \
    mkdir -p /distroless${APP_ROOT}/etc;


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE \
        BUILD_ROOT \
        NODE_ENV

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: app specific environment
    ENV NODE_ENV=${NODE_ENV} \
        ZIGBEE2MQTT_DATA="${APP_ROOT}/etc"

  # :: multi-stage
    COPY --from=distroless / /
    COPY --from=distroless-node-serial /distroless/ /
    COPY --from=distroless-localhealth / /
    COPY --from=build ${APP_ROOT}/node_modules /opt/zigbee2mqtt/node_modules
    COPY --from=build ${APP_ROOT}/index.js /opt/zigbee2mqtt/index.js
    COPY --from=build ${APP_ROOT}/package.json /opt/zigbee2mqtt/package.json
    COPY --from=dist ${APP_ROOT}/dist /opt/zigbee2mqtt/dist
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "http://127.0.0.1:8080/"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/node", "/opt/zigbee2mqtt/index.js"]