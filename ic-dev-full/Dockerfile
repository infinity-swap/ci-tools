ARG BIN_IMAGE=ghcr.io/infinity-swap/ic-dev-bin:latest
ARG BASE_IMAGE=ghcr.io/infinity-swap/ic-dev-base:latest

FROM $BIN_IMAGE as ic_bin
FROM $BASE_IMAGE

ARG WORK_DIR=$WORK_DIR
ENV DFX_WASMS_DIR=${WORK_DIR}/wasm
ENV DFX_DID_DIR=${WORK_DIR}/candid
ENV DFX_NEURONS_DIR=${WORK_DIR}/neurons
ENV IC_HOST=0.0.0.0:8000
ENV IC_URI=http://localhost:8000

WORKDIR $WORK_DIR

RUN mkdir $DFX_WASMS_DIR && \
    mkdir $DFX_DID_DIR && \
    git clone https://github.com/infinity-swap/ifx  && \
    cd ifx && cargo build --release && \
    cp target/release/ifx /usr/local/bin/

# DFX env preparation
COPY neurons/* ${DFX_NEURONS_DIR}/
COPY dfx.json ${WORK_DIR}
COPY bin/* /usr/local/bin/

# Pack external binaries
COPY --from=ic_bin --chown=root:root /ic/wasm $WORK_DIR/wasm
COPY --from=ic_bin --chown=root:root /ic/ic-nns-init /usr/local/bin/

RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g http-server

RUN cd $DFX_WASMS_DIR && curl -SsO https://storage.googleapis.com/dfx-server_ic/testnet/wasm/ledger-canister-min.wasm && \
    cd $DFX_DID_DIR && curl -SsO https://storage.googleapis.com/dfx-server_ic/testnet/candid/ledger-min.did
    
# Reference CLI command to add something into dfx
RUN J=$(jq ".canisters += {\"ledger-test\":{\"wasm\":\"$DFX_WASMS_DIR/ledger-canister-min.wasm\",\"candid\":\"$DFX_DID_DIR/ledger-min.did\",\"type\":\"custom\"}}" ./dfx.json) && echo "$J" > ./dfx.json

# Finishing stuff
# RUN chmod -R 0777 neurons
RUN chmod -R 0777 $DFX_WASMS_DIR && \
    chmod -R 0777 $DFX_DID_DIR && \
    chmod -R 0755 /usr/local/bin
    
RUN dfx start --clean --background && nns-init.sh && dfx stop

# All workspace should be accessible for any user
RUN chmod -R 0777 ./ && \
    # But we can not do it for DFX directory because it
    chmod -R 0770 .dfx

EXPOSE 8000

CMD dfx start --host $IC_HOST