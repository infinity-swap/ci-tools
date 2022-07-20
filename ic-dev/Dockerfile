FROM rust:1.60-slim-bullseye as base

ENV DEBIAN_FRONTEND=noninteractive
ENV WORK_DIR=/workspace
ENV HOME=/workspace

WORKDIR $WORK_DIR
# Dfinity SDK
ARG motoko_version=0.6.29
ARG dfx_version=0.9.3
ARG DFX_DEV_IDENTITY=ic_dev_identity
ARG DFX_DEV_ACCOUNT_IDENTITY=ic_dev_account

ENV DFX_DEV_IDENTITY=${DFX_DEV_IDENTITY}
ENV DFX_DEV_ACCOUNT_IDENTITY=${DFX_DEV_ACCOUNT_IDENTITY}

RUN apt-get update && \
    apt-get -y full-upgrade && \
    apt-get install -y pkg-config curl git gzip tar pigz build-essential cmake \ 
    libssl-dev clang liblmdb-dev csvkit jq python3 pipenv && \
    apt-get clean && \
    python3 -m pip install --upgrade pip && \
    # clean apt cache
    rm -rf /var/lib/apt/lists/* && \
    cargo install ic-cdk-optimizer && \
    rustup component add clippy rustfmt && \
    rustup target add wasm32-unknown-unknown

# RUN curl -fsSL https://download.dfinity.systems/motoko/${motoko_version}/x86_64-linux/motoko-${motoko_version}.tar.gz | tar -xz -C /opt/bin && chmod +x /opt/bin/moc
RUN curl -fsSL https://github.com/dfinity/motoko/releases/download/${motoko_version}/motoko-linux64-${motoko_version}.tar.gz \
    | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin && \
    DFX_VERSION=${dfx_version} sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)" && \
    dfx identity new --disable-encryption $DFX_DEV_ACCOUNT_IDENTITY && \
    dfx identity new --disable-encryption $DFX_DEV_IDENTITY && \
    dfx identity use $DFX_DEV_IDENTITY && \
    rm -rf $CARGO_HOME/registry && \
    chmod -R 0777 .cache && \
    chmod -R 0777 .config && \
    chown root:root /usr/local/bin/* && \
    chmod -R 0755 /usr/local/bin

FROM base as ic_builder

ARG IC_BUILD_BRANCH=rebased-2022-02-17 
# Just a hack to use it in next ENV instructions
ARG WORK_DIR=$WORK_DIR
ENV ARTIFACTS_DIR=${WORK_DIR}/ic/artifacts
ENV IC_RS_WD=${WORK_DIR}/ic/rs
ENV CARGO_TARGET_DIR=${WORK_DIR}/ic/rs/target

WORKDIR $WORK_DIR

RUN mkdir -p wasm && \
    mkdir /ic && \
    mkdir /ic/wasm && \
    git clone --depth 1 https://github.com/infinity-swap/ic.git --branch=${IC_BUILD_BRANCH} ic && \
    # Build NNS
    cd ${IC_RS_WD} && RUST_BACKTRACE=full cargo build --release --bin ic-nns-init && cd $WORK_DIR && \
    ls ${IC_RS_WD}/target/release && \
    mv ${IC_RS_WD}/target/release/ic-nns-init /ic && \
    # Build artifacts
    cd ic/gitlab-ci/tools && RUST_BACKTRACE=full ./cargo-build-canisters ${ARTIFACTS_DIR} && cd $WORK_DIR && \
    cd ${ARTIFACTS_DIR} && find *.gz | xargs -I {} gzip -df {} && cd $WORK_DIR && \
    mv ${ARTIFACTS_DIR}/*.wasm /ic/wasm && ls -la /ic/wasm

# Now put files into scratch based image
FROM scratch as ic_bin

COPY --from=ic_builder /ic /ic



FROM base as full

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
    npm install -g http-server && \
    cd $DFX_WASMS_DIR && curl -SsO https://storage.googleapis.com/dfx-server_ic/testnet/wasm/ledger-canister-min.wasm && cd $WORK_DIR && \
    cd $DFX_DID_DIR && curl -SsO https://storage.googleapis.com/dfx-server_ic/testnet/candid/ledger-min.did && cd $WORK_DIR && \
    # Reference CLI command to add something into dfx
    J=$(jq ".canisters += {\"ledger-test\":{\"wasm\":\"$DFX_WASMS_DIR/ledger-canister-min.wasm\",\"candid\":\"$DFX_DID_DIR/ledger-min.did\",\"type\":\"custom\"}}" ./dfx.json) && echo "$J" > ./dfx.json && \
    # Finishing stuff
    # RUN chmod -R 0777 neurons
    chmod -R 0777 $DFX_WASMS_DIR && \
    chmod -R 0777 $DFX_DID_DIR && \
    chmod -R 0755 /usr/local/bin && \
    dfx start --clean --background && nns-init.sh && dfx stop && \
    # All workspace should be accessible for any user
    chmod -R 0777 ./ && \
    # But we can not do it for DFX directory because it
    chmod -R 0770 .dfx

EXPOSE 8000

CMD dfx start --host $IC_HOST