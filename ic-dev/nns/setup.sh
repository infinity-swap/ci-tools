sleep 20 

dfx  identity new minter 
dfx  identity use nns-minter
principal=$(dfx identity get-principal)
minter=$(dfx ledger account-id)

echo -e "Deploying NNS: \nMINTER: $minter\nPRINCIPAL: $principal\n"

# Limit execution time for this script
# It could go into infinite retry loop on deployment error
timeout 180 \
ic-nns-init --url $IC_URI \
--wasm-dir $DFX_WASMS_DIR \
--initial-neurons initial-neurons.csv \
--minter minter \
--initialize-ledger-with-test-accounts-for-principals $principal

dfx stop
