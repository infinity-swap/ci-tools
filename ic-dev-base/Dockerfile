FROM rust:1.60-slim-bullseye as base

ENV DEBIAN_FRONTEND=noninteractive
ENV WORK_DIR=/workspace
ENV HOME=/workspace

WORKDIR $WORK_DIR
# Dfinity SDK
ARG motoko_version=0.6.29
ARG dfx_version=0.10.1
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
    rm -rf /var/lib/apt/lists/*
    
RUN cargo install ic-cdk-optimizer && \
    rustup component add clippy rustfmt && \
    rustup target add wasm32-unknown-unknown

# RUN curl -fsSL https://download.dfinity.systems/motoko/${motoko_version}/x86_64-linux/motoko-${motoko_version}.tar.gz | tar -xz -C /opt/bin && chmod +x /opt/bin/moc
RUN curl -fsSL https://github.com/dfinity/motoko/releases/download/${motoko_version}/motoko-linux64-${motoko_version}.tar.gz \
    | tar -xz -C /usr/local/bin && chmod +x /usr/local/bin
    
RUN DFX_VERSION=${dfx_version} sh -ci "$(curl -fsSL https://sdk.dfinity.org/install.sh)"

RUN dfx identity new --disable-encryption $DFX_DEV_ACCOUNT_IDENTITY && \
    dfx identity new --disable-encryption $DFX_DEV_IDENTITY && \
    dfx identity use $DFX_DEV_IDENTITY

RUN rm -rf $CARGO_HOME/registry && \
    chmod -R 0777 .cache && \
    chmod -R 0777 .config && \
    chown root:root /usr/local/bin/* && \
    chmod -R 0755 /usr/local/bin

