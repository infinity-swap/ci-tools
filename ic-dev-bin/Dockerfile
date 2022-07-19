ARG BASE_IMAGE=ghcr.io/infinity-swap/ic-dev-base:latest
FROM ${BASE_IMAGE} as ic_builder

ARG IC_BUILD_BRANCH=rebased-2022-02-17 
ARG IC_REPO=https://github.com/infinity-swap/ic.git
# Just a hack to use it in next ENV instructions
ARG WORK_DIR=$WORK_DIR
ENV ARTIFACTS_DIR=${WORK_DIR}/ic/artifacts
ENV IC_RS_WD=${WORK_DIR}/ic/rs
ENV CARGO_TARGET_DIR=${WORK_DIR}/ic/rs/target

WORKDIR $WORK_DIR

RUN mkdir -p wasm && \
    mkdir /ic && \
    mkdir /ic/wasm

RUN git clone --depth 1 ${IC_REPO} --branch=${IC_BUILD_BRANCH} --single-branch ic
    
# Build NNS
RUN cd ${IC_RS_WD} && \
    cargo update && \
    RUST_BACKTRACE=full cargo build --release --bin ic-nns-init
 
RUN ls ${IC_RS_WD}/target/release && \
    mv ${IC_RS_WD}/target/release/ic-nns-init /ic

# Build artifacts
# RUN mkdir -p /workspace/ic/artifacts
RUN cd ic/rs/nns/handlers/lifeline && cargo build --target wasm32-unknown-unknown
RUN ls -la ic/rs/nns/handlers/lifeline
RUN cd ic/gitlab-ci/tools && RUST_BACKTRACE=full ./cargo-build-canisters ${ARTIFACTS_DIR}
RUN cd ${ARTIFACTS_DIR} && find *.gz | xargs -I {} gzip -df {} 
RUN mv ${ARTIFACTS_DIR}/*.wasm /ic/wasm && ls -la /ic/wasm

# Now put files into scratch based image
FROM scratch as ic_bin

COPY --from=ic_builder /ic /ic
