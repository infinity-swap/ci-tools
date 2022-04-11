This repo contains configuration and CI scripts for building docker images
that contain IC utility canisters.

At the moment two containers are available:
* `ci` - contains rust and dfx, so it can be used for running builds and tests
  in CI scripts when developing IC containers
* `slim` - based on alpine image and contains only canisters, making it a very
  lightweight image, in case you only need compiled canisters and nothing more

Both containers have these directories:
* `/usr/src/canisters` - contains `wasm` and `did` files for IC 
  [ledger](https://github.com/infinity-swap/unlocked-ic-ledger) and
  [governance](https://github.com/infinity-swap/Governance)
* `/usr/src/identity` - contains private keys from the
  [identities](https://github.com/infinity-swap/identity) repo, that can
  be used for testing

# Login into Google Cloud

To be able to pull images from GC registry, you must login into it. To do it:

1. [Install GC SDK](https://cloud.google.com/sdk/docs/install). For linux:
```
sudo apt-get install apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-sdk
```

2. [Login into GC](https://cloud.google.com/container-registry/docs/advanced-authentication#gcloud-helper):
```shell
gcloud auth login
```

# Using ci image

```
docker pull us-central1-docker.pkg.dev/dfx-server/dfx-containers/ci
```

# Using slim

To download the image:
```
docker pull us-central1-docker.pkg.dev/dfx-server/dfx-containers/slim
```

You can build your image with the provided canisters like this:

```dockerfile
FROM us-central1-docker.pkg.dev/dfx-server/dfx-containers/slim as canisters

FROM debian:latest

WORKDIR /usr/src/myapp
COPY . .
COPY --from=canisters /usr/src/canisters ./canisters

#...
```
